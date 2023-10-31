import 'dart:math';

import 'package:flutter/material.dart';

class ColorName {
  final String name;
  final Color color;

  ColorName(this.name, this.color);
}

// Function to get the color name from the given Color object
String getColorName(Color targetColor) {
  List<ColorName> colorNames = [
    ColorName('Red', Colors.red),
    ColorName('Green', Colors.green),
    ColorName('Blue', Colors.blue),

    ColorName('Red Accent', Colors.redAccent),
    ColorName('White', Colors.white),
    ColorName('White', Colors.white10),
    ColorName('White', Colors.white12),
    ColorName('White', Colors.white24),
    ColorName('White', Colors.white30),
    ColorName('Brown', Colors.white38),
    ColorName('Cyan Accent', Colors.cyanAccent),
    ColorName('Cyan', Colors.cyan),

    ColorName('Pink', Colors.pink),
    ColorName('Pink Accent', Colors.pinkAccent),
    ColorName('Purple', Colors.purple),
    ColorName('Purple Accent', Colors.purpleAccent),
    ColorName('Deep Purple', Colors.deepPurple),

    ColorName('Green Accent', Colors.greenAccent),
    ColorName('Light Green', Colors.lightGreen),
    ColorName('Light Green Accent', Colors.lightGreenAccent),
    ColorName('Lime', Colors.lime),
    ColorName('Lime Accent', Colors.limeAccent),

    ColorName('Grey', Colors.grey),
    ColorName('Blue Grey', Colors.blueGrey),
    ColorName('Teal', Colors.teal),
    ColorName('Teal Accent', Colors.tealAccent),

    ColorName('Yellow', Colors.yellow),
    ColorName('Yellow Accent', Colors.yellowAccent),

    ColorName('Amber', Colors.amber),
    ColorName('Amber Accent', Colors.amberAccent),
    ColorName('Orange', Colors.orange),
    ColorName('Orange Accent', Colors.orangeAccent),
    ColorName('Deep Orange', Colors.deepOrange),
    ColorName('Deep Orange Accent', Colors.deepOrangeAccent),

    ColorName('Black', Colors.black),

    ColorName('Blue Accent', Colors.blueAccent),
    ColorName('Light Blue', Colors.lightBlue),
    ColorName('Light Blue Accent', Colors.lightBlueAccent),

    ColorName('Indigo', Colors.indigo),
    // Add more color names and their corresponding Color objects as needed
  ];

  // Calculate the squared Euclidean distance between two colors
  double calculateDistance(Color c1, Color c2) {
    int r = c1.red - c2.red;
    int g = c1.green - c2.green;
    int b = c1.blue - c2.blue;
    num distance = pow(((r * r) + (g * g) + (b * b)), 0.5);
    return distance.toDouble();
  }

  ColorName closestColor = colorNames[0];
  double minDistance =
      double.maxFinite; // maximum value dart double can contain

  for (var colorName in colorNames) {
    double distance = calculateDistance(targetColor, colorName.color);
    if (distance < minDistance) {
      minDistance = distance;
      closestColor = colorName;
    }
  }

  return closestColor.name;
}
