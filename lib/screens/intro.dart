import 'dart:io';

import 'package:eyemate/api/tts.dart';
import 'package:eyemate/main.dart';
import 'package:eyemate/screens/splashScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picovoice/picovoice_error.dart';
import 'package:picovoice/picovoice_manager.dart';
import 'package:translator/translator.dart';

class OnBoardingPage extends Tts {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends TtsState<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  var _picovoiceManager;
  Map<String, String> slots;

  GoogleTranslator translator = GoogleTranslator();
  var output;

  String pg;
  String pg1;
  String pg2;
  String pg3;
  String pg4;
  String pgb1;
  String pgf1;
  String pgt2;
  String pgb2;
  String pgt3;
  var desc = [];
  String pgt4;
  String pgb4;

  final commands = [
    'Porcupine Capture',
    'Porcupine Repeat',
    'Porcupine Camera',
    'Porcupine Change Language {language}',
    'Porcupine Help',
    'Porcupine Done',
    'Porcupine Exit',
  ];

  String pg1_en =
      'Eye mate. where you can see the world. An application specially developed for the Blind';
  String pg1_ml =
      'Eye mate. അവിടെ നിങ്ങൾക്ക് ലോകം കാണാൻ കഴിയും. അന്ധർക്കായി പ്രത്യേകം വികസിപ്പിച്ച ആപ്ലിക്കേഷൻ';
  String pg1_hi =
      'Eye mate. जहां आप दुनिया देख सकते हैं। नेत्रहीनों के लिए विशेष रूप से विकसित एक एप्लिकेशन';

  String pg2_en =
      'Application structure. The application has mainly three sections: Camera, Preview and Help. To recognize each section, a word corresponding to each is uttered';
  String pg2_ml =
      'അപ്ലിക്കേഷൻ ഘടന. ആപ്ലിക്കേഷന് പ്രധാനമായും മൂന്ന് വിഭാഗങ്ങളുണ്ട്: ക്യാമറ, പ്രിവ്യൂ, സഹായം. ഓരോ വിഭാഗവും തിരിച്ചറിയുന്നതിന്, ഓരോന്നിനും അനുയോജ്യമായ ഒരു വാക്ക് ഉച്ചരിക്കപ്പെടുന്നു';
  String pg2_hi =
      'आवेदन संरचना। एप्लिकेशन में मुख्य रूप से तीन खंड हैं: कैमरा, पूर्वावलोकन और सहायता। प्रत्येक खंड को पहचानने के लिए, प्रत्येक के अनुरूप एक शब्द का उच्चारण किया जाता है';

  String pg3_en =
      'Voice Commands to use. To capture the visual you desire, use Porcupine Capture. To Repeat the generated caption for the image captured or repeat help instructions, use Porcupine Repeat. To return to the camera screen from the preview page, use Porcupine Camera. To change the current language, use Porcupine Change Language and the language you desire to use. Example to change language to English, use Porcupine Change Language English. To navigate to the help page, use Porcupine help. Once you are done with help page, utter Porcupine Done. Once you are done with the application and wish to exit, you can do so by saying Porcupine Exit';
  String pg3_ml =
      'ഉപയോഗിക്കാനുള്ള വോയ്‌സ് കമാൻഡുകൾ. നിങ്ങൾ ആഗ്രഹിക്കുന്ന വിഷ്വൽ പകർത്താൻ, ഉപയോഗിക്കുക Porcupine Capture. പിടിച്ചെടുത്ത ചിത്രത്തിനായി ജനറേറ്റുചെയ്‌ത അടിക്കുറിപ്പ് ആവർത്തിക്കുന്നതിനോ സഹായ നിർദ്ദേശങ്ങൾ ആവർത്തിക്കുന്നതിനോ ഉപയോഗിക്കുക Porcupine Repeat. പ്രിവ്യൂ പേജിൽ നിന്ന് ക്യാമറ സ്ക്രീനിലേക്ക് മടങ്ങാൻ, ഉപയോഗിക്കുക Porcupine Camera. നിലവിലെ ഭാഷ മാറ്റാൻ ഉപയോഗിക്കുക Porcupine Change Language ഒപ്പം നിങ്ങൾ ഉപയോഗിക്കാൻ ആഗ്രഹിക്കുന്ന ഭാഷയും. ഭാഷ ഇംഗ്ലീഷിലേക്ക് മാറ്റുന്നതിനുള്ള ഉദാഹരണം, ഉപയോഗിക്കുക Porcupine Change Language English. സഹായ പേജിലേക്ക് നാവിഗേറ്റുചെയ്യാൻ, ഉപയോഗിക്കുക Porcupine help. സഹായ പേജ് പൂർത്തിയാക്കിക്കഴിഞ്ഞാൽ, ഉച്ചരിക്കുക Porcupine Done. നിങ്ങൾ ആപ്ലിക്കേഷൻ പൂർത്തിയാക്കി പുറത്തുകടക്കാൻ ആഗ്രഹിക്കുന്നുവെങ്കിൽ, പറയുക Porcupine Exit';
  String pg3_hi =
      'उपयोग करने के लिए वॉयस कमांड। अपने इच्छित दृश्य को कैप्चर करने के लिए, उपयोग करें Porcupine Capture । कैप्चर की गई छवि के लिए जेनरेट किए गए कैप्शन को दोहराने के लिए या सहायता निर्देशों को दोहराने के लिए, उपयोग करें Porcupine Repeat । पूर्वावलोकन पृष्ठ से कैमरा स्क्रीन पर लौटने के लिए, उपयोग करें Porcupine Camera । वर्तमान भाषा बदलने के लिए, उपयोग करें Porcupine Change Language और जिस भाषा का आप उपयोग करना चाहते हैं। भाषा को अंग्रेजी में बदलने का उदाहरण, उपयोग करें Porcupine Change Language English । सहायता पृष्ठ पर नेविगेट करने के लिए, उपयोग करें Porcupine help । एक बार जब आप सहायता पृष्ठ के साथ कर लें, तो बोलें Porcupine Done । एक बार जब आप आवेदन के साथ कर लेते हैं और बाहर निकलना चाहते हैं, तो बोलें Porcupine Exit';

