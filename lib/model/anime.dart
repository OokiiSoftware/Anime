import 'dart:io';
import '../auxiliar/import.dart';
import '../manager/import.dart';
import 'import.dart';

class Anime extends _Listener implements Map<String, Anime> {

  //region Variaveis
  static const String _TAG = 'Anime';

  final Anime parent;

  String _id;
  String _nome;
  String _nome2;
  String _desc;
  String _link;
  String _data;
  String _tipo;

  String _aviso;
  String _trailer;
  String _maturidade;
  String _miniatura;
  String _sinopse;
  int _episodios;
  int _ultimoAssistido;
  bool _isCopiado;
  bool _isFavorited;
  double _pontosBase;
  final List<String> _generos = [];
  final List<String> _links = [];

  final Classificacao classificacao = Classificacao();

  String _foto;

  final Map<String, Anime> _items = {};
  final List<String> parentes = [];

  //endregion

  //region Construttores

  Anime({this.parent});

  Anime.fromJson(Map map, this.parent) {
    _set(map);
  }

  static Map<String, Anime> fromJsonList(Map map, Anime parent) {
    Map<String, Anime> items = Map();
    if (map == null) return items;

    map.forEach((key, value) {
      items[key] = Anime.fromJson(value, parent);
    });

    return items;
  }

  Map<String, dynamic> toJson() => {
    "id": _id,
    "nome": _nome,
    "nome2": _nome2,
    "desc": _desc,
    "link": _link,
    "data": _data,
    "tipo": _tipo,
    "aviso": _aviso,
    'trailer': _trailer,
    "sinopse": _sinopse,
    "isCopiado": _isCopiado,
    "episodios": _episodios,
    "miniatura": _miniatura,
    'maturidade': _maturidade,
    'pontosBase': _pontosBase,
    "isFavorited": _isFavorited,
    "ultimoAssistido": _ultimoAssistido,
    'items': _itemsJson(),
    'links': _linksJson(),
    "generos": _generosJson(),
    'parentes': _parentesJson(),
    "classificacao": classificacao.toJson(),
  };

  void _set(Map map) {
    if (map == null) return;

    if (_notNull(map['id'])) _id = map['id'];
    if (_notNull(map['nome'])) _nome = map['nome'];
    if (_notNull(map['nome2'])) _nome2 = map['nome2'];
    if (_notNull(map['desc'])) _desc = map['desc'];
    if (_notNull(map['link'])) _link = map['link'];
    if (_notNull(map['data'])) _data = map['data'];
    if (_notNull(map['tipo'])) _tipo = map['tipo'];
    if (_notNull(map['aviso'])) _aviso = map['aviso'];
    if (_notNull(map['trailer'])) _trailer = map['trailer'];
    if (_notNull(map['sinopse'])) _sinopse = map['sinopse'];
    if (_notNull(map['isCopiado'])) _isCopiado = map['isCopiado'];
    if (_notNull(map['episodios'])) _episodios = map['episodios'];
    if (_notNull(map['miniatura'])) _miniatura = map['miniatura'];
    if (_notNull(map['pontosBase'])) _pontosBase = map['pontosBase'];
    if (_notNull(map['maturidade'])) _maturidade = map['maturidade'];
    if (_notNull(map['isFavorited'])) _isFavorited = map['isFavorited'];
    if (_notNull(map['ultimoAssistido'])) _ultimoAssistido = map['ultimoAssistido'];

    List generosTemp = map['generos'];
    if (generosTemp != null && generosTemp is List) {
      generos.clear();
      generosTemp.forEach((item) => generos.add(item.toString()));
    }
    classificacao.set(map['classificacao']);

    var linksTemp = map['links'];
    if (linksTemp != null && linksTemp is List) {
      linksTemp.forEach((item) {
        _links.add(item.toString());
      });
    }

    var parentesTemp = map['parentes'];
    if (parentesTemp != null && parentesTemp is List) {
      parentesTemp.forEach((item) {
        parentes.add(item.toString());
      });
    }

    final list = Anime.fromJsonList(map['items'], this);
    list.forEach((key, value) {
      if (containsKey(key))
        get(key).complete(value);
      else
        add(value);
    });

    for (var item in values) {
      if (item.generos.isEmpty)
        item.generos.addAll(generos);
    }
  }

