import 'package:anime/auxiliar/online_data.dart';
import 'package:anime/auxiliar/preferences.dart';
import 'package:anime/res/theme.dart';

class ListMode {
  static const int listValue = 430;
  static const int gridValue = 142;

  static ListMode get list => ListMode(listValue);
  static ListMode get grid => ListMode(gridValue);
  ListMode(this.value);
  int value;

  bool get isListMode => value == list.value;
  bool get isGridMode => value == grid.value;
}

class ListOrder {
  static const nome = 'Nome';
  static const dataAsc = 'Data Asc';
  static const dataDsc = 'Data Dsc';
}

class Config {
  static int _itemListMode;
  static String _filtro;
  static String _generos;
  static String _listOrder;
  static String _theme;
  static bool _showEcchi;

  //region get set

  static String get theme => _theme;
  static set theme(String value) {
    _theme = value;
    Preferences.setString(PreferencesKey.THEME, _theme);
  }
  static String get listOrder => _listOrder;
  static set listOrder(String value) {
    _listOrder = value;
    Preferences.setString(PreferencesKey.LIST_ORDER, _listOrder);
  }

  static ListMode get itemListMode => ListMode(_itemListMode);
  static set itemListMode(ListMode value) {
    _itemListMode = value.value;
    Preferences.setInt(PreferencesKey.ITEM_LIST_MODE, _itemListMode);
  }

  static String get filtro => _filtro ?? '#';
  static set filtro(String value) {
    _filtro = value;
    Preferences.setString(PreferencesKey.FILTRO, _filtro);
  }

  static String get generos => _generos ?? '';
  static set generos(String value) {
    _generos = value;
    Preferences.setString(PreferencesKey.GENEROS, _generos);
  }

  static bool get showEcchi => _showEcchi ?? false;
  static set showEcchi(bool value) {
    _showEcchi = value;
    Preferences.setBool(PreferencesKey.SHOW_ECCHI, _showEcchi);
  }

  //endregion

  static void readConfig() {
    _theme = Preferences.getString(PreferencesKey.THEME, padrao: ThemeMode.sistema);
    _listOrder = Preferences.getString(PreferencesKey.LIST_ORDER, padrao: ListOrder.dataDsc);
    _itemListMode = Preferences.getInt(PreferencesKey.ITEM_LIST_MODE, padrao: ListMode.listValue);
    _showEcchi = Preferences.getBool(PreferencesKey.SHOW_ECCHI, padrao: false);
    _generos = Preferences.getString(PreferencesKey.GENEROS, padrao: '');
    _filtro = Preferences.getString(PreferencesKey.FILTRO, padrao: '#');

    if (_generos.isEmpty) {
      for (String item in OnlineData.generos)
        _generos += '$item,';
    }
  }
}

class RunTime {
  static bool _updateAnimeFragment = false;
  static bool _changeListMode = false;
  static bool _generosAtualizados = false;
  static bool mostrandoAds = false;

  static set updateAnimeFragment(bool value) => _updateAnimeFragment = value;
  static bool get updateAnimeFragment {
    final b = _updateAnimeFragment;
    _updateAnimeFragment = false;
    return b;
  }

  static set changeListMode(bool value) => _changeListMode = value;
  static bool get changeListMode {
    final b = _changeListMode;
    _changeListMode = false;
    return b;
  }

  static set generosAtualizados(bool value) => _generosAtualizados = value;
  static bool get generosAtualizados {
    final b = _generosAtualizados;
    _generosAtualizados = false;
    return b;
  }
}