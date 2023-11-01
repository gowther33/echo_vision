import 'dart:io';
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
  const CustomRenderScreen({super.key});

  @override
  State<CustomRenderScreen> createState() => _CustomRenderScreenState();
}

class _CustomRenderScreenState extends State<CustomRenderScreen> {
  File? _image;

  // Get image dimensions
  late Size imageSize;

  // Extract bounding box data from the response
  List<List<double>> boundingBoxes = [];
  // List<String> classes = [];

  bool noImage = true; // Check if user has selected image
  bool detecting = false; // Check is still detecting
  bool detected = false; // Check if detections have finish

  // Utility funtions
  UtilityMethods utilsObj = UtilityMethods();

  void setImage(ImageSource source) async {
    setState(() {
      detecting = false;
      detected = false;
    });

    final XFile? image = await utilsObj.pickImage(source);
    final File imagefile = File(image!.path);
    Uint8List bytes = imagefile.readAsBytesSync();

    img_.Image img = img_.decodeImage(bytes)!;

    if (image != null) {
      setState(() {
        _image = File(image.path);
        imageSize = Size((img.width).toDouble(), (img.height).toDouble());
        noImage = false;
      });
    } else {
      noImage = true;
    }
  }

  // Upload function
  void upload() async {
    setState(() {
      detecting = true;
    });

    if (_image != null) {
      var uri = Uri.parse("http://192.168.1.102:8000/object_detection");

      var request = http.MultipartRequest("POST", uri);

      var multiport = http.MultipartFile.fromBytes(
          'file', File(_image!.path).readAsBytesSync(),
          filename: _image!.path);
      request.files.add(multiport);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // List<List<double>> boxes = (response['boxes'] as List)
      //     .map((box) => (box as List).map((e) => e.toDouble()).toList())
      //     .toList();
      // // Convert the 2D list of floats to a List of List of doubles

      // List<String> classes = List<String>.from(response['classes']);

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
            doubleList.add(double.parse(value.toString()));
          }

          // Add the converted element to the List<double>.
          boundingBoxes.add(doubleList);
        }

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Bounding Box'),
      ),
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
                          child: CustomPaint(
                            size: imageSize,
                            painter: BoundingBoxesPainter(
                                _image!.path, boundingBoxes, imageSize),
                          ),
                        )
                      : const Text(
                          "Detections Running",
                          style: TextStyle(color: Colors.amber),
                        )
                  : Expanded(
                      child: Image(
                        image: MemoryImage(
                          _image!.readAsBytesSync(),
                        ),
                      ),
                    ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      setImage(ImageSource.gallery);
                    },
                    child: const Text("Select"),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      upload();
                    },
                    child: const Text("Detect"),
                  ),
                  FloatingActionButton(
                    onPressed: () {},
                    child: const Text("Render"),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
