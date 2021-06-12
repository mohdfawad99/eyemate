import 'dart:io';
import 'dart:typed_data';

import 'package:eyemate/api/tts.dart';
import 'package:eyemate/main.dart';
import 'package:eyemate/screens/camera.dart';
import 'package:eyemate/screens/intro.dart';
import 'package:eyemate/screens/menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picovoice/picovoice_error.dart';
import 'package:picovoice/picovoice_manager.dart';
import 'package:translator/translator.dart';

class PreviewScreen extends Tts {
  final String imgPath;
  final String fileName;

  PreviewScreen({Key key, this.imgPath, this.fileName}) : super(key: key);

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends TtsState<PreviewScreen> {
  var text = 'Loading...';
  bool visible = false;
  bool isMute = (sp.getBool('mute') ?? false);
  var lang = sp.getString('langValue');

  GoogleTranslator translator = GoogleTranslator();
  var output;

  // FlutterTts _flutterTts;

  var _picovoiceManager;

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

  void _wakeWordCallback() {
    setState(() {});
  }

  void _inferenceCallback(Map<String, dynamic> inference) {
    print(inference);

    if (inference['isUnderstood']) {
      if (inference['intent'] == 'camera') {
        camPage();
      } else if (inference['intent'] == 'help') {
        helpPage();
      } else if (inference['intent'] == 'changeLang') {
        Map<String, String> slots = inference['slots'];
        changeLang(slots);
      } else if (inference['intent'] == 'repeat') {
        speak(text);
      } else if (inference['intent'] == 'exit') {
        Future.delayed(const Duration(milliseconds: 1000), () {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });
      } else {
        speak('I didn\'t understand. Please say properly.');
      }
      // if (inference['intent'] == 'done') {
      //   _onIntroEnd(context);
      // } else if (inference['intent'] == 'repeat') {
      //   introKey.currentState?.animateScroll(0);
      // }
    } else {
      print('Try again');
      speak('I did not understand');
    }
  }

  changeLang(Map<String, String> slots) async {
    if (slots['state'] != null) {
      await sp.setString('langValue', langCodes[slots['state']]);
      // await trans(text, langCodes[slots['state']]);
      // setState(() {
      //   // text = response.body;
      //   text = output.toString();
      //   print(text);
      // });
      speak('Language is set as ${slots['state']}');
      print('Language set as $lang , ${langCodes[slots['state']]}');
    }
  }

  helpPage() async {
    await _picovoiceManager.stop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OnBoardingPage()),
    );
  }

  camPage() async {
    await _picovoiceManager.stop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => CameraScreen()),
    );
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

  @override
  void initState() {
    super.initState();
    initAudio();
    _initPicovoice();
    initializeTts();
    Future.delayed(Duration(seconds: 1), () {
      speak('Preview Page');
    });
    _playSpeech();
  }

  Widget playButton() {
    return CupertinoButton(
      child: Icon(
        (isPlaying) ? CupertinoIcons.stop : CupertinoIcons.play,
        color: Colors.white,
        size: 40.0,
      ),
      onPressed: () {
        if (isPlaying) {
          stop();
        } else {
          speak(text);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('used back navigation');
        setState(() {
          text = '';
        });
        ttsState = TTSstate.stopped;
        ttsDispose();
        await _picovoiceManager.stop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => CameraScreen()),
        );
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            leading: BackButton(
              onPressed: () async {
                setState(() {
                  text = '';
                });
                ttsState = TTSstate.stopped;
                ttsDispose();
                await _picovoiceManager.stop();
                // Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => CameraScreen()),
                );
              },
            ),
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
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
                    child: Icon(
                      isMute ? Icons.volume_off : Icons.volume_up,
                      size: 26.0,
                    ),
                  )),
            ],
          ),
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Image.file(
                      File(widget.imgPath),
                      fit: BoxFit.contain,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(),
                          visible
                              ? playButton()
                              : CupertinoButton(
                                  child: Icon(
                                    CupertinoIcons.stop,
                                    color: Colors.black,
                                    size: 40.0,
                                  ),
                                  onPressed: () {}),
                          MenuButton(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Positioned(
                bottom: 130,
                left: 40,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    color: Colors.white.withOpacity(0.7),
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  //convert image file into ByteData
  Future getBytes() async {
    Uint8List bytes = File(widget.imgPath).readAsBytesSync() as Uint8List;

//    print(ByteData.view(buffer))
    return ByteData.view(bytes.buffer);
  }



  trans(String text, String lang) async {
    await translator
        // .translate(textEditingController.text, to: "$dropdownValue")
        .translate(text, to: lang)
        .then((value) {
      setState(() {
        output = value;
      });
      // return output;
    });
  }

  Future<StreamedResponse> uploadFile(String filePath) async {
    // Response response;
    var uri = Uri.parse('https://eyemate.e-quicko.com/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['lang'] = sp.getString('langValue');
    request.files.add(await http.MultipartFile.fromPath('a', filePath));
    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Uploaded!');
    }
    print(response);
    return response;
  }

  Future _playSpeech() async {
    var streamedResponse = await uploadFile(widget.imgPath);
    var response = await http.Response.fromStream(streamedResponse);
    // print(response.body);
    print(widget.imgPath);
    // String data =
    //     await 'An old man lived in the village. He was one of the most unfortunate people in the world. The whole village was tired of him; he was always gloomy, he constantly complained and was always in a bad mood.';
    // await 'ഒരിടത്തൊരിടത്ത് ദാമു എന്ന് പേരുള്ള സ്വാർത്ഥനും അത്യാഗ്രഹിയുമായ ഒരു മനുഷ്യനുണ്ടായിരുന്നു. ഒരു ദിവസം അയാളുടെ മുപ്പതു സ്വർണനാണയങ്ങൾ അടങ്ങിയ സഞ്ചി നഷ്ടമായി.';
    await trans(response.body, lang);
    setState(() {
      visible = true;
      // text = response.body;
      text = output.toString();
      // text = widget.imgPath;
    });
    speak(text);
  }


  @override
  void dispose() {
    super.dispose();
    ttsDispose();
  }
}
