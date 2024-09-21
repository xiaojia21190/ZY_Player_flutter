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
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/util/qs_common.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/utils.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/my_scroll_view.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:ZY_Player_flutter/xiaoshuo/widget/batter_view.dart';
import 'package:chewie/chewie.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
// import 'package:qr_flutter/qr_flutter.dart';
import 'package:video_player/video_player.dart';

class PlayerDetailPage extends StatefulWidget {
  const PlayerDetailPage({
    Key? key,
    required this.playerList,
  }) : super(key: key);

  final String playerList;

  @override
  _PlayerDetailPageState createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> with WidgetsBindingObserver {
  bool startedPlaying = false;

  final DetailProvider _detailProvider = DetailProvider();
  CollectProvider? _collectProvider;
  AppStateProvider? appStateProvider;
  StreamSubscription? _currentPosSubs;

  String actionName = "";

  int currentVideoIndex = -1;
  String currentVideo = "";
  Timer? searchTimer;

  String currentUrl = "";
  String currentUrlName = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Playlist? _playlist;

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  int bofangIndex = 0;

  double light = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    var result = jsonDecode(widget.playerList);
    _playlist = Playlist.fromJson(result);
    // getPlayDownLoadUrl(_playlist!.url);
    _collectProvider = Store.value<CollectProvider>(context);
    appStateProvider = Store.value<AppStateProvider>(context);
    bofangIndex = 0;
    initData();

    ApplicationEvent.event.on<DeviceEvent>().listen((event) async {
      if (event.device == 0) return;
      // 弹出dlna的弹窗
      if (mounted) {
        dlnaDevicesDialog();
      }
    });

    getLight();

    super.initState();
  }

  Future getLight() async {
    light = appStateProvider!.lightLevel;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('app lifecycle state: $state');
    super.didChangeAppLifecycleState(state);
  }

  Future setLight() async {
    // await ScreenBrightness().
  }

  @override
  void dispose() {
    setLight();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _videoPlayerController?.removeListener(_videoListener);
    _currentPosSubs?.cancel();
    super.dispose();
  }

