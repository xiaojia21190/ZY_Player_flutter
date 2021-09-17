import 'dart:async';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/event/event_bus.dart';
import 'package:ZY_Player_flutter/event/event_model.dart';
import 'package:ZY_Player_flutter/player/provider/detail_provider.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/res/styles.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/utils.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/xiaoshuo/widget/batter_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen/flutter_screen.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ZhiboDetailPage extends StatefulWidget {
  const ZhiboDetailPage({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);
  final String url;
  final String title;

  @override
  _ZhiboDetailPageState createState() => _ZhiboDetailPageState();
}

class _ZhiboDetailPageState extends State<ZhiboDetailPage> with WidgetsBindingObserver {
  bool startedPlaying = false;

  DetailProvider _detailProvider = DetailProvider();
  CollectProvider? _collectProvider;
  AppStateProvider? appStateProvider;

  String actionName = "";

  int currentVideoIndex = -1;
  Timer? searchTimer;

  String currentUrl = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    _collectProvider = Store.value<CollectProvider>(context);
    appStateProvider = Store.value<AppStateProvider>(context);

    initData();

    getLight();

    ApplicationEvent.event.on<DeviceEvent>().listen((event) async {
      if (event.device == 1) return;
      // 弹出dlna的弹窗
      if (mounted) {
        dlnaDevicesDialog();
      }
    });

