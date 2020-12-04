import 'package:anime/auxiliar/admin.dart';
import 'package:anime/auxiliar/online_data.dart';
import 'package:anime/model/anime.dart';
import 'package:anime/res/resources.dart';
import 'package:anime/res/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  @override
  MyPageState createState() => MyPageState();
}
class MyPageState extends State<AdminPage> {

  //region Variaveis
  static const String TAG = 'AdminPage';

  bool _inProgress = false;
  //endregion

  //region overrides

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Titles.ADMIN, style: Styles.titleText)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              child: Text('Atualizar Notas dos Animes'),
              onPressed: _atualizarNotasAnimes,
            ),
            Layouts.adsFooter()
          ],
        ),
      ),
      floatingActionButton: _inProgress ? Layouts.adsFooter(CircularProgressIndicator()) : null,
    );
  }

  //endregion

  //region Metodos

  void _atualizarNotasAnimes() async {
    _setInProgress(true);

    await OnlineData.baixarLista();
    await Admin.baixarUsers();
/*

    //Criar uma lista de classificações juntando todas as classificações de todos os animes
    //Ex: List<idAnime, <historia, list<valores>>>
    //region List<Categorias> animes = [];
    List<Categorias> animes = [];

    for (Anime item in getOnlineData.dataList) {
      String itemId = item.id;
      item.classificacao.votos = 0;

      for (User user in getAdmin.usersList) {
        Anime itemUser = user.concluidos[itemId];

        if (itemUser == null)
          continue;
        if (itemUser.classificacao.mediaValues(tudo: true).length == 0)
          continue;

        if (animes.where((x) => x.anime.id == itemUser.id).length == 0) {
          animes.add(Categorias(itemUser));
        }
        var anime = animes.firstWhere((x) => x.anime.id == itemId, orElse: null);

        var c = itemUser.classificacao;
        if (c.historia >= 0) anime.historia.add(c.historia);
        if (c.fim >= 0) anime.fim.add(c.fim);
        if (c.animacao >= 0) anime.animacao.add(c.animacao);
        if (c.ecchi >= 0) anime.ecchi.add(c.ecchi);
        if (c.comedia >= 0) anime.comedia.add(c.comedia);
        if (c.romance >= 0) anime.romance.add(c.romance);
        if (c.drama >= 0) anime.drama.add(c.drama);
        if (c.acao >= 0) anime.acao.add(c.acao);
        anime.votos++;
      }
    }
    //endregion

    //region Somar todos os valores de cada anime
    for (var anime in animes) {
      //region Variaveis
      double defValue = -1.0;
      double historiaV = defValue;
      double fimV = defValue;
      double animacaoV = defValue;
      double ecchiV = defValue;
      double comediaV = defValue;
      double romanceV = defValue;
      double dramaV = defValue;
      double acaoV = defValue;
      double terrorV = defValue;
      double aventuraV = defValue;
      //endregion

      //region Somar
      for (var i in anime.historia) historiaV = (historiaV == defValue) ? i : historiaV + i;
      for (var i in anime.fim) fimV = (fimV == defValue) ? i : fimV + i;
      for (var i in anime.animacao) animacaoV = (animacaoV == defValue) ? i : animacaoV + i;
      for (var i in anime.ecchi) ecchiV = (ecchiV == defValue) ? i : ecchiV + i;
      for (var i in anime.comedia) comediaV = (comediaV == defValue) ? i : comediaV + i;
      for (var i in anime.romance) romanceV = (romanceV == defValue) ? i : romanceV + i;
      for (var i in anime.drama) dramaV = (dramaV == defValue) ? i : dramaV + i;
      for (var i in anime.acao) acaoV = (acaoV == defValue) ? i : acaoV + i;
      for (var i in anime.terror) terrorV = (terrorV == defValue) ? i : terrorV + i;
      for (var i in anime.aventura) aventuraV = (aventuraV == defValue) ? i : aventuraV + i;
      //endregion

      //region Calcular a média
      if (anime.historia.length > 0) historiaV = historiaV/ anime.historia.length;
      if (anime.fim.length > 0) fimV = fimV/ anime.fim.length;
      if (anime.animacao.length > 0) animacaoV = animacaoV/ anime.animacao.length;
      if (anime.ecchi.length > 0) ecchiV = ecchiV/ anime.ecchi.length;
      if (anime.comedia.length > 0) comediaV = comediaV/ anime.comedia.length;
      if (anime.romance.length > 0) romanceV = romanceV/ anime.romance.length;
      if (anime.drama.length > 0) dramaV = dramaV/ anime.drama.length;
      if (anime.acao.length > 0) acaoV = acaoV/ anime.acao.length;
      if (anime.aventura.length > 0) aventuraV = aventuraV/ anime.aventura.length;
      if (anime.terror.length > 0) terrorV = terrorV/ anime.terror.length;
      //endregion

      //region Atribuir os novos valores ao anime
      String itemId = anime.anime.id;
      var c = getOnlineData.data[itemId].classificacao;
      c.historia = historiaV;
      c.fim = fimV;
      c.animacao = animacaoV;
      c.ecchi = ecchiV;
      c.comedia = comediaV;
      c.romance = romanceV;
      c.drama = dramaV;
      c.acao = acaoV;
      c.terror = terrorV;
      c.aventura = aventuraV;
      c.votos++;
      //endregion
    }
    //endregion

    //Salvar todos os valores
    for (Anime item in getOnlineData.dataList) {
      item.salvarAdmin();
    }
    Log.toast('Dados salvos');
    Log.d(TAG, 'atualizarAnimes', 'OK');
*/

    _setInProgress(false);
  }

  void _setInProgress(bool b) {
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}

class Categorias {
  Categorias(this.anime) {
    historia = List<double>();
    fim = List<double>();
    animacao = List<double>();
    ecchi = List<double>();
    comedia = List<double>();
    romance = List<double>();
    drama = List<double>();
    acao = List<double>();
    aventura = List<double>();
    terror = List<double>();
    votos = 0;
  }

  Anime anime;

  List<double> historia;
  List<double> fim;
  List<double> animacao;
  List<double> ecchi;
  List<double> comedia;
  List<double> romance;
  List<double> drama;
  List<double> acao;
  List<double> aventura;
  List<double> terror;
  int votos;
}