  List<dynamic> _parentesJson() {
    List<dynamic> items = [];
    parentes.forEach((item) {
      items.add(item);
    });
    return items;
  }

  List<dynamic> _generosJson() {
    List<dynamic> items = [];
    _generos.forEach((item) {
      items.add(item);
    });
    return items;
  }

  List<dynamic> _linksJson() {
    List<dynamic> items = [];
    _links.forEach((item) {
      items.add(item);
    });
    return items;
  }

  Map _itemsJson() {
    Map map = {};
    forEach((key, value) {
      map[key] = value.toJson();
    });
    return map;
  }

  bool _notNull(dynamic value) => value != null;

  //endregion

  //region get

  bool get isCollection => length > 1;

  bool get isComplete {
    if (isEmpty)
      return link.isNotEmpty;
    return getAt(0).isComplete;
  }

  bool get containsFavorite {
    if (isFavorited)
      return true;
    return where((item) => item.containsFavorite).isNotEmpty;
  }

  bool get isDataInicioFimIguais => anoInicio == anoFim;

  double get media {
    if (isEmpty)
      return getMedia;

    double value = 0.0;
    double i = 0.0;
    for (var item in values) {
      var media = item.getMedia;
      if (media >= 0) {
        i++;
        value += media;
      }
    }
    if (i == 0) return -1;

    value = value / i;
    return value;
  }

  String get anoInicio {
    if (isEmpty)
      return ano;
    var item = getAt(0);
    return item.ano;
  }

  String get anoFim {
    if (isEmpty)
      return ano;
    var item = getAt(length -1);
    return item.ano;
  }

  Anime get ultimoAnimeTV {
    var animesTV = values.firstWhere((e) => e.tipo == AnimeType.TV && e.miniatura.isNotEmpty, orElse: () => null);
    return animesTV != null ? animesTV : getAt(/*length -1*/0);
  }

  bool get isCrunchyroll {
    return getLink(LinksType.crunchyroll).isNotEmpty;
  }
  bool get isFunimation {
    return getLink(LinksType.funimation).isNotEmpty;
  }
  String getLink(LinksType type) {
    String v;
    switch(type){
      case LinksType.crunchyroll:
        v = 'crunchyroll';
        break;
      case LinksType.funimation:
        v = 'funimation';
        break;
      default:
        v = 'ASDFGHJKL:';
    }
    return _links.firstWhere((x) => x.contains(v), orElse: () => '');
  }

  bool get isNoLancado => !isLancado;
  bool get isLancado => data.compareTo(Calendario.now()) < 0;

  bool get hasLocalFoto => fotoFile.existsSync();
  bool get hasLocalPreview => previewFile.existsSync();

  File get fotoFile => StorageManager.i.file('$id.jpg', Directorys.POSTS);
  File get previewFile => StorageManager.i.file('$id.jpg', Directorys.PREVIEWS);

  String get ano {
    if (data.contains('-'))
      return data.substring(0, data.indexOf('-'));
    return data;
  }

  double get getMedia {
    var media = classificacao.media;
    if (pontosBase > 0)
      media += pontosBase;
    return media;
  }

  Future<String> get fotoUrl async {
    if (_foto == null) {
      // var ref = FirebaseManager.i.storage
      //     .child(FirebaseChild.ANIME)
      //     .child(FirebaseChild.CAPA).child(id[0])
      //     .child('$id.jpg');
      try {
        // _foto = await ref.getDownloadURL();
      } catch(e) {
        Log.e(_TAG, 'foto', e, !e.toString().contains('Not Found.  Could not get object'));
        return null;
      }
    }
    return _foto;
  }

  List<Anime> get list => values.toList()..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

  //==========================================

  String get id => _id ?? '';

  String get nome => _nome ?? '';

  String get tipo => _tipo ?? '';

  String get nome2 => _nome2 ?? null;

