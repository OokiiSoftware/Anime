import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';

class AdminPage extends StatefulWidget {
  @override
  _MyState createState() => _MyState();
}
class _MyState extends State<AdminPage> {

  //region Variaveis
  static const String TAG = 'AdminPage';

  bool _inProgress = false;
  //endregion

  //region overrides

  @override
  Widget build(BuildContext context) {
    var divider = Divider(color: OkiTheme.primary);

    return Scaffold(
      appBar: AppBar(title: Text(Titles.ADMIN, style: Styles.titleText)),
      body: SingleChildScrollView(
        padding: Layouts.adsPadding(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              child: Text('Atualizar Notas dos Animes'),
              onPressed: _atualizarNotasAnimes,
            ),
            ElevatedButton(
              child: Text('Excluir Testes do banco de dados'),
              onPressed: _delete,
            ),
            divider,
            ElevatedButton(
              child: Text('App Versão: ${Aplication.appVersionInDatabase}'),
              onPressed: !_inProgress ? _setAppVersao : null,
            ),
            ElevatedButton(
              child: Text('Abrir Play Story'),
              onPressed: () {
                Aplication.openUrl(AppResources.playStoryLink, context);
              },
            ),
            divider,
            ElevatedButton(
              child: Text('SnackBar'),
              onPressed: () {
                Log.snack('Teste de snackbar');
              },
            ),
            ElevatedButton(
              child: Text('SnackBar Erro'),
              onPressed: () {
                Log.snack('Teste de snackbar erro', isError: true);
              },
            ),
            ElevatedButton(
              child: Text('Ads: ${RunTime.mostrandoAds ? 'On' : 'Off'}'),
              onPressed: () {
                setState(() {
                  RunTime.mostrandoAds = !RunTime.mostrandoAds;
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: _inProgress ? AdsFooter(child: CircularProgressIndicator()) : null,
    );
  }

  //endregion

  //region Metodos

  void _atualizarNotasAnimes() async {
    _setInProgress(true);

    await OnlineData.baixarLista();
    await Admin.baixarUsers();

    //Criar uma lista de classificações juntando todas as classificações de todos os animes
    //Ex: List<idAnime, <historia, list<valores>>>
    //region List<Categorias> animes = [];
    List<Categorias> categorias = [];

    for (Anime item in OnlineData.dataAnimes) {
      String itemId = item.id;
      item.classificacao.votos = 0;

      for (UserOki user in Admin.usersList) {
        if (user.concluidos.length == 0) continue;

        AnimeCollection collection = user.animes[item.idPai];
        if (collection == null) continue;
        Anime itemUser = collection.items[itemId];

        if (itemUser == null || itemUser.classificacao.mediaValues(tudo: true).length == 0)
          continue;

        if (categorias.where((x) => x.anime.id == itemUser.id).length == 0) {
          categorias.add(Categorias(itemUser));
        }
        var categoria = categorias.firstWhere((x) => x.anime.id == itemId, orElse: null);

        var c = itemUser.classificacao;
        if (c.historia >= 0) categoria.historia.add(c.historia);
        if (c.fim >= 0) categoria.fim.add(c.fim);
        if (c.animacao >= 0) categoria.animacao.add(c.animacao);
        if (c.ecchi >= 0) categoria.ecchi.add(c.ecchi);
        if (c.comedia >= 0) categoria.comedia.add(c.comedia);
        if (c.romance >= 0) categoria.romance.add(c.romance);
        if (c.drama >= 0) categoria.drama.add(c.drama);
        if (c.acao >= 0) categoria.acao.add(c.acao);
        categoria.votos++;
      }
    }
    //endregion

    //region Somar todos os valores de cada anime
    for (var categoria in categorias) {
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
      for (var i in categoria.historia) historiaV = (historiaV == defValue) ? i : historiaV + i;
      for (var i in categoria.fim) fimV = (fimV == defValue) ? i : fimV + i;
      for (var i in categoria.animacao) animacaoV = (animacaoV == defValue) ? i : animacaoV + i;
      for (var i in categoria.ecchi) ecchiV = (ecchiV == defValue) ? i : ecchiV + i;
      for (var i in categoria.comedia) comediaV = (comediaV == defValue) ? i : comediaV + i;
      for (var i in categoria.romance) romanceV = (romanceV == defValue) ? i : romanceV + i;
      for (var i in categoria.drama) dramaV = (dramaV == defValue) ? i : dramaV + i;
      for (var i in categoria.acao) acaoV = (acaoV == defValue) ? i : acaoV + i;
      for (var i in categoria.terror) terrorV = (terrorV == defValue) ? i : terrorV + i;
      for (var i in categoria.aventura) aventuraV = (aventuraV == defValue) ? i : aventuraV + i;
      //endregion

      //region Calcular a média
      if (categoria.historia.length > 0) historiaV = historiaV/ categoria.historia.length;
      if (categoria.fim.length > 0) fimV = fimV/ categoria.fim.length;
      if (categoria.animacao.length > 0) animacaoV = animacaoV/ categoria.animacao.length;
      if (categoria.ecchi.length > 0) ecchiV = ecchiV/ categoria.ecchi.length;
      if (categoria.comedia.length > 0) comediaV = comediaV/ categoria.comedia.length;
      if (categoria.romance.length > 0) romanceV = romanceV/ categoria.romance.length;
      if (categoria.drama.length > 0) dramaV = dramaV/ categoria.drama.length;
      if (categoria.acao.length > 0) acaoV = acaoV/ categoria.acao.length;
      if (categoria.aventura.length > 0) aventuraV = aventuraV/ categoria.aventura.length;
      if (categoria.terror.length > 0) terrorV = terrorV/ categoria.terror.length;
      //endregion

      //region Atribuir os novos valores ao anime
      String itemId = categoria.anime.id;
      String itemIdPai = categoria.anime.idPai;
      var c = OnlineData.getAsync(itemIdPai).items[itemId].classificacao;
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
    for (Anime item in OnlineData.dataAnimes) {
      item.salvarClassificacao();
    }
    Log.snack('Dados salvos');
    Log.d(TAG, 'atualizarAnimes', 'OK');

    _setInProgress(false);
  }

  void _delete() async {
    _setInProgress(true);

    await FirebaseOki.database
        .child(FirebaseChild.TESTE)
        .remove().then((value) => Log.snack('Delete OK'))
        .catchError((e) => Log.snack('Delete Fail', isError: true));

    _setInProgress(false);
  }

  void _setAppVersao() async {
    var controler = TextEditingController();
    int currentVersion = Aplication.appVersionInDatabase;

    controler.text = currentVersion.toString();
    var title = 'Número da versão do app';
    var content = TextField(
      controller: controler,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          labelText: 'Número inteiro'
      ),
    );
    var result = await DialogBox.dialogCancelOK(context, title: title, content: [content]);
    if (!result.isPositive) return;
    int newVersion = int.parse(controler.text);

    if (newVersion != currentVersion) {
      Aplication.appVersionInDatabase = newVersion;

      _setInProgress(true);
      await FirebaseOki.database
          .child(FirebaseChild.VERSAO)
          .set(newVersion)
          .then((value) => Log.snack(MyTexts.DADOS_SALVOS))
          .catchError((e) => Log.snack(MyErros.ERRO_GENERICO));
      _setInProgress(false);
    }
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