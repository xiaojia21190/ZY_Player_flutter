import 'dart:async';
import 'dart:math';

import 'package:ZY_Player_flutter/model/audio_detail.dart';
import 'package:ZY_Player_flutter/model/audio_loc.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/tingshu/provider/tingshu_provider.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../Collect/provider/collect_provider.dart';

class TingshuDetailPage extends StatefulWidget {
  const TingshuDetailPage({
    Key? key,
    required this.url,
    required this.title,
    required this.cover,
  }) : super(key: key);

  final String url;
  final String title;
  final String cover;

  @override
  _TingshuDetailPageState createState() => _TingshuDetailPageState();
}

class _TingshuDetailPageState extends State<TingshuDetailPage> {
  late TingShuProvider _tingShuProvider;
  late AppStateProvider _appStateProvider;
  CollectProvider? _collectProvider;
  final player = AudioPlayer();

  String actionName = "";
  String currentUrl = "";
  Duration? currentDuration;
  int currentIndex = -1;
  int lastIndex = -1;

  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    _collectProvider = Store.value<CollectProvider>(context);
    _tingShuProvider = Store.value<TingShuProvider>(context);
    _appStateProvider = Store.value<AppStateProvider>(context);
    player.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.completed:
          if (isCompleted) return;
          isCompleted = true;
          // 自动播放下一集
          lastIndex = currentIndex + 1;
          if (lastIndex > _tingShuProvider.tingshudetail.length) return;
          _tingShuProvider.saveTingshu("${widget.url}_${lastIndex}_${_tingShuProvider.tingshudetail[lastIndex].name}_${_tingShuProvider.tingshudetail[lastIndex].musicrid}", widget.url);
          getAudioUrl(_tingShuProvider.tingshudetail[lastIndex].musicrid);
          break;
        case ProcessingState.idle:
          break;
        case ProcessingState.loading:
          break;
        case ProcessingState.buffering:
          break;
        case ProcessingState.ready:
          break;
      }
    });
    Future.microtask(() => initData());
  }

  @override
  void dispose() {
    _tingShuProvider.setInitPlayer(false, not: false);
    _tingShuProvider.changeLastTs();
    player.dispose();
    super.dispose();
  }

  Future initData() async {
    _appStateProvider.setloadingState(true);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getXmlyDetail, queryParameters: {"albumId": widget.url}, onSuccess: (data) {
      List<AudioDetail> LLL = [];
      List.generate(data.length, (index) => LLL.add(AudioDetail.fromJson(data[index])));

      _tingShuProvider.setTingshuDetail(LLL);
      _tingShuProvider.setTingshu(widget.url);

      _appStateProvider.setloadingState(false);
      _tingShuProvider.setStateType(StateType.empty);
      _collectProvider?.changeNoti();

      if (getFilterData(widget.url)) {
        _tingShuProvider.setActionName("取消");
      } else {
        _tingShuProvider.setActionName("收藏");
      }
    }, onError: (_, __) {
      _appStateProvider.setloadingState(false);
      _tingShuProvider.setStateType(StateType.network);
    });
  }

  Future getAudioUrl(String id) async {
    Toast.show("正在解析地址");
    _appStateProvider.setloadingState(true);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getXmlyDetailMp3, queryParameters: {"musicId": id}, onSuccess: (data) async {
      currentUrl = data;

      await player.stop();

      try {
        var record = _tingShuProvider.getRecord("${widget.url}_$currentUrl");
        var startAt = const Duration(seconds: 0);
        startAt = Duration(seconds: int.parse(record));
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

  bool getFilterData(String? id) {
    if (id != null) {
      var result = _collectProvider?.list.where((element) => element.url == id).toList();
      return result!.isNotEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // final ThemeData themeData = Theme.of(context);
    // final bool isDark = themeData.brightness == Brightness.dark;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Selector<TingShuProvider, String>(
              builder: (_, actionName, __) {
                return MyAppBar(
                    centerTitle: widget.title,
                    actionName: actionName,
                    onPressed: () {
                      if (getFilterData(widget.url)) {
                        _collectProvider?.removeTingshu(widget.url);
                        _tingShuProvider.setActionName("收藏");
                      } else {
                        _collectProvider?.addTingshu(AudioLoc(widget.url, widget.title, widget.cover));
                        _tingShuProvider.setActionName("取消");
                      }
                    });
              },
              selector: (_, store) => store.actionName)),
      body: Stack(
        children: [
          Consumer<TingShuProvider>(builder: (_, provider, __) {
            // ignore: unnecessary_null_comparison
            return provider.tingshudetail.isNotEmpty
                ? CustomScrollView(
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Container(
                          height: ScreenUtil.getInstance().getWidth(100),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              LoadImage(
                                widget.cover,
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                              Expanded(
                                  child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[Text("专辑: ${provider.tingshudetail[0].artist}")],
                                ),
                              ))
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
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
                                      if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                                        return Container(
                                          margin: const EdgeInsets.all(8.0),
                                          width: 20.0,
                                          height: 20.0,
                                          child: const CircularProgressIndicator(),
                                        );
                                      } else if (playing != true) {
                                        return TextButton.icon(
                                          icon: const Icon(Icons.play_arrow),
                                          label: const Text("播放"),
                                          onPressed: player.play,
                                        );
                                      } else if (processingState != ProcessingState.completed) {
                                        return TextButton.icon(
                                          icon: const Icon(Icons.pause),
                                          label: const Text("暂停"),
                                          onPressed: player.pause,
                                        );
                                      } else {
                                        return TextButton.icon(
                                          icon: const Icon(Icons.replay),
                                          label: const Text("播放下一集"),
                                          onPressed: () async {
                                            lastIndex = currentIndex + 1;
                                            _tingShuProvider.saveTingshu("${widget.url}_${lastIndex}_${provider.tingshudetail[lastIndex].name}_${provider.tingshudetail[lastIndex].musicrid}", widget.url);
                                            await getAudioUrl(provider.tingshudetail[lastIndex].musicrid);
                                          },
                                        );
                                      }
                                    },
                                  ),
                                  StreamBuilder<Duration?>(
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
                                          _tingShuProvider.saveRecordNof("${widget.url}_${currentUrl}_${position.inSeconds}");
                                          return SeekBar(
                                            duration: duration,
                                            position: position,
                                            onChangeEnd: (newPosition) {
                                              player.seek(newPosition);
                                            },
                                            onChanged: (Duration value) {
                                              debugPrint(value.toString());
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
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Gaps.vGap8,
                              provider.lastTingshu != ""
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        lastIndex >= 0 ? TextButton(onPressed: () {}, child: Text("正在听的章节：${provider.tingshudetail[lastIndex].name}")) : Container(),
                                        TextButton(
                                            onPressed: () {
                                              currentIndex = int.parse(provider.lastTingshu.split("_")[1]);
                                              getAudioUrl(provider.lastTingshu.split("_")[3]);
                                            },
                                            child: Text("最后听的章节：${provider.lastTingshu.split("_")[2]}"))
                                      ],
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: Gaps.vGap8,
                      ),
                      SliverFillRemaining(
                        child: ListView.builder(
                            itemBuilder: (_, index) {
                              return AnimationLimiter(
                                  child: Card(
                                      elevation: 5.0,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          side: BorderSide(
                                            style: BorderStyle.solid,
                                            color: Colours.yellow,
                                          )),
                                      margin: const EdgeInsets.all(5),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(5),
                                        subtitle: Text(
                                          provider.tingshudetail[index].artist,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        title: Text(
                                          provider.tingshudetail[index].name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () async {
                                          currentIndex = index;
                                          lastIndex = index;
                                          _tingShuProvider.saveTingshu("${widget.url}_${index}_${provider.tingshudetail[index].name}_${provider.tingshudetail[index].musicrid}", widget.url);

                                          await getAudioUrl(provider.tingshudetail[index].musicrid);
                                        },
                                      )));
                            },
                            itemCount: provider.tingshudetail.length),
                      ),
                    ],
                  )
                : StateLayout(type: provider.state, onRefresh: refresh);
          }),
        ],
      ),
    );
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  SeekBar({
    required this.duration,
    required this.position,
    required this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Slider(
          min: 0.0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: min(widget.position.inMilliseconds.toDouble(), widget.duration.inMilliseconds.toDouble()),
          onChanged: (value) {
            widget.onChanged(Duration(milliseconds: value.round()));
          },
          onChangeEnd: (value) {
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd!(Duration(milliseconds: value.round()));
            }
          },
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$').firstMatch("$_remaining")?.group(1) ?? '$_remaining', style: Theme.of(context).textTheme.caption),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}
