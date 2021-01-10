import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';
import 'package:anime/pages/import.dart';
import 'generos_fragment.dart';

class NaoLancadosFrament extends StatelessWidget {
  final BuildContext context;
  NaoLancadosFrament(this.context);

  @override
  Widget build(BuildContext context) => OnlineFragment(this.context, filtro: '0000');
}

class OnlineFragment extends StatefulWidget {
  final BuildContext context;
  final String filtro;
  OnlineFragment(this.context, {this.filtro});

  @override
  _MyState createState() => _MyState(context, filtro);
}
class _MyState extends State<OnlineFragment> with AutomaticKeepAliveClientMixin<OnlineFragment> {

  _MyState(this.context, this._args);

  //region Variaveis
  static const String TAG = 'OnlineFragment';
  String _args;
  String _filtro;

  final BuildContext context;
  List<AnimeCollection> collections = [];

  //endregion

  //region overrides

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    AdMob.instance.removeListener(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (_args == null)
      _filtro = Config.filtro;
    else
      _filtro = _args;

    _preencherLista(ignoreRunTime: true);
    AdMob.instance.addListener(this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _preencherLista();

    bool isListMode = Config.itemListMode.isListMode;
    var user = FirebaseOki.userOki;

    return RefreshIndicator(
      child: Scaffold(
        body: (collections.isEmpty) ?
        // Sem Resultados
        ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(MyTexts.SEM_RESULTADOS),
                subtitle: Text(MyTexts.SUJESTAO_ON_SEM_RESULTADOS),
                onTap: () async {
                  await Navigate.to(context, GenerosFragment());
                  if (RunTime.updateOnlineFragment) {
                    RunTime.updatePesquisaMainPage;// <- Remove o valor 'true' dessa variavel
                    _setFiltro('$_filtro');
                    setState(() {});
                  }
                },
              );
            }
        ) :
        isListMode ?
        ListView.builder(
          padding: Layouts.adsPadding(10, 10, 10, 80),
          itemCount: collections.length,
          itemBuilder: (context, index) {
            var item = collections[index];
            if (item.items.isEmpty) return Container();
            return AnimeItemList(
                item,
                onTap: () => _abrirAnime(item),
                listType: ListType.online,
                trailing: Layouts.markerCollection(item, user)
            );
          },
        ) :
        GridView.builder(
            itemCount: collections.length,
            padding: Layouts.adsPadding(0, 0, 0, 80),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                crossAxisCount: 3,
                childAspectRatio: 1/2
            ),
            itemBuilder: (context, index) {
              var item = collections[index];
              return AnimeItemGrid(
                  item,
                  onTap: () => _abrirAnime(item),
                  listType: ListType.online,
                  footer: Layouts.markerCollection(item, user, isGrid: true)
              );
            }
        ),
        floatingActionButton: RunTime.changeListMode ? AdsFooter(child: CircularProgressIndicator()) :
        _args == null ? AdsFooter(
            child: FloatingActionButton.extended(
                label: Text(_filtro),
                onPressed: _alterarFiltro
            )) : null,
      ),
      onRefresh: _onRefresh,
    );
  }

  //endregion

  //region Metodos

  Future _onRefresh() async {
    if (!RunTime.isOnline) return;
    Log.d(TAG, 'onRefresh');
    await OnlineData.baixarLista();
    _preencherLista(ignoreRunTime: true);
  }

  void _alterarFiltro() async {
    var title = Titles.ALTERAR_FILTRO;
    var controller = TextEditingController();
    controller.text = _filtro;
    var content = [
      Text(MyTexts.ALTERAR_FILTRO),
      TextField(
        controller: controller,
        decoration: InputDecoration(
            hintText: 'Ex: 2020'
        ),
      ),
      ElevatedButton(
        child: Text('Exemplos'),
        onPressed: () {
          var title = 'Exemplos de Filtros';
          var content = [
            Text('A (Uma letra)'),
            Text('An (Várias letras)'),
            Text('A-Z (Listar de A a Z)'),
            Text('A,Ba,C.. (Listar A,Ba,C..)'),
            Text('VAZIO ou # (Listar tudo)'),
            Text('2020 (Lançados em 2020)'),
            Text('0000 (Animes não lançados)'),
          ];
          DialogBox.dialogOK(context, title: title, content: content);
        },
      ),
      ElevatedButton(
        child: Text('Generos'),
        onPressed: () async {
          await Navigate.to(context, GenerosFragment());
        },
      ),
    ];

    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);
    if (result.isPositive) {
      var text = controller.text.toUpperCase().replaceAll(' ', '');
      if (text.isEmpty) text = '#';
      _setFiltro(text);
      _saveFiltro(text);
    } else if (RunTime.updateOnlineFragment) {
      _setFiltro(_filtro);
      setState(() {});
    }
  }

  void _setFiltro(String filtro) {
    collections.clear();
    switch(filtro) {
      case '#':
        collections.addAll(OnlineData.dataList);
        break;
      default:
        if (filtro.contains('-')) {
          List<String> sp = filtro.split('-').toSet().toList()..sort((a, b) => a.compareTo(b));
          String init = sp[0] ?? '';
          String fim = sp[1] ?? 'Z';
          if (init.isEmpty) init = '';
          if (fim.isEmpty) fim = 'Z';
          collections.addAll(OnlineData.dataList.where((x) => (x.nome[0].compareTo(init) >= 0) && (x.nome[0].compareTo(fim) <= 0)));
          break;
        } else if (filtro.contains(',')) {
          List<String> sp = filtro.split(',').toSet().toList()..sort((a, b) => a.compareTo(b));
          for (String s in sp)
            collections.addAll(OnlineData.dataList.where((x) => x.nome.toUpperCase().startsWith(s.toUpperCase())));
          break;
        }
        try {
          if (filtro.length != 4) throw ('');
          int i = int.parse(filtro);
          if (i == 0) {
            collections.addAll(OnlineData.dataList.where((x) => x.itemsToList.where((e) => e.isNoLancado).length > 0));
          } else {
            collections.addAll(OnlineData.dataList.where((x) => x.itemsToList.where((e) => e.data.contains(filtro)).length > 0));
            Log.snack('Animes lançados em $filtro');
          }
        } catch(e) {
          collections.addAll(OnlineData.dataList.where((x) => x.nome.toUpperCase().startsWith(filtro.toUpperCase())));
        }
    }
  }

  void _saveFiltro(String filtro) {
    setState(() {
      _filtro = filtro;
    });
    Config.filtro = filtro;
  }

  void _abrirAnime(AnimeCollection items) async {
    AnimeCollection itemsAux = AnimeCollection.newItem(items);

    if (itemsAux.items.length == 0)
      return;
    else if (itemsAux.items.length == 1)
      await Navigate.to(context, AnimePage(anime: items, listType: ListType.online));
    else
      await Navigate.to(context, AnimeCollectionPage(ListType.online, animeCollection: itemsAux));

    _preencherLista();
  }

  void _preencherLista({bool ignoreRunTime = false}) {
    setState(() {
      if (RunTime.updateOnlineFragment || ignoreRunTime) {
        collections.clear();
        _setFiltro(_filtro);
      }
    });
  }

  //endregion

}