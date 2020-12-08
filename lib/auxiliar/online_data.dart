import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'firebase.dart';
import 'logs.dart';
import 'offline_data.dart';

class OnlineData {
  static const String TAG = 'OnlineData';

  static final Map<String, AnimeCollection> _data = new Map();
  static final List<String> _generos = [];

  static Map<String, AnimeCollection> get data => _data;
  static List get generos => _generos..sort((a, b) => a.compareTo(b));
  static List<AnimeCollection> get dataList =>
      _data.values.where(_whereDataList).toList()..sort(_comparatorDataList);

  static bool _whereDataList(AnimeCollection data) {
    bool containsEcchi = data.generos.contains('Ecchi') || data.generos.contains('ecchi');
    bool add = false;
    final generos = Config.generos;
    // if (data.items.length == 0)
    //   add = true;
    if (data.items.length > 0) {
      for (var s in data.generos) {
        if (generos.contains(s)) {
          add = true;
          break;
        }
      }
    }
    return (!containsEcchi || Config.showEcchi) && add;
  }
  static int _comparatorDataList(AnimeCollection a, AnimeCollection b) =>
      a.nome.toLowerCase().compareTo(b.nome.toLowerCase());

  static List<Anime> get dataAnimes {
    final List<Anime> data = [];
    for (AnimeCollection items in dataList)
      data.addAll(items.itemsToList);
    return data;
  }

  static Future<AnimeCollection> get(String key) async {
    var item = _data[key];
    if (!item.isCompleto) {
      await item.completar();
    }
    return _data[key];
  }
  static AnimeCollection getAsync(String key) => _data[key];
  static void add(AnimeCollection item) {
    _data[item.id] = item;
    for(var i in item.items.values)
      for (String j in i.generos)
        if (!_generos.contains(j) && j.toLowerCase() != 'ecchi')
          _generos.add(j);
  }
  static void addAll(Map<String, AnimeCollection> items) => _data.addAll(items);
  static void remove(String key) => _data.remove(key);

  static void reset() {
    _data.clear();
    _generos.clear();
  }

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
    for (AnimeCollection items in dataList) {
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
        AnimeCollection item = AnimeCollection.fromJson(map[key], key);
        add(item);
      } catch(e) {
        Log.e(TAG, 'dd', e);
        continue;
      }
    }
  }
}
