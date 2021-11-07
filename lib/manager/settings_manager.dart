import 'import.dart';

class SettingsManager {
  static const String _LIST_MODE_KEY = '_LIST_MODE_KEY';
  static const String _GENEROS_KEY = '_GENEROS_KEY';
  static const String _LAYOUT_KEY = '_LAYOUT_KEY';
  static const String _FILTRO_KEY = '_FILTRO_KEY';

  static SettingsManager i = SettingsManager();

  Preferences get _pref => Preferences.pref;

  bool get useNewLayout => _pref.getBool(_LAYOUT_KEY, padrao: true);
  String get filtro => _pref.getString(_FILTRO_KEY, padrao: '#');
  List<String> get generos => _pref.getList(_GENEROS_KEY);
  AnimeListMode get listMode => AnimeListMode(_pref.getInt(_LIST_MODE_KEY));

  set filtro(String value) {
    _pref.setString(_FILTRO_KEY, value);
    _callFiltroListener(value);
  }
  set useNewLayout(bool value) {
    _pref.setBool(_LAYOUT_KEY, value);
    _callLayoutListener(value);
  }
  set generos(List<String> value) {
    _pref.setList(_GENEROS_KEY, value);
    _callGenerosListener(value);
  }
  set listMode(AnimeListMode value) {
    _pref.setInt(_LIST_MODE_KEY, value.value);
    _callListModeListener(value);
  }

  final List<Function(bool)> _layoutChangeListener = [];
  final List<Function(String)> _filtroChangeListener = [];
  final List<Function(List<String>)> _generosChangeListener = [];
  final List<Function(AnimeListMode)> _listModeChangeListener = [];

  void addListModeListener(Function(AnimeListMode) item) {
    if (!_listModeChangeListener.contains(item))
      _listModeChangeListener.add(item);
  }
  void removeListModeListener(Function(AnimeListMode) item) {
    _listModeChangeListener.remove(item);
  }
  void _callListModeListener(AnimeListMode list) {
    _listModeChangeListener.forEach((item) {
      item.call(list);
    });
  }

  void addFiltroListener(Function(String) filtro) {
    if (!_filtroChangeListener.contains(filtro))
      _filtroChangeListener.add(filtro);
  }
  void removeFiltroListener(Function(String) filtro) {
    _filtroChangeListener.remove(filtro);
  }
  void _callFiltroListener(String filtro) {
    _filtroChangeListener.forEach((item) {
      item.call(filtro);
    });
  }

  void addGenerosListener(Function(List<String> ) filtro) {
    if (!_generosChangeListener.contains(filtro))
      _generosChangeListener.add(filtro);
  }
  void removeGenerosListener(Function(List<String> ) filtro) {
    _generosChangeListener.remove(filtro);
  }
  void _callGenerosListener(List<String>  filtro) {
    _generosChangeListener.forEach((item) {
      item.call(filtro);
    });
  }

  void addLayoutListener(Function(bool) useNew) {
    if (!_layoutChangeListener.contains(useNew))
      _layoutChangeListener.add(useNew);
  }
  void removeLayoutListener(Function(bool) useNew) {
    _layoutChangeListener.remove(useNew);
  }
  void _callLayoutListener(bool useNew) {
    _layoutChangeListener.forEach((item) {
      item.call(useNew);
    });
  }
}