import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences instance;
  dynamic get(String key) => instance.get(key);

  static bool getBool(String key, {bool padrao = false}) => instance.getBool(key) ?? padrao;
  static int getInt(String key, {int padrao = 0}) => instance.getInt(key) ?? padrao;
  static double getDouble(String key, {double padrao = 0.0}) => instance.getDouble(key) ?? padrao;
  static String getString(String key, {String padrao = ''}) => instance.getString(key) ?? padrao;

  static Future<bool> setBool(String key, bool value) async => await instance.setBool(key, value);
  static Future<bool> setInt(String key, int value) async => await instance.setInt(key, value);
  static Future<bool> setDouble(String key, double value) async => await instance.setDouble(key, value);
  static Future<bool> setString(String key, String value) async => await instance.setString(key, value);

  static bool containsKey(String key) => instance.containsKey(key);
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

  static const String FILTRO = 'filtro';
  static const String TUTORIAL = 'tutorial_01';
  static const String ITEM_LIST_MODE = 'itemListMode';
  static const String GENEROS = 'generos';
  static const String SHOW_ECCHI = 'show_ecchi';

  static const String POST_AVANCADO = "POST_AVANCADO";
}