  String pg4_en =
      'Now you are ready to go. Say Porcupine Done to forward to the camera screen. Next time when you open the app, you will be directed to the camera screen. say Porcupine repeat, if you\'d like to go through the instructions again.';
  String pg4_ml =
      'ഇപ്പോൾ നിങ്ങൾ പോകാൻ തയ്യാറാണ്. പറയുക Porcupine Done ക്യാമറ സ്ക്രീനിലേക്ക് കൈമാറാൻ. അടുത്ത തവണ നിങ്ങൾ അപ്ലിക്കേഷൻ തുറക്കുമ്പോൾ, നിങ്ങളെ ക്യാമറ സ്‌ക്രീനിലേക്ക് നയിക്കും. പറയുക Porcupine repeat, നിങ്ങൾക്ക് നിർദ്ദേശങ്ങളിലൂടെ വീണ്ടും പോകാൻ താൽപ്പര്യമുണ്ടെങ്കിൽ.';
  String pg4_hi =
      'अब आप जाने के लिए तैयार हैं। कहो Porcupine Done कैमरा स्क्रीन पर अग्रेषित करने के लिए। अगली बार जब आप ऐप खोलेंगे, तो आपको कैमरा स्क्रीन पर निर्देशित किया जाएगा। कहो Porcupine repeat, यदि आप निर्देशों को फिर से पढ़ना चाहते हैं।';

  String pgb1_en = "where you can see the world";
  String pgb1_ml = 'അവിടെ നിങ്ങൾക്ക് ലോകം കാണാൻ കഴിയും';
  String pgb1_hi = 'जहां आप दुनिया देख सकते हैं';

  String pgf1_en = 'An application specially developed for the Blind';
  String pgf1_ml = 'അന്ധർക്കായി പ്രത്യേകം വികസിപ്പിച്ച ആപ്ലിക്കേഷൻ';
  String pgf1_hi = 'नेत्रहीनों के लिए विशेष रूप से विकसित एक एप्लिकेशन';

  String pgt2_en = "Application Structure";
  String pgt2_ml = 'അപ്ലിക്കേഷൻ ഘടന';
  String pgt2_hi = 'आवेदन संरचना';

  String pgb2_en =
      'The application has mainly three sections: \n \n1. Camera \n \n2. Preview \n \n3. Help';
  String pgb2_ml =
      'ആപ്ലിക്കേഷന് പ്രധാനമായും മൂന്ന് വിഭാഗങ്ങളുണ്ട്: \n\n1.ക്യാമറ \n\n2.പ്രിവ്യൂ \n\n3.സഹായം.';
  String pgb2_hi =
      'एप्लिकेशन में मुख्य रूप से तीन खंड हैं: \n\n1.कैमरा \n\n2.पूर्वावलोकन  \n\n3.सहायता';

  String pgt3_en = 'Voice Commands to use';
  String pgt3_ml = 'ഉപയോഗിക്കാനുള്ള വോയ്‌സ് കമാൻഡുകൾ';
  String pgt3_hi = 'उपयोग करने के लिए वॉयस कमांड';

