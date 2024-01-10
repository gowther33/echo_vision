class TtsProvider {
  late List<String> classes;
  late List<String> positions;
  late List<String> colors;

  String _speechString = "";

  TtsProvider(
    this.classes,
    this.positions,
    this.colors,
  );

  void setString() {
    for (int i = 0; i < classes.length; i++) {
      _speechString +=
          '${classes[i]} of color ${colors[i]} at ${positions[i]}, ';
    }
  }

  String getString() {
    return _speechString;
  }

  void clearString() {
    _speechString = "";
  }
}
