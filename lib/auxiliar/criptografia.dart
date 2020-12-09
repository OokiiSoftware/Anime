import 'package:anime/model/import.dart';

class Cript {

  static Map<String, Map<String, String>> _criptografia;
  static Map<String, Map<String, String>> get _getCriptografia {
    if (_criptografia == null)
      _criptografia = CriptDigitos.data;
    return _criptografia;
  }

  static String encript(String value) {
    if (value == null || value.isEmpty) return value;

    var digitos = _getCriptografia;
    String result = "";
    int second = DateTime.now().second;
    for (int i = 0; i < value.length; i++) {
      var digito = value[i];
      if (digitos.containsKey(digito))
        result += digitos[digito][second.toString()];

      // Se o usuário digitar por ex: 'aaaa' esta linha abaixo impede
      // que o mesmo valor criptografado seja usado em todos os digitos.
      second++;
      if (second == 60) second = 0;
    }
    return result;
  }

  static String decript(String value) {
    if (value == null || value.isEmpty) return value;

    String result = value;
    var data = _getCriptografia;
    for (var letra in data.keys) // letra contém uma coleção de 59 dados criptografados
      for (var numero in data[letra].values) // numero (0 a 59) cada item representa 1 segundo literal do Relógio
        if (result.contains(numero))
          result = result.replaceAll(numero, letra);
    return result;
  }
}