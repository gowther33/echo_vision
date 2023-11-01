// This file contains all the utility functions

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:image/image.dart'
    as img_; // Use an alias to differentiate the package name.
import 'package:image_picker/image_picker.dart';

import 'package:palette_generator/palette_generator.dart';
import 'dart:ui' as ui;
// import 'package:path_provider/path_provider.dart';
import 'package:echo_vision/utils/color_name.dart';

class UtilityMethods {
  final FlutterTts _flutterTts = FlutterTts(); // For tts
  final ImagePicker _picker = ImagePicker();
  late img_.Image img;
  late int w;
  late int h;

  UtilityMethods() {
    init();
  }

  Future<void> init() async {
    // For tts
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setVolume(0.8);
    await _flutterTts.setSpeechRate(0.2);
  }

  // Pick Image
  Future<XFile?> pickImage(ImageSource source) async {
    // source = 0 camera, source = 1 gallery
    //pick an image

    XFile? image = await _picker.pickImage(source: source);

    // For detecting relative positions of objects
    //convert XFile to File
    if (image != null) {
      final File imagefile = File(image!.path);
      Uint8List bytes = imagefile.readAsBytesSync();

      img = img_.decodeImage(
          bytes)!; // Use the alias(img_) to access the Image class.

      // height and width of image
      h = img.height;
      w = img.width;

      return image;
    } else {
      return null;
    }
  }

  // Speak labels & position detection
  void speakLabels(
      List<ResultObjectDetection?> objDetect, List<String?> objColors) {
    if (objDetect.isNotEmpty) {
      String label = '';
      int index = 0;
      for (var element in objDetect) {
        // For bounding box
        List<double> bbox = [
          element!.rect.left * w,
          element.rect.top * h,
          element.rect.right * w,
          element.rect.bottom * h
        ];
        double center_x = (bbox[0] + bbox[2] / 2);
        double center_y = ((bbox[1] + bbox[3]) / 2);

        // Detect Positions
        if (center_x > 0 &&
            center_x < w ~/ 2 &&
            center_y > 0 &&
            center_y < h ~/ 2) {
          label +=
              '${element.className} at Top Left, of color ${objColors[index]}, ';
        } else if (center_x >= w ~/ 2 &&
            center_x <= w &&
            center_y > 0 &&
            center_y < h ~/ 2) {
          label +=
              '${element.className} at Top Right, of color ${objColors[index]}, ';
        } else if (center_x > 0 &&
            center_x < w ~/ 2 &&
            center_y >= h ~/ 2 &&
            center_y <= h) {
          label +=
              '${element.className} at Bottom Left, of color ${objColors[index]}, ';
        } else {
          label +=
              '${element.className} at Bottom Right, of color ${objColors[index]}, ';
        }
        index += 1;
      }
      // Speak labels
      _flutterTts.speak(label);
    }
  }

  void stopSpeaking() {
    _flutterTts.stop();
  }

  // Detect Color
  Future<List<String?>> detectColor(
    List<ResultObjectDetection?> objDetect,
  ) async {
    List<String?> dominantColors = [];
    // To save image
    // int id = 0;
    // String filename;
    // final Future<Directory> appDocumentsDir = getApplicationDocumentsDirectory();
    // final Directory tempDir = await getTemporaryDirectory();
    // String path = tempDir.path;
    // print("Temp Path: $path");
    for (var element in objDetect) {
      // Crop the image based on the detected object's coordinates
      img_.Image croppedObj = img_.copyCrop(
          img,
          (element!.rect.left * w).toInt(),
          (element.rect.top * h).toInt(),
          (element.rect.right * w).toInt(),
          (element.rect.bottom * h).toInt());

      // convert to dart ui image
      ui.Image uiImage = await convertImgToUiImage(croppedObj);

      // Encode the resulting image to the PNG image format.
      // final png = img_.encodePng(croppedObj);

      // Detect the dominant color using the PaletteGenerator
      PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImage(uiImage);

      // Get the dominant color
      ui.Color dominantColor = paletteGenerator.dominantColor!.color;

      // Save image
      // Write the PNG formatted data to a file.
      // Save to filesystem
      // filename = '$path/Image$id.png';
      //
      // final file = File(filename);

      // copy the file to a new path
      // Save image
      // File savedImg = await file.writeAsBytes(png);
      //
      String colorName = getColorName(dominantColor);

      dominantColors.add(colorName);
      // id += 1;
    }
    // print("************Detected Objects: ${objDetect.length} ************************");
    return dominantColors;
  }

  // Function to convert img.Image to ui.Image
  Future<ui.Image> convertImgToUiImage(img_.Image image) async {
    ByteData? byteData = await _toByteData(image);
    if (byteData == null) {
      throw Exception('Failed to convert img.Image to ByteData.');
    }

    Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(byteData.buffer), (result) {
      return completer.complete(result);
    });

    return completer.future;
  }

  // Function to convert img.Image to ByteData
  Future<ByteData?> _toByteData(img_.Image image) async {
    img_.PngEncoder pngEncoder = img_.PngEncoder();
    List<int> pngBytes = pngEncoder.encodeImage(image);

    return ByteData.view(Uint8List.fromList(pngBytes).buffer);
  }

  // for displaying snackbars
  showSnackBar(BuildContext context, String text) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
