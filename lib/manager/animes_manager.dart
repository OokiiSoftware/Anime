import '../auxiliar/import.dart';
import '../model/import.dart';
import 'import.dart';

class AnimesManager {
  static AnimesManager i = AnimesManager();

  static const String _TAG = 'AnimesManager';
  static const String ROOT_ID = 'Anime';
  static const String _OFF_DATA_KEY = 'DATA_KEY';

  FirebaseManager get _firebase => FirebaseManager.i;
  Preferences get _pref => Preferences.pref;

  final Anime _onlineData = Anime();
  final List<String> _generos = [];

  bool sincronizado = false;

  List<Anime> get dataAnimes {
    final List<Anime> items = [];
    _onlineData.values.forEach((item) {
      items.addAll(item.values);
    });
    return items..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  }

  Anime get(String key) => _onlineData[key];

  List<String> getGeneros() => [..._generos].toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  Anime getFavoritos() {
    final temp = _onlineData.where((item) => item.containsFavorite);
    final a = Anime(parent: _onlineData);
    temp.forEach((item) {
      a.add(item);
    });
    return a;
  }

  Anime getList({String filtro}) {
    final temp = _onlineData;
    final a = Anime(parent: _onlineData);
    temp.forEach((key, item) {
      a.add(item);
    });
    _applyFiltro(a, filtro);
    _applyGeneros(a);
    return a;
  }

  void _applyFiltro(Anime list, String filtro) {
    if (filtro != null && filtro != '#') {
      if (filtro.contains('-')) {
        List<String> sp = filtro.toLowerCase().split('-').toSet().toList()..sort((a, b) => a.compareTo(b));
        String init = sp[0] ?? '';
        String fim = sp[1] ?? 'z';

        if (init.isEmpty) init = '';
        if (fim.isEmpty) fim = 'z';

        list.removeWhere((k, x) {
          if (x.nome.toLowerCase().compareTo(init) == -1 || x.nome.toLowerCase().compareTo('${fim}zzz') == 1)
            return true;

          return false;
        });

      } else if (filtro.contains(',')) {
        List<String> sp = filtro.toLowerCase().split(',').toSet().toList()..sort((a, b) => a.compareTo(b));
        List<String> ids = [];
        list.removeWhere((k, x) {
          for (String s in sp) {
            if (ids.contains(k))
              return false;

            if (x.nome.toLowerCase().startsWith(s)) {
              ids.add(k);
              return false;
            }
          }
          return true;
        });
      } else {
        try {
          if (filtro.length != 4) throw ('');
          int i = int.parse(filtro);
          if (i == 0) {
            list.removeWhere(((k, x) => x.values.where((e) => e.isNoLancado).length <= 0));
          } else {
            list.removeWhere((k, x) => x.values.where((e) => e.data.contains(filtro)).length <= 0);
          }
        } catch(e) {
          list.removeWhere((k, x) => !x.nome.toUpperCase().startsWith(filtro.toUpperCase()));
        }
      }
    }
  }

  void _applyGeneros(Anime list) {
    var generos = SettingsManager.i.generos;
    list.removeWhere((key, item) {
      bool remove = true;
      if (item.length > 0) {
        for (var s in item.generos) {
          if (generos.contains(s)) {
            remove = false;
            break;
          }
        }
      }
      return remove;
    });
  }

  void save() {
    _pref.setObj(_OFF_DATA_KEY, _toJson(_onlineData));
    Log.d(_TAG, 'save', 'ok');
  }

  Future<void> sincronizar() async {
    var snapshot = await _firebase.database
        .child(FirebaseChild.ANIME)
        .child(FirebaseChild.BASICO)
        .once();

    final list = Anime.fromJsonList(snapshot.value, _onlineData);
    list.forEach((key, value) {
      final copy = _onlineData[key];
      _onlineData.add(value);
      if (copy != null && copy.containsFavorite)
        _onlineData.get(key).apply(copy);
    });
    sincronizado = true;
  }

  void load() {
    try {
      _generos.clear();
      _generos.addAll(SettingsManager.i.generos);

      Map on = _pref.getObj(_OFF_DATA_KEY) ?? Map();
      _onlineData.addAll(Anime.fromJsonList(on, _onlineData));

      //region simulação do firebase

      // Map temp = database['basico'];
      // final list = Anime.fromJsonList(temp, _onlineData);
      // list.forEach((key, value) {
      //   final copy = _onlineData[key];
      //   _onlineData.add(value);
      //   if (copy != null && copy.containsFavorite)
      //     _onlineData.get(key).apply(copy);
      // });

      //endregion

      Log.d(_TAG, 'load', 'OK');
    } catch (e) {
      Log.e(_TAG, 'load', e);
    }
  }

  Map<String, dynamic> _toJson(Map<String, Anime> value) {
    Map<String, dynamic> items = {};
    value.forEach((key, value) {
      items[key] = value.toJson();
    });
    return items;
  }
}

class AnimeListMode {
  static const int listValue = 10;
  static const int gridValue = 41;

  static AnimeListMode get list => AnimeListMode(listValue);
  static AnimeListMode get grid => AnimeListMode(gridValue);

  AnimeListMode(this.value);
  int value;

  bool get isList => value == list.value;
  bool get isGrid => value == grid.value;
}

class AnimeType {
  static const String TV = 'TV';
  static const String OVA = 'OVA';
  static const String ONA = 'ONA';
  static const String MOVIE = 'MOVIE';
  static const String SPECIAL = 'SPECIAL';
  static const String INDEFINIDO = 'INDEFINIDO';
}