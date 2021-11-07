import 'package:flutter/material.dart';
import '../model/import.dart';
import '../res/import.dart';

class AnimesFragment extends StatelessWidget{
  final bool isListMode;
  final Anime anime;
  final Function(Anime) onItemClick;
  AnimesFragment({@required this.anime, this.isListMode = true, this.onItemClick});

  @override
  Widget build(BuildContext context) {
    final list = anime.list;

    if (isListMode)
      return ListView.builder(
        padding: adsPadding(botton: 80),
        itemCount: list.length,
        itemBuilder: (context, index) {
          var item = list[index];
          return AnimeItemList(
            anime: item,
            onClick: onItemClick,
          );
        },
      );

    return GridView.builder(
        itemCount: list.length,
        padding: adsPadding(botton: 80),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            crossAxisCount: 3,
            childAspectRatio: 1/2
        ),
        itemBuilder: (context, index) {
          var item = list[index];
          return AnimeItemGrid(
            anime: item,
            onClick: onItemClick,
          );
        }
    );
  }

}