import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:volume/volume.dart';

enum TTSstate { playing, stopped }

class Tts extends StatefulWidget {
  Tts({Key key}) : super(key: key);
  @override
  TtsState createState() => TtsState();
}

class TtsState<T extends Tts> extends State<T> {
  @override
  TTSstate ttsState = TTSstate.stopped;
  FlutterTts _flutterTts;

  get isPlaying => ttsState == TTSstate.playing;
  get isStopped => ttsState == TTSstate.stopped;

  ///text to speech methods
  initializeTts() {
    _flutterTts = FlutterTts();

    _flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TTSstate.playing;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TTSstate.stopped;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: " + err);
        ttsState = TTSstate.stopped;
      });
    });
  }

  Future<void> initAudioStreamType() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  initAudio() {
    initAudioStreamType();
  }

  mute() async {
    await Volume.setVol(0);
  }

  unmute() async {
    await Volume.setVol(100);
  }

  Future _speak(String text) async {
    if (text != null && text.isNotEmpty) {
      var result = await _flutterTts.speak(text);
      // if (result == 1)
      //   setState(() {
      //     ttsState = TTSstate.playing;
      //   });
      ttsState = TTSstate.playing;
    }
  }

  speak(String text) {
    _speak(text);
    print(ttsState);
  }

  Future _stop() async {
    var result = await _flutterTts.stop();
    if (result == 1)
      setState(() {
        ttsState = TTSstate.stopped;
      });
  }

  stop() {
    _stop();
  }

  ttsDispose() {
    _flutterTts.stop();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _flutterTts.stop();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void setMl() async {
    await _flutterTts.setLanguage('ml-IN');
  }

  void setHi() async {
    await _flutterTts.setLanguage('hi-IN');
  }

  void setEng() async {
    await _flutterTts.setLanguage("en-US");
  }

  Widget build(BuildContext context) {
    return Container();
  }
}
