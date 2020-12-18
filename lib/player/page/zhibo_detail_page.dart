import 'dart:async';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/event/event_bus.dart';
import 'package:ZY_Player_flutter/event/event_model.dart';
import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:ZY_Player_flutter/player/provider/detail_provider.dart';
import 'package:ZY_Player_flutter/player/widget/diy_fijkPanel.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ZhiboDetailPage extends StatefulWidget {
  const ZhiboDetailPage({
    Key key,
    @required this.url,
    @required this.title,
  }) : super(key: key);

  final String url;
  final String title;

  @override
  _ZhiboDetailPageState createState() => _ZhiboDetailPageState();
}

class _ZhiboDetailPageState extends State<ZhiboDetailPage> with WidgetsBindingObserver {
  final FijkPlayer _player = FijkPlayer();

  bool startedPlaying = false;

  DetailProvider _detailProvider = DetailProvider();
  CollectProvider _collectProvider;
  AppStateProvider appStateProvider;
  StreamSubscription _currentPosSubs;

  String actionName = "";
  bool _isFullscreen = false;

  int currentVideoIndex = -1;
  Timer searchTimer;

  String currentUrl = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _collectProvider = Store.value<CollectProvider>(context);
    appStateProvider = Store.value<AppStateProvider>(context);
    _collectProvider.setListDetailResource("collcetPlayer");
    _player.addListener(_fijkValueListener);

    initData();

    ApplicationEvent.event.on<DeviceEvent>().listen((event) async {
      Toast.show("推送视频 ${widget.title} 到设备：${event.devicesName}");
      await appStateProvider.dlnaManager.setDevice(event.devicesId);
      await appStateProvider.dlnaManager.setVideoUrlAndName(widget.url, widget.title);
      appStateProvider.setloadingState(false);
    });

    super.initState();
  }

  Future _fijkValueListener() async {
    FijkValue value = _player.value;
    _isFullscreen = value.fullScreen;
  }

  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    _isFullscreen
        ? SystemChrome.setEnabledSystemUIOverlays([])
        : SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('app lifecycle state: $state');
    if (state == AppLifecycleState.inactive) {
      _player.pause();
    } else if (state == AppLifecycleState.resumed) {
      _player.start();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    super.dispose();
    _player.removeListener(_fijkValueListener);
    _player.release();
    _currentPosSubs?.cancel();
  }

  Future initData() async {
    await setPlayerVideo();
    _player.setDataSource(widget.url, autoPlay: true);
  }

  Future setPlayerVideo() async {
    await _player.applyOptions(FijkOption()
      ..setFormatOption('fflags', 'fastseek')
      ..setHostOption('request-screen-on', 1)
      ..setHostOption('request-audio-focus', 1)
      ..setCodecOption('cover-after-prepared', 1)
      ..setPlayerOption('framedrop', 5)
      ..setPlayerOption('packet-buffering', 1)
      ..setPlayerOption('mediacodec', 1)
      ..setPlayerOption('enable-accurate-seek', 1)
      ..setPlayerOption('reconnect', 5)
      ..setPlayerOption('render-wait-start', 1));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final bool isDark = themeData.brightness == Brightness.dark;

    final bool fill = true;
    final int duration = 4000;
    final bool doubleTap = true;
    final bool snapShot = true;

    return ChangeNotifierProvider<DetailProvider>(
      create: (_) => _detailProvider,
      child: Scaffold(
          backgroundColor: Colors.black,
          key: _scaffoldKey,
          appBar: MyAppBar(
            title: widget.title,
            isBack: true,
          ),
          body: Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: ScreenUtil.getInstance().getWidth(230),
              child: FijkView(
                player: _player,
                color: Colors.black,
                panelBuilder: (player, data, BuildContext context, Size viewSize, Rect texturePos) {
                  return DiyFijkPanel(
                    player: player,
                    onBack: () {
                      player.exitFullScreen();
                    },
                    data: data,
                    viewSize: viewSize,
                    texPos: texturePos,
                    fill: fill,
                    doubleTap: doubleTap,
                    snapShot: snapShot,
                    hideDuration: duration,
                    isZhibo: true,
                  );
                },
                fsFit: FijkFit.ar16_9,
              ),
            ),
          )),
    );
  }
}
