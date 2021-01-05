import 'package:anime/auxiliar/import.dart';
import 'package:anime/res/import.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePage extends StatefulWidget {
  final String link;
  YouTubePage(this.link);

  @override
  _State createState() => _State(link);
}

class _State extends State<YouTubePage> {
  YoutubePlayerController _controller;

  YoutubeMetaData _videoMetaData;
  bool _isPlayerReady = false;

  final String link;

  _State(this.link);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _setOrientation(DeviceOrientation.values);

    _controller = YoutubePlayerController(
      initialVideoId: link,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _videoMetaData = const YoutubeMetaData();

    _controller.play();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _setOrientation([ DeviceOrientation.portraitUp ]);
          return true;
        },
        child: YoutubePlayerBuilder(
          onExitFullScreen: () {},
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: OkiTheme.primary,
            topActions: <Widget>[
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _controller.metadata.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
            onReady: () {
              _isPlayerReady = true;
            },
            onEnded: (data) {
              // _controller.load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
              // Log.snack('Next Video Started!');
            },
          ),
          builder: (context, player) => Scaffold(
            appBar: AppBar(title: const Text('Trailer', style: TextStyle(color: Colors.white))),
            body: ListView(
              children: [
                player,
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _space,
                      _text(_videoMetaData.title),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  Widget _text(String value) {
    return RichText(
      text: TextSpan(
        text: value ?? '',
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget get _space => const SizedBox(height: 10);

  void _setOrientation(List<DeviceOrientation> orientacoes) {
    SystemChrome.setPreferredOrientations(orientacoes);
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _videoMetaData = _controller.metadata;
      });
    }
  }

}