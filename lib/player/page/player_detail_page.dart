import 'dart:async';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/provider/detail_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/app_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../model/detail_reource.dart';

class PlayerDetailPage extends StatefulWidget {
  const PlayerDetailPage({
    Key key,
    @required this.url,
    @required this.title,
  }) : super(key: key);

  final String url;
  final String title;

  @override
  _PlayerDetailPageState createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> with WidgetsBindingObserver {
  final FijkPlayer _player = FijkPlayer();

  bool startedPlaying = false;

  DetailProvider _detailProvider = DetailProvider();
  CollectProvider _collectProvider;

  String actionName = "";
  bool _isFullscreen = false;

  int currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _collectProvider = context.read<CollectProvider>();
    _collectProvider.setListDetailResource("collcetPlayer");
    _player.addListener(_fijkValueListener);
    initData();
  }

  Future _fijkValueListener() async {
    FijkValue value = _player.value;

    if (value.state == FijkState.completed) {
      // 是否播放完成 完成后播放下一集
      var currentIndex = currentVideoIndex + 1;
      if (_detailProvider.detailReource.videoList.length >= currentIndex) return;
      _player.reset();
      _player.setDataSource(_detailProvider.detailReource.videoList[currentIndex]);
      _detailProvider.saveJuji("${widget.url}_$currentIndex");
    }
    _isFullscreen = value.fullScreen;
  }

  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    _isFullscreen ? SystemChrome.setEnabledSystemUIOverlays([]) : SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
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
  }

  Future initData() async {
    _detailProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.detailReource, queryParameters: {"url": widget.url}, onSuccess: (data) {
      _detailProvider.setDetailResource(DetailReource.fromJson(data[0]));
      _detailProvider.setJuji();
      _collectProvider.changeNoti();
      setPlayerVideo();
      if (getFilterData(_detailProvider.detailReource)) {
        actionName = "点击取消";
      } else {
        actionName = "点击收藏";
      }
      _detailProvider.setStateType(StateType.empty);
      setState(() {});
    }, onError: (_, __) {
      _detailProvider.setStateType(StateType.network);
    });
  }

  Future setPlayerVideo() async {
    // 寻找最后的记录，从这里播放

    var benjuji = _detailProvider.kanguojuji.where((element) => element.split("_")[0] == widget.url).toList();

    if (benjuji.length == 0) {
      _player.setDataSource(_detailProvider.detailReource.videoList[currentVideoIndex], autoPlay: true);
    } else {
      benjuji.sort((a, b) => int.parse(a.split("_")[1]) - int.parse(b.split("_")[1]));
      _player.setDataSource(_detailProvider.detailReource.videoList[int.parse(benjuji[benjuji.length - 1].split("_")[1])], autoPlay: true);
      currentVideoIndex = int.parse(benjuji[benjuji.length - 1].split("_")[1]);
    }

    Toast.show("开始播放第${currentVideoIndex + 1}集");

    await _player.applyOptions(FijkOption()
      ..setFormatOption('flush_packets', 1)
      ..setFormatOption('analyzeduration', 1)
      ..setCodecOption('skip_loop_filter', 48)
      ..setCodecOption('request-screen-on', 1)
      ..setCodecOption('request-audio-focus', 1)
      ..setCodecOption('cover-after-prepared', 1)
      ..setPlayerOption('packet-buffering', 0)
      ..setPlayerOption('framedrop', 1)
      ..setPlayerOption('enable-accurate-seek', 1)
      ..setPlayerOption('find_stream_info', 0)
      ..setPlayerOption('render-wait-start', 1));
  }

  bool getFilterData(DetailReource data) {
    if (data != null) {
      var result = _collectProvider.listDetailResource.where((element) => element.url == data.url).toList();
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
          appBar: MyAppBar(
              centerTitle: widget.title,
              actionName: actionName,
              onPressed: () {
                if (getFilterData(_detailProvider.detailReource)) {
                  Log.d("点击取消");
                  _collectProvider.removeResource(_detailProvider.detailReource.url);
                  actionName = "点击收藏";
                } else {
                  Log.d("点击收藏");
                  _collectProvider.addResource(
                    _detailProvider.detailReource,
                  );
                  actionName = "点击取消";
                  setState(() {});
                }
              }),
          body: Consumer<DetailProvider>(builder: (_, provider, __) {
            return provider.detailReource != null
                ? CustomScrollView(
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: ScreenUtil.getInstance().getWidth(200),
                          child: FijkView(
                            player: _player,
                            color: Colors.black,
                            panelBuilder: fijkPanel2Builder(snapShot: true),
                            fsFit: FijkFit.fill,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Card(
                          shadowColor: Colors.blueAccent,
                          elevation: 2,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[Text("剧情介绍"), Gaps.vGap10, Text(provider.detailReource.content)],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: provider.detailReource.videoList.length > 1
                            ? Card(
                                shadowColor: Colors.blueAccent,
                                elevation: 2,
                                child: Container(
                                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(top: 10, bottom: 10),
                                        child: Text(
                                          "剧集选择",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      Wrap(
                                        spacing: 15, // 主轴(水平)方向间距
                                        runSpacing: 10, // 纵轴（垂直）方向间距
                                        alignment: WrapAlignment.start, //沿主轴方向居中
                                        children: List.generate(provider.detailReource.videoList.length, (index) {
                                          return Container(
                                            width: ScreenUtil.getInstance().getWidth(100),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: _detailProvider.kanguojuji.contains("${widget.url}_$index") ? Colors.red : Colours.text_gray_c,
                                                borderRadius: BorderRadius.all(Radius.circular(5))),
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                                onTap: () {
                                                  if (currentVideoIndex == index) return;
                                                  currentVideoIndex = index;
                                                  _detailProvider.saveJuji("${widget.url}_$index");
                                                  _player.reset().then((value) {
                                                    _player.setDataSource(_detailProvider.detailReource.videoList[currentVideoIndex], autoPlay: true);
                                                    Toast.show("开始播放第${currentVideoIndex + 1}集");
                                                  });
                                                },
                                                child: Text(
                                                  '第${index + 1}集',
                                                  style: TextStyle(
                                                    color: isDark ? Colours.dark_text : Colors.white,
                                                  ),
                                                )),
                                          );
                                        }),
                                      )
                                    ],
                                  ),
                                ))
                            : Container(),
                      )
                    ],
                  )
                : StateLayout(
                    type: provider.stateType,
                    onRefresh: initData,
                  );
          }),
        ));
  }
}
