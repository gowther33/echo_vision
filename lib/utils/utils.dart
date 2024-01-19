// This file contains all the utility functions

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image/image.dart'
    as img_; // Use an alias to differentiate the package name.
import 'package:image_picker/image_picker.dart';
import 'package:echo_vision/utils/globals.dart';

class UtilityMethods {
  final FlutterTts _flutterTts = FlutterTts(); // For tts
  final ImagePicker _picker = ImagePicker();
  // late int w;
  // late int h;

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
      final File imagefile = File(image.path);
      Uint8List bytes = imagefile.readAsBytesSync();

      img = img_.decodeImage(
          bytes)!; // Use the alias(img_) to access the Image class.

      // height and width of image
      h = img!.height;
      w = img!.width;

      return image;
    } else {
      return null;
    }
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
