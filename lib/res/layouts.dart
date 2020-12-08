import 'dart:io';
import 'dart:ui';
import 'strings.dart';
import 'theme.dart';
import 'my_icons.dart';
import 'package:anime/auxiliar/import.dart';
import 'package:anime/model/import.dart';

class Layouts {
  static Widget _fotoAnime(Anime item, {double iconSize, BoxFit fit}) {
    bool fotoLocal = item.fotoLocalExist;

    return fotoLocal ?
    fotoFile(item.fotoToFile, iconSize: iconSize, fit: fit) :
    item.miniatura.isEmpty ? Icon(Icons.image) :
    fotoNetwork(item.miniatura, iconSize: iconSize, fit: fit);
  }

  static Widget fotoFile(File file, {double iconSize, BoxFit fit}) => Image.file(file, fit: fit, width: iconSize, height: iconSize, errorBuilder: (c, u, e) => Icon(Icons.image));
  static Widget fotoNetwork(String url, {double iconSize, BoxFit fit}) =>
      Image.network(
        url, fit: fit, width: iconSize, height: iconSize, errorBuilder: (c, u, e) => Icon(Icons.image),
        loadingBuilder: (context, widget, progress) {
          if (progress == null) return widget;
          return Icon(Icons.image);
        },
      );

  static Widget _animeItemList (AnimeCollection items, {ListType listType, @required onTap(), Widget trailing, bool showSeconfName = false}) {
    var media = items.media;
    String subtitle = '';
    if (showSeconfName && items.nome2 != null)
      subtitle = items.nome2;
    else if ((listType.isOnline || listType.isConcluidos) && media >= 0)
      subtitle = 'Media: $media';
    else if (listType.isAssistindo) {
      if (items.items.length == 1)
        subtitle = 'Ultimo assistido: ${items.getItem(0).ultimoAssistido}';
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

    var animesTV = items.itemsToList.where((e) => e.tipo == AnimeType.TV).toList();
    var ultimoAnime = animesTV.length > 0 ? animesTV[animesTV.length -1] : items.getItem(items.items.length -1);

    String itemsCount = items.items.length <= 1 ? '' : '(${items.items.length})';
    // var icon = getIcon(ultimoAnime.tipo);
    return Hero(
      tag: items.id,
      child: ListTile(
        contentPadding: EdgeInsets.only(bottom: 3),
        leading: FotoAnime(ultimoAnime),
        title: Text('${items.nome} $itemsCount'),
        subtitle: Row(children: [
          Expanded(child: Text(subtitle)),
          if (items.isDataInicioFimIguais)
            Text(items.anoFim)
          else
            Text('${items.anoInicio} - ${items.anoFim}'),
        ]),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  static Widget _animeItemGrid(AnimeCollection items, {ListType listType, @required onTap(), onLongPress(), Widget footer, bool isOrientationPortrait = true}) {
    var textStyle = TextStyle(color: isOrientationPortrait ? OkiTheme.text : OkiTheme.textInvert());

    var animesTV = items.itemsToList.where((e) => e.tipo == AnimeType.TV).toList();
    var ultimoAnime = animesTV.length > 0 ? animesTV[animesTV.length -1] : items.getItem(items.items.length -1);

//    var ultimoAnime = items.getItem(items.items.length -1);
    var icon = getIcon(ultimoAnime.tipo);
    var media = items.media;
    String subtitle = '';
    if (items.nome2 != null)
      subtitle = '${items.nome2}\n';
    subtitle += 'Episódios: ${items.episodios}';

    if ((listType.isOnline || listType.isConcluidos) && media >= 0)
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
          color: isOrientationPortrait ? Colors.black87 : OkiTheme.tint,
          child: isOrientationPortrait ? Column(
            children: [
              Expanded(child: FotoAnime(ultimoAnime, fit: BoxFit.fitHeight)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: Text(items.nome, maxLines: 1, style: TextStyle(color: OkiTheme.text)),
              )
            ],
          ) :
          Row(
              children: [
                FotoAnime(ultimoAnime, fit: BoxFit.fitHeight),
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

  static Widget _animeItemLayout(Anime item, {@required ListType listType, @required onTap(), Widget trailing, bool showSeconfName = false}) {
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
    else if ((listType.isOnline || listType.isConcluidos) && media >= 0)
      subtitle += '\nMedia: $media';
    else if (listType.isAssistindo)
      subtitle += '\nUltimo: ${item.ultimoAssistido}';

    subtitle += '\nAno: ${item.ano}';

    var icon = getIcon(item.tipo);
    return ListTile(
      contentPadding: EdgeInsets.only(bottom: 5),
      leading: FotoAnime(item),
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
      case AnimeType.TV:
        return Icon(Icons.tv);
        break;
      case AnimeType.OVA:
        return Icon(MyIcons.egg, size: 20);
        break;
      case AnimeType.ONA:
        return Icon(Icons.wifi_tethering);
        break;
      case AnimeType.MOVIE:
        return Icon(Icons.video_call);
        break;
      case AnimeType.SPECIAL:
        return Icon(Icons.star);
        break;
      case AnimeType.INDEFINIDO:
        return Icon(Icons.error);
        break;
      default:
        return Icon(Icons.circle, color: Colors.transparent);
    }
  }

  static Widget teste(AnimeCollection item, UserOki user, {bool isGrid = false}) {
    double iconSize = 15.0;
    String id = item.id;
    if (isGrid)
      return Row(
          children: [
            if(user.assistindo.containsKey(id))
              Icon(Icons.list, size: iconSize, color: OkiTheme.tint),
            if(user.favoritos.containsKey(id))
              Icon(Icons.favorite, size: iconSize, color: OkiTheme.tint),
            if(user.concluidos.containsKey(id))
              Icon(Icons.offline_pin, size: iconSize, color: OkiTheme.tint),
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
  static Widget teste2(Anime item, UserOki user) {
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

  static Widget _splashScreen({bool mostrarLog = false}) {
    var padding = Padding(padding: EdgeInsets.only(top: 10));
    return Scaffold(
      backgroundColor: OkiTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(MyIcons.ic_launcher, width: 200),
            padding,
            Text(AppResources.APP_NAME, style: TextStyle(fontSize: 30, color: OkiTheme.text)),
            if (mostrarLog)...[
              padding,
              Text('Parece que sua conexão está sem Chakra\nIniciando modo Offline', style: TextStyle(color: OkiTheme.text)),
              LinearProgressIndicator(backgroundColor: OkiTheme.primary)
            ],
          ],
        ),
      ),
    );
  }

  static List<DropdownMenuItem<String>> dropDownMenuItems(List list) {
    List<DropdownMenuItem<String>> items = new List();
    for (String value in list) {
      items.add(new DropdownMenuItem(
          value: value,
          child: new Text(value)
      ));
    }
    return items;
  }

  static Padding adsFooter([Widget child]) {
    double value = 0;
    if (RunTime.mostrandoAds)
      value = 50;
    return Padding(padding: EdgeInsets.only(bottom: value), child: child);
  }
  static EdgeInsets adsPadding(double value, [double top, double right, double botton]) {
    double temp = 0;
    if (RunTime.mostrandoAds)
      temp = 50;
    return EdgeInsets.fromLTRB(value, top ?? value, right ?? value, (botton ?? value) + temp);
  }
}

class AnimeItemGrid extends StatelessWidget {

  final AnimeCollection items;
  final ListType listType;
  final Widget footer;
  final bool isOrientationPortrait;
  final Function onTap;

  AnimeItemGrid(this.items, {this.listType, @required this.onTap(), this.footer, this.isOrientationPortrait = true});

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(color: isOrientationPortrait ? OkiTheme.text : OkiTheme.textInvert());

    var animesTV = items.itemsToList.where((e) => e.tipo == AnimeType.TV).toList();
    var ultimoAnime = animesTV.length > 0 ? animesTV[animesTV.length -1] : items.getItem(items.items.length -1);

//    var ultimoAnime = items.getItem(items.items.length -1);
    var icon = Layouts.getIcon(ultimoAnime.tipo);
    var media = items.media;
    String subtitle = '';
    if (items.nome2 != null)
      subtitle = '${items.nome2}\n';
    subtitle += 'Episódios: ${items.episodios}';

    if ((listType.isOnline || listType.isConcluidos) && media >= 0)
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
          color: isOrientationPortrait ? Colors.black87 : OkiTheme.tint,
          child: isOrientationPortrait ? Column(
            children: [
              Expanded(child: FotoAnime(ultimoAnime, fit: BoxFit.fitHeight)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: Text(items.nome, maxLines: 1, style: TextStyle(color: OkiTheme.text)),
              )
            ],
          ) :
          Row(
              children: [
                FotoAnime(ultimoAnime, fit: BoxFit.fitHeight),
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
    );
  }

}

class AnimeItemList extends StatelessWidget {

  final AnimeCollection items;
  final ListType listType;
  final Widget trailing;
  final bool showSeconfName;
  final Function onTap;

  AnimeItemList(this.items, {this.listType, @required this.onTap(), this.trailing, this.showSeconfName = false});

  @override
  Widget build(BuildContext context) {
    var media = items.media;
    String subtitle = '';
    if (showSeconfName && items.nome2 != null)
      subtitle = items.nome2;
    else if ((listType.isOnline || listType.isConcluidos) && media >= 0)
      subtitle = 'Media: $media';
    else if (listType.isAssistindo) {
      if (items.items.length == 1)
        subtitle = 'Ultimo assistido: ${items.getItem(0).ultimoAssistido}';
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

    var animesTV = items.itemsToList.where((e) => e.tipo == AnimeType.TV).toList();
    var ultimoAnime = animesTV.length > 0 ? animesTV[animesTV.length -1] : items.getItem(items.items.length -1);

    String itemsCount = items.items.length <= 1 ? '' : '(${items.items.length})';
    // var icon = getIcon(ultimoAnime.tipo);
    return Hero(
      tag: items.id,
      child: ListTile(
        contentPadding: EdgeInsets.only(bottom: 3),
        leading: FotoAnime(ultimoAnime),
        title: Text('${items.nome} $itemsCount'),
        subtitle: Row(children: [
          Expanded(child: Text(subtitle)),
          if (items.isDataInicioFimIguais)
            Text(items.anoFim)
          else
            Text('${items.anoInicio} - ${items.anoFim}'),
        ]),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

}

class AnimeItemLayout extends StatelessWidget {

  final Anime item;
  final ListType listType;
  final Widget trailing;
  final bool showSeconfName;
  final Function onTap;
  AnimeItemLayout(this.item, {@required this.listType, @required this.onTap(), this.trailing, this.showSeconfName = false});

  @override
  Widget build(BuildContext context) {
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
    else if ((listType.isOnline || listType.isConcluidos) && media >= 0)
      subtitle += '\nMedia: $media';
    else if (listType.isAssistindo)
      subtitle += '\nUltimo: ${item.ultimoAssistido}';

    subtitle += '\nAno: ${item.ano}';

    var icon = Layouts.getIcon(item.tipo);
    return ListTile(
      contentPadding: EdgeInsets.only(bottom: 5),
      leading: FotoAnime(item),
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

}

class FotoAnime extends StatelessWidget {
  final Anime item;
  final double iconSize;
  final BoxFit fit;
  FotoAnime(this.item, {this.iconSize, this.fit});

  @override
  Widget build(BuildContext context) {
    bool fotoLocal = item.fotoLocalExist;
    return fotoLocal ?
    Layouts.fotoFile(item.fotoToFile, iconSize: iconSize, fit: fit) :
    item.miniatura.isEmpty ? Icon(Icons.image) :
    Layouts.fotoNetwork(item.miniatura, iconSize: iconSize, fit: fit);
  }

}

class SplashScreen extends StatelessWidget {

  final bool mostrarLog;

  SplashScreen({this.mostrarLog = false});
  @override
  Widget build(BuildContext context) {
    var padding = Padding(padding: EdgeInsets.only(top: 10));
    return Scaffold(
      backgroundColor: OkiTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(MyIcons.ic_launcher, width: 200),
            padding,
            Text(AppResources.APP_NAME, style: TextStyle(fontSize: 30, color: OkiTheme.text)),
            if (mostrarLog)...[
              padding,
              Text('Parece que sua conexão está sem Chakra\nIniciando modo Offline', style: TextStyle(color: OkiTheme.text)),
              LinearProgressIndicator(backgroundColor: OkiTheme.primary)
            ],
          ],
        ),
      ),
    );
  }

}