  int get episodios {
    if (isEmpty)
      return _episodios ?? 0;

    if (length == 1)
      return getAt(0).episodios;

    int value = 0;
    bool contemIndefinidos = false;
    for (Anime item in values) {
      if (item.episodios >= 0)
        value += item.episodios;
      else {
        contemIndefinidos = true;
        break;
      }
    }

    return contemIndefinidos ? -value : value;
  }

  String get miniatura {
    if (isEmpty)
      return _miniatura ?? '';
    return getAt(0)?.miniatura ?? '';
  }

  List<String> get generos {
    if (_generos.isEmpty && isNotEmpty)
      return getAt(0)._generos;
    return _generos;
  }

  String get aviso => _aviso ?? '';

  String get trailer => _trailer ?? '';

  String get sinopse => _sinopse ?? '';

  String get data => _data ?? '';

  String get maturidade => _maturidade ?? '';

  String get link => _link ?? '';

  //endregion

  //region Metodos

  int indexOf(Anime value) => list.indexOf(value);

  void add(Anime value) {
    _items[value.id] = value;
    _callListener(value);
  }

  Anime get(String key) => _items[key];

  Anime getAt(int index) {
    if (index >= length)
      return null;
    return values.elementAt(index);
  }

  Future<bool> complete([Anime item]) async {
    try{
      if (item == null) {
        var snapshot = database['complemento'];
        var map = snapshot[id];
        if(map == null) return false;

        _set(map);

        // var snapshot = await _firebase.database
        //     .child(FirebaseChild.ANIME)
        //     .child(FirebaseChild.COMPLEMENTO)
        //     .child(idPai)
        //     .child(FirebaseChild.ITEMS)
        //     .child(id)
        //     .once();
        //
        // _set(snapshot.value);
        // Log.d(_TAG, 'complete', idPai, id);
        // var item = Anime.fromJson(snapshot.value);
      } else {
        _episodios = item._episodios;
        _link = item._link;
        pontosBase = item._pontosBase;
        _sinopse = item._sinopse;
        _links.clear();
        _links.addAll(item._links);
      }
      return true;
    } catch(e) {
      Log.e(_TAG, 'complete', id, e);
      return false;
    }
  }

  /// Add dados do usuário
  void apply(Anime item) {
    if (item == null) return;

    print(nome);
    _desc = item._desc;
    _ultimoAssistido = item._ultimoAssistido;
    _isFavorited = item._isFavorited;

    if (item.classificacao.media >= 0)
      classificacao.set(item.classificacao.toJson());

    forEach((key, value) {
      if (item.containsKey(key))
        value.apply(item[key]);
    });
  }

  /*Future<bool> salvarAdmin() async {
    try {
      Map basico = {
        'data': data,
        'id': id,
        'nome': nome,
        'nome2': nome2,
        'miniatura': miniatura,
      };
      Map complemento = {
        'episodios': episodios,
        'id': id,
        'link': link,
        'sinopse': sinopse,
        'tipo': tipo,
        'generos': generos,
        'trailer': trailer,
        'maturidade': maturidade,
        'pontosBase': pontosBase,
        'classificacao': classificacao.toJson(),
      };

      Future<bool> salvarBasico() async {
        // return await _firebase.database
        //     .child(FirebaseChild.TESTE)
        //     .child(FirebaseChild.BASICO)
        //     .child(idPai)
        //     .child(FirebaseChild.ITEMS)
        //     .child(id)
        //     .set(basico).then((value) async {
        //   Log.d(_TAG, 'salvarAdmin', 'salvarBasico', id, 'OK');
        //   return true;
        // }).catchError((e) {
        //   Log.e(_TAG, 'salvarAdmin fail', 'salvarBasico', id, e);
        //   return false;
        // });
      }
      Future<bool> salvarComplemento() async {
        // return await _firebase.database
        //     .child(FirebaseChild.TESTE)
        //     .child(FirebaseChild.COMPLEMENTO)
        //     .child(idPai)
        //     .child(FirebaseChild.ITEMS)
        //     .child(id)
        //     .set(complemento).then((value) {
        //   Log.d(_TAG, 'salvarAdmin', 'salvarComplemento', id, 'OK');
        //   return true;
        // }).catchError((e) {
        //   Log.e(_TAG, 'salvarAdmin fail', 'salvarComplemento', id, e);
        //   return false;
        // });
      }

      if (await salvarBasico())
        return await salvarComplemento();
      return false;
    } catch (e) {
      Log.e(_TAG, 'salvarAdmin', id, e);
      return false;
    }
  }
  Future<bool> salvarClassificacao() async {
    Future<bool> salvarComplemento() async {
      // return await _firebase.database
      //     .child(FirebaseChild.ANIME)
      //     .child(FirebaseChild.COMPLEMENTO)
      //     .child(idPai)
      //     .child(FirebaseChild.ITEMS)
      //     .child(id)
      //     .child(FirebaseChild.CLASSIFICACAO)
      //     .set(classificacao.toJson()).then((value) {
      //   Log.d(_TAG, 'salvarAdmin', 'salvarComplemento', id, 'OK');
      //   return true;
      // }).catchError((e) {
      //   Log.e(_TAG, 'salvarAdmin fail', 'salvarComplemento', id, e);
      //   return false;
      // });
    }

    return await salvarComplemento();
  }*/

