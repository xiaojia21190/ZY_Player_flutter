import 'dart:async';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/event/event_bus.dart';
import 'package:ZY_Player_flutter/event/event_model.dart';
import 'package:ZY_Player_flutter/player/provider/detail_provider.dart';
import 'package:ZY_Player_flutter/player/widget/my_controller.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

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
  bool startedPlaying = false;

  DetailProvider _detailProvider = DetailProvider();
  CollectProvider _collectProvider;
  AppStateProvider appStateProvider;
  StreamSubscription _currentPosSubs;

  String actionName = "";

  int currentVideoIndex = -1;
  Timer searchTimer;

  String currentUrl = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _collectProvider = Store.value<CollectProvider>(context);
    appStateProvider = Store.value<AppStateProvider>(context);
    _collectProvider.setListDetailResource("collcetPlayer");

    initData();

    ApplicationEvent.event.on<DeviceEvent>().listen((event) async {
      Toast.show("推送视频 ${widget.title} 到设备：${event.devicesName}");
      await appStateProvider.dlnaManager.setDevice(event.devicesId);
      await appStateProvider.dlnaManager.setVideoUrlAndName(widget.url, widget.title);
      appStateProvider.setloadingState(false);
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _videoPlayerController?.dispose();
    _videoPlayerController?.removeListener(_videoListener);
    _chewieController?.dispose();
    _currentPosSubs?.cancel();
  }

  void _videoListener() async {
    if (_videoPlayerController.value.initialized) {
      _detailProvider.setInitPlayer(true);
    }
  }

  Future initData() async {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.pause();

    _videoPlayerController = VideoPlayerController.network(widget.url);
    await _videoPlayerController.initialize();
    _videoPlayerController.addListener(_videoListener);
    _chewieController = ChewieController(
      customControls: MyControls(widget.title),
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      allowedScreenSleep: false,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      placeholder: CachedNetworkImage(imageUrl: 'https://tva2.sinaimg.cn/large/007UW77jly1g5elwuwv4rj30sg0g0wfo.jpg'),
      autoInitialize: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final bool isDark = themeData.brightness == Brightness.dark;

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
              child: Selector<DetailProvider, bool>(
                  builder: (_, isplayer, __) {
                    return isplayer
                        ? Chewie(
                            controller: _chewieController,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(height: 20),
                              Text(
                                'Loading',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          );
                  },
                  selector: (_, store) => store.isInitPlayer),
            ),
          )),
    );
  }
}
