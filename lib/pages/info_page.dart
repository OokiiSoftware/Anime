import 'package:flutter/material.dart';
import 'dart:io';
import '../manager/import.dart';
import '../res/import.dart';

class InfoPage extends StatefulWidget {
  @override
  _MyState createState() => _MyState();
}
class _MyState extends State<InfoPage> {

  //region Variaveis

  // ignore: unused_field
  static const String TAG = 'InfoPage';

  static bool _showInfo = false;
  var _titleStyle = TextStyle(fontSize: 20);

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
    AdMobManager.i.addListener(_adMobChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Titles.INFORMACOES)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            //Info
            ExpansionTile(
              initiallyExpanded: _showInfo,
              trailing: Icon(_showInfo ? Icons.arrow_circle_up : Icons.arrow_circle_down),
              title: Text('${_showInfo ? 'Ocultar' : 'Mostrar'} Info', style: _titleStyle),
              children: [
                _iconsInfo(),
              ],
              onExpansionChanged: (value) {
                setState(() {
                  _showInfo = value;
                });
              },
            ), // Info

            Divider(),

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

  void _adMobChanged(bool b) {//todo admob

  }

  Widget _appInfo() {
    var dividerP = Padding(padding: EdgeInsets.only(top: 10, right: 5));
    var dividerG = Padding(padding: EdgeInsets.only(top: 30));
    return Column(children: [
      //Icone
      Image.asset(MyIcons.ic_launcher_adaptive,
        width: 130,
        height: 130,
        color: OkiColors.primary,
      ),
      // dividerG,
      Text('${AppResources.APP_NAME}'),
      dividerP,
      if (Platform.isAndroid)
        Text('${Strings.VERSAO} : ${AplicationManager.i.packageInfo.version}'),
      dividerG,
      Text(Strings.CONTATOS),
      dividerP,
      GestureDetector(
        child: Text(AppResources.app_email, style: TextStyle(color: OkiColors.primary)),
        onTap: () {AplicationManager.i.openEmail(AppResources.app_email);},
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
            child: Text('Icones', style: _titleStyle),
          ),
          Row(
              children: [
                AnimeTypeIcon(value: AnimeType.TV),
                Padding(
                  padding: padding,
                  child: Text('${AnimeType.TV}: Televisão'),
                )
              ]
          ),
          Row(
              children: [
                AnimeTypeIcon(value: AnimeType.OVA),
                Padding(
                  padding: padding,
                  child: Text('${AnimeType.OVA}: Original Video Animation'),
                )
              ]
          ),
          Row(
              children: [
                AnimeTypeIcon(value: AnimeType.ONA),
                Padding(
                  padding: padding,
                  child: Text('${AnimeType.ONA}: Original Net Animation'),
                )
              ]
          ),
          Row(
              children: [
                AnimeTypeIcon(value: AnimeType.MOVIE),
                Padding(
                  padding: padding,
                  child: Text('${AnimeType.MOVIE}: Filme'),
                )
              ]
          ),
          Row(
              children: [
                AnimeTypeIcon(value: AnimeType.SPECIAL),
                Padding(
                  padding: padding,
                  child: Text('${AnimeType.SPECIAL}: Especial'),
                )
              ]
          ),
          Row(
              children: [
                AnimeTypeIcon(value: AnimeType.INDEFINIDO),
                Padding(
                  padding: padding,
                  child: Text('${AnimeType.INDEFINIDO}: Indefinido'),
                )
              ]
          ),
        ]
    );
  }

  //endregion

}