import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:flutter_pytorch/pigeon.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';

import 'package:echo_vision/loader/loader_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:echo_vision/utils/utils.dart';

import 'package:http/http.dart' as http;

// This screen contains in memory detection model logic
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ModelObjectDetection _objectModel;
  String? _imagePrediction;
  File? _image;

  List<ResultObjectDetection?> objDetect = [];

  bool noImage = true; // Check if user has selected image
  bool isSpeaking = false;
  bool detecting = false; // Check if still detecting
  bool detected = false; // Check if detections have finish

  // Utility funtions
  UtilityMethods utilsObj = UtilityMethods();

  List<String?> objColors = [];

  List<List<double>> boundingBox = [];

  // List<File> croppedObjects = [];

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
      boundingBox = [];
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
      boundingBox = [];
    });
  }

  void speak() {
    setState(() {
      isSpeaking = true;
    });

    // utilsObj.speakLabels(objDetect, objColors);
  }

  void stop() {
    setState(() {
      isSpeaking = false;
    });

    // utilsObj.stopSpeaking();
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
    // objColors = await utilsObj.detectColor(objDetect);

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

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        utilsObj.showSnackBar(context, "Image Uploaded");
        Map<String, dynamic> data = json.decode(response.body);
        var jsonMap = json.decode(response.body);

        // var listOfLists = jsonMap['boxes']
        //     .map<List<double>>((l) => List<double>.from(l))
        //     .toList();

        // print(listOfLists); // expect [[1, 2, 3], [4, 5, 6], [1, 8, 9]]
        // print(listOfLists.runtimeType); // expect List<List<int>>

        for (var element in jsonMap['boxes']) {
          // Cast the element to a List<dynamic>.
          List<dynamic> dynamicList = element as List<dynamic>;

          // Iterate over the List<dynamic> and convert each element to a double using the `double.parse()` function.
          List<double> doubleList = [];
          for (var value in dynamicList) {
            doubleList.add(double.parse(value.toString()));
          }

          // Add the converted element to the List<double>.
          boundingBox.add(doubleList);
        }

        data.forEach((key, value) {
          print("$key: $value");
        });
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
        body: Column(
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
    );
  }
}
