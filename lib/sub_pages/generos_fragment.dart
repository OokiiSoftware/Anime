import 'package:anime/auxiliar/import.dart';
import 'package:anime/res/import.dart';

class GenerosFragment extends StatefulWidget {
  @override
  _MyState createState() => _MyState();
}
class _MyState extends State<GenerosFragment> {

  //region variaveis
  bool _allSelected = true;
  bool _mostrarFab = false;
  Map<String, bool> _data = Map();
  //endregion

  //region overrides
  @override
  void initState() {
    super.initState();
    for (var s in OnlineData.generos) {
      var b = Config.generos.contains(s);
      _data[s] = b;
      if (!b) _allSelected = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Titles.GENEROS, style: Styles.titleText),
        actions: [
          Tooltip(
            message: _allSelected ? 'Desmarcar Tudo' : 'Marcar Tudo',
            child: Checkbox(
              value: _allSelected,
              onChanged: (value) {
                _onMostrarFab(true);
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
                    _onMostrarFab(true);
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
      floatingActionButton: _mostrarFab ? AdsFooter(child: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: _onSave,
      )) : null,
    );
  }

  //endregion

  //region metodos

  bool get isTudoSelecionado {
    for (var key in _data.keys) {
      if (!_data[key]) return false;
    }
    return true;
  }

  void _onMostrarFab(bool b) {
    setState(() {
      _mostrarFab = b;
    });
  }

  void _onSave() {
    var temp = '';
    for (var key in _data.keys) {
      if (_data[key])
        temp += '$key,';
    }
    Config.generos = temp;
    RunTime.updateOnlineFragment = true;

    Log.snack('Dados Salvos');

    _onMostrarFab(false);
  }

  //endregion
}