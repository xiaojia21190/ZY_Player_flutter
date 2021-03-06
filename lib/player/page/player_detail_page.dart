import 'dart:async';
import 'dart:convert';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/event/event_bus.dart';
import 'package:ZY_Player_flutter/event/event_model.dart';
import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/provider/detail_provider.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/util/qs_common.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/my_scroll_view.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:ZY_Player_flutter/xiaoshuo/widget/batter_view.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen/flutter_screen.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:video_player/video_player.dart';

class PlayerDetailPage extends StatefulWidget {
  const PlayerDetailPage({
    Key key,
    @required this.playerList,
  }) : super(key: key);

  final String playerList;

  @override
  _PlayerDetailPageState createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> with WidgetsBindingObserver {
  bool startedPlaying = false;

  DetailProvider _detailProvider = DetailProvider();
  CollectProvider _collectProvider;
  AppStateProvider appStateProvider;
  StreamSubscription _currentPosSubs;

  String actionName = "";

  int currentVideoIndex = -1;
  String currentVideo = "";
  Timer searchTimer;

  String currentUrl = "";
  String currentUrlName = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Playlist _playlist;

  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  int bofangIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    var result = jsonDecode(widget.playerList);
    _playlist = Playlist.fromJson(result);
    _collectProvider = Store.value<CollectProvider>(context);
    appStateProvider = Store.value<AppStateProvider>(context);
    _collectProvider.setListDetailResource("collcetPlayer");
    bofangIndex = 0;
    initData();

    ApplicationEvent.event.on<DeviceEvent>().listen((event) async {
      // 弹出dlna的弹窗
      dlnaDevicesDialog();
    });

    getLight();
    super.initState();
  }

  Future getLight() async {
    light = await FlutterScreen.brightness;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('app lifecycle state: $state');
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _videoPlayerController?.removeListener(_videoListener);
    _currentPosSubs?.cancel();
    FlutterScreen.resetBrightness();
    super.dispose();
  }

