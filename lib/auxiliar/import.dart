import 'dart:async';
import 'package:anime/model/anime.dart';
import 'package:anime/res/dialog_box.dart';
import 'package:anime/res/strings.dart';
import 'package:flutter/material.dart';

class Import {
  static const String TAG = 'Import';

//  static Future<bool> appIsTnstaled(String package) async {
//    return await DeviceApps.isAppInstalled(package);
//  }

//  static Future<void> openApp(String package, String anime) async {
//    try {
//      if (Platform.isAndroid) {
//        AndroidIntent intent = AndroidIntent(
//          action: 'action_view',
//          data: anime,
//          package: package,
//        );
//        await intent.launch();
//      }
//    } catch (e) {
//      Log.e(TAG, 'openApp', e);
//    }
//    await DeviceApps.openApp(package);
//  }

  static Future<bool> moverAnime(BuildContext context, Anime item, ListType list) async {
    var title = Titles.MOVER_ITEM;
    var content = [
      if (!list.isAssistindo)
        FlatButton(child: Text(Strings.ASSISTINDO), onPressed: () {
          Navigator.pop(context, DialogResult(DialogResult.negative));
        }),
      if (!list.isFavoritos)
        FlatButton(child: Text(Strings.FAVORITOS), onPressed: () {
          Navigator.pop(context, DialogResult(DialogResult.aux));
        }),
      if (!list.isConcluidos && item.isLancado)
        FlatButton(child: Text(Strings.CONCLUIDOS), onPressed: () {
          Navigator.pop(context, DialogResult(DialogResult.positive));
        }),
    ];
    var result = await DialogBox.dialogCancel(context, title: title, content: content);

    ListType novaList;
    switch(result.result) {
      case DialogResult.aux:
        novaList = ListType.favoritos;
        break;
      case DialogResult.positive:
        novaList = ListType.concluidos;
        break;
      case DialogResult.negative:
        novaList = ListType.assistindo;
        break;
      default:
        return false;
    }

    if (await item.mover(novaList, list)) {
      return true;
    }
    return false;
  }
}

class Navigate {
  static dynamic to(BuildContext context, StatefulWidget widget) async {
    return await Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget));
  }
  static toReplacement(BuildContext context, StatefulWidget widget) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => widget));
  }
}
