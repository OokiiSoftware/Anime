import 'dart:io';
import 'dart:ui';
import 'package:anime/model/anime.dart';
import 'package:anime/model/user.dart';
import 'package:anime/res/my_icons.dart';
import 'package:anime/res/theme.dart';
import 'package:flutter/material.dart';

class MyLayouts {
  static Widget fotoAnime(Anime item, {double iconSize, BoxFit fit}) {
    bool fotoLocal = item.fotoLocalExist;

    return fotoLocal ?
    fotoFile(item.fotoToFile, iconSize: iconSize, fit: fit) :
    item.miniatura.isEmpty ? Icon(Icons.image) :
    fotoNetwork(item.miniatura, item.foto, iconSize: iconSize, fit: fit);
  }

  static Widget fotoFile(File file, {double iconSize, BoxFit fit}) => Image.file(file, fit: fit, width: iconSize, height: iconSize, errorBuilder: (c, u, e) => Icon(Icons.image));
  static Widget fotoNetwork(String miniatura, String foto, {double iconSize, BoxFit fit}) =>
      Image.network(
          miniatura, fit: fit, width: iconSize, height: iconSize, errorBuilder: (c, u, e) => Icon(Icons.image),
          loadingBuilder: (context, widget, progress) {
            if (progress == null) return widget;
            return Icon(Icons.image);
          },
      );

  static Widget animeItemList (AnimeList items, {ListType list, @required onTap(), Widget trailing, bool showSeconfName = false}) {
    var media = items.media;
    String subtitle = '';
    if (showSeconfName && items.nome2 != null)
      subtitle = items.nome2;
    else if ((list.isOnline || list.isConcluidos) && media >= 0)
      subtitle = 'Media: $media';
    else if (list.isAssistindo) {
      if (items.items.length == 1)
      subtitle = 'Ultimo: ${items.getItem(0).ultimoAssistido}';
    }
    else if (items.nome2 != null)
      subtitle = items.nome2;

    int eps = items.episodios;
    if(eps != 0) {
      int temp = eps < 0 ? eps*-1 : eps;
      if (temp > 1) {
        var epsS = eps < 0 ? '${eps*-1}+' : '$eps';
        subtitle += '\nEpi: $epsS';
      }
    }

    var animesTV = items.itemsToList.where((e) => e.tipo == AnimeTipo.TV).toList();

    var ultimoAnime = animesTV.length > 0 ? animesTV[animesTV.length -1] : items.getItem(items.items.length -1);
    // var icon = getIcon(ultimoAnime.tipo);
    return ListTile(
      contentPadding: EdgeInsets.only(bottom: 3),
      leading: MyLayouts.fotoAnime(ultimoAnime),
      title: Text(items.nome),
      subtitle: Row(children: [
        // if (icon != null)
        //   Padding(
        //     padding: EdgeInsets.only(right: 10),
        //     child: icon,
        //   ),
        Expanded(child: Text(subtitle)),
        if (items.isDataInicioFimIguais)
          Text(items.anoFim)
        else
          Text('${items.anoInicio} - ${items.anoFim}'),
      ]),
      trailing: trailing,
      onTap: onTap,
    );
  }