    super.initState();
  }

  Future getLight() async {
    light = await FlutterScreen.brightness;
  }

  @override
  void dispose() {
    super.dispose();

    _videoPlayerController?.dispose();
    _videoPlayerController?.removeListener(_videoListener);
    _chewieController?.dispose();
  }

  void _videoListener() async {
    if (_videoPlayerController!.value.isInitialized) {
      _detailProvider.setInitPlayer(true);
    }
  }

  dlnaDevicesDialog() {
    showElasticDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
              child: Container(
                  decoration: BoxDecoration(
                    color: context.dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  width: 270,
                  height: 200,
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    children: <Widget>[
                      const Text(
                        '可以投屏的设备',
                        style: TextStyles.textBold18,
                      ),
                      Gaps.vGap16,
                      Expanded(
                        child: Selector<AppStateProvider, List>(
                            builder: (_, devices, __) {
                              return ListView.separated(
                                itemCount: devices.length,
                                itemBuilder: (_, index) {
                                  return TextButton(
                                    child: Text(devices[index]["name"]),
                                    onPressed: () async {
                                      _chewieController!.pause();
                                      Toast.show("推送视频 ${widget.title} 到设备：${devices[index]["name"]}");
                                      await appStateProvider!.dlnaManager.setDevice(devices[index]["id"]);
                                      await appStateProvider!.dlnaManager.setVideoUrlAndName(widget.url, widget.title);
                                      await appStateProvider!.dlnaManager.startAndPlay();
                                      appStateProvider!.setloadingState(false);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                                separatorBuilder: (_, index) => const Divider(),
                              );
                            },
                            selector: (_, store) => store.dlnaDevices),
                      )
                    ],
                  ))),
        );
      },
    );
  }

  searchDialog() {
    // 提示是否继续搜索
    appStateProvider!.setSearchText("设备搜索超时");
    showDialog(
        context: context,
        builder: (_) => Selector<AppStateProvider, String>(
            builder: (_, words, __) {
              return FlareGiffyDialog(
                flarePath: 'assets/images/space_demo.flr',
                flareAnimation: 'loading',
                title: Text(words, textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
                description: Text(
                  '请打开相关设备后点击重新搜索',
                  textAlign: TextAlign.center,
                ),
                entryAnimation: EntryAnimation.BOTTOM,
                buttonOkText: Text("重新搜索"),
                buttonCancelText: Text("停止搜索"),
                onOkButtonPressed: () async {
                  await appStateProvider!.searchDlna(0);
                },
                onCancelButtonPressed: () async {
                  Navigator.pop(context);
                  await appStateProvider!.dlnaManager.stop();
                },
              );
            },
            selector: (_, store) => store.searchText));
  }

  Offset? _initialVerLightOffset;
  Offset? _finalVerLightOffset;
  double light = 0;

  void _onVerticalDragStart(DragStartDetails details) {
    _initialVerLightOffset = details.globalPosition;
  }

  Future _onVerticalDragUpdate(DragUpdateDetails details) async {
    _finalVerLightOffset = details.globalPosition;
    final offsetDifference = _initialVerLightOffset!.dy - _finalVerLightOffset!.dy;
    var offsetAbs = offsetDifference.abs() / 300;
    // Log.d(offsetAbs.toString());
    var entLight;
    if (offsetDifference > 0) {
      entLight = light + offsetAbs;
      if (entLight >= 1) {
        entLight = 1.0;
      }
      FlutterScreen.setBrightness(entLight);
    } else {
      entLight = light - offsetAbs;
      if (entLight <= 0) {
        entLight = 0.0;
      }
      FlutterScreen.setBrightness(entLight);
    }
    var verLightText = "亮度：${(entLight * 100).toInt()}%";
    appStateProvider!.setVerLight(true, verLightText);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_initialVerLightOffset != null) {
      getLight();
      appStateProvider!.setVerLight(false, "");
    }
  }

  Future initData() async {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.pause();

    _videoPlayerController = VideoPlayerController.network(widget.url);
    await _videoPlayerController!.initialize();
    _videoPlayerController!.addListener(_videoListener);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        allowedScreenSleep: false,
        looping: false,
        isLive: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        placeholder: CachedNetworkImage(imageUrl: 'https://tva2.sinaimg.cn/large/007UW77jly1g5elwuwv4rj30sg0g0wfo.jpg'),
        autoInitialize: true,
        routePageBuilder: (context, animation, __, provider) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Scaffold(
                  backgroundColor: Colors.black,
                  body: GestureDetector(
                    onVerticalDragStart: _onVerticalDragStart,
                    onVerticalDragUpdate: _onVerticalDragUpdate,
                    onVerticalDragEnd: _onVerticalDragEnd,
                    child: Stack(children: [
                      Container(
                        alignment: Alignment.center,
                        child: provider,
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: TextButton.icon(
                              onPressed: () async {
                                // 取消全屏
                                _chewieController!.exitFullScreen();
                                // 延迟点击
                                Future.delayed(Duration(seconds: 1), () {
                                  // 点击显示投屏数据
                                  if (appStateProvider!.dlnaDevices.length == 0) {
                                    // 没有搜索到
                                    searchDialog();
                                  } else {
                                    // 搜索到了
                                    dlnaDevicesDialog();
                                  }
                                });
                              },
                              icon: Icon(
                                Icons.present_to_all_sharp,
                                color: Colors.white,
                              ),
                              label: Text(
                                "投屏",
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ),
                      Consumer<AppStateProvider>(builder: (_, _detailProvider, __) {
                        return _detailProvider.verLight
                            ? Positioned.fill(
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: 30,
                                      width: 80,
                                      decoration: BoxDecoration(color: Colours.dark_bg_color, borderRadius: BorderRadius.circular(10)),
                                      child: Center(
                                        child: Text(
                                          _detailProvider.verLightText,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )),
                              )
                            : Container();
                      }),
                      Positioned.fill(
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Text(
                                    "剩余电量:",
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  Gaps.hGap5,
                                  BatteryView()
                                ],
                              ),
                            )),
                      ),
                    ]),
                  ));
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DetailProvider>(
      create: (_) => _detailProvider,
      child: Scaffold(
          backgroundColor: Colors.black,
          key: _scaffoldKey,
          appBar: MyAppBar(
            title: widget.title,
            isBack: true,
          ),
          body: Stack(
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 230,
                  child: Selector<DetailProvider, bool>(
                      builder: (_, isplayer, __) {
                        return isplayer
                            ? Chewie(
                                controller: _chewieController!,
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
              ),
            ],
          )),
    );
  }
}