  Future getPlayVideoUrl(String url, int index) async {
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getPlayVideoUrl, queryParameters: {"url": url}, onSuccess: (data) {
      currentUrl = data;
    }, onError: (_, msg) {
      currentVideoIndex = index;
      Toast.show(msg);
      appStateProvider!.setloadingState(false);
    });
  }

  Future initData() async {
    _detailProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.detailReource, queryParameters: {"url": _playlist!.url}, onSuccess: (data) {
      if (data != null && data.length > 0) {
        List.generate(data.length, (index) => _detailProvider.addDetailResource(DetailReource.fromJson(data[index])));
        _detailProvider.setJuji();
        _detailProvider.setStateType(StateType.empty);
      } else {
        _detailProvider.setStateType(StateType.network);
      }
      _collectProvider?.changeNoti();
      if (getFilterData(_playlist!.url)) {
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
                                          const Text("分享 虱子聚合"),
                                          Text(
                                            title,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          ),
                                          const Text("点击复制链接"),
                                          const Text("或者保存到相册分享")
                                        ],
                                      ),
                                      // QrImage(
                                      //   padding: const EdgeInsets.all(7),
                                      //   backgroundColor: Colors.white,
                                      //   data: "https://crawel.lppfk.top/static/index.html",
                                      //   size: 100,
                                      // ),
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
                                  Clipboard.setData(const ClipboardData(text: "https://crawel.lppfk.top/static/index.html"));
                                  Toast.show("复制链接成功，快去分享吧");
                                },
                              ),
                              TextButton(
                                child: const Text('保存到相册', style: TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  ByteData? byteData = await QSCommon.capturePngToByteData(haibaoKey);
                                  // 保存
                                  var result = await QSCommon.saveImageToCamera(byteData!);
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
        icon: const Icon(Icons.share),
        label: const Text("分享"));
  }

  void _videoListener() async {
    if (_videoPlayerController!.value.isInitialized) {
      if (!_detailProvider.isInitPlayer) {
        _detailProvider.setInitPlayer(true);
      }
    }
    _detailProvider.saveRecordNof("${_playlist!.url}_${_detailProvider.chooseYuanIndex}_${currentVideoIndex}_${_videoPlayerController!.value.position.inSeconds}");

    // 存储播放记录
    PlayerModel playerModel = PlayerModel(
        videoId: "${_playlist!.url}_${_detailProvider.chooseYuanIndex}_${currentVideoIndex}_${_videoPlayerController!.value.position.inSeconds}",
        name: "${_playlist!.title}_${_detailProvider.detailReource[_detailProvider.chooseYuanIndex].ziyuanUrl[currentVideoIndex].title}",
        url: currentUrl,
        cover: _playlist!.cover,
        startAt: "${_videoPlayerController!.value.position.inSeconds}");
    appStateProvider!.savePlayerRecord(playerModel);
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
                      child: Selector<AppStateProvider, List<DLNADevice>>(
                          builder: (_, devices, __) {
                            return ListView.separated(
                              itemCount: devices.length,
                              itemBuilder: (_, index) {
                                return TextButton(
                                  child: Text(devices[index].info.friendlyName),
                                  onPressed: () async {
                                    _chewieController!.pause();
                                    Toast.show("推送视频 ${_detailProvider.detailReource[_detailProvider.chooseYuanIndex].ziyuanUrl[currentVideoIndex].title} 到设备：${devices[index].info.friendlyName}");
                                    await devices[index].setUrl(currentUrl);
                                    await devices[index].play();
                                    appStateProvider!.setloadingState(false);

                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              separatorBuilder: (_, index) => const Divider(),
                            );
                          },
                          selector: (_, store) => store.deviceList.values.toList()),
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
    appStateProvider!.setSearchText("点击开始搜索设备");
    showDialog(
        context: context,
        builder: (_) => Selector<AppStateProvider, String>(
            builder: (_, words, __) {
              return SimpleDialog(
                title: Text(words),
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () async {
                      await appStateProvider!.searchDlna(1);
                    },
                    child: const Text('开始搜索'),
                  ),
                  SimpleDialogOption(
                    onPressed: () async {
                      await appStateProvider!.searcher.stop();
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: const Text('停止搜索'),
                  ),
                ],
              );
            },
            selector: (_, store) => store.searchText));
  }

  Offset? _initialSwipeOffset;
  Offset? _finalSwipeOffset;

  Offset? _initialVerLightOffset;
  Offset? _finalVerLightOffset;

  void _onHorizontalDragStart(DragStartDetails details) {
    _initialSwipeOffset = details.globalPosition;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _finalSwipeOffset = details.globalPosition;
    var text = "";
    if (_initialSwipeOffset != null) {
      final offsetDifference = _initialSwipeOffset!.dx - _finalSwipeOffset!.dx;
      String fintext = "";
      // 最多滑动20分钟
      var offsetAbs = offsetDifference.abs() / Screen.widthOt;

      fintext = offsetDifference < 0 ? "快进到：" : "后退到：";
      if (offsetDifference < 0) {
        var endTime = offsetAbs * (_videoPlayerController!.value.duration.inSeconds - _videoPlayerController!.value.position.inSeconds);
        text = "$fintext${Duration(seconds: _videoPlayerController!.value.position.inSeconds + endTime.toInt()).toString().split(".")[0]}";
      } else {
        var endTime = offsetAbs * (_videoPlayerController!.value.position.inSeconds);
        text = "$fintext${Duration(seconds: _videoPlayerController!.value.position.inSeconds - endTime.toInt()).toString().split(".")[0]}";
      }
      appStateProvider!.setVerSwiper(true, text);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_initialSwipeOffset != null) {
      final offsetDifference = _initialSwipeOffset!.dx - _finalSwipeOffset!.dx;
      var offsetAbs = offsetDifference.abs() / Screen.widthOt;
      if (offsetDifference > 0) {
        var endTime = offsetAbs * (_videoPlayerController!.value.position.inSeconds);
        if (_videoPlayerController!.value.isPlaying) {
          Log.d(Duration(seconds: _videoPlayerController!.value.position.inSeconds - endTime.toInt()).toString());
          _videoPlayerController!.position.then((value) => {_videoPlayerController!.seekTo(value! - Duration(seconds: endTime.toInt()))});
        }
      } else {
        var endTime = offsetAbs * (_videoPlayerController!.value.duration.inSeconds - _videoPlayerController!.value.position.inSeconds);
        if (Duration(seconds: _videoPlayerController!.value.position.inSeconds + endTime.toInt()) <= _videoPlayerController!.value.duration) {
          Log.d(Duration(seconds: _videoPlayerController!.value.position.inSeconds + endTime.toInt()).toString());
          if (_videoPlayerController!.value.isPlaying) {
            _videoPlayerController!.position.then((value) => {_videoPlayerController!.seekTo(value! + Duration(seconds: endTime.toInt()))});
          }
        }
      }
    }
    appStateProvider!.setVerSwiper(false, "");
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _initialVerLightOffset = details.globalPosition;
  }

  Future _onVerticalDragUpdate(DragUpdateDetails details) async {
    _finalVerLightOffset = details.globalPosition;
    final offsetDifference = _initialVerLightOffset!.dy - _finalVerLightOffset!.dy;
    var offsetAbs = offsetDifference.abs() / 1000;
    // Log.d(offsetAbs.toString());
    double entLight;
    if (offsetDifference > 0) {
      entLight = light + offsetAbs;
      if (entLight >= 1) {
        entLight = 1.0;
      }
    } else {
      entLight = light - offsetAbs;
      if (entLight <= 0) {
        entLight = 0.0;
      }
    }

    ScreenBrightness().setScreenBrightness(entLight);
    var verLightText = "亮度：${(entLight * 100).toInt()}%";
    appStateProvider!.setVerLight(true, verLightText);
    // light 赋值 并不改变外界的 亮度值
    light = entLight;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_initialVerLightOffset != null) {
      appStateProvider!.setVerLight(false, "");
    }
  }

  Future playVideo2(int index, List<ZiyuanUrl> urls, int chooseIndex) async {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.pause();
    currentVideoIndex = index;
    currentVideo = "${index}_$chooseIndex";
    appStateProvider!.setloadingState(true);
    Toast.show("正在解析地址");
    try {
      // currentUrl = urls[currentVideoIndex].url;
      await getPlayVideoUrl(urls[currentVideoIndex].url, currentVideoIndex);
      currentUrlName = "${_playlist!.title}_${_detailProvider.detailReource[_detailProvider.chooseYuanIndex].ziyuanUrl[currentVideoIndex].title}";
      _detailProvider.saveJuji("${_playlist!.url}_${chooseIndex}_$currentVideoIndex");
      var record = _detailProvider.getRecord("${_playlist!.url}_${chooseIndex}_$currentVideoIndex");
      var startAt = Duration(seconds: int.parse(record));

      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(currentUrl));

      await _videoPlayerController!.initialize();
      _videoPlayerController!.addListener(_videoListener);

      _chewieController = ChewieController(
        // customControls: MyControls(_playlist.title, urls.length),
        videoPlayerController: _videoPlayerController!,
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
                  _chewieController?.play();
                },
                icon: const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 42,
                ),
                label: const Text("哎呀~~播放失败了,点击重新播放")),
          );
        },
        showOptions: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: Theme.of(context).primaryColor,
          handleColor: Theme.of(context).primaryColor,
          bufferedColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          backgroundColor: Theme.of(context).disabledColor.withOpacity(.5),
        ),
        routePageBuilder: (context, animation, __, provider) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
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
                                _chewieController!.exitFullScreen();
                                // 延迟点击
                                Future.delayed(const Duration(seconds: 1), () {
                                  // 点击显示投屏数据
                                  if (appStateProvider!.deviceList.isEmpty) {
                                    // 没有搜索到
                                    searchDialog();
                                  } else {
                                    // 搜索到了
                                    dlnaDevicesDialog();
                                  }
                                });
                              },
                              icon: const Icon(
                                Icons.present_to_all_sharp,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "投屏",
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ),
                      Consumer<AppStateProvider>(builder: (_, provider, __) {
                        return provider.verSwiper && _videoPlayerController!.value.isPlaying
                            ? Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    decoration: BoxDecoration(color: const Color.fromRGBO(0, 0, 0, 0.8), borderRadius: BorderRadius.circular(5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(provider.verText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                          )),
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
                                      decoration: BoxDecoration(color: const Color.fromRGBO(0, 0, 0, 0.8), borderRadius: BorderRadius.circular(5)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(provider.verLightText,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                            )),
                                      ),
                                    )),
                              )
                            : Container();
                      }),
                      Positioned.fill(
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              child: const Row(
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
          videoId: "${_playlist!.url}_${_detailProvider.chooseYuanIndex}_${currentVideoIndex}_$record}", name: "${_playlist!.title}_${_detailProvider.detailReource[_detailProvider.chooseYuanIndex].ziyuanUrl[currentVideoIndex].title}", url: currentUrl, cover: _playlist!.cover, startAt: record);
      appStateProvider!.savePlayerRecord(playerModel);
    } catch (e) {
      print(e);
      appStateProvider!.setloadingState(false);
      Toast.show("可能资源已损坏,请点击切换源,查看其他资源!", duration: 5000);
    }
    appStateProvider!.setloadingState(false);
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: _detailProvider.kanguojuji.contains("${_playlist!.url}_${chooseIndex}_$index") ? Colors.redAccent : Colors.blueAccent,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
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
                  urls[index].title,
                  style: TextStyle(
                    color: isDark ? Colours.dark_text : Colors.white,
                  ),
                )));
      }),
    );
  }

  List<DropdownMenuItem<int>> textWidget(provider) {
    return List.generate(
        provider.detailReource.length,
        (index) => DropdownMenuItem(
              value: index,
              child: Text(provider.detailReource[index].ziyuanName),
            )).toList();
  }

  bool getFilterData(String? url) {
    if (url != null) {
      List<Playlist>? result = _collectProvider?.listDetailResource.where((element) => element.url == url).toList();
      return result!.isNotEmpty;
    }
    return false;
  }

  DateTime? startTime;
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
                  preferredSize: const Size.fromHeight(48.0),
                  child: Selector<DetailProvider, String>(
                      builder: (_, actionName, __) {
                        return MyAppBar(
                            centerTitle: _playlist!.title,
                            actionName: actionName,
                            onPressed: () {
                              if (getFilterData(_playlist!.url)) {
                                Log.d("点击取消");
                                _collectProvider?.removeResource(_playlist!.url);
                                _detailProvider.setActionName("收藏");
                              } else {
                                Log.d("点击收藏");
                                _collectProvider?.addResource(
                                  _playlist!,
                                );
                                _detailProvider.setActionName("取消");
                              }
                            });
                      },
                      selector: (_, store) => store.actionName)),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      color: Colors.black,
                      width: Screen.widthOt,
                      height: 300,
                      child: Selector<DetailProvider, bool>(
                          builder: (_, isplayer, __) {
                            return isplayer
                                ? Chewie(
                                    controller: _chewieController!,
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
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
                  // TextButton.icon(
                  //     onPressed: () {
                  //       // 弹窗
                  //       showElasticDialog<void>(
                  //         context: context,
                  //         builder: (BuildContext context) {
                  //           return Material(
                  //             type: MaterialType.transparency,
                  //             elevation: 10,
                  //             child: Center(
                  //                 child: Container(
                  //               decoration: BoxDecoration(
                  //                 color: context.dialogBackgroundColor,
                  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
                  //               ),
                  //               width: 300,
                  //               height: 430,
                  //               child: ListView.builder(
                  //                   itemCount: playDownUrl.length,
                  //                   itemBuilder: (_, i) {
                  //                     return TextButton(
                  //                         onPressed: () async {
                  //                           await launchDownLoadUrl(playDownUrl[i].url);
                  //                         },
                  //                         child: Text(playDownUrl[i].title));
                  //                   }),
                  //             )),
                  //           );
                  //         },
                  //       );
                  //     },
                  //     icon: Icon(Icons.download_rounded),
                  //     label: Text("下载")),
                  Expanded(child: Consumer<DetailProvider>(builder: (_, provider, __) {
                    return provider.detailReource.isNotEmpty
                        ? MyScrollView(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          buildShare(_playlist!.cover, _playlist!.title),
                                          //源切换
                                          Row(
                                            children: [
                                              const Text("切换源:"),
                                              Gaps.hGap8,
                                              DropdownButton(
                                                onChanged: (int? value) {
                                                  provider.setChooseYuanIndex(value!);
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
                                    buildJuJi(provider.detailReource[provider.chooseYuanIndex].ziyuanUrl, provider.chooseYuanIndex, isDark),
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
        onWillPop: () async => !appStateProvider!.loadingState);
  }
}
