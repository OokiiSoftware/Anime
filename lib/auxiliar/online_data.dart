import 'package:anime/model/anime.dart';
import 'package:anime/model/config.dart';
import 'firebase.dart';
import 'logs.dart';
import 'offline_data.dart';

class OnlineData {
  static const String TAG = 'OnlineData';
  static bool isOnline = false;

  static Map<String, AnimeList> _data = new Map();
  static List<String> _generos = [];

  static Map<String, AnimeList> get data => _data;
  static List get generos => _generos..sort((a, b) => a.compareTo(b));
  static List<AnimeList> get dataList =>
      _data.values.where(_whereDataList).toList()..sort(_comparatorDataList);

  static bool _whereDataList(AnimeList data) {
    bool containsEcchi = data.generos.contains('Ecchi') || data.generos.contains('ecchi');
    bool add = false;
    if (data.items.length == 0)
      add = true;
    for (var s in data.generos) {
      if (Config.generos.contains(s)) {
        add = true;
        break;
      }
    }
    return (!containsEcchi || Config.showEcchi) && add;
  }
  static int _comparatorDataList(AnimeList a, AnimeList b) {
    return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    /*switch(Config.listOrder) {
      case ListOrder.nome:
        return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      case ListOrder.dataAsc:
        return a.anoInicio.toLowerCase().compareTo(b.anoInicio.toLowerCase());
      default:
        return b.anoInicio.toLowerCase().compareTo(a.anoInicio.toLowerCase());
    }*/
  }

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

  /*static bool _teste(List<dynamic> data) {
    if (data.length == 0)
      return true;
    for (var s in data) {
      if (Config.generos.contains(s))
        return true;
    }
    return false;
  }*/

  static Future<void> baixarLista() async {
    try {
      var snapshot = await FirebaseOki.database
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