  static Widget animeItemGrid(AnimeList items, {ListType list, @required onTap(), onLongPress(), Widget footer, bool isOrientationPortrait = true}) {
    var textStyle = TextStyle(color: isOrientationPortrait ? MyTheme.text() : MyTheme.textInvert());

    var animesTV = items.itemsToList.where((e) => e.tipo == AnimeTipo.TV).toList();
    var ultimoAnime = animesTV.length > 0 ? animesTV[animesTV.length -1] : items.getItem(items.items.length -1);

//    var ultimoAnime = items.getItem(items.items.length -1);
    var icon = getIcon(ultimoAnime.tipo);
    var media = items.media;
    String subtitle = '';
    if (items.nome2 != null)
      subtitle = '${items.nome2}\n';
    subtitle += 'Episódios: ${items.episodios}';

    if ((list.isOnline || list.isConcluidos) && media >= 0)
      subtitle += '\nMedia: $media';

    return GestureDetector(
      child: GridTile(
        header: isOrientationPortrait ? Container(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 6,
                    color: Colors.black12
                )
              ]
          ),
          padding: EdgeInsets.all(3),
          child: footer,
        ) : null,
        child: Container(
          color: isOrientationPortrait ? Colors.black87 : MyTheme.tint(),
          child: isOrientationPortrait ? Column(
            children: [
              Expanded(child: MyLayouts.fotoAnime(ultimoAnime, fit: BoxFit.fitHeight)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: Text(items.nome, maxLines: 1, style: TextStyle(color: MyTheme.text())),
              )
            ],
          ) :
          Row(
              children: [
                MyLayouts.fotoAnime(ultimoAnime, fit: BoxFit.fitHeight),
                Expanded(child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items.nome, maxLines: 1, style: textStyle),
                        Text(subtitle, style: textStyle),
                        if (icon != null) ...[
                          Row(
                              children: [
                                Text('Tipo: ${ultimoAnime.tipo}   ', style: textStyle),
                                icon
                              ]
                          ),
                        ]
                      ]
                  ),
                )),
                if (!isOrientationPortrait && footer != null)
                  Container(
                    padding: EdgeInsets.all(3),
                    child: footer,
                  )
              ]
          ),
        ),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  static Widget anime(Anime item, {@required ListType list, @required onTap(), Widget trailing, bool showSeconfName = false}) {
    var media = item.classificacao.media;
    String subtitle = '';
    if (item.episodios >= 0) {
      if (item.episodios > 1)
        subtitle = 'Epi: ${item.episodios}';
    } else {
      subtitle = 'Indefinido';
    }
    if (showSeconfName && item.nome2 != null)
      subtitle = item.nome2;
    else if ((list.isOnline || list.isConcluidos) && media >= 0)
        subtitle += '\nMedia: $media';
    else if (list.isAssistindo)
      subtitle += '\nUltimo: ${item.ultimoAssistido}';

    subtitle += '\nAno: ${item.ano}';

    var icon = getIcon(item.tipo);
    return ListTile(
      contentPadding: EdgeInsets.only(bottom: 5),
      leading: MyLayouts.fotoAnime(item),
      title: Text(item.nome),
      subtitle: Row(children: [
        if (icon != null)
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: icon,
          ),
        Expanded(child: Text(subtitle))
      ]),
      trailing: trailing,
      onTap: onTap,
    );
  }

  static Icon getIcon(String animeTipo) {
    switch(animeTipo) {
      case AnimeTipo.TV:
        return Icon(Icons.tv);
        break;
      case AnimeTipo.OVA:
        return Icon(MyIcons.egg, size: 20);
        break;
      case AnimeTipo.ONA:
        return Icon(Icons.wifi_tethering);
        break;
      case AnimeTipo.MOVIE:
        return Icon(Icons.video_call);
        break;
      case AnimeTipo.SPECIAL:
        return Icon(Icons.star);
        break;
      default:
        return Icon(Icons.error);
    }
  }

  static Widget teste(AnimeList item, User user, {bool isGrid = false}) {
    double iconSize = 15.0;
    String id = item.id;
    if (isGrid)
      return Row(
        children: [
          if(user.assistindo.containsKey(id))
            Icon(Icons.list, size: iconSize, color: MyTheme.tint()),
          if(user.favoritos.containsKey(id))
            Icon(Icons.favorite, size: iconSize, color: MyTheme.tint()),
          if(user.concluidos.containsKey(id))
            Icon(Icons.offline_pin, size: iconSize, color: MyTheme.tint()),
        ]
      );
    return Column(
        children: [
          if(user.assistindo.containsKey(id))
            Icon(Icons.list, size: iconSize),
          if(user.favoritos.containsKey(id))
            Icon(Icons.favorite, size: iconSize),
          if(user.concluidos.containsKey(id))
            Icon(Icons.offline_pin, size: iconSize),
        ]
    );
  }
  static Widget teste2(Anime item, User user) {
    double iconSize = 15.0;
    String id = item.id;

    Map<dynamic, dynamic> assistindoMap = user.assistindo[item.idPai];
    Map<dynamic, dynamic> concluidosMap = user.concluidos[item.idPai];
    Map<dynamic, dynamic> favoritosMap = user.favoritos[item.idPai];

    return Column(
        children: [
          if(assistindoMap != null && assistindoMap.containsKey(id))
            Icon(Icons.list, size: iconSize),
          if(favoritosMap != null && favoritosMap.containsKey(id))
            Icon(Icons.favorite, size: iconSize),
          if(concluidosMap != null && concluidosMap.containsKey(id))
            Icon(Icons.offline_pin, size: iconSize),
        ]
    );
  }
}

class MyStyles {
  static TextStyle titleText = TextStyle(fontSize: 20, color: MyTheme.text());
  static TextStyle text = TextStyle(color: MyTheme.text());
}
