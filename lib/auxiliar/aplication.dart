import 'dart:ui';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';
import 'firebase.dart';
import 'import.dart';
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

  static Future<bool> moverAnime(BuildContext context, Anime item, ListType listType) async {
    var title = Titles.MOVER_ITEM;
    var content = [
      if (!listType.isAssistindo)
        FlatButton(child: Text(Strings.ASSISTINDO), onPressed: () {
          Navigator.pop(context, DialogResult.aux2);
        }),
      if (!listType.isFavoritos)
        FlatButton(child: Text(Strings.FAVORITOS), onPressed: () {
          Navigator.pop(context, DialogResult.aux);
        }),
      if (!listType.isConcluidos && item.isLancado)
        FlatButton(child: Text(Strings.CONCLUIDOS), onPressed: () {
          Navigator.pop(context, DialogResult.positive);
        }),
    ];
    var result = await DialogBox.dialogCancel(context, title: title, content: content);

    ListType novaList;
    switch(result.value) {
      case DialogResult.auxValue:
        novaList = ListType.favoritos;
        break;
      case DialogResult.positiveValue:
        novaList = ListType.concluidos;
        break;
      case DialogResult.aux2Value:
        novaList = ListType.assistindo;
        break;
      default:
        return false;
    }
    if (!result.isNone) {
      RunTime.updateFragment(listType);
      RunTime.updateFragment(novaList);
    }

    if (await item.mover(novaList, listType)) {
      return true;
    }
    return false;
  }
}