  String pgt4_en = "Now you're ready to go";
  String pgt4_ml = 'ഇപ്പോൾ നിങ്ങൾ പോകാൻ തയ്യാറാണ്';
  String pgt4_hi = 'अब आप जाने के लिए तैयार हैं';

  String pgb4_en =
      "If you'd like to go through the instructions again, click the button below:";
  String pgb4_ml =
      'നിങ്ങൾക്ക് നിർദ്ദേശങ്ങളിലൂടെ വീണ്ടും പോകാൻ താൽപ്പര്യമുണ്ടെങ്കിൽ, ചുവടെയുള്ള ബട്ടൺ ക്ലിക്കുചെയ്യുക:';
  String pgb4_hi =
      'यदि आप निर्देशों को फिर से पढ़ना चाहते हैं, तो नीचे दिए गए बटन पर क्लिक करें:';

  final desc_en = [
    'Captures the visual you desire',
    'Repeat the generated caption for the image captured / repeat help instructions',
    'Return to the camera screen',
    '''Change the current language.
Example: \"Porcupine Change Language English\" ''',
    'Navigates to the help page',
    'To move out of help page',
    'Exits the application'
  ];

  final desc_ml = [
    'നിങ്ങൾ ആഗ്രഹിക്കുന്ന വിഷ്വൽ ക്യാപ്‌ചർ ചെയ്യുന്നു',
    'പിടിച്ചെടുത്ത ചിത്രത്തിനായി ജനറേറ്റുചെയ്ത അടിക്കുറിപ്പ് ആവർത്തിക്കുക / സഹായ നിർദ്ദേശങ്ങൾ ആവർത്തിക്കുക',
    'ക്യാമറ സ്‌ക്രീനിലേക്ക് മടങ്ങുക',
    'നിലവിലെ ഭാഷ മാറ്റുക. \nഉദാഹരണം: \"Porcupine Change Language English\"',
    'സഹായ പേജിലേക്ക് നാവിഗേറ്റുചെയ്യുന്നു',
    'സഹായ പേജിൽ നിന്ന് പുറത്തുകടക്കാൻ',
    'അപ്ലിക്കേഷനിൽ നിന്ന് പുറത്തുകടക്കുന്നു'
  ];

  final desc_hi = [
    'आपके इच्छित दृश्य को कैप्चर करता है',
    'कैप्चर की गई छवि के लिए जेनरेट किए गए कैप्शन को दोहराएं / सहायता निर्देशों को दोहराएं',
    'कैमरा स्क्रीन पर लौटें',
    'वर्तमान भाषा बदलें। \nउदाहरण: \"Porcupine Change Language English\"',
    'सहायता पृष्ठ पर नेविगेट करता है',
    'सहायता पृष्ठ से बाहर निकलने के लिए',
    'आवेदन से बाहर निकलता है'
  ];

