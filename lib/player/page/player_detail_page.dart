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
import 'package:cached_network_image/cached_network_image.dart';
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

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('app lifecycle state: $state');
    if (state == AppLifecycleState.inactive) {
      _videoPlayerController.pause();
    } else if (state == AppLifecycleState.resumed) {
      _videoPlayerController.play();
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
      if (data.length > 0) {
        List.generate(data.length, (index) => _detailProvider.addDetailResource(DetailReource.fromJson(data[index])));
        _detailProvider.setJuji();
      } else {
        _detailProvider.setStateType(StateType.network);
      }
      _collectProvider.changeNoti();
      if (getFilterData(_playlist.url)) {
        _detailProvider.setActionName("点击取消");
      } else {
        _detailProvider.setActionName("点击收藏");
      }
      _detailProvider.setStateType(StateType.empty);
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
                  const OutlinedBorder buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0)));
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
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              width: 270.0,
                              height: ScreenUtil.getInstance().getWidth(400),
                              // padding: const EdgeInsets.only(top: 24.0),
                              child: TextButtonTheme(
                                data: TextButtonThemeData(
                                    style: ButtonStyle(
                                  // 文字颜色
                                  foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                                  // 按下高亮颜色
                                  shadowColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor.withOpacity(0.2)),
                                  // 按钮大小
                                  minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, double.infinity)),
                                  // 修改默认圆角
                                  shape: MaterialStateProperty.all<OutlinedBorder>(buttonShape),
                                )),
                                child: Column(
                                  children: <Widget>[
                                    LoadImage(
                                      image,
                                      height: ScreenUtil.getInstance().getWidth(250),
                                    ),
                                    Expanded(
                                        child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text("分享 zy_player_flutter"),
                                            Container(
                                              child: Text(
                                                "影片名称:$title",
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                              ),
                                              width: ScreenUtil.getInstance().getWidth(120),
                                            ),
                                            Text("点击复制链接"),
                                            Text("或者保存到相册分享")
                                          ],
                                        ),
                                        QrImage(
                                          padding: EdgeInsets.all(ScreenUtil.getInstance().getWidth(7)),
                                          backgroundColor: Colors.white,
                                          data: "https://xiaojia21190.github.io/ZY_Player_flutter/",
                                          size: ScreenUtil.getInstance().getWidth(120),
                                        ),
                                      ],
                                    ))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                child: const Text('点击复制链接'),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: "https://xiaojia21190.github.io/ZY_Player_flutter/"));
                                  Toast.show("复制链接成功，快去分享吧");
                                },
                              ),
                              TextButton(
                                child: const Text('保存到相册'),
                                onPressed: () async {
                                  ByteData byteData = await QSCommon.capturePngToByteData(haibaoKey);
                                  // 保存
                                  File file = await QSCommon.saveImageToCamera(byteData);
                                  debugPrint('$file');
                                  if (file.path.length > 0) {
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
      _detailProvider.setInitPlayer(true);
      appStateProvider.setloadingState(false);
    }
  }

  Wrap buildJuJi(List<ZiyuanUrl> urls, int chooseIndex, var isDark) {
    return Wrap(
      spacing: 20, // 主轴(水平)方向间距
      runSpacing: 10, // 纵轴（垂直）方向间距
      alignment: WrapAlignment.start, //沿主轴方向居中
      children: List.generate(urls.length, (index) {
        return InkWell(
            onTap: () async {
              if (currentVideoIndex == index) return;
              _videoPlayerController?.removeListener(_videoListener);
              _videoPlayerController?.pause();
              currentVideoIndex = index;
              appStateProvider.setloadingState(true);
              Toast.show("正在解析地址");
              await getPlayVideoUrl(urls[currentVideoIndex].url, currentVideoIndex);
              _detailProvider.saveJuji("${_playlist.url}_${chooseIndex}_$currentVideoIndex");
              _videoPlayerController = VideoPlayerController.network(currentUrl);
              await _videoPlayerController.initialize();
              _videoPlayerController.addListener(_videoListener);
              _chewieController = ChewieController(
                customControls: MyControls(_playlist.title),
                videoPlayerController: _videoPlayerController,
                autoPlay: false,
                allowedScreenSleep: false,
                looping: false,
                aspectRatio: _videoPlayerController.value.aspectRatio,
                placeholder: CachedNetworkImage(imageUrl: 'https://tva2.sinaimg.cn/large/007UW77jly1g5elwuwv4rj30sg0g0wfo.jpg'),
                autoInitialize: true,
              );
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
                            _detailProvider.setActionName("点击收藏");
                          } else {
                            Log.d("点击收藏");
                            _collectProvider.addResource(
                              _playlist,
                            );
                            _detailProvider.setActionName("点击取消");
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
                      width: MediaQuery.of(context).size.width,
                      height: ScreenUtil.getInstance().getWidth(210),
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
                          selector: (_, store) => store.isInitPlayer)),
                ],
              ),
              Expanded(child: Consumer<DetailProvider>(builder: (_, provider, __) {
                return provider.detailReource != null && provider.detailReource.length > 0
                    ? MyScrollView(
                        children: [
                          MyCard(
                              child: Container(
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
                          ))
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
