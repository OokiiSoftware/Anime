import '../manager/admob_manager.dart';
import 'package:flutter/material.dart';

class AdsFooter extends StatefulWidget {
  final Widget child;
  AdsFooter({this.child});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<AdsFooter> {

  bool _showingAds = false;

  @override
  void dispose() {
    super.dispose();
    AdMobManager.i.removeListener(_onAdsChanged);
  }

  @override
  void initState() {
    super.initState();
    AdMobManager.i.addListener(_onAdsChanged);
  }

  @override
  Widget build(BuildContext context) {
    double value = 0;
    if (_showingAds)
      value = 50;
    return Padding(
      padding: EdgeInsets.only(bottom: value),
      child: widget.child ?? Container(),
    );
  }

  void _onAdsChanged(bool showing) {
    if (mounted)
    setState(() {
      _showingAds = showing;
    });
  }
}

class AdsPadding extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  AdsPadding({this.child, this.padding = const EdgeInsets.all(10)});

  @override
  State<StatefulWidget> createState() => _StatePadding();
}
class _StatePadding extends State<AdsPadding> {

  bool _showingAds = false;

  @override
  void dispose() {
    super.dispose();
    AdMobManager.i.removeListener(_onAdsChanged);
  }

  @override
  void initState() {
    super.initState();
    AdMobManager.i.addListener(_onAdsChanged);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = widget.padding.bottom;
    return Padding(
      padding: widget.padding.copyWith(bottom: _showingAds ? bottom + 40 : bottom),
      child: widget.child ?? Container(),
    );
  }

  void _onAdsChanged(bool showing) {
    if (mounted)
      setState(() {
        _showingAds = showing;
      });
  }
}
