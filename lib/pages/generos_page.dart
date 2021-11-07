import 'package:flutter/material.dart';
import '../auxiliar/import.dart';
import '../manager/import.dart';
import '../res/import.dart';

class GenerosPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<GenerosPage> {

  //region variaveis

  AnimesManager get _animes => AnimesManager.i;
  SettingsManager get _settings => SettingsManager.i;

  bool _allSelected = true;
  bool _showSaveButton = false;
  final Map<String, bool> _data = Map();

  //endregion

  //region overrides

  @override
  void dispose() {
    AdMobManager.i.removeListener(_adMobChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animes.getGeneros().forEach((item) {
      var b = _settings.generos.contains(item);
      _data[item] = b;
      if (!b) _allSelected = false;
    });
    AdMobManager.i.addListener(_adMobChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Titles.GENEROS),
        actions: [
          Tooltip(
            message: _allSelected ? 'Desmarcar Tudo' : 'Marcar Tudo',
            child: Checkbox(
              value: _allSelected,
              onChanged: (value) {
                _onShowSaveButton(true);
                setState(() {
                  _allSelected = value;
                  for (var key in _data.keys)
                    _data[key] = _allSelected;
                });
              },
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 5))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 80),
        child: Column(
            children: [
              for (var key in _data.keys)
                CheckboxListTile(
                  title: Text(key),
                  value: _data[key],
                  onChanged: (value) {
                    _onShowSaveButton(true);
                    setState(() {
                      _data[key] = value;
                      _allSelected = isTudoSelecionado;
                    });
                  },
                ),
              AdsFooter()
            ]
        ),
      ),
      floatingActionButton: _showSaveButton ? AdsFooter(child: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: _onSave,
      )) : null,
    );
  }

  //endregion

  //region metodos

  bool get isTudoSelecionado {
    return _data.values.firstWhere((x) => !x, orElse: () => true);
  }

  void _adMobChanged(bool b) {//todo admob

  }

  void _onShowSaveButton(bool b) {
    setState(() {
      _showSaveButton = b;
    });
  }

  void _onSave() {
    List<String> temp = [];
    for (var key in _data.keys) {
      if (_data[key])
        temp.add(key);
    }
    _settings.generos = temp;

    Log.snack('Dados Salvos');

    _onShowSaveButton(false);
  }

  //endregion

}