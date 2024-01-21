import 'dart:ui' as ui;
import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
import 'dart:math';

class BoundingBoxesPainter extends CustomPainter {
  final ui.Image image;
  final List<List<double>> boundingBoxes;
  final List<String>? classes;
  // final String imagePath;

  BoundingBoxesPainter(
    this.image,
    this.boundingBoxes,
    this.classes,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // double scaleX = size.width / imageSize.width;
    // double scaleY = size.height / imageSize.height;

    // print("Image Dimensions");
    // print("w:${imageSize.width}");
    // print("h:${imageSize.height}");

    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawImage(image, Offset.zero, Paint());
    // Offset a = Offset(0, 0);
    // Offset b = Offset(100 * scaleX, 100 * scaleY);

    String labelTxt;
    const double maxFont = 25;
    for (int i = 0; i < boundingBoxes.length; i++) {
      List<double> box = boundingBoxes[i];
      labelTxt = "${classes?[i]}";

      double left = box[0];
      double top = box[1];
      double right = box[2];
      double bottom = box[3];

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);

      double tempFont = box.reduce(max) / boundingBoxes.length;

      // Use the minimum of the calculated size and the maximum allowed size
      double font = tempFont < maxFont ? tempFont : maxFont;

      // Draw text showing the class
      TextSpan span = TextSpan(
        style: TextStyle(
          color: Colors.amber,
          fontSize: font,
        ),
        text: labelTxt,
      );

      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );

      // var l = ((left + right) / 2) - 30;
      // Offset(left, ((top + bottom) / 2) + (bottom - top) / 2),
      tp.layout();
      tp.paint(
        canvas,
        Offset(left, bottom),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
