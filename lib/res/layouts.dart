import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import '../manager/import.dart';
import '../model/import.dart';
import '../res/import.dart';
import 'import.dart';

class OkiTextField extends StatelessWidget {
  final String hint;
  final String initialValue;
  final TextEditingController controller;
  final Widget icon;
  final bool textIsEmpty;
  final bool isPassword;
  final bool readOnly;
  final Function(String) onChanged;
  final Function onTap;
  final int maxLines;
  final FocusNode focus;
  final TextStyle style;
  final TextInputType textInputType;
  final TextInputAction action;
  // final List<TextInputFormatter> formatters;
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSave;

  OkiTextField({
    this.hint,
    this.initialValue,
    this.controller,
    this.icon,
    this.textIsEmpty = false,
    this.isPassword = false,
    this.readOnly = false,
    this.textInputType,
    this.maxLines = 1,
    // this.formatters,
    this.focus,
    this.style,
    this.action,
    this.onTap,
    this.onChanged,
    this.validator,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        minLines: 1,
        focusNode: focus,
        initialValue: initialValue,
        readOnly: readOnly,
        obscureText: isPassword,
        keyboardType: textInputType,
        style: style,
        textInputAction: action,
        decoration: InputDecoration(
          suffixIcon: icon,
          labelText: hint,
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: style?.color?.withOpacity(0.2) ?? Colors.black38
              )
          ),
          labelStyle: style?.copyWith(
              color: style.color.withAlpha(120)
          ),
        ),
        onTap: onTap,
        onChanged: onChanged,
        validator: validator,
        onSaved: onSave,
      ),
    );
  }
}

class OkiButton extends StatelessWidget {
  final Widget child;
  final Color color;
  final Function onPressed;
  OkiButton({this.child, this.color = OkiColors.primary, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: child,
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color),
      ),
    );
  }
}

class OkiDropDown extends StatelessWidget {
  final List<String> items;
  final Function(String) onChanged;
  final String text;
  final String info;
  final String value;
  final TextStyle style;
  final Color dropdownColor;
  OkiDropDown({this.text, @required this.items, this.info, this.style, this.dropdownColor, @required this.onChanged, @required this.value});

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> temp = [];
    String valueZero = '';
    bool semValor = false;

    if (items.isNotEmpty) {
      valueZero = items[0];
      semValor = !items.contains(value);
    }

    for (String value in items) {
      temp.add(new DropdownMenuItem(value: value, child: Text(value, style: style)));
    }
    return ListTile(
      title: text == null ? null : Text(text, style: style),
      subtitle: info == null ? null : Text(info, style: style),
      trailing: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: DropdownButton(
          value: semValor ? valueZero : value,
          disabledHint: Text(semValor ? valueZero : value),
          items: temp,
          onChanged: onChanged,
          dropdownColor: dropdownColor,
        ),
      ),
    );
  }
}

class OkiSlider extends StatelessWidget {
  final String title;
  final String label;
  final double value;
  final Color color;
  final Function(double) onChanged;
  OkiSlider({this.title, this.label, this.value, this.color, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(title ?? ''),
      title: Slider(
        value: value,
        min: -1,
        max: 10,
        divisions: 11,

        activeColor: color,
        onChanged: (value) => onChanged?.call(value),
        onChangeEnd: (value) {

        },
      ),
      trailing: Text('${value.toInt()}'),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final bool mostrarLog;

  SplashScreen({this.mostrarLog = false});
  @override
  Widget build(BuildContext context) {
    var padding = Padding(padding: EdgeInsets.only(top: 10));
    return Scaffold(
      backgroundColor: OkiColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(MyIcons.ic_launcher_adaptive, width: 200),
            padding,
            Text(AppResources.APP_NAME,
                style: TextStyle(fontSize: 30, color: OkiColors.textDark)),
            if (mostrarLog) ...[
              padding,
              Text(
                  'Parece que sua conexão está sem Chakra\nIniciando modo Offline',
                  style: TextStyle(color: OkiColors.textDark)),
              LinearProgressIndicator(backgroundColor: OkiColors.primary)
            ],
          ],
        ),
      ),
    );
  }
}

class AnimeItemGrid extends StatelessWidget {
  final Anime anime;
  final Function(Anime) onClick;
  AnimeItemGrid({this.anime, @required this.onClick});

