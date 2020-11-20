import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:anime/model/anime.dart';
import 'package:anime/model/config.dart';
import 'package:anime/model/data_hora.dart';
import 'package:anime/model/user.dart';
import 'package:anime/res/dialog_box.dart';
import 'package:anime/res/strings.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase.dart';
import 'logs.dart';

//      atualizarUser > _organizarListas();

class Import {
  static const String TAG = 'Import';
  static PackageInfo packageInfo;
  static SharedPreferences sharedPreferences;

//  static Future<bool> appIsTnstaled(String package) async {
//    return await DeviceApps.isAppInstalled(package);
//  }

//  static Future<void> openApp(String package, String anime) async {
//    try {
//      if (Platform.isAndroid) {
//        AndroidIntent intent = AndroidIntent(
//          action: 'action_view',
//          data: anime,
//          package: package,
//        );
//        await intent.launch();
//      }
//    } catch (e) {
//      Log.e(TAG, 'openApp', e);
//    }
//    await DeviceApps.openApp(package);
//  }

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

  static Future<bool> moverAnime(BuildContext context, Anime item, ListType list) async {
    var title = MyTitles.MOVER_ITEM;
    var content = SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!list.isAssistindo)
              FlatButton(child: Text(MyStrings.ASSISTINDO), onPressed: () {
                Navigator.pop(context, DialogResult(DialogResult.nao));
              }),
            if (!list.isFavoritos)
              FlatButton(child: Text(MyStrings.FAVORITOS), onPressed: () {
                Navigator.pop(context, DialogResult(DialogResult.ok));
              }),
            if (!list.isConcluidos && (item.status == null || item.status != 'Ainda não foi ao ar'))
              FlatButton(child: Text(MyStrings.CONCLUIDOS), onPressed: () {
                Navigator.pop(context, DialogResult(DialogResult.sim));
              }),
          ]
      ),
    );
    var result = await DialogBox.dialogCancel(context, title: title, content: content);

    ListType novaList;
    switch(result.result) {
      case DialogResult.ok:
        novaList = ListType(ListType.favoritos);
        break;
      case DialogResult.sim:
        novaList = ListType(ListType.concluidos);
        break;
      case DialogResult.nao:
        novaList = ListType(ListType.assistindo);
        break;
      default:
        return false;
    }

    if (await item.mover(novaList, list)) {
      return true;
    }
    return false;
  }
}

class GlobalData {
  static const String TAG = 'GlobalData';
  static Future<void> init() async {
    Log.d(TAG, 'init', 'iniciando');
    await OfflineData.readDirectorys();
    await OfflineData.createDataDirectory();
    await OfflineData.readOfflineData();
    Import.packageInfo = await PackageInfo.fromPlatform();
    Import.sharedPreferences = await SharedPreferences.getInstance();
    Config.readConfig();
    Log.d(TAG, 'init', 'OK');
  }
}

class Navigate {
  static dynamic to(BuildContext context, StatefulWidget widget) async {
    return await Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget));
  }
  static toReplacement(BuildContext context, StatefulWidget widget) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => widget));
  }
}

// ignore: camel_case_types
class getAdmin {
  static const String TAG = 'getAdmin';
  static Map<String, User> _users = new Map();
  static Map<String, User> get users => _users;
  static List<User> get usersList => _users.values.toList();
  static Future<User> get(String key) async {
    if (_users[key] == null) {
      var item = await baixarUser(key);
      if (item != null)
        add(item);
    }
    return _users[key];
  }

  static void add(User item) {
    _users[item.dados.id] = item;
  }
  static void addAll(Map<String, User> items) {
    _users.addAll(items);
  }
  static void remove(String key) {
    _users.remove(key);
  }
  static void reset() {
    _users.clear();
  }
  static Future<void> baixarUsers() async {
    try {
      var snapshot = await Firebase.databaseReference.child(FirebaseChild.USUARIO).once();
      Map<dynamic, dynamic> map = snapshot.value;
      dd(map);
      Log.d(TAG, 'baixa', 'OK');
    } catch (e) {
      Log.e(TAG, 'baixa', e);
    }
  }