  Future getPlayVideoUrl(String videoUrl, int index) async {
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getPlayVideoUrl, queryParameters: {"url": videoUrl},
        onSuccess: (data) {
      currentUrl = data;
    }, onError: (_, __) {
      currentVideoIndex = index;
      Toast.show("获取链接失败，请从新获取");
      appStateProvider.setloadingState(false);
    });
  }

  Future initData() async {
    _detailProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.detailReource, queryParameters: {"url": _playlist.url},
        onSuccess: (data) {
      if (data != null && data.length > 0) {
        List.generate(data.length, (index) => _detailProvider.addDetailResource(DetailReource.fromJson(data[index])));
        _detailProvider.setJuji();
        _detailProvider.setStateType(StateType.empty);
      } else {
        _detailProvider.setStateType(StateType.network);
      }
      _collectProvider.changeNoti();
      if (getFilterData(_playlist.url)) {
        _detailProvider.setActionName("取消");
      } else {
        _detailProvider.setActionName("收藏");
      }
    }, onError: (_, __) {
      _detailProvider.setStateType(StateType.network);
    });
  }

  Widget buildShare(String image, String title) {
    GlobalKey haibaoKey = GlobalKey();
    return TextButton.icon(
        onPressed: () => {
              showElasticDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return Material(
                    type: MaterialType.transparency,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RepaintBoundary(
                            key: haibaoKey,
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.dialogBackgroundColor,
                              ),
                              width: 300,
                              height: 430,
                              child: Column(
                                children: <Widget>[
                                  LoadImage(
                                    image,
                                    height: 300,
                                    width: 300,
                                    // width: ,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  Expanded(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("分享 虱子聚合"),
                                          Container(
                                            child: Text(
                                              "$title",
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            ),
                                          ),
                                          Text("点击复制链接"),
                                          Text("或者保存到相册分享")
                                        ],
                                      ),
                                      QrImage(
                                        padding: EdgeInsets.all(7),
                                        backgroundColor: Colors.white,
                                        data:
                                            "http://hall.moitech.cn/shizhijuhe/index.html#/playVideo?random=${DateTime.now()}&url=${Uri.encodeComponent(_playlist.url)}",
                                        size: 100,
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                child: const Text('点击复制链接', style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          "http://hall.moitech.cn/shizhijuhe/index.html#/playVideo?random=${DateTime.now()}&url=${Uri.encodeComponent(_playlist.url)}"));
                                  Toast.show("复制链接成功，快去分享吧");
                                },
                              ),
                              TextButton(
                                child: const Text('保存到相册', style: TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  ByteData byteData = await QSCommon.capturePngToByteData(haibaoKey);
                                  // 保存
                                  var result = await QSCommon.saveImageToCamera(byteData);
                                  if (result["isSuccess"]) {
                                    Toast.show("保存成功, 快去分享吧");
                                  } else {
                                    Toast.show("保存失败");
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            },
        icon: Icon(Icons.share),
        label: Text("分享"));
  }

  void _videoListener() async {
    if (_videoPlayerController.value.isInitialized) {
      if (!_detailProvider.isInitPlayer) {
        _detailProvider.setInitPlayer(true);
      }
    }
    _detailProvider.saveRecordNof(
        "${_playlist.url}_${_detailProvider.chooseYuanIndex}_${currentVideoIndex}_${_videoPlayerController.value.position.inSeconds}");

    // 存储播放记录
    PlayerModel playerModel = PlayerModel(
        videoId:
            "${_playlist.url}_${_detailProvider.chooseYuanIndex}_${currentVideoIndex}_${_videoPlayerController.value.position.inSeconds}",
        name:
            "${_playlist.title}_${_detailProvider.detailReource[_detailProvider.chooseYuanIndex].ziyuanUrl[currentVideoIndex].title}",
        url: currentUrl,
        cover: _playlist.cover,
        startAt: "${_videoPlayerController.value.position.inSeconds}");
    appStateProvider.savePlayerRecord(playerModel);
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
                                    _chewieController.pause();
                                    Toast.show(
                                        "推送视频 ${_detailProvider.detailReource[_detailProvider.chooseYuanIndex].ziyuanUrl[currentVideoIndex].title} 到设备：${devices[index]["name"]}");
                                    await appStateProvider.dlnaManager.setDevice(devices[index]["id"]);
                                    await appStateProvider.dlnaManager.setVideoUrlAndName(
                                        currentUrl,
                                        _detailProvider.detailReource[_detailProvider.chooseYuanIndex]
                                            .ziyuanUrl[currentVideoIndex].title);
                                    await appStateProvider.dlnaManager.startAndPlay();
                                    appStateProvider.setloadingState(false);
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
                )),
          ),
        );
      },
    );
  }

  searchDialog() {
    // 提示是否继续搜索
    appStateProvider.setSearchText("设备搜索超时");
    showDialog(
        context: context,
        builder: (_) => Selector<AppStateProvider, String>(
            builder: (_, words, __) {
              return FlareGiffyDialog(
                flarePath: 'assets/images/space_demo.flr',
                flareAnimation: 'loading',
                title: Text(words,
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
                description: Text(
                  '请打开相关设备后点击重新搜索',
                  textAlign: TextAlign.center,
                ),
                entryAnimation: EntryAnimation.BOTTOM,
                buttonOkText: Text("重新搜索"),
                buttonCancelText: Text("停止搜索"),
                onOkButtonPressed: () async {
                  await appStateProvider.searchDlna();
                },
                onCancelButtonPressed: () async {
                  Navigator.pop(context);
                  await appStateProvider.dlnaManager.stop();
                },
              );
            },
            selector: (_, store) => store.searchText));
  }

  Offset _initialSwipeOffset;
  Offset _finalSwipeOffset;

  Offset _initialVerLightOffset;
  Offset _finalVerLightOffset;
  double light = 0;

  void _onHorizontalDragStart(DragStartDetails details) {
    _initialSwipeOffset = details.globalPosition;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _finalSwipeOffset = details.globalPosition;
    var text = "";
    if (_initialSwipeOffset != null) {
      final offsetDifference = _initialSwipeOffset.dx - _finalSwipeOffset.dx;
      String fintext = "";
      // 最多滑动20分钟
      var offsetAbs = offsetDifference.abs() / Screen.widthOt;

      fintext = offsetDifference < 0 ? "快进到：" : "后退到：";
      if (offsetDifference < 0) {
        var endTime = offsetAbs *
            (_videoPlayerController.value.duration.inSeconds - _videoPlayerController.value.position.inSeconds);
        text =
            "$fintext${Duration(seconds: _videoPlayerController.value.position.inSeconds + endTime.toInt()).toString().split(".")[0]}";
      } else {
        var endTime = offsetAbs * (_videoPlayerController.value.position.inSeconds);
        text =
            "$fintext${Duration(seconds: _videoPlayerController.value.position.inSeconds - endTime.toInt()).toString().split(".")[0]}";
      }
      appStateProvider.setVerSwiper(true, text);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_initialSwipeOffset != null) {
      final offsetDifference = _initialSwipeOffset.dx - _finalSwipeOffset.dx;
      var offsetAbs = offsetDifference.abs() / Screen.widthOt;
      if (offsetDifference > 0) {
        var endTime = offsetAbs * (_videoPlayerController.value.position.inSeconds);
        if (_videoPlayerController.value.isPlaying) {
          Log.d(Duration(seconds: _videoPlayerController.value.position.inSeconds - endTime.toInt()).toString());
          _videoPlayerController.position
              .then((value) => {_videoPlayerController.seekTo(value - Duration(seconds: endTime.toInt()))});
        }
      } else {
        var endTime = offsetAbs *
            (_videoPlayerController.value.duration.inSeconds - _videoPlayerController.value.position.inSeconds);
        if (Duration(seconds: _videoPlayerController.value.position.inSeconds + endTime.toInt()) <=
            _videoPlayerController.value.duration) {
          Log.d(Duration(seconds: _videoPlayerController.value.position.inSeconds + endTime.toInt()).toString());
          if (_videoPlayerController.value.isPlaying) {
            _videoPlayerController.position
                .then((value) => {_videoPlayerController.seekTo(value + Duration(seconds: endTime.toInt()))});
          }
        }
      }
    }
    appStateProvider.setVerSwiper(false, "");
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _initialVerLightOffset = details.globalPosition;
  }

  Future _onVerticalDragUpdate(DragUpdateDetails details) async {
    _finalVerLightOffset = details.globalPosition;
    final offsetDifference = _initialVerLightOffset.dy - _finalVerLightOffset.dy;
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
    appStateProvider.setVerLight(true, verLightText);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_initialVerLightOffset != null) {
      getLight();
      appStateProvider.setVerLight(false, "");
    }
  }

  Future playVideo2(int index, List<ZiyuanUrl> urls, int chooseIndex) async {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.pause();
    currentVideoIndex = index;
    currentVideo = "${index}_$chooseIndex";
    appStateProvider.setloadingState(true);
    Toast.show("正在解析地址");
    try {
      await getPlayVideoUrl(urls[currentVideoIndex].url, currentVideoIndex);
      currentUrlName =
          "${_playlist.title}_${_detailProvider.detailReource[_detailProvider.chooseYuanIndex].ziyuanUrl[currentVideoIndex].title}";
      _detailProvider.saveJuji("${_playlist.url}_${chooseIndex}_$currentVideoIndex");
      var record = _detailProvider.getRecord("${_playlist.url}_${chooseIndex}_$currentVideoIndex");
      var startAt = Duration(seconds: 0);
      if (record != null) {
        startAt = Duration(seconds: int.parse(record));
      }
      _videoPlayerController = VideoPlayerController.network(currentUrl);

      await _videoPlayerController.initialize();
      _videoPlayerController.addListener(_videoListener);

      _chewieController = ChewieController(
        // customControls: MyControls(_playlist.title, urls.length),
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        allowedScreenSleep: false,
        looping: false,
        aspectRatio: 16 / 9,
        autoInitialize: true,
        startAt: startAt,
        errorBuilder: (context, message) {
          return Center(
            child: TextButton.icon(
                onPressed: () {
                  _chewieController.exitFullScreen();
                },
                icon: Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 42,
                ),
                label: Text(message)),
          );
        },
        routePageBuilder: (context, animation, __, provider) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget child) {
              return Scaffold(
                  backgroundColor: Colors.black,
                  body: GestureDetector(
                    onHorizontalDragStart: _onHorizontalDragStart,
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onHorizontalDragEnd: _onHorizontalDragEnd,
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
                                _chewieController.exitFullScreen();
                                // 延迟点击
                                Future.delayed(Duration(seconds: 1), () {
                                  // 点击显示投屏数据
                                  if (appStateProvider.dlnaDevices.length == 0) {
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
                      _videoPlayerController.value.isBuffering
                          ? Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  height: 30,
                                  width: 120,
                                  decoration: BoxDecoration(
                                      color: Colours.dark_bg_color, borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            '正在加载中...',
                                            style: Theme.of(context).textTheme.headline6,
                                          ),
                                          CircularProgressIndicator(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      Consumer<AppStateProvider>(builder: (_, provider, __) {
                        return provider.verSwiper && _videoPlayerController.value.isPlaying
                            ? Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    height: 30,
                                    width: 120,
                                    decoration: BoxDecoration(
                                        color: Colours.dark_bg_color, borderRadius: BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        provider.verText,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container();
                      }),
                      Consumer<AppStateProvider>(builder: (_, provider, __) {
                        return provider.verLight
                            ? Positioned.fill(
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: 30,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          color: Colours.dark_bg_color, borderRadius: BorderRadius.circular(10)),
                                      child: Center(
                                        child: Text(
                                          provider.verLightText,
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
        },
      );

      // 存储播放记录
      PlayerModel playerModel = PlayerModel(
          videoId: "${_playlist.url}_${_detailProvider.chooseYuanIndex}_${currentVideoIndex}_$record}",
          name:
              "${_playlist.title}_${_detailProvider.detailReource[_detailProvider.chooseYuanIndex].ziyuanUrl[currentVideoIndex].title}",
          url: currentUrl,
          cover: _playlist.cover,
          startAt: record);
      appStateProvider.savePlayerRecord(playerModel);
    } catch (e) {
      appStateProvider.setloadingState(false);
    }
    appStateProvider.setloadingState(false);
  }

  Future playVideo(int index, List<ZiyuanUrl> urls, int chooseIndex) async {
    if (currentVideo == "${index}_$chooseIndex") return;
    playVideo2(index, urls, chooseIndex);
  }

  // 当前播放的是那集
  int currentClickIndex = -1;

  Wrap buildJuJi(List<ZiyuanUrl> urls, int chooseIndex, var isDark) {
    return Wrap(
      spacing: 20, // 主轴(水平)方向间距
      runSpacing: 10, // 纵轴（垂直）方向间距
      alignment: WrapAlignment.start, //沿主轴方向居中
      children: List.generate(urls.length, (index) {
        return InkWell(
            onTap: () async {
              currentClickIndex = index;
              await playVideo(index, urls, chooseIndex);
            },
            child: Container(
                width: 100,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: _detailProvider.kanguojuji.contains("${_playlist.url}_${chooseIndex}_$index")
                        ? Colors.redAccent
                        : Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: currentClickIndex == index
                        ? Border.all(
                            color: isDark ? Colours.white : Colours.dark_bg_color,
                            //边框宽度
                            width: 2)
                        : Border.all(
                            color: Colors.white,
                            //边框宽度
                            width: 0)),
                alignment: Alignment.center,
                child: Text(
                  '${urls[index].title}',
                  style: TextStyle(
                    color: isDark ? Colours.dark_text : Colors.white,
                  ),
                )));
      }),
    );
  }

  List<Widget> textWidget(provider) {
    return List.generate(
        provider.detailReource.length,
        (index) => DropdownMenuItem(
              child: Text(provider.detailReource[index].ziyuanName),
              value: index,
            )).toList();
  }

  bool getFilterData(String url) {
    if (url != null) {
      var result = _collectProvider.listDetailResource.where((element) => element.url == url).toList();
      return result.length > 0;
    }
    return false;
  }

  DateTime startTime;
  rangeDownload() async {}

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final bool isDark = themeData.brightness == Brightness.dark;

    return WillPopScope(
        child: ChangeNotifierProvider<DetailProvider>(
            create: (_) => _detailProvider,
            child: Scaffold(
              key: _scaffoldKey,
              appBar: PreferredSize(
                  preferredSize: Size.fromHeight(48.0),
                  child: Selector<DetailProvider, String>(
                      builder: (_, actionName, __) {
                        return MyAppBar(
                            centerTitle: _playlist.title,
                            actionName: actionName,
                            onPressed: () {
                              if (getFilterData(_playlist.url)) {
                                Log.d("点击取消");
                                _collectProvider.removeResource(_playlist.url);
                                _detailProvider.setActionName("收藏");
                              } else {
                                Log.d("点击收藏");
                                _collectProvider.addResource(
                                  _playlist,
                                );
                                _detailProvider.setActionName("取消");
                              }
                            });
                      },
                      selector: (_, store) => store.actionName)),
              body: Column(
                children: [
                  Container(
                      color: Colors.black,
                      width: Screen.widthOt,
                      height: 300,
                      child: Selector<DetailProvider, bool>(
                          builder: (_, isplayer, __) {
                            return isplayer
                                ? Chewie(
                                    controller: _chewieController,
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(height: 20),
                                      Text(
                                        '等待播放...',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  );
                          },
                          selector: (_, store) => store.isInitPlayer)),
                  Gaps.vGap8,
                  Expanded(child: Consumer<DetailProvider>(builder: (_, provider, __) {
                    return provider.detailReource != null && provider.detailReource.length > 0
                        ? MyScrollView(
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          buildShare(_playlist.cover, _playlist.title),
                                          //源切换
                                          Row(
                                            children: [
                                              Text("切换源:"),
                                              Gaps.hGap8,
                                              DropdownButton(
                                                onChanged: (value) {
                                                  provider.setChooseYuanIndex(value);
                                                },
                                                items: textWidget(provider),
                                                value: provider.chooseYuanIndex,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Gaps.vGap8,
                                    buildJuJi(provider.detailReource[provider.chooseYuanIndex].ziyuanUrl,
                                        provider.chooseYuanIndex, isDark),
                                  ],
                                ),
                              )
                            ],
                          )
                        : StateLayout(
                            type: provider.stateType,
                            onRefresh: initData,
                          );
                  }))
                ],
              ),
            )),
        onWillPop: () async => !appStateProvider.loadingState);
  }
}
