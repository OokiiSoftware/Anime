import 'package:anime/auxiliar/import.dart';
import 'package:anime/res/strings.dart';

class DialogResult {
  static const int noneValue = 50;
  static const int positiveValue = 12;
  static const int negativeValue = 22;
  static const int auxValue = 33;
  static const int aux2Value = 54;

  static DialogResult get none => DialogResult(noneValue);
  static DialogResult get positive => DialogResult(positiveValue);
  static DialogResult get negative => DialogResult(negativeValue);
  static DialogResult get aux => DialogResult(auxValue);
  static DialogResult get aux2 => DialogResult(aux2Value);

  DialogResult(this.value);

  int value;
  bool get isPositive => value == positiveValue;
  bool get isNegative => value == negativeValue;
  bool get isAux => value == auxValue;
  bool get isAux2 => value == aux2Value;
  bool get isNone => value == noneValue;
}

enum DialogType {
  ok,
  okCancel,
  cancel,
  sim,
  simNao,
  nao,
}

class DialogBox {
  static Future<DialogResult> dialogSimNao(BuildContext context,
      {String title, List<Widget> content, EdgeInsets contentPadding}) async {
    return await _dialogAux(context, title: title,
        content: content,
        contentPadding: contentPadding,
        dialogType: DialogType.simNao);
  }

  static Future<DialogResult> dialogCancelOK(BuildContext context,
      {String title, String auxBtnText, String positiveButton, String negativeButton, List<
          Widget> content, EdgeInsets contentPadding}) async {
    return await _dialogAux(context, title: title,
        positiveButton: positiveButton,
        negativeButton: negativeButton,
        auxBtnText: auxBtnText,
        content: content,
        contentPadding: contentPadding,
        dialogType: DialogType.okCancel);
  }

  static Future<DialogResult> dialogOK(BuildContext context,
      {String title, String positiveButton, String auxBtnText, List<
          Widget> content, EdgeInsets contentPadding}) async {
    return await _dialogAux(context, title: title,
        positiveButton: positiveButton,
        auxBtnText: auxBtnText,
        content: content,
        contentPadding: contentPadding,
        dialogType: DialogType.ok);
  }

  static Future<DialogResult> dialogCancel(BuildContext context,
      {String title, String negativeButton, String auxBtnText, List<
          Widget> content, EdgeInsets contentPadding}) async {
    return await _dialogAux(context, title: title,
        negativeButton: negativeButton,
        auxBtnText: auxBtnText,
        content: content,
        contentPadding: contentPadding,
        dialogType: DialogType.cancel);
  }

  static Future<DialogResult> _dialogAux(BuildContext context, {
    String title,
    String auxBtnText,
    String positiveButton,
    String negativeButton,
    List<Widget> content,
    EdgeInsets contentPadding,
    @required DialogType dialogType,
  }) async {
    //region variaveis
    auxBtnText ??= '';
    contentPadding ??= EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0);

    positiveButton ??=
    (dialogType == DialogType.sim || dialogType == DialogType.simNao) ?
    Strings.SIM : Strings.OK;

    negativeButton ??=
    (dialogType == DialogType.nao || dialogType == DialogType.simNao) ?
    Strings.NAO : Strings.CANCELAR;

    bool okButton = _showPositiveButton(dialogType);
    bool cancelButton = _showNegativeButton(dialogType);

    content ??= [];
    //endregion

    return await showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setState) =>
                AlertDialog(
                  title: title == null ? null : Text(title),
                  content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: content,
                      )
                  ),
                  contentPadding: contentPadding,
                  actions: [
                    if (auxBtnText.isNotEmpty) FlatButton(
                      child: Text(auxBtnText),
                      onPressed: () =>
                          Navigator.pop(
                              context, DialogResult.aux),
                    ),
                    if (cancelButton) FlatButton(
                      child: Text(negativeButton),
                      onPressed: () =>
                          Navigator.pop(
                              context, DialogResult.negative),
                    ),
                    if (okButton) FlatButton(
                      child: Text(positiveButton),
                      onPressed: () =>
                          Navigator.pop(
                              context, DialogResult.positive),
                    ),
                  ],
                ),
          ),
    ) ?? DialogResult.none;
  }

  static bool _showPositiveButton(DialogType dialogType) {
    return (dialogType == DialogType.sim || dialogType == DialogType.simNao) ||
        (dialogType == DialogType.ok || dialogType == DialogType.okCancel);
  }

  static bool _showNegativeButton(DialogType dialogType) {
    return (dialogType == DialogType.nao || dialogType == DialogType.simNao) ||
        (dialogType == DialogType.cancel || dialogType == DialogType.okCancel);
  }
}
