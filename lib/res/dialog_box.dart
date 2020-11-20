import 'package:anime/res/strings.dart';
import 'package:flutter/material.dart';

class DialogResult {
  static const int ok = 1;
  static const int cancel = 2;
  static const int sim = 7;
  static const int nao = 5;
  static const int none = 0;
  DialogResult(this.result);

  int result;

  bool get isOK => result == ok;
  bool get isCancel => result == cancel;
  bool get isNone => result == none;
  bool get isSim => result == sim;
  bool get isNao => result == nao;
}

class DialogBox {
  static Future<DialogResult> dialogCancelOK(BuildContext context, {@required String title, Widget content, EdgeInsets contentPadding, EdgeInsets insetPadding}) async {
    return await _dialogAux(context, title: title, content: content, contentPadding: contentPadding, insetPadding: insetPadding);
  }
  static Future<DialogResult> dialogOk(BuildContext context, {@required String title, Widget content, EdgeInsets contentPadding, EdgeInsets insetPadding}) async {
    return await _dialogAux(context, title: title, content: content, contentPadding: contentPadding, insetPadding: insetPadding, cancel: false);
  }
  static Future<DialogResult> dialogCancel(BuildContext context, {@required String title, Widget content, EdgeInsets contentPadding, EdgeInsets insetPadding}) async {
    return await _dialogAux(context, title: title, content: content, contentPadding: contentPadding, insetPadding: insetPadding, ok: false);
  }

  static Future<DialogResult> dialogNaoSim(BuildContext context, {@required String title, Widget content, EdgeInsets contentPadding, EdgeInsets insetPadding}) async {
    return await _dialogAux(context, title: title, content: content, contentPadding: contentPadding, insetPadding: insetPadding, ok: false, sim: true, nao: true);
  }

  static Future<DialogResult> _dialogAux(BuildContext context,
      {@required String title, Widget content, bool cancel = true,
        bool ok = true, bool nao = false, bool sim = false, EdgeInsets contentPadding, EdgeInsets insetPadding}) async {
    if(contentPadding == null) contentPadding = EdgeInsets.all(20);
    if(insetPadding == null) insetPadding = EdgeInsets.all(20);

    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: title == null ? null : Text(title),
          content: content,
          contentPadding: contentPadding,
          insetPadding: insetPadding,
          actions: [
            if (cancel) FlatButton(
              child: Text(MyStrings.CANCELAR),
              onPressed: () => Navigator.pop(context, DialogResult(DialogResult.cancel)),
            ),
            if (nao) FlatButton(
              child: Text(MyStrings.NAO),
              onPressed: () => Navigator.pop(context, DialogResult(DialogResult.nao)),
            ),
            if (sim) FlatButton(
              child: Text(MyStrings.SIM),
              onPressed: () => Navigator.pop(context, DialogResult(DialogResult.sim)),
            ),
            if (ok) FlatButton(
              child: Text(MyStrings.OK),
              onPressed: () => Navigator.pop(context, DialogResult(DialogResult.ok)),
            ),
          ],
        )
    ) ?? DialogResult(DialogResult.none);
  }
}
