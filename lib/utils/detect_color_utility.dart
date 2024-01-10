import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:palette_generator/palette_generator.dart';

import 'color_name.dart';
import 'package:image/image.dart'
    as img_; // Use an alias to differentiate the package name.

import 'package:echo_vision/utils/globals.dart';

class DetectObjectColor {
  // Detect Color **
  Future<List<String?>> detectColorCustom(
    List<List<double?>> objDetect,
  ) async {
    List<String> dominantColors = [];
    // To save image
    // int id = 0;
    // String filename;
    // // final Future<Directory> appDocumentsDir = getApplicationDocumentsDirectory();
    // final Directory tempDir = await getTemporaryDirectory();
    // String path = tempDir.path;
    // print("Temp Path: $path");
    for (var i = 0; i < objDetect.length; i++) {
      // Crop the image based on the detected object's coordinates
      img_.Image croppedObj = img_.copyCrop(
        img!,
        (objDetect[i][0]! * w!).toInt(),
        (objDetect[i][1]! * h!).toInt(),
        (objDetect[i][2]! * w!).toInt(),
        (objDetect[i][3]! * h!).toInt(),
      );

      // Encode the resulting image to the PNG image format.
      // final png = img_.encodePng(croppedObj);

      // Save image
      // Write the PNG formatted data to a file.
      // Save to filesystem
      // filename = '$path/Image$id.png';

      // final file = File(filename);

      // copy the file to a new path
      // Save image
      // await file.writeAsBytes(png);

      // convert to dart ui image
      ui.Image uiImage = await convertImgToUiImage(croppedObj);
      PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImage(uiImage);

      try {
        ui.Color dominantColor = paletteGenerator.dominantColor!.color;
        dominantColors.add(getColorName(dominantColor));
      } catch (e) {
        dominantColors.add("Black");
      }
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
}
