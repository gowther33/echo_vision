import 'package:flutter_tts/flutter_tts.dart';

class TextSpeaker {
  static late FlutterTts _flutterTts;

  TextSpeaker() {
    _flutterTts = FlutterTts();
    init();
  }

  void init() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setVolume(0.8);
    await _flutterTts.setSpeechRate(0.2);
  }

// labels = class + position + color

  // Speak labels & position detection ***
  void speakLabelCustom(String labels) {
    // Speak labels
    _flutterTts.speak(labels);
  }

  void stopSpeaking() {
    _flutterTts.stop();
  }
}
