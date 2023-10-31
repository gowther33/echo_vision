import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:flutter_pytorch/pigeon.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';

import 'package:echo_vision/loader_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:echo_vision/utils.dart';

import 'package:http/http.dart' as http;

// Home Class
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ModelObjectDetection _objectModel;
  String? _imagePrediction;
  File? _image;

  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];

  bool noImage = true;
  bool isSpeaking = false;
  bool detecting = false; //
  bool detected = false; // Check if detections have finish

  UtilityMethods utilsObj = UtilityMethods();

  List<String?> objColors = [];

  // List<File> croppedObjects = [];

  // For relative position
  late int h; // img height
  late int w; // img width

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  FutureOr loadModel() async {
    String pathObjectDetectionModel = "assets/models/yolov5s.torchscript";
    try {
      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
          pathObjectDetectionModel, 80, 640, 640,
          labelPath: "assets/labels/labels.txt");
    } catch (e) {
      if (e is PlatformException) {
        if (kDebugMode) {
          print("only supported for android, Error is $e");
        }
      } else {
        if (kDebugMode) {
          print("Error is $e");
        }
      }
    }
  }

  void handleTimeout() {
    // callback function
    // When its called, the loader finished
    setState(() {
      detected = true;
    });
  }

  Timer scheduleTimeout([int milliseconds = 1000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);

  // Set image to screen
  void setImage(ImageSource source) async {
    setState(() {
      detecting = false;
      detected = false;
      objDetect = [];
    });

    final XFile? image = await utilsObj.pickImage(source);

    if (image != null) {
      setState(() {
        _image = File(image.path);
        noImage = false;
      });
    } else {
      noImage = true;
    }
  }

  // Default: detected = false, detecting = false, noImage = true, isSpeaking = false
  void clearAll() {
    setState(() {
      detecting = false;
      detected = false;
      noImage = true;
      isSpeaking = false;
    });
  }

  void speak() {
    setState(() {
      isSpeaking = true;
    });

    utilsObj.speakLabels(objDetect, objColors);
  }

  void stop() {
    setState(() {
      isSpeaking = false;
    });

    utilsObj.stopSpeaking();
  }

  //running detections on image
  FutureOr runObjectDetection() async {
    setState(() {
      detecting = true;
    });

    objDetect = await _objectModel.getImagePrediction(
        await File(_image!.path).readAsBytes(),
        minimumScore: 0.1,
        IOUThershold: 0.3);

    // Get Colors
    objColors = await utilsObj.detectColor(objDetect);

    // Schedules timeout for 5*x secs
    scheduleTimeout(5 * 1000);
  }

  // Upload function
  void upload() async {
    if (_image != null) {
      var uri = Uri.parse("http://192.168.1.102:8000/object_detection");

      var request = http.MultipartRequest("POST", uri);

      var multiport = http.MultipartFile.fromBytes(
          'file', File(_image!.path).readAsBytesSync(),
          filename: _image!.path);
      request.files.add(multiport);

      var response = await request.send();

      if (response.statusCode == 200) {
        utilsObj.showSnackBar(context, "Image Uploaded");
      } else {
        utilsObj.showSnackBar(context, "Image Uploaded Failed");
      }
    } else {
      utilsObj.showSnackBar(context, "No Image Selected");
    }
  }

  // Default: detected = false, detecting = false, noImage = true, isSpeaking = false

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.remove_red_eye_outlined),
          title: Text(
            "Echo Vision",
            style: TextStyle(color: Colors.purple.shade900),
          ),
          backgroundColor: Colors.lightBlue.shade200,
        ),
        backgroundColor: Color.fromARGB(237, 35, 77, 139),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // If noImage then show text
              noImage
                  ? const Text(
                      "Give Image to Run Detection",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  : detecting // if detections are running
                      ? detected // if detections finished
                          ? Expanded(
                              child: Container(
                                  child: _objectModel.renderBoxesOnImage(
                                      _image!, objDetect)),
                            )
                          : const LoaderState()
                      : Expanded(
                          child: Image(
                            image: MemoryImage(
                              _image!.readAsBytesSync(),
                            ),
                          ),
                        ),

              Center(
                child: Visibility(
                  visible: _imagePrediction != null,
                  child: Text("$_imagePrediction"),
                ),
              ),
              //Button to click pic
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setImage(ImageSource.camera);
                        },
                        child: const Icon(
                          Icons.camera,
                          semanticLabel: "Camera Icon to Capture Image",
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setImage(ImageSource.gallery);
                        },
                        child: const Text("Select Image"),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      detected
                          ? ElevatedButton(
                              onPressed: () {
                                // do not run detection until image != null
                                clearAll();
                              },
                              child: const Text("Clear"),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                // do not run detection until image != null
                                if (_image != null) {
                                  runObjectDetection();
                                }
                              },
                              child: const Text("Detect"),
                            ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      isSpeaking
                          ? ElevatedButton(
                              onPressed: () {
                                stop();
                              },
                              child: const Text("Stop"),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                if (objDetect.isNotEmpty) {
                                  speak();
                                }
                              },
                              child: const Text("Speak"),
                            ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          upload();
                        },
                        child: const Text("Upload"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