  static Future<User> baixarUser(String uid) async {
    try {
      var snapshot = await Firebase.databaseReference
          .child(FirebaseChild.USUARIO).child(uid).once();
      User user = User.fromJson(snapshot.value);
      return user;
    } catch (e) {
      Log.e(TAG, 'baixarUser', e);
      return null;
    }
  }
  static void dd(Map<dynamic, dynamic> map) {
    if (map == null)
      return;

    reset();

    for (String key in map.keys) {
      try {
        User item = User.fromJson(map[key]);
        item.dados.id = key;
        add(item);
      } catch(e) {
        Log.e(TAG, 'dd', e);
        continue;
      }
    }
  }


  static void init() async {
    Log.e(TAG, 'init', 'iniciando');
    await baixarUsers();
    Log.e(TAG, 'init', 'OK');
  }

}

class OnlineData {
  static const String TAG = 'getOnlineData';
  static bool isOnline = false;

  static Map<String, AnimeList> _data = new Map();
  static List<String> _generos = [];

  static Map<String, AnimeList> get data => _data;
  static List get generos => _generos..sort((a, b) => a.compareTo(b));
  static List<AnimeList> get dataList => _data.values.where((e) => (!e.generos.contains('Ecchi') || Config.showEcchi) && _teste(e.generos))
      .toList()..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

  static List<Anime> get dataAnimes {
    final List<Anime> data = [];
    for (AnimeList items in dataList)
      data.addAll(items.itemsToList);
    return data;
  }

  static Future<AnimeList> get(String key) async {
    var item = _data[key];
    if (!item.isCompleto) {
      await item.completar();
    }
    return _data[key];
  }
  static void add(AnimeList item) {
    data[item.id] = item;
    for(var i in item.items.values)
      for (String j in i.generos)
        if (!_generos.contains(j) && j.toLowerCase() != 'ecchi')
          _generos.add(j);
  }
  static void addAll(Map<String, AnimeList> items) {
    _data.addAll(items);
  }
  static void remove(String key) {
    _data.remove(key);
  }

  static void reset() {
    _data.clear();
    _generos.clear();
  }

  static bool _teste(List<dynamic> data) {
    if (data.length == 0)
      return true;
    for (var s in data) {
      if (Config.generos.contains(s))
        return true;
    }
    return false;
  }

  static Future<void> baixarLista() async {
    try {
      var snapshot = await Firebase.databaseReference
          .child(FirebaseChild.ANIME)
          .child(FirebaseChild.BASICO)
          .once();
      Map<dynamic, dynamic> map = snapshot.value;
      dd(map);
      Log.d(TAG, 'baixa', 'OK');
    } catch (e) {
      Log.e(TAG, 'baixa', e);
    }
  }

  static bool _isInProgress = false;
  static Future<void> saveFotoLocal(Anime item) async {
    if(_isInProgress) return;
    if (item == null) return;

    try {
      _isInProgress = true;
      await OfflineData.downloadFile(item.miniatura, OfflineData.localPath, item.fotoLocal);
    } catch(e) {
      Log.e(TAG, 'saveLocalFotos', e);
    }
    _isInProgress = false;
    Log.d(TAG, 'saveLocalFotos', 'OK');
  }

  static Future<void> saveAllFotoLocal() async {
    for (AnimeList items in dataList) {
      for (Anime item in items.items.values)
        await saveFotoLocal(item);
    }
    Log.d(TAG, 'saveAllFotoLocal', 'OK');
  }

  static void dd(Map<dynamic, dynamic> map) {
    if (map == null)
      return;

    reset();

    for (String key in map.keys) {
      try {
        AnimeList item = AnimeList.fromJson(map[key], key);
        add(item);
      } catch(e) {
        Log.e(TAG, 'dd', e);
        continue;
      }
    }
  }
}

class OfflineData {
  static const String TAG = 'offlineData';
  static const String FILE_USER = 'user';
  static const String FILE_ANIMES = 'animes';
  static String localPath = '';
//  static Dio _dio = Dio();

