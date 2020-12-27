import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/event/event_bus.dart';
import 'package:ZY_Player_flutter/event/event_model.dart';
import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/provider/detail_provider.dart';
import 'package:ZY_Player_flutter/player/widget/my_controller.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/utils.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/utils/qs_common.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/my_card.dart';
import 'package:ZY_Player_flutter/widgets/my_scroll_view.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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
  Timer searchTimer;

  String currentUrl = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Playlist _playlist;

  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    var result = jsonDecode(widget.playerList);
    _playlist = Playlist.fromJson(result);

    _collectProvider = Store.value<CollectProvider>(context);
    appStateProvider = Store.value<AppStateProvider>(context);
    _collectProvider.setListDetailResource("collcetPlayer");

    initData();

    ApplicationEvent.event.on<DeviceEvent>().listen((event) async {
      Toast.show(
          "推送视频 ${_detailProvider.detailReource[_detailProvider.chooseYuanIndex].ziyuanUrl[currentVideoIndex].title} 到设备：${event.devicesName}");
      await appStateProvider.dlnaManager.setDevice(event.devicesId);
      await appStateProvider.dlnaManager
          .setVideoUrlAndName(currentUrl, _detailProvider.detailReource[_detailProvider.chooseYuanIndex].ziyuanUrl[currentVideoIndex].title);
      appStateProvider.setloadingState(false);
    });

    ApplicationEvent.event.on<ChangeJujiEvent>().listen((event) async {
      // 播放下一级
      if (currentVideoIndex + 1 > _detailProvider.detailReource[_detailProvider.chooseYuanIndex].ziyuanUrl.length) {
        Toast.show("全部播放完了！");
        return;
      }
      await playVideo(
          currentVideoIndex + 1, _detailProvider.detailReource[_detailProvider.chooseYuanIndex].ziyuanUrl, _detailProvider.chooseYuanIndex);
    });

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('app lifecycle state: $state');
    if (state == AppLifecycleState.inactive) {
      _videoPlayerController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _videoPlayerController?.play();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.dispose();
    _videoPlayerController?.removeListener(_videoListener);
    _chewieController?.dispose();
    _currentPosSubs?.cancel();
  }

  Future getPlayVideoUrl(String videoUrl, int index) async {
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getPlayVideoUrl, queryParameters: {"url": videoUrl}, onSuccess: (data) {
      currentUrl = data;
    }, onError: (_, __) {
      currentVideoIndex = index;
    });
  }

  Future initData() async {
    _detailProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.detailReource, queryParameters: {"url": _playlist.url}, onSuccess: (data) {
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
    return FlatButton.icon(
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
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              width: ScreenUtil.getInstance().getWidth(300),
                              height: ScreenUtil.getInstance().getWidth(430),
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Column(
                                children: <Widget>[
                                  LoadImage(
                                    image,
                                    height: ScreenUtil.getInstance().getWidth(300),
                                    width: ScreenUtil.getInstance().getWidth(300),
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
                                              "影片名称:$title",
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            ),
                                          ),
                                          Text("点击复制链接"),
                                          Text("或者保存到相册分享")
                                        ],
                                      ),
                                      QrImage(
                                        padding: EdgeInsets.all(ScreenUtil.getInstance().getWidth(7)),
                                        backgroundColor: Colors.white,
                                        data: "https://xiaojia21190.github.io/ZY_Player_flutter/",
                                        size: ScreenUtil.getInstance().getWidth(100),
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
                                  Clipboard.setData(ClipboardData(text: "https://xiaojia21190.github.io/ZY_Player_flutter/"));
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
    if (_videoPlayerController.value.initialized) {
      if (!_detailProvider.isInitPlayer) {
        _detailProvider.setInitPlayer(true);
      }
    }
    _detailProvider
        .saveRecordNof("${_playlist.url}_${_detailProvider.chooseYuanIndex}_${currentVideoIndex}_${_videoPlayerController.value.position.inSeconds}");
  }

  Future playVideo(int index, List<ZiyuanUrl> urls, int chooseIndex) async {
    if (currentVideoIndex == index) return;
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.pause();
    _chewieController?.dispose();
    currentVideoIndex = index;
    appStateProvider.setloadingState(true);
    Toast.show("正在解析地址");
    await getPlayVideoUrl(urls[currentVideoIndex].url, currentVideoIndex);
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
      customControls: MyControls(_playlist.title, urls.length),
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      allowedScreenSleep: false,
      looping: false,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      startAt: startAt,
    );
    appStateProvider.setloadingState(false);
  }

  Wrap buildJuJi(List<ZiyuanUrl> urls, int chooseIndex, var isDark) {
    return Wrap(
      spacing: 20, // 主轴(水平)方向间距
      runSpacing: 10, // 纵轴（垂直）方向间距
      alignment: WrapAlignment.start, //沿主轴方向居中
      children: List.generate(urls.length, (index) {
        return InkWell(
            onTap: () async {
              await playVideo(index, urls, chooseIndex);
            },
            child: Container(
                width: ScreenUtil.getInstance().getWidth(100),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: _detailProvider.kanguojuji.contains("${_playlist.url}_${chooseIndex}_$index") ? Colors.redAccent : Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
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

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final bool isDark = themeData.brightness == Brightness.dark;

    return ChangeNotifierProvider<DetailProvider>(
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
              Stack(
                children: [
                  Container(
                      color: Colors.black,
                      width: Screen.widthOt,
                      height: ScreenUtil.getInstance().getWidth(300),
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
                ],
              ),
              Expanded(child: Consumer<DetailProvider>(builder: (_, provider, __) {
                return provider.detailReource != null && provider.detailReource.length > 0
                    ? MyScrollView(
                        children: [
                          Gaps.vGap10,
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
                                      Text(
                                        "剧集选择",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      buildShare(_playlist.cover, _playlist.title),
                                      //源切换
                                      DropdownButton(
                                        onChanged: (value) {
                                          provider.setChooseYuanIndex(value);
                                        },
                                        items: textWidget(provider),
                                        value: provider.chooseYuanIndex,
                                      ),
                                    ],
                                  ),
                                ),
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
        ));
  }
}
