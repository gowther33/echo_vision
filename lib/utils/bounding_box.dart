import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
import 'dart:io';

class BoundingBoxesPainter extends CustomPainter {
  final List<List<dynamic>> boundingBoxes;
  // final List<String> classes;
  final Size imageSize;
  final String imagePath;
  late ui.Image image;

  BoundingBoxesPainter(this.imagePath, this.boundingBoxes, this.imageSize);

  Future<ui.Image> loadImage() async {
    File imageFile = File(imagePath);
    Uint8List imageBytes = await imageFile.readAsBytes();
    return await decodeImageFromList(imageBytes);
  }

  @override
  void paint(Canvas canvas, Size size) {
    image = loadImage() as ui.Image;

    double scaleX = size.width / imageSize.width;
    double scaleY = size.height / imageSize.height;

    canvas.drawImage(image, Offset.zero, Paint());

    for (int i = 0; i < boundingBoxes.length; i++) {
      // List<dynamic> box = boundingBoxes[i];

      // double left = box[0] * scaleX;
      // double top = box[1] * scaleY;
      // double right = box[2] * scaleX;
      // double bottom = box[3] * scaleY;

      // canvas.drawRect(
      //   Rect.fromLTRB(left, top, right, bottom),
      //   Paint()
      //     ..color = Colors.red // Set the color for the bounding box
      //     ..style = PaintingStyle.stroke
      //     ..strokeWidth = 2, // Set the width of the bounding box
      // );

      // Draw text showing the class
      // TextSpan span = TextSpan(
      //   style: TextStyle(color: Colors.red, fontSize: 16),
      //   text: classes[i],
      // );

      // TextPainter tp = TextPainter(
      //   text: span,
      //   textAlign: TextAlign.left,
      //   textDirection: TextDirection.ltr,
      // );

      // tp.layout();
      // tp.paint(canvas, Offset(left, top - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
