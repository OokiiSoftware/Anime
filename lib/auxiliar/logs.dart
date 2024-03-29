import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';
import 'package:anime/res/import.dart';

class Log {
  static final scaffKey = GlobalKey<ScaffoldState>();

  static void snack(String texto, {bool isError = false, String actionLabel = '', onTap()}) {
    try {
      scaffKey.currentState.hideCurrentSnackBar();

      var textColor = OkiTheme.text;
      var snack = SnackBar(
        content: Container(
          margin: Layouts.adsPadding(0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isError ? Icons.clear : Icons.check, color: textColor),
              SizedBox(width: 12.0),
              Text(texto, style: TextStyle(color: textColor)),
            ],
          ),
        ),
        backgroundColor: isError ? Colors.red : OkiTheme.accent,
        action: onTap == null ? null: SnackBarAction(
          label: actionLabel,
          onPressed: onTap,
        ),
      );
      scaffKey.currentState.showSnackBar(snack);
    } catch (ex) {
      e('Log', 'snackbar', ex, false);
    }
  }

  static void d(String tag, String metodo, [dynamic value, dynamic value1, dynamic value2, dynamic value3]) {
    String msg = '';
    if (value != null) msg += value.toString();
    if (value1 != null) msg += ': ' + value1.toString();
    if (value2 != null) msg += ': ' + value2.toString();
    if (value3 != null) msg += ': ' + value3.toString();
    print('AnimeApp D: $tag: $metodo: $msg');
  }
  static void e(String tag, String metodo, dynamic e, [dynamic value, dynamic value1, dynamic value2, dynamic value3]) {
    String msg = e.toString();
    bool send = false;
    if (value != null) {
      if (value is bool && value == false)
        send = false;
      else
        msg += ': ' + value.toString();
    }
    if (value1 != null) msg += ': ' + value1.toString();
    if (value2 != null) msg += ': ' + value2.toString();
    if (value3 != null) msg += ': ' + value3.toString();
    print('AnimeApp E: $tag: $metodo: $msg');

    if (send)
      _sendError(tag, metodo, msg);
  }

  static void test(String tag) {
    print(tag + ": Teste");
  }

  static _sendError(String tag, String metodo, String value) {
    String id = '';

    Erro e = Erro();
    e.data = DataHora.now();
    e.classe = tag;
    e.metodo = metodo;
    e.valor = value;
    e.userId = id;
//    e.salvar();
  }
}