  @override
  Widget build(BuildContext context) {
    Color colorC = getColorCrunch(anime);
    Color colorF = getColorFun(anime) ?? colorC ?? Colors.black87;

    return GestureDetector(
      child: Card(
        margin: EdgeInsets.zero,
        child: GridTile(
          header: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black12,
                ),
              ],
            ),
            padding: EdgeInsets.all(3),
            child: Row(
              children: [
                if (anime.isFavorited)
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 15,
                  )
                else if (anime.containsFavorite)
                  Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 15,
                  ),
              ],
            ),
          ),
          child: MiniaturaAnime(anime),
          footer: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  if (colorC != null)
                    colorC
                  else
                    colorF,
                  colorF,
                ]
              )
            ),
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            child: Text(anime.nome, maxLines: 1, style: TextStyle(color: Colors.white),),
          ),
        ),
      ),
      onTap: () => onClick?.call(anime),
    );
  }
}

class AnimeItemList extends StatelessWidget {
  final Anime anime;
  final bool showSeconfName;
  final Function(Anime) onClick;

  AnimeItemList({this.anime, this.onClick, this.showSeconfName = true});

  @override
  Widget build(BuildContext context) {
    double media = anime.media;
    List<String> subtitle = [];
    if (showSeconfName && anime.nome2 != null)
      subtitle.add(anime.nome2);
    if (media >= 0)
      subtitle.add('Media: ${media.toStringAsFixed(2)}');
    if (anime.isFavorited) {
      if (anime.length == 1)
        subtitle.add('Ultimo assistido: ${anime.getAt(0).ultimoAssistido}');
    }

    int eps = anime.episodios;
    if (eps != 0) {
      int temp = eps < 0 ? eps * -1 : eps;
      if (temp > 1) {
        var epsS = eps < 0 ? '${eps * -1}+' : '$eps';
        subtitle.add('Epi: $epsS');
      }
    }

    String itemsCount = anime.isCollection ? '(${anime.length})' : '';

    return Row(
      children: [
        Container(
          color: getColorCrunch(anime),
          height: 50,
          width: 2,
        ),
        Expanded(
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
            child: ListTile(
              leading: MiniaturaAnime(anime),
              title: Text('${anime.nome} $itemsCount', maxLines: 1,),
              subtitle: Text(subtitle.join('\n')),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (anime.isFavorited)
                    Icon(
                      Icons.favorite,
                      size: 15,
                    )
                  else if (anime.containsFavorite)
                    Icon(
                      Icons.favorite_border,
                      size: 15,
                    ),
                  if (anime.isDataInicioFimIguais)
                    Text(anime.anoFim)
                  else
                    Text('${anime.anoInicio} - ${anime.anoFim}'),
                ],
              ),
              onTap: () => onClick?.call(anime),
            ),
          ),
        ),
        Container(
          color: getColorFun(anime),
          height: 50,
          width: 2,
        ),
      ],
    );
  }
}

Color getColorCrunch(Anime anime) {
  if (anime.isCrunchyroll || anime.parent.isCrunchyroll)
    return OkiColors.accent;
  return null;
}
Color getColorFun(Anime anime) {
  if (anime.isFunimation || anime.parent.isFunimation)
    return Colors.deepPurple;
  return null;
}

class MiniaturaAnime extends StatelessWidget {
  final Anime item;
  MiniaturaAnime(this.item);

  @override
  Widget build(BuildContext context) {
    return Image(
      image: NetworkToFileImage(
        url: item.miniatura,
        file: item.previewFile,
      ),
      fit: BoxFit.cover,
      errorBuilder: (c, o, e) => Icon(Icons.image),
      loadingBuilder: (context, widget, progress) {
        if (progress == null) return widget;
        return CircularProgressIndicator();
      },
    );
  }
}

class AnimeTypeIcon extends StatelessWidget {
  final String value;
  AnimeTypeIcon({this.value});

  @override
  Widget build(BuildContext context) {
    switch (value) {
      case AnimeType.TV:
        return Icon(Icons.tv);
      case AnimeType.OVA:
        return Icon(MyIcons.egg, size: 20);
      case AnimeType.ONA:
        return Icon(Icons.wifi_tethering);
      case AnimeType.MOVIE:
        return Icon(Icons.video_call);
      case AnimeType.SPECIAL:
        return Icon(Icons.star);
      case AnimeType.INDEFINIDO:
        return Icon(Icons.error);
      default:
        return Icon(Icons.circle, color: Colors.transparent);
    }
  }
}

EdgeInsets adsPadding({bool showingAds = false, double all = 0, double top, double left, double right, double botton}) {
  double temp = 0;
  if (showingAds) temp = 50;
  return EdgeInsets.fromLTRB(left ?? all, top ?? all, right ?? all, (botton ?? all) + temp);
}
