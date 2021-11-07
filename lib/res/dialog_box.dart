import 'package:flutter/material.dart';

class DialogBox {
  final BuildContext context;
  final String title;
  final String notShowAgainText;
  final String auxBtnText;
  final bool dismissible;
  final List<Widget> content;
  final EdgeInsets contentPadding;
  final Function(bool value) onNotShowAgain;
  final Function(StateSetter) onBuilder;
  DialogBox({
    @required this.context,
    this.title,
    this.notShowAgainText = 'Não mostrar novamente',
    this.auxBtnText = '',
    this.dismissible = true,
    this.content = const [],
    this.contentPadding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.onNotShowAgain,
    this.onBuilder,
  });

  Future<DialogResult> none() async {
    return await _aux();
  }

  Future<DialogResult> simNao() async {
    return await _aux(
        dismissible: dismissible,
        actions: [
          negativeButton('Não'),
          positiveButton('Sim'),
        ]
    );
  }
  Future<DialogResult> simNaoCancel() async {
    return await _aux(
        dismissible: dismissible,
        actions: [
          noneButton('Cancelar'),
          negativeButton('Não'),
          positiveButton('Sim'),
        ]
    );
  }

  Future<DialogResult> cancelOK() async {
    return await _aux(
        dismissible: dismissible,
        actions: [
          negativeButton('Cancelar'),
          positiveButton('OK'),
        ]
    );
  }

  Future<DialogResult> ok() async {
    return await _aux(
        dismissible: dismissible,
        actions: [
          positiveButton('OK'),
        ]
    );
  }

  Future<DialogResult> cancel() async {
    return await _aux(
        dismissible: dismissible,
        actions: [
          negativeButton('Cancelar'),
        ]
    );
  }

  Future<DialogResult> _aux({List<Widget> actions, bool dismissible = true}) async {
    return await showDialog<DialogResult>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) =>
          StatefulBuilder(
              builder: (context, setState) {
                onBuilder?.call(setState);

                return AlertDialog(
                  title: title == null ? null : Text(title),
                  content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: content,
                      )
                  ),
                  contentPadding: contentPadding,
                  actions: actions,
                );
              }
          ),
    ) ?? DialogResult.none;
  }

  Widget noneButton(String text) =>
      TextButton(
        child: Text(text),
        onPressed: () =>
            Navigator.pop(
                context, DialogResult.none),
      );

  Widget negativeButton(String text) =>
      TextButton(
        child: Text(text),
        onPressed: () =>
            Navigator.pop(
                context, DialogResult.negative),
      );

  Widget positiveButton(String text) =>
      TextButton(
        child: Text(text),
        onPressed: () =>
            Navigator.pop(
                context, DialogResult.positive),
      );
}

class DialogResult {
  static const int noneValue = 5720;
  static const int positiveValue = 122;
  static const int negativeValue = 2252;

  final int value;
  DialogResult(this.value);

  static DialogResult get none => DialogResult(noneValue);
  static DialogResult get positive => DialogResult(positiveValue);
  static DialogResult get negative => DialogResult(negativeValue);

  bool get isPositive => value == positiveValue;
  bool get isNegative => value == negativeValue;
  bool get isNone => value == noneValue;
}

class DialogFullScreen {
  final BuildContext context;
  final List<Widget> content;
  DialogFullScreen({@required this.context, this.content = const []});

  Future<void> show() async {
    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.3),
      pageBuilder: (context, anim1, anim2) { // your widget implementation
        return SizedBox.expand( // makes widget fullscreen
          child: Column(
            children: content,
          ),
        );
      },
    );
  }

  Future<void> showIndex(int index) async {
    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.3),
      pageBuilder: (context, anim1, anim2) { // your widget implementation
        return content[index];
      },
    );
  }
}
