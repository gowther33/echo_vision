class ObjectsPostionFinder {
  final List<double> objDetect;
  final int w;
  final int h;

  ObjectsPostionFinder(
    this.objDetect,
    this.w,
    this.h,
  );

  String getPosition() {
    List<double> bbox = [
      objDetect[0] * w,
      objDetect[1] * h,
      objDetect[2] * w,
      objDetect[3] * h,
    ];
    double centerX = (bbox[0] + bbox[2] / 2);
    double centerY = ((bbox[1] + bbox[3]) / 2);

    // Detect Positions
    if (centerX > 0 && centerX < w ~/ 2 && centerY > 0 && centerY < h ~/ 2) {
      return "Top Left";
    } else if (centerX >= w ~/ 2 &&
        centerX <= w &&
        centerY > 0 &&
        centerY < h ~/ 2) {
      return "Top Right";
    } else if (centerX > 0 &&
        centerX < w ~/ 2 &&
        centerY >= h ~/ 2 &&
        centerY <= h) {
      return "Bottom Left";
    } else {
      return "Bottom Right";
    }
  }
}
