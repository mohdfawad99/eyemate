

import 'package:eyemate/main.dart';
import 'package:eyemate/screens/camera.dart';
import 'package:eyemate/screens/setLang.dart';
import 'package:flutter/material.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

Widget selectPage() {
  bool _seen = (sp.getBool('seen') ?? false);
  print('Language is set as ${sp.getString('langValue')}');
  print('OnBoard page visited: ${sp.getBool('seen')}');
  // _seen = false;
  if (_seen) {
    return CameraScreen();
  } else {
    return SetLang();
  }
}

  final commands = [
    'Porcupine Capture',
    'Porcupine Repeat',
    'Porcupine Camera',
    'Porcupine Change Language {language}',
    'Porcupine Help',
    'Porcupine Done',
    'Porcupine Exit',
  ];

  final desc = [
    'captures the visual you desire',
    'repeat the generated caption for the image captured / repeat help instructions',
    'return to the camera screen',
    'change the current language. Example: \"Porcupine Change Language English\" ',
    'navigates to the help page',
    'to move out of help page',
    'exits the application'
  ];

Widget splashScreen = SplashScreenView(
  navigateRoute: selectPage(),
  duration: 3000,
  imageSize: 200,
  imageSrc: "assets/logo.png",
  text: "EyeMate",
  textType: TextType.NormalText,
  textStyle: TextStyle(
    fontSize: 30.0,
  ),
  backgroundColor: Colors.white,
);
