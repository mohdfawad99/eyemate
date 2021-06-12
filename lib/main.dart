import 'package:eyemate/screens/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences sp;
var langCodes;
bool isMute;

String contextAsset;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  langCodes = {'English': 'en', 'Malayalam': 'ml', 'Hindi': 'hi'};
  contextAsset =
        "assets/eyemateCommands_en_android_2021-06-16-utc_v1_6_0.rhn";
  sp = await SharedPreferences.getInstance();
  isMute = (sp.getBool('mute') ?? false);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //Main
    return MaterialApp(
      title: 'EyeMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Rubik',
        primaryColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: splashScreen,
    );
  }
}
