import 'dart:io';
import 'package:anime/auxiliar/import.dart';
import 'package:anime/auxiliar/firebase.dart';
import 'package:anime/auxiliar/logs.dart';
import 'package:anime/pages/MainPage.dart';
import 'package:anime/res/my_icons.dart';
import 'package:anime/res/resources.dart';
import 'package:anime/res/strings.dart';
import 'package:anime/res/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  MyPageState createState() => MyPageState();
}
class MyPageState extends State<LoginPage> {

  //region Variaveis

  static const String TAG = 'LoginPage';

  bool _inProgress = false;

  //endregion

  //region overrides

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(MyIcons.ic_launcher, width: 200),
            Padding(padding: EdgeInsets.only(top: 10)),
            if (Platform.isAndroid)
              GestureDetector(
                child: Container(
                  width: 270,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      border: Border.all(
                        width: 1.5,
                        color: Colors.blue,
                      )
                  ),
                  child: Row(
                    children: [
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(5),
                        child: Image.asset(MyIcons.ic_google),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Login com Google', style: TextStyle(color: Colors.white, fontSize: 20)),
                      )
                    ],
                  ),
                ),
                onTap: onLoginWithGoogleButtonPressed,
              )
          ],
        ),
      ),
      floatingActionButton: _inProgress ? Layouts.adsFooter(CircularProgressIndicator()) : null,
    );
  }

  //endregion

  //region Metodos

  void onLoginWithGoogleButtonPressed() async {
    _setInProgress(true);
    try{
      Log.d(TAG, 'Login com Google');
      await FirebaseOki.googleAuth();
      Log.d(TAG, 'Login com Google', 'OK');
      Navigate.toReplacement(context, MainPage());
    } catch (e) {
      Log.e(TAG, 'Login com Google Fail', e);
      Log.snack('Login with Google fails');
    }
    _setInProgress(false);
  }

  void _setInProgress(bool b) {
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}