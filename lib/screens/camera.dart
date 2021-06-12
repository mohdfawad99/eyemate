import 'dart:io';

import 'package:eyemate/api/tts.dart';
import 'package:eyemate/main.dart';
import 'package:eyemate/screens/intro.dart';
import 'package:eyemate/screens/preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picovoice/picovoice_error.dart';
import 'package:picovoice/picovoice_manager.dart';

import 'menu.dart';

class CameraScreen extends Tts {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends TtsState<CameraScreen> {
  CameraController cameraController;
  List cameras;
  int selectedCameraIndex;
  String imgPath;

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
      if (inference['intent'] == 'capture') {
        onCapture(context);
      } else if (inference['intent'] == 'help') {
        helpPage();
      } else if (inference['intent'] == 'changeLang') {
        Map<String, String> slots = inference['slots'];
        changeLang(slots);
        speak('Language is set as ${langCodes[slots['state']]}');
      } else if (inference['intent'] == 'exit') {
        Future.delayed(const Duration(milliseconds: 1000), () {
          // _picovoiceManager.stop();
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
      speak('I didn\'t understand');
      print('Try again');
    }
  }

  changeLang(Map<String, String> slots) async {
    if (slots['state'] != null) {
      await sp.setString('langValue', langCodes[slots['state']]);
      print('Language set as $lang , ${langCodes[slots['state']]}');
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

  //initialize CameraController object
  Future initCamera(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController.dispose();
    }

    cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);

    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    if (cameraController.value.hasError) {
      print('Camera Error ${cameraController.value.errorDescription}');
    }

    try {
      await cameraController.initialize();
    } catch (e) {
      showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// Display camera preview
  Widget cameraPreview() {
    if (cameraController == null || !cameraController.value.isInitialized) {
      return Text(
        'Loading',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: CameraPreview(cameraController),
    );
  }

  ///Display Shutter button
  Widget cameraControl(context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FloatingActionButton(
              child: Icon(
                Icons.camera,
                color: Colors.black,
              ),
              backgroundColor: Colors.white,
              onPressed: () {
                onCapture(context);
              },
            )
          ],
        ),
      ),
    );
  }

  ///Display toggle button
  Widget cameraToggle() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FlatButton.icon(
            onPressed: () {
              onSwitchCamera();
            },
            icon: Icon(
              getCameraLensIcons(lensDirection),
              color: Colors.white,
              size: 24,
            ),
            label: Text(
              '${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1).toUpperCase()}',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            )),
      ),
    );
  }

  ///initState
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    availableCameras().then((value) {
      cameras = value;
      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 0;
        });
        initCamera(cameras[selectedCameraIndex]).then((value) {});
      } else {
        print('No camera available');
      }
    }).catchError((e) {
      print('Error : ${e.code}');
    });
    _initPicovoice();
    initializeTts();
    Future.delayed(Duration(seconds: 1), () {
      speak('Camera Page');
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    ttsDispose();
  }

  ///Layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: cameraPreview(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // cameraToggle(),
                      Spacer(),
                      cameraControl(context),
                      MenuButton(),
                      // Spacer(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  getCameraLensIcons(lensDirection) {
    switch (lensDirection) {
      case CameraLensDirection.back:
        return CupertinoIcons.switch_camera;
      case CameraLensDirection.front:
        return CupertinoIcons.switch_camera_solid;
      case CameraLensDirection.external:
        return CupertinoIcons.photo_camera;
      default:
        return Icons.device_unknown;
    }
  }

  onCapture(context) async {
    try {
      final p = await getTemporaryDirectory();
      final name = DateTime.now();
      final path = "${p.path}/$name.png";

      ttsState = TTSstate.stopped;
      ttsDispose();
      await _picovoiceManager.stop();

      await cameraController.takePicture(path).then((value) {
        print('here');
        print(path);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewScreen(
                      imgPath: path,
                      fileName: "$name.png",
                    )));
      });
    } catch (e) {
      showCameraException(e);
    }
  }

  onSwitchCamera() {
    selectedCameraIndex =
        selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    initCamera(selectedCamera);
  }

  showCameraException(e) {
    String errorText = 'Error ${e.code} \nError message: ${e.description}';
  }

  helpPage() async {
    await _picovoiceManager.stop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OnBoardingPage()),
    );
  }
}
