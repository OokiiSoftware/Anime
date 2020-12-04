class Classificacao {

  //region Variaveis
  static const String ACAO = 'acao';
  static const String DRAMA = 'drama';
  static const String TERROR = 'terror';
  static const String ROMANCE = 'romance';
  static const String COMEDIA = 'comedia';
  static const String ANIMACAO = 'animacao';
  static const String AVENTURA = 'aventura';
  static const String HISTORIA = 'historia';
  static const String ECCHI = 'ecchi';
  static const String FIM = 'fim';
  static const String VOTOS = 'votos';

  double _acao;
  double _drama;
  double _terror;
  double _romance;
  double _comedia;
  double _animacao;
  double _aventura;
  double _historia;
  double _ecchi;
  double _fim;
  int _votos;
  //endregion

  //region Construtores

  Classificacao();

  Classificacao.fromJson(Map<dynamic, dynamic> map) {
    if (map == null) return;
    //A forma que eu usava antes <map[ACAO]?.toString()> não estava funcionando
    //então fiz essa verificação <_mapNotNull>
    if(_mapNotNull(map[ACAO])) acao = double.tryParse(map[ACAO]?.toString());
    if(_mapNotNull(map[DRAMA])) drama = double.tryParse(map[DRAMA]?.toString());
    if(_mapNotNull(map[TERROR])) terror = double.tryParse(map[TERROR]?.toString());
    if(_mapNotNull(map[ROMANCE])) romance = double.tryParse(map[ROMANCE]?.toString());
    if(_mapNotNull(map[COMEDIA])) comedia = double.tryParse(map[COMEDIA]?.toString());
    if(_mapNotNull(map[ANIMACAO])) animacao = double.tryParse(map[ANIMACAO]?.toString());
    if(_mapNotNull(map[AVENTURA])) aventura = double.tryParse(map[AVENTURA]?.toString());
    if(_mapNotNull(map[HISTORIA])) historia = double.tryParse(map[HISTORIA]?.toString());
    if(_mapNotNull(map[ECCHI])) ecchi = double.tryParse(map[ECCHI]?.toString());
    if(_mapNotNull(map[FIM])) fim = double.tryParse(map[FIM]?.toString());
    if(_mapNotNull(map[VOTOS])) votos = map[VOTOS];
  }

  Map<String, dynamic> toJson() => {
    ACAO: acao,
    DRAMA: drama,
    TERROR: terror,
    ROMANCE: romance,
    COMEDIA: comedia,
    ANIMACAO: animacao,
    AVENTURA: aventura,
    HISTORIA: historia,
    ECCHI: ecchi,
    FIM: fim,
    VOTOS: votos,
  };

  //endregion

  //region Metodos

  double get media {
    List<double> values = mediaValues();

    if (values.length == 0)
      return -1.0;
    double value = 0;
    double total = 0;
    for (double v in values) {
      value += v;
    }
    total = value / values.length;
    return double.parse(total.toStringAsFixed(2));
  }

  List<double> mediaValues({bool tudo = false}) {
    List<double> values = [];
    if (acao >= 0) values.add(acao);
    if (drama >= 0) values.add(drama);
    if (romance >= 0) values.add(romance);
    if (comedia >= 0) values.add(comedia);
    if (animacao >= 0) values.add(animacao);
    if (aventura >= 0) values.add(aventura);
    if (historia >= 0) values.add(historia);
    if (fim >= 0) values.add(fim);
    if (tudo) {
      if (terror >= 0) values.add(terror);
      if (ecchi >= 0) values.add(ecchi);
    }

    return values;
  }

  static bool _mapNotNull(dynamic value) {
    return value != null;
  }

  //endregion

  //region get set

  double get historia => _historia ?? -1.0;

  set historia(double value) {
    _historia = value;
  }

  double get fim => _fim ?? -1.0;

  set fim(double value) {
    _fim = value;
  }

  double get animacao => _animacao ?? -1.0;

  set animacao(double value) {
    _animacao = value;
  }

  double get ecchi => _ecchi ?? -1.0;

  set ecchi(double value) {
    _ecchi = value;
  }

  double get comedia => _comedia ?? -1.0;

  set comedia(double value) {
    _comedia = value;
  }

  double get romance => _romance ?? -1.0;

  set romance(double value) {
    _romance = value;
  }

  double get drama => _drama ?? -1.0;

  set drama(double value) {
    _drama = value;
  }

  double get acao => _acao ?? -1.0;

  set acao(double value) {
    _acao = value;
  }

  double get aventura => _aventura ?? -1.0;

  set aventura(double value) {
    _aventura = value;
  }

  double get terror => _terror ?? -1.0;

  set terror(double value) {
    _terror = value;
  }

  int get votos => _votos ?? null;

  set votos(int value) {
    _votos = value;
  }

//endregion

}