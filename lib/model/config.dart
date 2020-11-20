import 'package:anime/auxiliar/import.dart';
import 'package:anime/res/strings.dart';

class ItemListMode {
  static const int list = 0;
  static const int grid = 1;

  ItemListMode(this.value);
  int value;

  bool get isListMode => value == list;
  bool get isGridMode => value == grid;
}

class Config {
  static int _itemListMode;
  static String _filtro;
  static String _generos;
  static bool _showEcchi;

  static int get itemListMode => _itemListMode ?? ItemListMode.list;
  static set itemListMode(int value) {_itemListMode = value;}

  static String get filtro => _filtro ?? '#';
  static set filtro(String value) {_filtro = value;}

  static String get generos => _generos ?? '';
  static set generos(String value) {_generos = value;}

  static bool get showEcchi => _showEcchi ?? false;
  static set showEcchi(bool value) {_showEcchi = value;}

  static void readConfig() {
    _itemListMode = Import.sharedPreferences.getInt(SharedPrefKey.ITEM_LIST_MODE);
    _showEcchi = Import.sharedPreferences.getBool(SharedPrefKey.SHOW_ECCHI) ?? false;
    _generos = Import.sharedPreferences.getString(SharedPrefKey.GENEROS) ?? '';
    _filtro = Import.sharedPreferences.getString(SharedPrefKey.FILTRO) ?? '#';

    if (_generos.isEmpty) {
      for (String item in OnlineData.generos)
        _generos += '$item,';
    }
  }

  static void save() {
    Import.sharedPreferences.setInt(SharedPrefKey.ITEM_LIST_MODE, _itemListMode);
    Import.sharedPreferences.setString(SharedPrefKey.GENEROS, generos);
    Import.sharedPreferences.setString(SharedPrefKey.FILTRO, filtro);
    Import.sharedPreferences.setBool(SharedPrefKey.SHOW_ECCHI, showEcchi);
  }
}

class RunTime {
  static bool _updateAnimeFragment = false;
  static bool _changeListMode = false;
  static bool _generosAtualizados = false;

  static set updateAnimeFragment(bool value) {
    _updateAnimeFragment = value;
  }
  static bool get updateAnimeFragment {
    final b = _updateAnimeFragment;
    _updateAnimeFragment = false;
    return b;
  }

  static set changeListMode(bool value) {
    _changeListMode = value;
  }
  static bool get changeListMode {
    final b = _changeListMode;
    _changeListMode = false;
    return b;
  }

  static set generosAtualizados(bool value) {
    _generosAtualizados = value;
  }
  static bool get generosAtualizados {
    final b = _generosAtualizados;
    _generosAtualizados = false;
    return b;
  }
}