  static Future<void> readDirectorys() async {
    String directory = await OfflineData._getDirectoryPath();
    localPath = directory + '/data';
  }

  static Future<bool> saveOfflineData() async {
//    await deleteOfflineData();
    try {
      File pathUser = _getDataFile(localPath, FILE_USER);
      File pathAnimes = _getDataFile(localPath, FILE_ANIMES);
      String dataUser = jsonEncode(Firebase.user.toJson());
      String dataAnimes = jsonEncode(OnlineData.data);
      await pathUser.writeAsString(dataUser);
      await pathAnimes.writeAsString(dataAnimes);
      Log.d(TAG, 'saveOfflineData', 'OK', pathUser.path);
      return true;
    } catch(e) {
      Log.e(TAG, 'saveOfflineData', e);
      return false;
    }
  }
  static Future<bool> readOfflineData() async {
    try {
      File pathAnimes = _getDataFile(localPath, FILE_ANIMES);
      File pathUser = _getDataFile(localPath, FILE_USER);
      if (await pathAnimes.exists()) {
        String dataAnimes = await pathAnimes.readAsString();
        OnlineData.dd(jsonDecode(dataAnimes));
        Log.d(TAG, 'readOfflineData', 'animes', 'OK', pathAnimes.path);
      }
      if (await pathUser.exists()) {
        String dataUser = await pathUser.readAsString();
        User itemUser = User.fromJson(jsonDecode(dataUser));
        if (itemUser != null) {
          Firebase.user = itemUser;
          Firebase.organizarListas();
        }
        Log.d(TAG, 'readOfflineData', 'user', 'OK', pathUser.path);
      }

      return true;
    } catch(e) {
      Log.e(TAG, 'readOfflineData', e);
      return false;
    }
  }
  static Future<bool> deleteOfflineData() async {
    try {
      File fileUser = _getDataFile(localPath, FILE_USER);
      if (fileUser.existsSync())
        await fileUser.delete();
      File fileAnimes = _getDataFile(localPath, FILE_ANIMES);
      if (fileAnimes.existsSync())
        await fileAnimes.delete();
      Log.d(TAG, 'deleteOfflineData', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'deleteOfflineData', e);
      return false;
    }
  }
  static Future<bool> deletefile(String path, String fileName) async {
    try {
      File file = File('$path/$fileName');
      if (file.existsSync())
        await file.delete();
      Log.d(TAG, 'deletefile', 'OK', fileName);
      return true;
    } catch(e) {
      Log.e(TAG, 'deletefile', fileName, e);
      return false;
    }
  }

  static Future<String> _getDirectoryPath() async {
    Directory directory = await _getDirectory();
    return directory.path;
  }

  static Future<Directory> _getDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  static File _getDataFile(String path, String fileName) {
    String s = '$path/$fileName.json';
    return File(s);
  }

  static Future<void> createDataDirectory() async {
    Directory directory = await _getDirectory();
    Directory dir = Directory(directory.path + '/data');
    if (!dir.existsSync())
      await dir.create();
  }

  static Future<bool> downloadFile(String url, String path, String fileName, {bool override = false/*, ProgressCallback onProgress, CancelToken cancelToken*/}) async {
    if (url == null || url.isEmpty)
      return true;

    try {
      String _path = '$path/$fileName';
      File file = File(_path);
      if (await file.exists()) {
        if (override) {
          await file.delete();
        } else {
          return true;
        }
      }
      Log.d(TAG, 'downloadFile', 'Iniciando');
//      await _dio.download(url, _path, onReceiveProgress: onProgress, cancelToken: cancelToken);
      Log.d(TAG, 'downloadFile', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'downloadFile', e, url);
      return false;
    }
  }

  static Future<void> saveData(String data) async {
    var dir = await _getDirectoryPath();
    var fileName = DataHora.now() + '.txt';
    File file = File('$dir/$fileName');
    await file.writeAsString(data);
    Log.d(TAG, 'saveData', 'OK', fileName);
  }
}
