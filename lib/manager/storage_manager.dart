import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../auxiliar/import.dart';

class Directorys {
  static const String APP_FOLDER = 'Anime';
  static const String TEMP = 'temp';
  static const String POSTS = 'posts';
  static const String PREVIEWS = 'previews';
}

class StorageManager {

  static const _TAG = 'StorageManager';
  static StorageManager i = StorageManager();

  String localPath;
  String externalPath;

  Future<void> init() async {
    await _loadLocalPath();
    await _renameAppFolder();
    await createFolder(Directorys.PREVIEWS);
    await createFolder(Directorys.POSTS);
    await createFolder(Directorys.TEMP);
    Log.d(_TAG, 'init', 'OK');
  }

  Future<void> _loadLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    localPath = '${directory.path}$divider${Directorys.APP_FOLDER}';

    Directory directoryE;
    if (Platform.isWindows) {
      directoryE = directory;
    } else {
      directoryE = await getExternalStorageDirectory();
    }
    if (directoryE != null) {
      String path = directoryE.path.replaceAll('Android/data/com.ookiisoftware.anime/files', 'Pictures');
      externalPath = '$path$divider${Directorys.APP_FOLDER}';
    }
  }

  Future<Map<String, dynamic>> loadTest() async {
    Map<String, dynamic> map = {};

    int position = 0;
    try {
      try {
        var temp = await getTemporaryDirectory();
        map['temp'] = temp.path;
      } catch(e) {
        map['temp'] = e.toString();
      }
      position++;
      try {
        var suport = await getApplicationSupportDirectory();
        map['suport'] = suport.path;
      } catch(e) {
        map['suport'] = e.toString();
      }
      position++;
      try {
        var library = await getLibraryDirectory();
        map['library'] = library.path;
      } catch(e) {
        map['library'] = e.toString();
      }
      position++;
      try {
        var docs = await getApplicationDocumentsDirectory();
        map['docs'] = docs.path;
      } catch(e) {
        map['docs'] = e.toString();
      }
      position++;
      try {
        var external = await getExternalStorageDirectory();
        externalPath = external.path.replaceAll('Android/data/com.ookiisoftware.booru/files', 'booru');
        map['external'] = externalPath;
      } catch(e) {
        map['external'] = e.toString();
      }
      position++;
      try {
        var download = await getDownloadsDirectory();
        map['download'] = download.path;
      } catch(e) {
        map['download'] = e.toString();
      }
      position++;
      try {
        var cache = await getExternalCacheDirectories();
        map['cache'] = cache.asMap().toString();
      } catch(e) {
        map['cache'] = e.toString();
      }
      position++;
      try {
        var externals = await getExternalStorageDirectories();
        map['externals'] = externals.asMap().toString();
      } catch(e) {
        map['externals'] = e.toString();
      }
      position++;
    } catch(e) {
      map['ERROR'] = e.toString();
    }

    map['position'] = position.toString();
    return map;
  }

  String makePath(List<String> path) {
    return '$localPath$divider${path.join(divider)}';
  }

  Future<String> createFolder(String name, [bool external = false]) async {
    var temp = Directory('$localPath$divider$name');
    if (!await temp.exists()) {
      await temp.create(recursive: true);
    }
    return null;
  }

  void deleteFolder(String name) {
    var temp = Directory('$localPath$divider$name');
    if (temp.existsSync()) {
      temp.deleteSync(recursive: true);
    }
  }

  Directory getFolder(List<String> path, [bool external = false]) {
    return Directory('$localPath$divider${path.join(divider)}');
  }

  Future<bool> delete(String fileName, [String path]) async {
    if (fileExist(fileName, path))
      await file(fileName, path).delete();
    return true;
  }

  bool fileExist(String fileName, [String path]) => file(fileName, path).existsSync();

  File file(String fileName, [String path]) {
    if ( path == null || path.isEmpty)
      return File('$localPath$divider$fileName');
    return File('$localPath$divider$path$divider$fileName');
  }

  Future _renameAppFolder() async {
    Directory dir = getFolder(['thumbnails']);
    if (await dir.exists())
      await dir.rename(file(Directorys.PREVIEWS).path);
  }

  String get divider {
    return Platform.isWindows ? '\\': '/';
  }

}