  langSet() async {
    var lang = sp.getString('langValue');
    if (lang == 'en') {
      setEng();
      setState(() {
        pg1 = pg1_en;
        pg2 = pg2_en;
        pg3 = pg3_en;
        pg4 = pg4_en;
        pgb1 = pgb1_en;
        pgf1 = pgf1_en;
        pgt2 = pgt2_en;
        pgb2 = pgb2_en;
        pgt3 = pgt3_en;
        pgt4 = pgt4_en;
        pgb4 = pgb4_en;
        desc = desc_en;
      });
    } else if (lang == 'ml') {
      setMl();
      setState(() {
        pg1 = pg1_ml;
        pg2 = pg2_ml;
        pg3 = pg3_ml;
        pg4 = pg4_ml;
        pgb1 = pgb1_ml;
        pgf1 = pgf1_ml;
        pgt2 = pgt2_ml;
        pgb2 = pgb2_ml;
        pgt3 = pgt3_ml;
        pgt4 = pgt4_ml;
        pgb4 = pgb4_ml;
        desc = desc_ml;
      });
    } else if (lang == 'hi') {
      setHi();
      setState(() {
        pg1 = pg1_hi;
        pg2 = pg2_hi;
        pg3 = pg3_hi;
        pg4 = pg4_hi;
        pgb1 = pgb1_hi;
        pgf1 = pgf1_hi;
        pgt2 = pgt2_hi;
        pgb2 = pgb2_hi;
        pgt3 = pgt3_hi;
        pgt4 = pgt4_hi;
        pgb4 = pgb4_hi;
        desc = desc_hi;
      });
    }
  }

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
      if (inference['intent'] == 'done') {
        _onIntroEnd(context);
      } else if (inference['intent'] == 'repeat') {
        introKey.currentState?.animateScroll(0);
        dictatePgs();
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

  void _onIntroEnd(context) async {
    await sp.setBool('seen', true);
    setState(() {
      pg = '';
    });
    ttsState = TTSstate.stopped;
    ttsDispose();
    await _picovoiceManager.stop();
    print('OnBoard page visited: ${sp.getBool('seen')}');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => selectPage()),
    );
  }

  FlutterTts _flutterTts;
  void initState() {
    super.initState();
    initAudio();
    _initPicovoice();
    initializeTts();
    langSet();
    Future.delayed(Duration(seconds: 1), () {
      speak('Help Page');
    });
    Future.delayed(Duration(seconds: 2), () {
      dictatePgs();
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await _picovoiceManager.stop();
    ttsDispose();
  }

  dictatePgs() {
    // // speak(pg1);
    // if (isPlaying) {
    // }
    setState(() {
      pg = pg1;
    });
    speak(pg);

    Future.delayed(Duration(seconds: 9), () {
      introKey.currentState?.animateScroll(1);
      setState(() {
        pg = pg2;
      });
      Future.delayed(Duration(seconds: 2), () {
        speak(pg);
        Future.delayed(Duration(seconds: 14), () {
          introKey.currentState?.animateScroll(2);
          setState(() {
            pg = pg3;
          });
          Future.delayed(Duration(seconds: 2), () async {
            speak(pg);
            await _picovoiceManager.stop();
            Future.delayed(Duration(seconds: 48), () {
              introKey.currentState?.animateScroll(3);
              setState(() {
                pg = pg4;
              });
              Future.delayed(Duration(seconds: 2), () {
                speak(pg);
                Future.delayed(Duration(seconds: 15), () {
                  _initPicovoice();
                });
              });
            });
          });
        });
      });
    });

    // Future.delayed(Duration(seconds: 9), () {
    //   speak(pg2);
    // });

    // Future.delayed(Duration(seconds: 20), () {
    //   introKey.currentState?.animateScroll(2);
    // });

    // Future.delayed(Duration(seconds: 22), () async {
    //   speak(pg3);
    //   await _picovoiceManager.stop();
    // });

    // Future.delayed(Duration(seconds: 65), () {
    //   introKey.currentState?.animateScroll(3);
    // });

    // Future.delayed(Duration(seconds: 67), () {
    //   speak(pg4);
    // });

    // Future.delayed(Duration(seconds: 82), () {
    //   _initPicovoice();
    // });
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  Widget command(text) {
    return Text(
      text,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return WillPopScope(
      onWillPop: () async => false,
      child: IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Colors.white,
        globalHeader: Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Row(
              children: [
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 16, right: 16),
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
                // Spacer(),
                // Padding(
                //   padding: const EdgeInsets.only(top: 16, right: 16),
                //   child: _buildImage('flutter.png', 100),
                // ),
              ],
            ),
          ),
        ),

        pages: [
          PageViewModel(
            title: "EyeMate",
            body: pgb1,
            image: Image.asset(
              'assets/logo.png',
              height: 100,
              width: 100,
            ),
            footer: Text(pgf1),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: pgt2,
            body: pgb2,
            image: _buildImage('img1.jpg'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Text(
                pgt3,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            bodyWidget: Container(
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      title: command(commands[0]),
                      subtitle: Text(desc[0]),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: command(commands[1]),
                      subtitle: Text(desc[1]),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: command(commands[2]),
                      subtitle: Text(desc[2]),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: command(commands[3]),
                      subtitle: Text(desc[3]),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: command(commands[4]),
                      subtitle: Text(desc[4]),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: command(commands[5]),
                      subtitle: Text(desc[5]),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: command(commands[6]),
                      subtitle: Text(desc[6]),
                    ),
                  ),
                ],
              ),
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: pgt4,
            body: pgb4,
            image: _buildImage('img2.jpg'),
            footer: FloatingActionButton(
              onPressed: () {
                introKey.currentState?.animateScroll(0);
                dictatePgs();
              },
              child: const Icon(
                Icons.replay,
                size: 30.0,
              ),
              // style: ElevatedButton.styleFrom(
              //   primary: Colors.lightBlue,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(8.0),
              //   ),
              // ),
            ),
            decoration: pageDecoration,
          ),
        ],
        onDone: () => _onIntroEnd(context),
        //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: true,
        skipFlex: 0,
        nextFlex: 0,
        //rtl: true, // Display as right-to-left
        skip: const Text('Skip'),
        onSkip: () => _onIntroEnd(context),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(16),
        controlsPadding: kIsWeb
            ? const EdgeInsets.all(12.0)
            : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        dotsContainerDecorator: const ShapeDecoration(
          color: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }
}
