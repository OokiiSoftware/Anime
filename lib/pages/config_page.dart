import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';
import 'admin_page.dart';

class ConfigPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<ConfigPage> {

  //region Variaveis
  static const String TAG = 'ConfigPage';

  bool _isAdmin = false;
  bool inProgress = false;
  bool _showEcchi = false;

  // List<DropdownMenuItem<String>> _dropDownThema;
  String _currentThema;

  ///Ordem de listagem dos animes
  // List<DropdownMenuItem<String>> _dropDownOrdem;
  String _currentOrdem;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _isAdmin = FirebaseOki.isAdmin;
    _showEcchi = Config.showEcchi;
    // _dropDownThema = Layouts.dropDownMenuItems(Arrays.thema);
    // _dropDownOrdem = Layouts.dropDownMenuItems(Arrays.ordem);
    _currentThema = Config.theme;
    _currentOrdem = Config.listOrder;
  }

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.all(Radius.circular(5));

    return Scaffold(
      appBar: AppBar(
        title: Text(Titles.CONFIGURACOES, style: Styles.titleText),
        actions: [
          if (_isAdmin)
            IconButton(
              tooltip: Titles.ADMIN,
              icon: Icon(Icons.admin_panel_settings),
              onPressed: _gotoAdminPage,
            ),
          // if (RunTime.semInternet)
          //   Layouts.icAlertInternet,
          // Layouts.appBarActionsPadding,
          // IconButton(
          //   tooltip: 'Informações',
          //     icon: Icon(Icons.info),
          //     onPressed: _onInfoClick
          // ),
          // IconButton(
          //   tooltip: Strings.LOGOUT,
          //   icon: Icon(Icons.logout),
          //   onPressed: _onLogout,
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: borderRadius,
              child: Container(
                color: OkiTheme.textInvert(0.2),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Theme
                    Row(
                      children: [
                        Text('Tema'),
                        Padding(padding: EdgeInsets.only(right: 10)),
                        DropDownMenu(
                          value: _currentThema,
                          items: Arrays.thema,
                          onChanged: _onThemeChanged,
                        ),
                      ],
                    ),
                    // Odem de listagem dos animes
                    Row(
                      children: [
                        Text('Ordem de listagem'),
                        Padding(padding: EdgeInsets.only(right: 10)),
                        DropDownMenu(
                          value: _currentOrdem,
                          items: Arrays.ordem,
                          onChanged: _onOrderChanged,
                        ),
                        IconButton(
                            icon: Icon(Icons.help),
                            onPressed: _onOrderHelpClick
                        )
                      ],
                    ),
                    Divider(),
                    CheckboxListTile(
                        title: Text('Mostrar animes com gênero Ecchi'),
                        value: _showEcchi,
                        onChanged: _onEcchiChanged
                    ),
                  ],
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(5)),
            //Sugestões
            ClipRRect(
              borderRadius: borderRadius,
              child: Container(
                color: OkiTheme.textInvert(0.2),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                        'Ajude-nos a melhorar enviando sugestões',
                        textAlign: TextAlign.center),
                    Divider(),
                    FlatButton(
                      minWidth: 200,
                      color: OkiTheme.accent,
                      child: Text(MyTexts.ANINE_SUGESTAO, style: Styles.text),
                      onPressed: () => _onSugestaoCkick(true),
                    ),
                    FlatButton(
                      minWidth: 200,
                      color: OkiTheme.accent,
                      child: Text(MyTexts.ENVIE_SUGESTAO, style: Styles.text),
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

  void onSalvar() async {
    Log.snack(MyTexts.DADOS_SALVOS);
  }

  void _onThemeChanged(String value) async {
    setState(() {
      _currentThema = value;
    });
    Config.theme = value;
    Brightness brightness = OkiTheme.getBrilho(value);
    await DynamicTheme.of(context).setBrightness(brightness);
  }
  void _onOrderChanged(String value) async {
    setState(() {
      _currentOrdem = value;
    });
    Config.listOrder = value;
  }
  void _onEcchiChanged(bool value) async {
    setState(() {
      _showEcchi = value;
    });
    Config.showEcchi = value;
  }

  void _onSugestaoCkick([bool isSugestaoAnime = false]) async {
    var controller = TextEditingController();
    var title = MyTexts.ENVIAR_SUGESTAO_TITLE;
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
    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);
    var desc = controller.text;
    if (result.isPositive && desc.trim().isNotEmpty) {
      Sugestao item = Sugestao();
      item.idUser = FirebaseOki.user.uid;
      item.data = DataHora.now();
      item.descricao = desc;

      _setInProgress(true);
      if (await item.salvar(isSugestaoAnime))
        Log.snack(MyTexts.ENVIE_SUGESTAO_AGRADECIMENTO);
      else
        Log.snack(MyErros.ERRO_GENERICO, isError: true);
      _setInProgress(false);
    }
  }

  void _gotoAdminPage() {
    Navigate.to(context, AdminPage());
  }

  void _onOrderHelpClick() {
    var title = 'Info';
    var content = [
      Text('Essa listagem não altera a ordem nas listas principais \'Assistindo, Favoritos, Concluidos e Online\''),
      Text('É alterada na lista de animes com várias temporadas')
    ];
    DialogBox.dialogOK(context, title: title, content: content);
  }

  void _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      inProgress = b;
    });
  }

  //endregion

}
