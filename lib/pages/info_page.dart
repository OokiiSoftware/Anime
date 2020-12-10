import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';

class InfoPage extends StatefulWidget {
  @override
  _MyState createState() => _MyState();
}
class _MyState extends State<InfoPage> {

  //region Variaveis

  // static const String TAG = 'ConfigPage';

  bool showInfo = false;
  var titleStyle = TextStyle(fontSize: 20);

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    showInfo = Preferences.getBool(PreferencesKey.CONFIG_SHOW_INFO, padrao: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Titles.INFORMACOES, style: Styles.titleText)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            //Info
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: Container(
                color: OkiTheme.textInvert(0.05),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    GestureDetector(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${showInfo ? 'Ocultar' : 'Mostrar'} Info', style: titleStyle),
                          Padding(padding: EdgeInsets.all(5)),
                          Icon(showInfo ? Icons.arrow_circle_up : Icons.arrow_circle_down)
                        ],
                      ),
                      onTap: _onShowInfoClick,
                    ),

                    Divider(),
//                    Text('Disponibilizamos links no app para melhorar o seu uso.\nNão somos patrocinados.'),
                    if (showInfo)...[
                      Text('Esperamos que esse App seja útil a você e à comunidade Otaku.\n\nEstamos adicionando novos animes, seja paciente, se desejar pode sugerir seus animes favoritos e nós trabalharemos para adiciona-lo o mais rápido possível.\n\nOBS: Não disponibilizaremos animes com conteúdo impróprio.'),
                      _iconsInfo(),
                      // Divider(),
                      // _doacaoPix(),
                    ],
                  ],
                ),
              ),
            ),

            Padding(padding: EdgeInsets.only(top: 30)),
            _appInfo(),
            Padding(padding: EdgeInsets.only(top: 100)),

            AdsFooter()
          ],
        ),
      ),
    );
  }

  //endregion

  //region Metodos

  Widget _appInfo() {
    var dividerP = Padding(padding: EdgeInsets.only(top: 10, right: 5));
    var dividerG = Padding(padding: EdgeInsets.only(top: 30));
    return Column(children: [
      //Icone
      Image.asset(MyIcons.ic_launcher,
        width: 130,
        height: 130,
      ),
      dividerG,
      Text('${AppResources.APP_NAME}'),
      dividerP,
      Text('${Strings.VERSAO} : ${Aplication.packageInfo.version}'),
      dividerG,
      Text(Strings.CONTATOS),
      dividerP,
      GestureDetector(
        child: Text(AppResources.app_email, style: TextStyle(color: OkiTheme.primary)),
        onTap: () {Aplication.openEmail(AppResources.app_email, context);},
      ),
      dividerG,
      Text(Strings.POR),
      dividerP,
      Tooltip(
        message: AppResources.company_name,
        child: Image.asset(MyIcons.ic_oki_logo,
          width: 80,
          height: 80,
        ),
      ),
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
           Layouts.getAnimeTypeIcon(AnimeType.TV),
           Padding(
             padding: padding,
             child: Text('${AnimeType.TV}: Televisão'),
           )
         ]
       ),
       Row(
         children: [
           Layouts.getAnimeTypeIcon(AnimeType.OVA),
           Padding(
             padding: padding,
             child: Text('${AnimeType.OVA}: Original Video Animation'),
           )
         ]
       ),
       Row(
         children: [
           Layouts.getAnimeTypeIcon(AnimeType.ONA),
           Padding(
             padding: padding,
             child: Text('${AnimeType.ONA}: Original Net Animation'),
           )
         ]
       ),
       Row(
         children: [
           Layouts.getAnimeTypeIcon(AnimeType.MOVIE),
           Padding(
             padding: padding,
             child: Text('${AnimeType.MOVIE}: Filme'),
           )
         ]
       ),
       Row(
         children: [
           Layouts.getAnimeTypeIcon(AnimeType.SPECIAL),
           Padding(
             padding: padding,
             child: Text('${AnimeType.SPECIAL}: Especial'),
           )
         ]
       ),
       Row(
         children: [
           Layouts.getAnimeTypeIcon(AnimeType.INDEFINIDO),
           Padding(
             padding: padding,
             child: Text('${AnimeType.INDEFINIDO}: Indefinido'),
           )
         ]
       ),
      ]
    );
  }

  /*Widget _doacaoPix() {
    return Column(
      children: [
        Text('Doação', style: titleStyle),
        Padding(padding: EdgeInsets.all(5)),
        Text('Faça-nos uma doação através do pix'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Jonas S. Ferreira'),
            FlatButton(
              child: Text('Copiar chave Pix'),
              onPressed: () {
                ClipboardManager.copyToClipBoard(AppResources.pix).then((value) {
                  Log.snack('Pix copiado');
                }).catchError((e) {
                  Log.snack('Erro ao copiar o pix', isError: true);
                });
              },
            )
          ],
        )
      ]
    );
  }*/

  void _onShowInfoClick() {
    setState(() {
      showInfo = !showInfo;
    });
    Preferences.setBool(PreferencesKey.CONFIG_SHOW_INFO, showInfo);
  }

  //endregion

}