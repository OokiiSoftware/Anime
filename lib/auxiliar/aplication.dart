import 'dart:ui';
import 'package:anime/auxiliar/preferences.dart';
import 'package:anime/model/config.dart';
import 'package:anime/res/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase.dart';
import 'logs.dart';
import 'offline_data.dart';

class Aplication {
  static const String TAG = 'Aplication';

  static int appVersionInDatabase = 0;
  static PackageInfo packageInfo;

  static bool get isRelease => bool.fromEnvironment('dart.vm.product');
  static Locale get locale => Locale('pt', 'BR');

  static Future<void> init() async {
    Log.d(TAG, 'init', 'iniciando');

    Preferences.instance = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();

    await OfflineData.readDirectorys();
    await OfflineData.createDataDirectory();
    await OfflineData.readOfflineData();
    Config.readConfig();
    Log.d(TAG, 'init', 'OK');
  }

  static Future<String> buscarAtualizacao() async {
    Log.d(TAG, 'buscarAtualizacao', 'Iniciando');
    int _value = await FirebaseOki.database
        .child(FirebaseChild.VERSAO)
        .once()
        .then((value) => value.value)
        .catchError((e) {
      Log.e(TAG, 'buscarAtualizacao', e);
      return -1;
    });
    String url;

    Log.d(TAG, 'buscarAtualizacao', 'Web Version', _value, 'Local Version', packageInfo.buildNumber);
    appVersionInDatabase = _value;
    int appVersion = int.parse(packageInfo.buildNumber);

    if (_value > appVersion) {
      url = 'https://play.google.com/store/apps/details?id=com.ookiisoftware.protips';
//      String folder = Platform.isAndroid ? FirebaseChild.APK : FirebaseChild.IOS;
//      String ext = Platform.isAndroid ? '.apk' : '';
//      String fileName = MyStrings.APP_NAME + '_' + _value.toString() + ext;
//      Log.d(TAG, 'buscarAtualizacao', 'fileName', fileName);
//      try {
//        url = await getFirebase.storage()
//            .child(FirebaseChild.APP)
//            .child(folder)
//            .child(fileName)
//            .getDownloadURL();
//      } catch(e) {
//        Log.e(TAG, 'buscarAtualizacao', e);
//      }
    }

    return url;
  }

  static Future<void> openUrl(String url, [BuildContext context]) async {
    try {
      if (await canLaunch(url))
        await launch(url);
      else
        throw Exception(MyErros.ABRIR_LINK);
    } catch(e) {
      if (context != null)
        Log.snack(MyErros.ABRIR_LINK, isError: true);
      Log.e(TAG, 'openUrl', e);
    }
  }

  static void openEmail(String email, [BuildContext context]) async {
    final Uri _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: '$email',
        queryParameters: {
          'subject': 'Anime App'
        }
    );
    try {
      if (await canLaunch(_emailLaunchUri.toString()))
        await launch(_emailLaunchUri.toString());
      else
        throw Exception(MyErros.ABRIR_EMAIL);
    } catch(e) {
      if (context != null)
        Log.snack(MyErros.ABRIR_EMAIL, isError: true);
      Log.e(TAG, 'openUrl', e);
    }
  }

}