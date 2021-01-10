import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';

class OfflineData {
  static const String TAG = 'OfflineData';
  static const String FILE_USER = 'user';
  static const String FILE_ANIMES = 'animes';
  static String localPath = '';
 static Dio _dio = Dio();

  static Future<void> readDirectorys() async {
    String directory = await OfflineData._getDirectoryPath();
    localPath = directory + '/data';
  }

  static Future<bool> saveOfflineData() async {
//    await deleteOfflineData();
    try {
      // Log.d(TAG, 'saveOfflineData', 'Init', OnlineData.data);
      File fileUser = _getDataFile(localPath, FILE_USER);
      File fileAnimes = _getDataFile(localPath, FILE_ANIMES);
      String dataUser = jsonEncode(FirebaseOki.userOki.toJson());
      String dataAnimes = jsonEncode(OnlineData.data);
      await fileUser.writeAsString(dataUser);
      await fileAnimes.writeAsString(dataAnimes);
      Log.d(TAG, 'saveOfflineData', 'OK', fileUser.path);
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
        UserOki itemUser = UserOki.fromJson(jsonDecode(dataUser));
        if (itemUser != null) {
          FirebaseOki.userOki = itemUser;
          // FirebaseOki.organizarListas();
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
    Directory dir2 = Directory(directory.path + '/data/thumbnails');
    if (!dir.existsSync())
      await dir.create();
    if (!dir2.existsSync())
      await dir2.create();
  }

  static Future<bool> downloadFile(String url, String path, String fileName, {bool override = false, ProgressCallback onProgress, CancelToken cancelToken}) async {
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
     await _dio.download(url, _path, onReceiveProgress: onProgress, cancelToken: cancelToken);
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