  //endregion

  //region override

  @override
  remove(Object key) {
    var t = _items.remove(key);
    _callListener(t);
    return t;
  }

  @override
  void addAll(Map other) {
    _items.addAll(other);
  }

  @override
  String toString() => toJson().toString();

  @override
  void addEntries(Iterable<MapEntry> newEntries) => _items.addEntries(newEntries);

  @override
  Map<RK, RV> cast<RK, RV>() => _items.cast();

  @override
  void clear() => _items.clear();

  @override
  bool containsKey(Object key) => _items.containsKey(key);

  @override
  bool containsValue(Object value) => _items.containsValue(value);

  @override
  Iterable<MapEntry<String, Anime>> get entries => _items.entries;

  @override
  void forEach(void Function(String key, Anime value) action) => _items.forEach(action);

  Iterable<Anime> where(bool Function(Anime) test) {
    return values.where(test);
  }

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(String key, Anime value) convert) => _items.map(convert);

  @override
  putIfAbsent(key, Function() ifAbsent) => _items.putIfAbsent(key, ifAbsent);

  @override
  void removeWhere(bool Function(String key, Anime value) test) {
    _items.removeWhere(test);
  }

  @override
  update(key, Function(Anime value) update, {Function() ifAbsent}) =>
    _items.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(Function(String key, Anime value) update) {
    _items.updateAll(update);
  }

  @override
  operator [](Object key) => _items[key];

  @override
  void operator []=(key, value) => _items[key] = value;

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  Iterable<String> get keys => _items.keys;

  @override
  int get length => _items.length;

  @override
  Iterable<Anime> get values => _items.values;

  //endregion

  //region get set

  bool get isFavorited {
    if (length <= 1)
      return _isFavorited ?? false;
    return where((e) => e.isFavorited).length == length;
  }
  set isFavorited(bool value) => _isFavorited = value;

  String get desc => _desc ?? '';
  set desc(String value) => _desc = value;

  bool get isCopiado => _isCopiado ?? false;
  set isCopiado(bool value) => _isCopiado = value;

  int get ultimoAssistido => _ultimoAssistido ?? 0;
  set ultimoAssistido(int value) => _ultimoAssistido = value;

  double get pontosBase => _pontosBase ?? -1;
  set pontosBase(double value) => _pontosBase = value;

  //endregion

}

enum LinksType {
  crunchyroll, funimation
}

class _Listener {
  final List<Function(Anime)> _onChanged = [];

  void addListener(Function(Anime) item) {
    if (!_onChanged.contains(item))
      _onChanged.add(item);
  }
  void removeListener(Function(Anime) item) {
    _onChanged.remove(item);
  }
  void _callListener(Anime item) {
    _onChanged.forEach((fun) {
      fun?.call(item);
    });
  }
}