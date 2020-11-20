class DataHora {

  int _ano;
  int _mes;
  int _dia;

  DataHora();

  //format = 2000-12-01
  bool setData(String date) {
    try {
      var teste = date.split("-");
      int ano = int.parse(teste[0]);
      int mes = int.parse(teste[1]);
      int dia = int.parse(teste[2]);

      if (dia == 0 || mes == 0 || dia > 31 || mes > 12 || ano < 1900)
        return false;

      this.dia = dia;
      this.mes = mes;
      this.ano = ano;
      return true;
    } catch (e) {
      return false;
    }
  }

  Map toJson() => {
    "ano": ano,
    "mes": mes,
    "dia": dia,
  };

  DataHora.fromJson(Map map) {
    ano = map['ano'];
    mes = map['mes'];
    dia = map['dia'];
  }

  @override
  String toString() {
    if (dia == 0 || mes == 0) {
      return ' ';
    }
    var mesS = mes.toString();
    var diaS = dia.toString();
    if (mesS.length == 1)
      mesS = '0' + mesS;
    if (diaS.length == 1)
      diaS = '0' + mesS;

    String s = ano.toString() + '-' + mesS + '-' + diaS;
    return s;
  }

  int idade() => DateTime.now().year - ano;

  bool isValido() => (dia > 0 && dia <= 31) && (mes > 0 && mes <= 12) && ano >= 1900;

  //region get set

  int get dia => _dia ?? 0;

  set dia(int value) {
    _dia = value;
  }

  int get mes => _mes ?? 0;

  set mes(int value) {
    _mes = value;
  }

  int get ano => _ano ?? DateTime.now().year;

  set ano(int value) {
    _ano = value;
  }

  //endregion

  static String now() {
    //format yyyy-MM-dd hh:mm:ss
    String value = DateTime.now().toString();
    return value.substring(0, value.indexOf('.'));
  }

  static int toHour(String value) {
    try {
      return int.parse(value.substring(0, value.indexOf(':')));
    } catch(e) {
      return 0;
    }
  }
  static int toMinute(String value) {
    try {
      return int.parse(value.substring(value.indexOf(':')+1));
    } catch(e) {
      return 0;
    }
  }

}