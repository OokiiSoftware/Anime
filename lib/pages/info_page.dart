import 'package:anime/auxiliar/import.dart';
import 'package:anime/auxiliar/firebase.dart';
import 'package:anime/auxiliar/logs.dart';
import 'package:anime/model/anime.dart';
import 'package:anime/model/config.dart';
import 'package:anime/model/data_hora.dart';
import 'package:anime/model/feedback.dart';
import 'package:anime/res/dialog_box.dart';
import 'package:anime/res/my_icons.dart';
import 'package:anime/res/resources.dart';
import 'package:anime/pages/login_page.dart';
import 'package:anime/res/strings.dart';
import 'package:anime/res/theme.dart';
import 'file:///C:/Users/jhona/Documents/GitHub/anime/lib/pages/admin_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  @override
  MyPageState createState() => MyPageState();
}
class MyPageState extends State<InfoPage> {

  //region Variaveis

  static const String TAG = 'ConfigPage';

  bool _inProgress = false;
  bool _isAdmin = false;
  bool _showEcchi = false;

  var titleStyle = TextStyle(fontSize: 20);

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _isAdmin = Firebase.isAdmin;
    _showEcchi = Config.showEcchi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(MyTitles.INFORMACOES, style: MyStyles.titleText),
        actions: [
          if (_isAdmin)
            IconButton(
              tooltip: MyTitles.ADMIN,
              icon: Icon(Icons.admin_panel_settings),
              onPressed: _gotoAdminPage,
            ),
          IconButton(
            tooltip: MyStrings.LOGOUT,
            icon: Icon(Icons.logout),
            onPressed: onLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            //Info
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: Container(
                color: MyTheme.textInvert(0.05),
                padding: EdgeInsets.all(10),
                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Info', style: titleStyle),
                    Divider(),
//                    Text('Disponibilizamos links no app para melhorar o seu uso.\nNão somos patrocinados.'),
                    Text('Esperamos que esse App seja útil a você e à comunidade Otaku.\n\nEstamos adicionando novos animes, seja paciente, se desejar pode sugerir seus animes favoritos e nós trabalharemos para adiciona-lo o mais rápido possível.\n\nOBS: Não disponibilizaremos animes com conteúdo improprio.'),
                    _iconsInfo(),
                  ],
                ),
              ),
            ),

            Padding(padding: EdgeInsets.all(10)),
            //Sugestões
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: Container(
                color: MyTheme.textInvert(0.05),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                        'Ajude-nos a melhorar enviando sugestões',
                        textAlign: TextAlign.center),
                    Divider(),
                    FlatButton(
                      minWidth: 200,
                      color: MyTheme.accent(),
                      child: Text(MyTexts.ANINE_SUGESTAO, style: MyStyles.text),
                      onPressed: () => onSugestao(true),
                    ),
                    FlatButton(
                      minWidth: 200,
                      color: MyTheme.accent(),
                      child: Text(MyTexts.ENVIE_SUGESTAO, style: MyStyles.text),
                      onPressed: onSugestao,
                    ),
                  ],
                ),
              ),
            ),

            CheckboxListTile(
              title: Text('Mostrar animes com gênero Ecchi'),
                value: _showEcchi,
                onChanged: (value) {
                  setState(() {
                    _showEcchi = value;
                    Config.showEcchi = value;
                    Config.save();
                  });
                }
            ),

            Padding(padding: EdgeInsets.only(top: 30)),
            _appInfo()
          ],
        ),
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
    );
  }

  //endregion

  //region Metodos

  Widget _appInfo() {
    var divider = Divider(height: 30, color: MyTheme.background());
    return Column(children: [
      //Icone
      Image.asset(MyIcons.ic_launcher,
        width: 130,
        height: 130,
      ),
      divider,
      Text('${MyStrings.VERSAO} : ${Import.packageInfo.version}'),
      divider,
      Text(MyStrings.CONTATOS),
      GestureDetector(
        child: Text(MyResources.app_email, style: TextStyle(color: MyTheme.primary())),
        onTap: () {Import.openEmail(MyResources.app_email, context);},
      ),
      Divider(height: 30),
      Text(MyStrings.POR),
      Text(MyResources.company_name),
    ]);
  }

  Widget _iconsInfo() {
    var padding = EdgeInsets.symmetric(horizontal: 10, vertical: 5);

    return Column(
      children: [
        Padding(
          padding: padding,
          child: Text('Icones', style: titleStyle),
        ),
       Row(
         children: [
           MyLayouts.getIcon(AnimeTipo.TV),
           Padding(
             padding: padding,
             child: Text('${AnimeTipo.TV}: Televisão'),
           )
         ]
       ),
       Row(
         children: [
           MyLayouts.getIcon(AnimeTipo.OVA),
           Padding(
             padding: padding,
             child: Text('${AnimeTipo.OVA}: Original Video Animation'),
           )
         ]
       ),
       Row(
         children: [
           MyLayouts.getIcon(AnimeTipo.ONA),
           Padding(
             padding: padding,
             child: Text('${AnimeTipo.ONA}: Original Net Animation'),
           )
         ]
       ),
       Row(
         children: [
           MyLayouts.getIcon(AnimeTipo.MOVIE),
           Padding(
             padding: padding,
             child: Text('${AnimeTipo.MOVIE}: Filme'),
           )
         ]
       ),
       Row(
         children: [
           MyLayouts.getIcon(AnimeTipo.SPECIAL),
           Padding(
             padding: padding,
             child: Text('${AnimeTipo.SPECIAL}: Especial'),
           )
         ]
       ),
       Row(
         children: [
           MyLayouts.getIcon(AnimeTipo.INDEFINIDO),
           Padding(
             padding: padding,
             child: Text('${AnimeTipo.INDEFINIDO}: Indefinido'),
           )
         ]
       ),
      ]
    );
  }

  void onSugestao([bool isSugestaoAnime = false]) async {
    var controller = TextEditingController();
    var title = MyTexts.ENVIAR_SUGESTAO_TITLE;
    var content = SingleChildScrollView(
      child: Column(
        children: [
          if (isSugestaoAnime)
            Text('Insira corretamente o nome completo do anime'),
          TextField(
            controller: controller,
            decoration: InputDecoration(
                hintText: MyTexts.DIGITE_AQUI
            ),
          )
        ],
      ),
    );
    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);
    var desc = controller.text;
    if (result.isOK && desc.trim().isNotEmpty) {
      Sugestao item = Sugestao();
      item.idUser = Firebase.fUser.uid;
      item.data = DataHora.now();
      item.descricao = desc;

      _setInProgress(true);
      await item.salvar(isSugestaoAnime);
      _setInProgress(false);
      Log.snack(MyTexts.ENVIE_SUGESTAO_AGRADECIMENTO);
    }
  }

  void onLogout() async {
    _setInProgress(true);
    await Firebase.finalize();
    Navigate.toReplacement(context, LoginPage());
  }

  void _gotoAdminPage() {
    Navigate.to(context, AdminPage());
  }

  void _setInProgress(bool b) {
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}