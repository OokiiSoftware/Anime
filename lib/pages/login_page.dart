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
      backgroundColor: MyTheme.primary(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(MyIcons.ic_launcher, width: 200),
            Padding(padding: EdgeInsets.only(top: 10)),
            ElevatedButton(
                child: Text(MyTexts.FAZER_LOGIN, style: MyStyles.titleText),
                onPressed: onLoginWithGoogleButtonPressed
            )
          ],
        ),
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
    );
  }

  //endregion

  //region Metodos

  void onLoginWithGoogleButtonPressed() async {
    _setInProgress(true);
    try{
      Log.d(TAG, 'Login com Google');
      await Firebase.googleAuth();
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