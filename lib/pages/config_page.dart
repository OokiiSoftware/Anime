import 'package:flutter/material.dart';
import '../auxiliar/import.dart';
import '../manager/import.dart';
import '../model/import.dart';
import '../res/import.dart';
import 'import.dart';

class ConfigPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<ConfigPage> {

  //region Variaveis

  // ignore: unused_field
  static const String TAG = 'ConfigPage';

  bool _isAdmin = false;
  bool inProgress = false;

  ThemeManager get _theme => ThemeManager.i;
  SettingsManager get _settings => SettingsManager.i;
  String _currentOrdem;

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
    // _isAdmin = AdminManager.i.isAdmin;
    // _currentOrdem = ConfigManager.i.listOrder;
    AdMobManager.i.addListener(_adMobChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Titles.CONFIGURACOES),
        actions: [
          if (_isAdmin)
            IconButton(
              tooltip: Titles.ADMIN,
              icon: Icon(Icons.admin_panel_settings),
              onPressed: _gotoAdminPage,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: OkiDropDown(
                text: 'Tema',
                value: _theme.themeModeString,
                items: Arrays.thema,
                onChanged: _onThemeChanged,
              ),
            ),

            Card(
              child: CheckboxListTile(
                  title: Text('Menu lateral na tela principal'),
                  value: _settings.useNewLayout,
                  onChanged: _onLayoutChanged
              ),
            ),

            Padding(padding: EdgeInsets.all(5)),
            //Sugestões
            Card(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Ajude-nos a melhorar enviando sugestões',
                      textAlign: TextAlign.center,
                    ),
                    Divider(),
                    TextButton(
                      // minWidth: 200,
                      // color: OkiColors.accent,
                      child: Text(MyTexts.ANINE_SUGESTAO),
                      onPressed: () => _onSugestaoCkick(true),
                    ),
                    TextButton(
                      // minWidth: 200,
                      // color: OkiColors.accent,
                      child: Text(MyTexts.ENVIE_SUGESTAO),
                      onPressed: _onSugestaoCkick,
                    ),
                  ],
                ),
              ),
            ),
            AdsFooter()
          ],
        ),
      ),
      floatingActionButton: inProgress ? AdsFooter(child: CircularProgressIndicator()) : null,
    );
  }

  //endregion

  //region Metodos

  void _adMobChanged(bool b) {//todo admob

  }

  void onSalvar() async {
    Log.snack(MyTexts.DADOS_SALVOS);
  }

  void _onThemeChanged(String value) async {
    setState(() {
      _theme.setThemeMode(value);
    });
  }
  void _onOrderChanged(String value) async {
    setState(() {
      _currentOrdem = value;
    });
  }
  void _onLayoutChanged(bool value) async {
    setState(() {
      _settings.useNewLayout = value;
    });
  }

  void _onSugestaoCkick([bool isSugestaoAnime = false]) async {
    var controller = TextEditingController();
    var title = isSugestaoAnime ? MyTexts.ANINE_SUGESTAO : MyTexts.ENVIAR_SUGESTAO_TITLE;
    var content = [
      if (isSugestaoAnime)
        Text('Insira corretamente o nome completo do anime'),
      TextField(
        controller: controller,
        decoration: InputDecoration(
            hintText: MyTexts.DIGITE_AQUI
        ),
      )
    ];
    var result = await DialogBox(context: context, title: title, content: content,).cancelOK();
    var desc = controller.text;
    if (result.isPositive && desc.trim().isNotEmpty) {
      // Sugestao item = Sugestao();
      // item.idUser = FirebaseManager.i.user.uid;//todo
      // item.data = DataHora.now();
      // item.descricao = desc;

      // _setInProgress(true);
      // if (await item.salvar(isSugestaoAnime))
      //   Log.snack(MyTexts.ENVIE_SUGESTAO_AGRADECIMENTO);
      // else
      //   Log.snack(MyErros.ERRO_GENERICO, isError: true);
      // _setInProgress(false);
    }
  }

  void _gotoAdminPage() {
    // Navigate.to(context, AdminPage());
  }

  void _onOrderHelpClick() {
    var title = 'Info';
    var content = [
      Text('Essa listagem não altera a ordem nas listas principais \'Assistindo, Favoritos, Concluidos e Online\''),
      Text('É alterada na lista de animes com várias temporadas')
    ];
    DialogBox(context: context, title: title, content: content,).ok();
  }

  void _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      inProgress = b;
    });
  }

  //endregion

}
