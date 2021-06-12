import 'package:eyemate/main.dart';
import 'package:eyemate/screens/intro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

String lang = langCodes.keys.firstWhere(
    (k) => langCodes[k] == sp.getString('langValue'),
    orElse: () => null);

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<dynamic> languages;

  void aboutPage(BuildContext context) {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('Change Language'),
            leading: SizedBox(
              width: 10,
            ),
            trailing: Text(
              // lang,
              langCodes.keys.firstWhere(
                  (k) => langCodes[k] == sp.getString('langValue'),
                  orElse: () => null),
              // langCodes.keys.firstWhere((k) => langCodes[k] == sp.getString('langValue'), orElse: () => null),
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            onTap: () async {
              showMaterialModalBottomSheet(
                bounce: true,
                context: context,
                builder: (context) => ChangeLang(),
              ).then((value) => setState(() {
                    lang = lang;
                  }));
            },
          ),
          ListTile(
            title: Text('Help'),
            leading: SizedBox(
              width: 10,
            ),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => OnBoardingPage()),
            ),
          ),
          ListTile(
            title: Text('About'),
            leading: SizedBox(
              width: 10,
            ),
            onTap: () {
              return showAboutDialog(
      context: context,
      applicationVersion: '1.0.0',
      applicationLegalese: "Developed by Group 2 of MEA 2017-21 CS1 batch",
      children: [
        SizedBox(height: 20,),
        Text('Where you can see the world. \nAn application specially developed for the Blind')
      ],
      // applicationIcon: ImageIcon(AssetImage('logo_icon.png'))
    );
            },
          ),
        ],
      ),
    ));
  }
}

class ChangeLang extends StatefulWidget {
  @override
  _ChangeLangState createState() => _ChangeLangState();
}

class _ChangeLangState extends State<ChangeLang> {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('English'),
            leading: SizedBox(
              width: 10,
            ),
            onTap: () async {
              setState(() {
                lang = 'English';
              });
              await sp.setString('langValue', langCodes[lang]);
              print('Language set as $lang , ${langCodes[lang]}');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('Malayalam'),
            leading: SizedBox(
              width: 10,
            ),
            onTap: () async {
              setState(() {
                lang = 'Malayalam';
              });
              await sp.setString('langValue', langCodes[lang]);
              print('Language set as $lang , ${langCodes[lang]}');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('Hindi'),
            leading: SizedBox(
              width: 10,
            ),
            onTap: () async {
              setState(() {
                lang = 'Hindi';
              });
              await sp.setString('langValue', langCodes[lang]);
              print('Language set as $lang , ${langCodes[lang]}');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    ));
  }
}

class MenuButton extends StatefulWidget {
  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            CupertinoButton(
              child: Icon(
                Icons.menu,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                ;
                showMaterialModalBottomSheet(
                  bounce: true,
                  context: context,
                  builder: (context) => Menu(),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
