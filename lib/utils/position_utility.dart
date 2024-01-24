import 'package:echo_vision/utils/globals.dart';

class ObjectsPostionFinder {
  final List<List<double>> objDetect;
  final List<String> positions = [];
  final List<String> cls;

  ObjectsPostionFinder(this.objDetect, this.cls);

  Future<List<String>> getPosition() async {
    for (int i = 0; i < objDetect.length; i++) {
      List<double> bbox = [
        objDetect[i][0],
        objDetect[i][1],
        objDetect[i][2],
        objDetect[i][3],
      ];
      // [502.8691101074219, 110.95758056640625, 813.1492919921875, 424.7120361328125]
      double centerX = (bbox[0] + bbox[2]) / 2;
      double centerY = (bbox[1] + bbox[3]) / 2;
      // Detect Positions
      if (centerX > 0 &&
          centerX < w! ~/ 2 &&
          centerY > 0 &&
          centerY < h! ~/ 2) {
        positions.add("Top Left");
      } else if (centerX >= w! ~/ 2 &&
          centerX <= w! &&
          centerY > 0 &&
          centerY < h! ~/ 2) {
        positions.add("Top Right");
      } else if (centerX > 0 &&
          centerX < w! ~/ 2 &&
          centerY >= h! ~/ 2 &&
          centerY <= h!) {
        positions.add("Bottom Left");
      } else {
        positions.add("Bottom Right");
      }
    }
    return positions;
  }
}
