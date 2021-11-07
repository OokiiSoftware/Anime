import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../auxiliar/import.dart';

class Preferences {

  static const _TAG = 'Preferences';
  static Preferences pref = Preferences();

  SharedPreferences _instance;

  int getInt(String key, {int padrao = 0}) => _instance.getInt(key) ?? padrao;
  bool getBool(String key, {bool padrao = false}) => _instance.getBool(key) ?? padrao;
  String getString(String key, {String padrao = ''}) => _instance.getString(key) ?? padrao;
  double getDouble(String key, {double padrao = 0.0}) => _instance.getDouble(key) ?? padrao;
  List<String> getList(String key, {List<String> padrao = const []}) => _instance.getStringList(key) ?? padrao;
  dynamic getObj(String key) {
    var temp = getString(key);
    if (temp.isEmpty)
      return null;
    return jsonDecode(temp);
  }

  Future<bool> setInt(String key, int value) async => await _instance.setInt(key, value);
  Future<bool> setBool(String key, bool value) async => await _instance.setBool(key, value);
  Future<bool> setDouble(String key, double value) async => await _instance.setDouble(key, value);
  Future<bool> setString(String key, String value) async => await _instance.setString(key, value?? '');
  Future<bool> setList(String key, List<String> value) async => await _instance.setStringList(key, value);
  Future<bool> setObj(String key, dynamic value) async => await setString(key, json.encode(value));

  Future<bool> remove(String key) async => await _instance.remove(key);

  bool containsKey(String key) => _instance.containsKey(key);

  Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
    Log.d(_TAG, 'init', 'OK');
  }
}

class PreferencesKey {
  static const String EMAIL = "email";
  static const String DIA_PAGAMENTO = "dia_pagamento";
  static const String ULTIMO_TOKEM = "ultimo_tokem";
  static const String ULTIMO_TUTORIAL_OK = "01";
  static const String TUTORIAL_POSITION = "TUTORIAL_POSITION_";
  static const String UPDATE_NOTIFICATION = "UPDATE_NOTIFICATION_1";
  static const String USER_LOGADO = "USER_LOGADO";
  static const String MSG_DE_TESTES = "MSG_DE_TESTES";
  static const String THEME = "THEME";
  static const String CONFIG_SHOW_INFO = "CONFIG_SHOW_INFO";
  static const String ABRIR_CONFIG_PAGE = "ABRIR_CONFIG_PAGE";
  static const String LIST_ORDER = "LIST_ORDER_2";
  static const String PAGE_ANIME_DICA_DESLIZE = "PAGE_ANIME_DICA_DESLIZE";
  static const String PAGE_MAIN_DICA_FILTROS = "PAGE_MAIN_DICA_FILTROS_1";

  static const String FILTRO = 'filtro';
  static const String TUTORIAL = 'tutorial_01';
  static const String ITEM_LIST_MODE = 'itemListMode';
  static const String CURRENT_TAB_IN_MAIN_PAGE = 'CURRENT_TAB_IN_MAIN_PAGE';
  static const String GENEROS = 'generos_v2';
  static const String USE_NOVO_LAYOUT = 'USE_NOVO_LAYOUT';
  static const String SHOW_ECCHI = 'show_ecchi';

  static const String POST_AVANCADO = "POST_AVANCADO";
}
