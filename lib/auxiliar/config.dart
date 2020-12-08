import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';

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
    _theme = Preferences.getString(PreferencesKey.THEME, padrao: OkiThemeMode.sistema);
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
  static bool _updateOnlineFragment = false;
  static bool _updateAssistindoFragment = false;
  static bool _updateFavoritosFragment = false;
  static bool _updateConcluidosFragment = false;
  static bool _changeListMode = false;
  static bool mostrandoAds = false;
  static bool isOnline = false;

  static void updateFragment(ListType listType) {
    switch(listType.value) {
      case ListType.assistindoValue:
        RunTime.updateAssistindoFragment = true;
        break;
      case ListType.favoritosValue:
        RunTime.updateFavoritosFragment = true;
        break;
      case ListType.concluidosValue:
        RunTime.updateConcluidosFragment = true;
        break;
    }
  }

  static set updateOnlineFragment(bool value) => _updateOnlineFragment = value;
  static bool get updateOnlineFragment {
    final b = _updateOnlineFragment;
    _updateOnlineFragment = false;
    return b;
  }
  static set updateAssistindoFragment(bool value) => _updateAssistindoFragment = value;
  static bool get updateAssistindoFragment {
    final b = _updateAssistindoFragment;
    _updateAssistindoFragment = false;
    return b;
  }
  static set updateFavoritosFragment(bool value) => _updateFavoritosFragment = value;
  static bool get updateFavoritosFragment {
    final b = _updateFavoritosFragment;
    _updateFavoritosFragment = false;
    return b;
  }
  static set updateConcluidosFragment(bool value) => _updateConcluidosFragment = value;
  static bool get updateConcluidosFragment {
    final b = _updateConcluidosFragment;
    _updateConcluidosFragment = false;
    return b;
  }

  static set changeListMode(bool value) => _changeListMode = value;
  static bool get changeListMode {
    final b = _changeListMode;
    _changeListMode = false;
    return b;
  }

}