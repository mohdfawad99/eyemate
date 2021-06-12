import 'dart:io';

import 'package:eyemate/api/tts.dart';
import 'package:eyemate/main.dart';
import 'package:eyemate/screens/intro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picovoice/picovoice_error.dart';
import 'package:picovoice/picovoice_manager.dart';

class SetLang extends Tts {
  SetLang({Key key}) : super(key: key);

  @override
  _SetLangState createState() => _SetLangState();
}

class _SetLangState extends TtsState<SetLang> {
  bool _visible = true;
  bool displayWidget = false;
  bool changePosition = false;

  String _chosenLang;
  String validText = '';

  var _picovoiceManager;
  Map<String, String> slots;

  _initPicovoice() async {
    // String platform = Platform.isAndroid ? "android" : "ios";
    String keywordAsset = "assets/porcupine_android.ppn";
    String keywordPath = await _extractAsset(keywordAsset);
    String contextPath = await _extractAsset(contextAsset);

    try {
      _picovoiceManager = await PicovoiceManager.create(
          keywordPath, _wakeWordCallback, contextPath, _inferenceCallback);
      _picovoiceManager.start();
    } on PvError catch (ex) {
      print(ex);
    }
  }

  void _wakeWordCallback() {}

  void _inferenceCallback(Map<String, dynamic> inference) {
    print(inference);
    if (inference['isUnderstood']) {
      // Map<String, String> slots = inference['slots'];
      // print(slots);
      print(inference['intent']);
      if (inference['slots']['state'] == 'English' ||
          inference['slots']['state'] == 'Malayalam' ||
          inference['slots']['state'] == 'Hindi') {
        setState(() {
          _chosenLang = inference['slots']['state'];
        });
        langSubmit();
      } else if (inference['intent'] == 'repeat') {
        speak(
            'Hai! Set language of your choice. The languages available are English, Malayalam and Hindi. Say Porcupine English to set as English, Porcupine Malayalam to set as Malayalam and Porcupine Hindi to set as Hindi. To repeat the instructions, say Porcupine repeat.');
      } else if (inference['intent'] == 'exit') {
        Future.delayed(const Duration(milliseconds: 1000), () {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });
      } else {
        speak('I didn\'t understand. Please say properly.');
      }
    } else {
      print('Try again');
      speak('I did not understand');
    }
    print(_chosenLang);
  }

  Future<String> _extractAsset(String resourcePath) async {
    // extraction destination
    String resourceDirectory = (await getApplicationDocumentsDirectory()).path;
    String outputPath = '$resourceDirectory/$resourcePath';
    File outputFile = new File(outputPath);

    ByteData data = await rootBundle.load(resourcePath);
    final buffer = data.buffer;

    await outputFile.create(recursive: true);
    await outputFile.writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    return outputPath;
  }

  langSubmit() async {
    if (_chosenLang == null) {
      setState(() {
        validText = 'Note: Please Choose a Language';
      });
    } else {
      await sp.setString('langValue', langCodes[_chosenLang]);
      speak('Language is set as $_chosenLang');
      print('Language is set as ${sp.getString('langValue')}');
      // await _picovoiceManager.stop();

      Future.delayed(Duration(seconds: 2), () async {
        ttsDispose();
        // ttsState = TTSstate.stopped;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => OnBoardingPage()),
        );
      });
    }
  }

  Widget dropDown() {
    return DropdownButton<String>(
        focusColor: Colors.white,
        value: _chosenLang,
        //elevation: 5,
        style: TextStyle(color: Colors.white),
        iconEnabledColor: Colors.black,
        items: <String>['English', 'Malayalam', 'Hindi']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        hint: Text(
          "Choose a language",
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        onChanged: (String value) {
          setState(() {
            _chosenLang = value;
          });
          print(_chosenLang);
        });
  }

  Widget _logo() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.png',
            height: 200,
            width: 200,
          ),
          SizedBox(
            height: 20,
          ),
          Visibility(
            visible: _visible,
            // maintainAnimation: true,
            child: Text(
              'EyeMate',
              style: TextStyle(fontSize: 30.0, fontStyle: FontStyle.normal),
            ),
          ),
          SizedBox(
            height: 200,
          ),
        ],
      ),
    );
  }

  initPage() async {
    // status =;
    // print(status);
    if (await Permission.microphone.request().isGranted) {
      Future.delayed(Duration(seconds: 0), () {
        setState(() {
          changePosition = true;
          _visible = false;
        });
      });
      Future.delayed(Duration(milliseconds: 2500), () {
        setState(() {
          displayWidget = true;
          speak(
              'Hai! Set language of your choice. The languages available are English, Malayalam and Hindi. Say Porcupine English to set as English, Porcupine Malayalam to set as Malayalam and Porcupine Hindi to set as Hindi. To repeat the instructions, say Porcupine repeat.');
        });
      });
      initializeTts();
      Future.delayed(Duration(seconds: 18), () {
        _initPicovoice();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initAudio();
    initPage();
    print(isMute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 25,
              right: 8,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 8),
                child: IconButton(
                  onPressed: () {
                    if (isMute) {
                      setState(() {
                        isMute = false;
                      });
                      unmute();
                      sp.setBool('mute', false);
                      // print(isMute);
                      print(sp.getBool('mute'));
                    } else {
                      setState(() {
                        isMute = true;
                      });
                      mute();
                      sp.setBool('mute', true);
                      // print(isMute);
                      print(sp.getBool('mute'));
                    }
                  },
                  icon: Icon(
                    (isMute) ? Icons.volume_off : Icons.volume_up,
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              top: changePosition ? 150.0 : 300.0,
              duration: Duration(milliseconds: 2500),
              curve: Curves.fastOutSlowIn,
              child: _logo(),
            ),
            Positioned(
              bottom: 200,
              child: Column(
                children: [
                  Visibility(visible: displayWidget, child: dropDown()),
                  Visibility(
                    visible: displayWidget,
                    child: Text(
                      validText,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: displayWidget,
                    child: FlatButton(
                      color: Colors.blue,
                      onPressed: () {
                        langSubmit();
                      },
                      child: Text(
                        'Go',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
