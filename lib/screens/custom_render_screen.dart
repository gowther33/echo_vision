import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:echo_vision/utils/utils.dart';

import 'package:image_picker/image_picker.dart';

import 'package:image/image.dart' as img_;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/bounding_box.dart';

class CustomRenderScreen extends StatefulWidget {
  final String imagePath;
  const CustomRenderScreen({super.key, required this.imagePath});

  @override
  State<CustomRenderScreen> createState() => _CustomRenderScreenState();
}

class _CustomRenderScreenState extends State<CustomRenderScreen> {
  File? _image;
  ui.Image? uiIamge;
  // Get image dimensions
  // late Size imageSize;

  // Extract bounding box data from the response
  List<List<double>> boundingBox = [];
  List<String>? classes;
  List<String?> objColors = [];

  bool noImage = true; // Check if user has selected image
  bool detecting = false; // Check is still detecting
  bool detected = false; // Check if detections have finish
  bool isSpeaking = false;

  // Utility funtions
  UtilityMethods utilsObj = UtilityMethods();

  @override
  void initState() {
    super.initState();
    setInitImage();
  }

  void setInitImage() async {
    final File imagefile = File(widget.imagePath);
    Uint8List bytes = imagefile.readAsBytesSync();
    final im = await decodeImageFromList(bytes);
    setState(() {
      uiIamge = im;
      _image = File(widget.imagePath);
      noImage = false;
    });
  }

  void setImage(ImageSource source) async {
    final XFile? image = await utilsObj.pickImage(source);
    if (image != null) {
      final File imagefile = File(image.path);
      Uint8List bytes = imagefile.readAsBytesSync();
      // img_.Image img = img_.decodeImage(bytes)!;
      final im = await decodeImageFromList(bytes);

      setState(() {
        // imageSize = Size((img.width).toDouble(), (img.height).toDouble());
        uiIamge = im;
        _image = File(image.path);
        noImage = false; // display image
        detecting = false;
        detected = false; // detect button display
        boundingBox = [];
        classes = [];
        objColors = [];
      });
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
      classes = [];
      objColors = [];
    });
  }

  void speak() {
    setState(() {
      isSpeaking = true;
    });

    utilsObj.speakLabelCustom(boundingBox, classes, objColors);
  }

  void stop() {
    setState(() {
      isSpeaking = false;
    });
    utilsObj.stopSpeaking();
  }

  // Upload function
  void detect() async {
    setState(() {
      detecting = true;
    });

    if (_image != null) {
      var uri = Uri.parse("http://192.168.1.103:8000/object_detection");

      var request = http.MultipartRequest("POST", uri);

      var multiport = http.MultipartFile.fromBytes(
          'file', File(_image!.path).readAsBytesSync(),
          filename: _image!.path);
      request.files.add(multiport);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Store classes as a simple List of Strings
      if (response.statusCode == 200) {
        utilsObj.showSnackBar(context, "Image Uploaded");
        Map<String, dynamic> data = json.decode(response.body);

        for (var element in data['boxes']) {
          // Cast the element to a List<dynamic>.
          List<dynamic> dynamicList = element as List<dynamic>;

          // Iterate over the List<dynamic> and convert each element to a double using the `double.parse()` function.
          List<double> doubleList = [];
          for (var value in dynamicList) {
            doubleList.add(
              double.parse(value.toString()),
            );
          }

          // Add the converted element to the List<double>.
          boundingBox.add(doubleList);
        }

        final class_ =
            (data['phrases'] as List).map((e) => e as String).toList();
        classes = class_;

        // Get Colors
        objColors = await utilsObj.detectColorCustom(boundingBox);

        print("Colors ******** : ${objColors}");

        setState(() {
          detected = true;
        });
      } else {
        utilsObj.showSnackBar(context, "Image Uploaded Failed");
      }
    } else {
      utilsObj.showSnackBar(context, "No Image Selected");
    }
  }

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
        backgroundColor: const Color.fromARGB(237, 35, 77, 139),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // If noImage then show text
            noImage
                ? const Center(
                    child: Text(
                      "Give Image to Run Detections",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                : detecting // if detections are running
                    ? detected // if detections finished
                        ? Expanded(
                            child: FittedBox(
                              child: SizedBox(
                                width: uiIamge!.width.toDouble(),
                                height: uiIamge!.height.toDouble(),
                                child: CustomPaint(
                                  painter: BoundingBoxesPainter(
                                    uiIamge!,
                                    boundingBox,
                                    classes,
                                    objColors,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const Text(
                            "Running Detections",
                            style: TextStyle(color: Colors.white),
                          )
                    : Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 400,
                            height: 600,
                            child: Image(
                              image: MemoryImage(
                                _image!.readAsBytesSync(),
                              ),
                            ),
                          ),
                        ),
                      ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: ui.Color.fromARGB(255, 105, 66, 112),
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              detected
                  ? ElevatedButton(
                      onPressed: clearAll,
                      child: const Text("Clear"),
                    )
                  : ElevatedButton(
                      onPressed: detect,
                      child: const Text("Detect"),
                    ),
              isSpeaking
                  ? ElevatedButton(
                      onPressed: stop,
                      child: const Text("Stop"),
                    )
                  : ElevatedButton(
                      onPressed: speak,
                      child: const Text("Speak"),
                    ),
              ElevatedButton(
                onPressed: () {
                  setImage(ImageSource.camera);
                },
                child: const Icon(Icons.camera),
              ),
              ElevatedButton(
                onPressed: () {
                  setImage(ImageSource.gallery);
                },
                child: const Text("Select"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
