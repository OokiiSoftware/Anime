import 'dart:io';
import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';
import 'MainPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _MyState createState() => _MyState();
}
class _MyState extends State<LoginPage> {

  //region Variaveis

  static const String TAG = 'LoginPage';

  bool _inProgress = false;

  //endregion

  //region overrides

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OkiTheme.primary,
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
      floatingActionButton: _inProgress ? AdsFooter(child: CircularProgressIndicator()) : null,
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
      UserDados(FirebaseOki.user).salvar();
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