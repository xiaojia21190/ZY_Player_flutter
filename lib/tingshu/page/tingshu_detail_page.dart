import 'dart:async';
import 'dart:math';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/common/common.dart';
import 'package:ZY_Player_flutter/model/ting_shu_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/tingshu/provider/tingshu_detail_provider.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/util/qs_common.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wakelock/wakelock.dart';

class TingshuDetailPage extends StatefulWidget {
  const TingshuDetailPage({
    Key key,
    @required this.url,
    @required this.title,
  }) : super(key: key);

  final String url;
  final String title;

  @override
  _TingshuDetailPageState createState() => _TingshuDetailPageState();
}

class _TingshuDetailPageState extends State<TingshuDetailPage> {
  TingShuDetailProvider _tingShuProvider = TingShuDetailProvider();
  CollectProvider _collectProvider;
  AppStateProvider _appStateProvider;
  final player = AudioPlayer();

  String currentUrl = "";
  Duration currentDuration;
  int currentIndex = -1;
  int lastIndex = -1;

  bool isCompleted = false;

  @override
  void initState() {
    _collectProvider = Store.value<CollectProvider>(context);
    _collectProvider.setListDetailResource("collcetTingshu");
    _appStateProvider = Store.value<AppStateProvider>(context);
    player.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.completed:
          if (isCompleted) return;
          isCompleted = true;
          // 自动播放下一集
          lastIndex = currentIndex + 1;
          if (lastIndex > _tingShuProvider.tingshudetail.catlogs.length) return;
          _tingShuProvider.saveTingshu(
              "${widget.url}_${lastIndex}_${_tingShuProvider.tingshudetail.catlogs[lastIndex].text}_${_tingShuProvider.tingshudetail.catlogs[lastIndex].url}",
              widget.url);
          getAudioUrl(_tingShuProvider.tingshudetail.catlogs[lastIndex].url);
          break;
        case ProcessingState.idle:
          // TODO: Handle this case.
          break;
        case ProcessingState.loading:
          // TODO: Handle this case.
          break;
        case ProcessingState.buffering:
          // TODO: Handle this case.
          break;
        case ProcessingState.ready:
          // TODO: Handle this case.
          break;
      }
    });
    Future.microtask(() => initData());

    Wakelock.enable();
    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();

    _tingShuProvider.setInitPlayer(false, not: false);
    _tingShuProvider.changeLastTs();
    player?.dispose();
    super.dispose();
  }

  Future initData() async {
    _tingShuProvider.setStateType(StateType.empty);
    _appStateProvider.setloadingState(true);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getXmlyDetail, queryParameters: {"url": widget.url},
        onSuccess: (data) {
      _tingShuProvider.setTingshuDetail(TingShuDetail.fromJson(data));
      _tingShuProvider.setTingshu(widget.url);

      if (getFilterData(_tingShuProvider.tingshudetail)) {
        _tingShuProvider.setActionName("取消");
      } else {
        _tingShuProvider.setActionName("收藏");
      }
      _appStateProvider.setloadingState(false);
      _tingShuProvider.setStateType(StateType.empty);
    }, onError: (_, __) {
      _appStateProvider.setloadingState(false);
      _tingShuProvider.setStateType(StateType.network);
    });
  }

  Future getAudioUrl(String url) async {
    Toast.show("正在解析地址");
    _appStateProvider.setloadingState(true);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getXmlyDetailMp3, queryParameters: {"url": url},
        onSuccess: (data) async {
      currentUrl = data;

      await player?.stop();

      try {
        var record = _tingShuProvider.getRecord("${widget.url}_$currentUrl");
        var startAt = Duration(seconds: 0);
        if (record != null) {
          startAt = Duration(seconds: int.parse(record));
        }
        currentDuration = await player.setUrl(currentUrl);
        player.play();
        await player.seek(startAt);
        _appStateProvider.setloadingState(false);
        _tingShuProvider.setInitPlayer(true);
        isCompleted = false;
      } catch (e) {
        Toast.show("获取音频失败，请重试");
        _appStateProvider.setloadingState(false);
        isCompleted = false;
      }
    }, onError: (_, __) {
      _appStateProvider.setloadingState(false);
      Toast.show("获取音频失败，请重试");
      isCompleted = false;
    });
  }

  Future refresh() async {
    await initData();
  }

  bool getFilterData(TingShuDetail data) {
    if (data != null) {
      var result = _collectProvider.list.where((element) => element.url == data.url).toList();
      return result.length > 0;
    }
    return false;
  }

  Widget buildShare(String image, String title) {
    GlobalKey haibaoKey1 = GlobalKey();
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
                            key: haibaoKey1,
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
                                            "http://hall.moitech.cn/shizhijuhe/index.html#/upload?random=${DateTime.now()}",
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
                                          "http://hall.moitech.cn/shizhijuhe/index.html#/upload?random=${DateTime.now()}"));
                                  Toast.show("复制链接成功，快去分享吧");
                                },
                              ),
                              TextButton(
                                child: const Text('保存到相册', style: TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  ByteData byteData = await QSCommon.capturePngToByteData(haibaoKey1);
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
        label: Text("分享听书"));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final bool isDark = themeData.brightness == Brightness.dark;
    return ChangeNotifierProvider<TingShuDetailProvider>(
        create: (_) => _tingShuProvider,
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Selector<TingShuDetailProvider, String>(
                  builder: (_, actionName, __) {
                    return MyAppBar(
                        centerTitle: widget.title,
                        actionName: actionName,
                        onPressed: () {
                          if (getFilterData(_tingShuProvider.tingshudetail)) {
                            _collectProvider.removeTingshu(_tingShuProvider.tingshudetail.url);
                            _tingShuProvider.setActionName("收藏");
                          } else {
                            _collectProvider.addTingshu(
                              _tingShuProvider.tingshudetail,
                            );
                            _tingShuProvider.setActionName("取消");
                          }
                        });
                  },
                  selector: (_, store) => store.actionName)),
          body: Stack(
            children: [
              Consumer<TingShuDetailProvider>(builder: (_, provider, __) {
                return provider.tingshudetail != null
                    ? CustomScrollView(
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: Container(
                              height: 100,
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  LoadImage(
                                    provider.tingshudetail.cover,
                                    width: 100,
                                    fit: BoxFit.contain,
                                  ),
                                  Expanded(
                                      child: Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          provider.tingshudetail.author,
                                        ),
                                        Text(
                                          provider.tingshudetail.zhubo,
                                        ),
                                        Text(provider.tingshudetail.state),
                                      ],
                                    ),
                                  ))
                                ],
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: buildShare(provider.tingshudetail.cover, provider.tingshudetail.title),
                          ),
                          SliverToBoxAdapter(
                            child: Gaps.vGap8,
                          ),
                          SliverToBoxAdapter(
                            child: provider.isInitPlayer
                                ? Column(
                                    children: [
                                      StreamBuilder<PlayerState>(
                                        stream: player.playerStateStream,
                                        builder: (context, snapshot) {
                                          final playerState = snapshot.data;
                                          final processingState = playerState?.processingState;
                                          final playing = playerState?.playing;
                                          if (processingState == ProcessingState.loading ||
                                              processingState == ProcessingState.buffering) {
                                            return Container(
                                              margin: EdgeInsets.all(8.0),
                                              width: 20.0,
                                              height: 20.0,
                                              child: CircularProgressIndicator(),
                                            );
                                          } else if (playing != true) {
                                            return TextButton.icon(
                                              icon: Icon(Icons.play_arrow),
                                              label: Text("播放"),
                                              onPressed: player.play,
                                            );
                                          } else if (processingState != ProcessingState.completed) {
                                            return TextButton.icon(
                                              icon: Icon(Icons.pause),
                                              label: Text("暂停"),
                                              onPressed: player.pause,
                                            );
                                          } else {
                                            return TextButton.icon(
                                              icon: Icon(Icons.replay),
                                              label: Text("播放下一集"),
                                              onPressed: () {
                                                lastIndex = currentIndex + 1;
                                                _tingShuProvider.saveTingshu(
                                                    "${widget.url}_${lastIndex}_${provider.tingshudetail.catlogs[lastIndex].text}_${provider.tingshudetail.catlogs[lastIndex].url}",
                                                    widget.url);
                                                getAudioUrl(provider.tingshudetail.catlogs[lastIndex].url);
                                              },
                                            );
                                          }
                                        },
                                      ),
                                      StreamBuilder<Duration>(
                                        stream: player.durationStream,
                                        builder: (context, snapshot) {
                                          final duration = snapshot.data ?? Duration.zero;
                                          return StreamBuilder<Duration>(
                                            stream: player.positionStream,
                                            builder: (context, snapshot) {
                                              var position = snapshot.data ?? Duration.zero;
                                              if (position > duration) {
                                                position = duration;
                                              }
                                              _tingShuProvider
                                                  .saveRecordNof("${widget.url}_${currentUrl}_${position.inSeconds}");
                                              return SeekBar(
                                                duration: duration,
                                                position: position,
                                                onChangeEnd: (newPosition) {
                                                  player.seek(newPosition);
                                                },
                                              );
                                            },
                                          );
                                        },
                                      )
                                    ],
                                  )
                                : Container(),
                          ),
                          SliverToBoxAdapter(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    provider.tingshudetail.content,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    maxLines: 5,
                                  ),
                                  Gaps.vGap8,
                                  provider.lastTingshu != ""
                                      ? Row(
                                          children: [
                                            lastIndex >= 0
                                                ? TextButton(
                                                    onPressed: null,
                                                    child: Text(
                                                      "正在听的章节：${provider.tingshudetail.catlogs[lastIndex].text}",
                                                      style: TextStyle(fontSize: 13),
                                                    ))
                                                : Container(),
                                            TextButton(
                                                onPressed: () {
                                                  currentIndex = int.parse(provider.lastTingshu.split("_")[1]);
                                                  getAudioUrl(provider.lastTingshu.split("_")[3]);
                                                },
                                                child: Text("最后听的章节：${provider.lastTingshu.split("_")[2]}",
                                                    style: TextStyle(fontSize: 13)))
                                          ],
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.all(10),
                            sliver: AnimationLimiter(
                              child: SliverGrid(
                                //Grid
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5, //Grid按两列显示
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 1,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return AnimationConfiguration.staggeredGrid(
                                      position: index,
                                      duration: const Duration(milliseconds: 375),
                                      columnCount: provider.tingshudetail.catlogs.length,
                                      child: ScaleAnimation(
                                        child: FadeInAnimation(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: _tingShuProvider.kanguozhangjie.contains(
                                                          "${widget.url}_${index}_${provider.tingshudetail.catlogs[index].text}_${provider.tingshudetail.catlogs[index].url}")
                                                      ? Colors.redAccent
                                                      : Colors.blueAccent,
                                                  borderRadius: BorderRadius.all(Radius.circular(5))),
                                              alignment: Alignment.center,
                                              child: TextButton(
                                                  onPressed: () {
                                                    currentIndex = index;
                                                    lastIndex = index;
                                                    _tingShuProvider.saveTingshu(
                                                        "${widget.url}_${index}_${provider.tingshudetail.catlogs[index].text}_${provider.tingshudetail.catlogs[index].url}",
                                                        widget.url);
                                                  },
                                                  child: Text(
                                                    '${provider.tingshudetail.catlogs[index].text}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: isDark ? Colours.dark_text : Colors.white, fontSize: 11),
                                                  ))),
                                        ),
                                      ),
                                    );
                                    //创建子widget
                                  },
                                  childCount: provider.tingshudetail.catlogs.length,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : StateLayout(type: provider.state, onRefresh: refresh);
              }),
            ],
          ),
        ));
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Slider(
          min: 0.0,
          max: widget.duration.inMilliseconds.toDouble(),
          value:
              min(_dragValue ?? widget.position.inMilliseconds.toDouble(), widget.duration.inMilliseconds.toDouble()),
          onChanged: (value) {
            setState(() {
              _dragValue = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd(Duration(milliseconds: value.round()));
            }
            _dragValue = null;
          },
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$').firstMatch("$_remaining")?.group(1) ?? '$_remaining',
              style: Theme.of(context).textTheme.caption),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}
