import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'package:ZY_Player_flutter/common/common.dart';
import 'package:ZY_Player_flutter/event/event_bus.dart';
import 'package:flutter_picker/flutter_picker.dart';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/provider/detail_provider.dart';
import 'package:ZY_Player_flutter/provider/theme_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/app_bar.dart';
import 'package:ZY_Player_flutter/widgets/my_card.dart';
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

class _PlayerDetailPageState extends State<PlayerDetailPage>
    with WidgetsBindingObserver {
  final FijkPlayer _player = FijkPlayer();

  bool startedPlaying = false;

  DetailProvider _detailProvider = DetailProvider();
  CollectProvider _collectProvider;
  ThemeProvider _themeProvider;
  StreamSubscription _currentPosSubs;

  String actionName = "";
  bool _isFullscreen = false;

  int currentVideoIndex = -1;

  String currentUrl = "";
  Picker _picker;
  StreamSubscription _deviceSubs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> pickerDevices([PickerConfirmCallback onConfirm]) async {
    // 如果设备信息更新通知，onConfirm肯定为null
    // 此时需要校验一下picker是否还显示着，如果已经不显示了，就没有必要刷新信息了。
    // FIXME：这儿刷新设备信息的方法比较差劲，对flutter不熟，或许有更好的方法。
    if (onConfirm == null && (_picker == null || !_picker.state.mounted)) {
      _picker = null;
      return;
    }

    // 显示两列内容，第一列是视频列表，第二列是设备列表。
    List<PickerItem<String>> devices = [];
    if (Constant.dlnaDevices.length == 0) {
      devices.add(PickerItem(text: Text("正在搜寻...")));
    } else {
      for (var item in Constant.dlnaDevices) {
        devices.add(PickerItem(text: Text(item["name"]), value: item["id"]));
      }
    }
    List<PickerItem<String>> videos = [];
    for (VideoList item in _detailProvider.detailReource.videoList) {
      videos.add(PickerItem(
          text: Text("${item.title}"), value: item.url, children: devices));
    }
    PickerDataAdapter<String> _adapter =
        PickerDataAdapter<String>(data: videos);

    // 处理更新设备信息的逻辑
    if (_picker != null) {
      if (onConfirm == null) {
        onConfirm = _picker.onConfirm;
      }
      if (_picker.state.mounted) {
        _picker.doCancel(context);
      }
    }

    // 显示picker窗口
    _picker = Picker(
        adapter: _adapter,
        title: Text("请选择推送内容"),
        cancelText: "取消",
        confirmText: "确认",
        onConfirm: onConfirm);
    _picker.show(_scaffoldKey.currentState);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _collectProvider = Store.value<CollectProvider>(context);
    _themeProvider = Store.value<ThemeProvider>(context);
    _collectProvider.setListDetailResource("collcetPlayer");
    _player.addListener(_fijkValueListener);

    initData();
    super.initState();
  }

  Future _fijkValueListener() async {
    FijkValue value = _player.value;
    _isFullscreen = value.fullScreen;
    // 播放完成 是否从新播放下一集 completed
    Log.d(value.duration.inMilliseconds.toString());
    if (value.state == FijkState.completed) {
      if (_detailProvider.detailReource.videoList.length > 1) {
        currentVideoIndex += 1;
        _themeProvider.setloadingState(true);
        Toast.show("正在解析地址,开始播放下一集");
        await getPlayVideoUrl(
            _detailProvider.detailReource.videoList[currentVideoIndex].url,
            currentVideoIndex);
        _detailProvider.saveJuji("${widget.url}_$currentVideoIndex");
        _player.reset().then((value) {
          _player.setDataSource(currentUrl, autoPlay: true);
          Toast.show("开始播放第${currentVideoIndex + 1}集");
          _themeProvider.setloadingState(false);
        });
      } else {
        Toast.show("已播放完成");
      }
    }
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
    _deviceSubs?.cancel();
  }

  Future getPlayVideoUrl(String videoUrl, int index) async {
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getPlayVideoUrl,
        queryParameters: {"url": videoUrl}, onSuccess: (data) {
      currentUrl = data;
    }, onError: (_, __) {
      currentVideoIndex = index;
    });
  }

  Future initData() async {
    _detailProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.detailReource,
        queryParameters: {"url": widget.url}, onSuccess: (data) {
      _detailProvider.setDetailResource(DetailReource.fromJson(data[0]));
      _detailProvider.setJuji();
      _collectProvider.changeNoti();
      setPlayerVideo();
      if (getFilterData(_detailProvider.detailReource)) {
        _detailProvider.setActionName("点击取消");
      } else {
        _detailProvider.setActionName("点击收藏");
      }
      _detailProvider.setStateType(StateType.empty);
    }, onError: (_, __) {
      _detailProvider.setStateType(StateType.network);
    });

    _deviceSubs = ApplicationEvent.event.on<DeviceEvent>().listen((event) {
      pickerDevices();
    });
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

  bool getFilterData(DetailReource data) {
    if (data != null) {
      var result = _collectProvider.listDetailResource
          .where((element) => element.url == data.url)
          .toList();
      return result.length > 0;
    }
    return false;
  }

  Widget buildTuiSong(var provider, var isDark) {
    return FlatButton(
      child: Icon(Icons.present_to_all_sharp),
      onPressed: () async {
        _player.pause();
        _themeProvider.setloadingState(false);

        // 强制重新搜寻设备
        if (Constant.dlnaDevices.length == 0) {
          Constant.dlnaManager.stop();
        }
        Constant.dlnaManager.search();
        pickerDevices((picker, selecteds) {
          List selected = picker.adapter.getSelectedValues();
          String videoUrl = selected[0];
          String deviceUuid = selected[1];
          if (deviceUuid == null || videoUrl == null) {
            return;
          }
          var device;
          for (var item in Constant.dlnaDevices) {
            if (item['id'] == deviceUuid) {
              device = item;
              break;
            }
          }
          String videoTitle;
          for (var item in _detailProvider.detailReource.videoList) {
            if (item.url == videoUrl) {
              videoTitle = item.title;
              break;
            }
          }
          if (device == null || videoTitle == null) {
            return;
          }
          _themeProvider.setloadingState(true);
          Toast.show("正在解析地址");
          getPlayVideoUrl(videoUrl, currentVideoIndex).then((value) async {
            print("推送视频 $videoTitle $currentUrl 到设备：${device['name']}");

            Toast.show("推送视频 $videoTitle 到设备：${device['name']}");
            await Constant.dlnaManager.setDevice(device["id"]);
            await Constant.dlnaManager
                .setVideoUrlAndName(currentUrl, videoTitle);
            _themeProvider.setloadingState(false);
          });
          _picker = null;
        });
      },
    );
  }

  Wrap buildJuJi(var provider, var isDark) {
    return Wrap(
      spacing: 20, // 主轴(水平)方向间距
      runSpacing: 10, // 纵轴（垂直）方向间距
      alignment: WrapAlignment.start, //沿主轴方向居中
      children: List.generate(provider.detailReource.videoList.length, (index) {
        return InkWell(
            onTap: () async {
              if (currentVideoIndex == index) return;
              currentVideoIndex = index;
              _themeProvider.setloadingState(true);
              Toast.show("正在解析地址");
              await getPlayVideoUrl(
                  _detailProvider
                      .detailReource.videoList[currentVideoIndex].url,
                  currentVideoIndex);
              _detailProvider.saveJuji("${widget.url}_$currentVideoIndex");
              _player.reset().then((value) {
                _player.setDataSource(currentUrl, autoPlay: true);
                Toast.show("开始播放第${currentVideoIndex + 1}集");
                _themeProvider.setloadingState(false);
              });
            },
            child: Container(
                width: ScreenUtil.getInstance().getWidth(100),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: _detailProvider.kanguojuji
                            .contains("${widget.url}_$index")
                        ? Colors.redAccent
                        : Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                alignment: Alignment.center,
                child: Text(
                  '${_detailProvider.detailReource.videoList[index].title}',
                  style: TextStyle(
                    color: isDark ? Colours.dark_text : Colors.white,
                  ),
                )));
      }),
    );
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
          key: _scaffoldKey,
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Selector<DetailProvider, String>(
                  builder: (_, actionName, __) {
                    return MyAppBar(
                        centerTitle: widget.title,
                        actionName: actionName,
                        onPressed: () {
                          if (getFilterData(_detailProvider.detailReource)) {
                            Log.d("点击取消");
                            _collectProvider.removeResource(
                                _detailProvider.detailReource.url);
                            _detailProvider.setActionName("点击收藏");
                          } else {
                            Log.d("点击收藏");
                            _collectProvider.addResource(
                              _detailProvider.detailReource,
                            );
                            _detailProvider.setActionName("点击取消");
                          }
                        });
                  },
                  selector: (_, store) => store.actionName)),
          body: Consumer<DetailProvider>(builder: (_, provider, __) {
            return provider.detailReource != null
                ? Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: ScreenUtil.getInstance().getWidth(230),
                            child: FijkView(
                              player: _player,
                              color: Colors.black,
                              panelBuilder: (player, data, BuildContext context,
                                  Size viewSize, Rect texturePos) {
                                return _FijkPanel2(
                                  player: player,
                                  onBack: () {
                                    player.exitFullScreen();
                                  },
                                  onError: () {
                                    _player.reset().then((value) {
                                      _player.setDataSource(currentUrl,
                                          autoPlay: true);
                                      Toast.show(
                                          "开始播放第${currentVideoIndex + 1}集");
                                      _themeProvider.setloadingState(false);
                                    });
                                  },
                                  data: data,
                                  viewSize: viewSize,
                                  texPos: texturePos,
                                  fill: fill,
                                  doubleTap: doubleTap,
                                  snapShot: snapShot,
                                  hideDuration: duration,
                                );
                              },
                              fsFit: FijkFit.fill,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                          child: CustomScrollView(
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: MyCard(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("剧情介绍"),
                                    Text(
                                      provider.detailReource.content,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 10,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: provider.detailReource.videoList.length > 0
                                ? MyCard(
                                    child: Container(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10, bottom: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                "剧集选择",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              buildTuiSong(provider, isDark)
                                            ],
                                          ),
                                        ),
                                        buildJuJi(provider, isDark),
                                      ],
                                    ),
                                  ))
                                : Container(),
                          )
                        ],
                      ))
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

class _FijkData {
  static String _fijkViewPanelVolume = "__fijkview_panel_init_volume";
  static String _fijkViewPanelBrightness = "__fijkview_panel_init_brightness";
  static String _fijkViewPanelSeekto = "__fijkview_panel_sekto_position";

  final Map<String, dynamic> _data = HashMap();

  void setValue(String key, dynamic value) {
    _data[key] = value;
  }

  void clearValue(String key) {
    _data.remove(key);
  }

  bool contains(String key) {
    return _data.containsKey(key);
  }

  dynamic getValue(String key) {
    return _data[key];
  }
}

String _duration2String(Duration duration) {
  if (duration.inMilliseconds < 0) return "-: negtive";

  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  int inHours = duration.inHours;
  return inHours > 0
      ? "$inHours:$twoDigitMinutes:$twoDigitSeconds"
      : "$twoDigitMinutes:$twoDigitSeconds";
}

class _FijkPanel2 extends StatefulWidget {
  final FijkPlayer player;
  final FijkData data;
  final VoidCallback onBack;
  final VoidCallback onError;
  final Size viewSize;
  final Rect texPos;
  final bool fill;
  final bool doubleTap;
  final bool snapShot;
  final int hideDuration;

  const _FijkPanel2(
      {Key key,
      @required this.player,
      this.data,
      this.fill,
      this.onBack,
      this.onError,
      this.viewSize,
      this.hideDuration,
      this.doubleTap,
      this.snapShot,
      this.texPos})
      : assert(player != null),
        assert(
            hideDuration != null && hideDuration > 0 && hideDuration < 10000),
        super(key: key);

  @override
  __FijkPanel2State createState() => __FijkPanel2State();
}

class __FijkPanel2State extends State<_FijkPanel2> {
  FijkPlayer get player => widget.player;

  Timer _hideTimer;
  bool _hideStuff = true;

  Timer _statelessTimer;
  bool _prepared = false;
  bool _playing = false;
  bool _dragLeft;
  double _volume;
  double _brightness;

  double _seekPos = -1.0;
  Duration _duration = Duration();
  Duration _currentPos = Duration();
  Duration _bufferPos = Duration();
  bool _isBuffer = false;

  StreamSubscription _currentPosSubs;
  StreamSubscription _bufferPosSubs;
  StreamSubscription _isBufferPosSubs;

  StreamController<double> _valController;

  // snapshot
  ImageProvider _imageProvider;
  Timer _snapshotTimer;

  // Is it needed to clear seek data in _FijkData (widget.data)
  bool _needClearSeekData = true;

  static const FijkSliderColors sliderColors = FijkSliderColors(
      cursorColor: Color.fromARGB(240, 250, 100, 10),
      playedColor: Color.fromARGB(200, 240, 90, 50),
      baselineColor: Color.fromARGB(100, 20, 20, 20),
      bufferedColor: Color.fromARGB(180, 200, 200, 200));

  @override
  void initState() {
    super.initState();

    _valController = StreamController.broadcast();
    _prepared = player.state.index >= FijkState.prepared.index;
    _playing = player.state == FijkState.started;
    _duration = player.value.duration;
    _currentPos = player.currentPos;
    _bufferPos = player.bufferPos;
    _isBuffer = player.isBuffering;

    _currentPosSubs = player.onCurrentPosUpdate.listen((v) {
      if (_hideStuff == false) {
        setState(() {
          _currentPos = v;
        });
      } else {
        _currentPos = v;
      }
      if (_needClearSeekData) {
        widget.data.clearValue(_FijkData._fijkViewPanelSeekto);
      }
      _needClearSeekData = false;
    });

    if (widget.data.contains(_FijkData._fijkViewPanelSeekto)) {
      var pos = widget.data.getValue(_FijkData._fijkViewPanelSeekto) as double;
      _currentPos = Duration(milliseconds: pos.toInt());
    }

    _bufferPosSubs = player.onBufferPosUpdate.listen((v) {
      if (_hideStuff == false) {
        setState(() {
          _bufferPos = v;
        });
      } else {
        _bufferPos = v;
      }
    });

    _isBufferPosSubs = player.onBufferStateUpdate.listen((v) {
      setState(() {
        _isBuffer = v;
      });
    });

    player.addListener(_playerValueChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _valController?.close();
    _hideTimer?.cancel();
    _statelessTimer?.cancel();
    _snapshotTimer?.cancel();
    _currentPosSubs?.cancel();
    _bufferPosSubs?.cancel();
    _isBufferPosSubs?.cancel();
    player.removeListener(_playerValueChanged);
  }

  double dura2double(Duration d) {
    return d != null ? d.inMilliseconds.toDouble() : 0.0;
  }

  void _playerValueChanged() {
    FijkValue value = player.value;

    if (value.duration != _duration) {
      if (_hideStuff == false) {
        setState(() {
          _duration = value.duration;
        });
      } else {
        _duration = value.duration;
      }
    }
    bool playing = (value.state == FijkState.started);
    bool prepared = value.prepared;
    if (playing != _playing ||
        prepared != _prepared ||
        value.state == FijkState.asyncPreparing) {
      setState(() {
        _playing = playing;
        _prepared = prepared;
      });
    }
  }

  void _restartHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(milliseconds: widget.hideDuration), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void onTapFun() {
    if (_hideStuff == true) {
      _restartHideTimer();
    }
    setState(() {
      _hideStuff = !_hideStuff;
    });
  }

  void playOrPause() {
    if (player.isPlayable() || player.state == FijkState.asyncPreparing) {
      if (player.state == FijkState.started) {
        player.pause();
      } else {
        player.start();
      }
    } else {
      FijkLog.w("Invalid state ${player.state} ,can't perform play or pause");
    }
  }

  void onDoubleTapFun() {
    playOrPause();
  }

  void onVerticalDragStartFun(DragStartDetails d) {
    if (d.localPosition.dx > panelWidth() / 2) {
      // right, volume
      _dragLeft = false;
      FijkVolume.getVol().then((v) {
        if (widget.data != null &&
            !widget.data.contains(_FijkData._fijkViewPanelVolume)) {
          widget.data.setValue(_FijkData._fijkViewPanelVolume, v);
        }
        setState(() {
          _volume = v;
          _valController.add(v);
        });
      });
    } else {
      // left, brightness
      _dragLeft = true;
      FijkPlugin.screenBrightness().then((v) {
        if (widget.data != null &&
            !widget.data.contains(_FijkData._fijkViewPanelBrightness)) {
          widget.data.setValue(_FijkData._fijkViewPanelBrightness, v);
        }
        setState(() {
          _brightness = v;
          _valController.add(v);
        });
      });
    }
    _statelessTimer?.cancel();
    _statelessTimer = Timer(const Duration(milliseconds: 2000), () {
      setState(() {});
    });
  }

  void onVerticalDragUpdateFun(DragUpdateDetails d) {
    double delta = d.primaryDelta / panelHeight();
    delta = -delta.clamp(-1.0, 1.0);
    if (_dragLeft != null && _dragLeft == false) {
      if (_volume != null) {
        _volume += delta;
        _volume = _volume.clamp(0.0, 1.0);
        FijkVolume.setVol(_volume);
        setState(() {
          _valController.add(_volume);
        });
      }
    } else if (_dragLeft != null && _dragLeft == true) {
      if (_brightness != null) {
        _brightness += delta;
        _brightness = _brightness.clamp(0.0, 1.0);
        FijkPlugin.setScreenBrightness(_brightness);
        setState(() {
          _valController.add(_brightness);
        });
      }
    }
  }

  void onVerticalDragEndFun(DragEndDetails e) {
    _volume = null;
    _brightness = null;
  }

  Widget buildPlayButton(BuildContext context, double height) {
    Icon icon = (player.state == FijkState.started)
        ? Icon(Icons.pause)
        : Icon(Icons.play_arrow);
    bool fullScreen = player.value.fullScreen;
    return IconButton(
      padding: EdgeInsets.all(0),
      iconSize: fullScreen ? height : height * 0.8,
      color: Color(0xFFFFFFFF),
      icon: icon,
      onPressed: playOrPause,
    );
  }

  Widget buildFullScreenButton(BuildContext context, double height) {
    Icon icon = player.value.fullScreen
        ? Icon(Icons.fullscreen_exit)
        : Icon(Icons.fullscreen);
    bool fullScreen = player.value.fullScreen;
    return IconButton(
      padding: EdgeInsets.all(0),
      iconSize: fullScreen ? height : height * 0.8,
      color: Color(0xFFFFFFFF),
      icon: icon,
      onPressed: () {
        player.value.fullScreen
            ? player.exitFullScreen()
            : player.enterFullScreen();
      },
    );
  }

  Widget buildTimeText(BuildContext context, double height) {
    String text =
        "${_duration2String(_currentPos)}" + "/${_duration2String(_duration)}";
    return Text(text, style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF)));
  }

  Widget buildSlider(BuildContext context) {
    double duration = dura2double(_duration);

    double currentValue = _seekPos > 0 ? _seekPos : dura2double(_currentPos);
    currentValue = currentValue.clamp(0.0, duration);

    double bufferPos = dura2double(_bufferPos);
    bufferPos = bufferPos.clamp(0.0, duration);

    return Padding(
      padding: EdgeInsets.only(left: 3),
      child: _FijkSlider(
        colors: sliderColors,
        value: currentValue,
        cacheValue: bufferPos,
        min: 0.0,
        max: duration,
        onChanged: (v) {
          _restartHideTimer();
          setState(() {
            _seekPos = v;
            _currentPos = Duration(milliseconds: _seekPos.toInt());
          });
        },
        onChangeEnd: (v) {
          setState(() {
            player.seekTo(v.toInt());
            _currentPos = Duration(milliseconds: _seekPos.toInt());
            widget.data.setValue(_FijkData._fijkViewPanelSeekto, _seekPos);
            _needClearSeekData = true;
            _seekPos = -1.0;
          });
        },
      ),
    );
  }

  Widget buildBottom(BuildContext context, double height) {
    if (_duration != null && _duration.inMilliseconds > 0) {
      return Row(
        children: <Widget>[
          buildPlayButton(context, height),
          buildTimeText(context, height),
          Expanded(child: buildSlider(context)),
          buildFullScreenButton(context, height),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          buildPlayButton(context, height),
          Expanded(child: Container()),
          buildFullScreenButton(context, height),
        ],
      );
    }
  }

  void takeSnapshot() {
    player.takeSnapShot().then((v) {
      var provider = MemoryImage(v);
      precacheImage(provider, context).then((_) {
        setState(() {
          _imageProvider = provider;
        });
      });
      FijkLog.d("get snapshot succeed");
    }).catchError((e) {
      FijkLog.d("get snapshot failed");
    });
  }

  Widget buildPanel(BuildContext context) {
    double height = panelHeight();

    bool fullScreen = player.value.fullScreen;
    Widget centerWidget = Container(
      color: Color(0x00000000),
    );

    Widget centerChild = Container(
      color: Color(0x00000000),
    );

    if (fullScreen && widget.snapShot) {
      centerWidget = Row(
        children: <Widget>[
          Expanded(child: centerChild),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  padding: EdgeInsets.all(0),
                  color: Color(0xFFFFFFFF),
                  icon: Icon(Icons.camera_alt),
                  onPressed: () {
                    takeSnapshot();
                  },
                ),
              ],
            ),
          )
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: height > 200 ? 80 : height / 5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x88000000), Color(0x00000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: buildBack(context),
        ),
        Expanded(
          child: centerWidget,
        ),
        Container(
          height: height > 80 ? 80 : height / 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x88000000), Color(0x00000000)],
              end: Alignment.topCenter,
              begin: Alignment.bottomCenter,
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            height: height > 80 ? 45 : height / 2,
            padding: EdgeInsets.only(left: 8, right: 8, bottom: 5),
            child: buildBottom(context, height > 80 ? 40 : height / 2),
          ),
        )
      ],
    );
  }

  GestureDetector buildGestureDetector(BuildContext context) {
    return GestureDetector(
      onTap: onTapFun,
      onDoubleTap: widget.doubleTap ? onDoubleTapFun : null,
      onVerticalDragUpdate: onVerticalDragUpdateFun,
      onVerticalDragStart: onVerticalDragStartFun,
      onVerticalDragEnd: onVerticalDragEndFun,
      onHorizontalDragUpdate: (d) {},
      child: AbsorbPointer(
        absorbing: _hideStuff,
        child: AnimatedOpacity(
          opacity: _hideStuff ? 0 : 1,
          duration: Duration(milliseconds: 300),
          child: buildPanel(context),
        ),
      ),
    );
  }

  Rect panelRect() {
    Rect rect = player.value.fullScreen || (true == widget.fill)
        ? Rect.fromLTWH(0, 0, widget.viewSize.width, widget.viewSize.height)
        : Rect.fromLTRB(
            max(0.0, widget.texPos.left),
            max(0.0, widget.texPos.top),
            min(widget.viewSize.width, widget.texPos.right),
            min(widget.viewSize.height, widget.texPos.bottom));
    return rect;
  }

  double panelHeight() {
    if (player.value.fullScreen || (true == widget.fill)) {
      return widget.viewSize.height;
    } else {
      return min(widget.viewSize.height, widget.texPos.bottom) -
          max(0.0, widget.texPos.top);
    }
  }

  double panelWidth() {
    if (player.value.fullScreen || (true == widget.fill)) {
      return widget.viewSize.width;
    } else {
      return min(widget.viewSize.width, widget.texPos.right) -
          max(0.0, widget.texPos.left);
    }
  }

  Widget buildBack(BuildContext context) {
    if (_duration != null && _duration.inMilliseconds > 0) {
      return IconButton(
        padding: EdgeInsets.only(left: 5),
        icon: Icon(
          Icons.arrow_back_ios,
          color: Color(0xDDFFFFFF),
        ),
        onPressed: widget.onBack,
      );
    }
  }

  Widget buildStateless() {
    if (_volume != null || _brightness != null) {
      Widget toast = _volume == null
          ? defaultFijkBrightnessToast(_brightness, _valController.stream)
          : defaultFijkVolumeToast(_volume, _valController.stream);
      return IgnorePointer(
        child: AnimatedOpacity(
          opacity: 1,
          duration: Duration(milliseconds: 500),
          child: toast,
        ),
      );
    } else if (player.state == FijkState.asyncPreparing || _isBuffer) {
      // 缓冲中，获得是加载中
      return Container(
        alignment: Alignment.center,
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white)),
        ),
      );
    } else if (player.state == FijkState.error) {
      // 错误之后，点击重新播放
      return GestureDetector(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 30,
                color: Color(0x99FFFFFF),
              ),
              Text(
                "点击刷新",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
        onTap: widget.onError,
      );
    } else if (_imageProvider != null) {
      _snapshotTimer?.cancel();
      _snapshotTimer = Timer(Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _imageProvider = null;
          });
        }
      });
      return Center(
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.yellowAccent, width: 3)),
            child:
                Image(height: 200, fit: BoxFit.contain, image: _imageProvider),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    Rect rect = panelRect();

    List ws = <Widget>[];

    if (_statelessTimer != null && _statelessTimer.isActive) {
      ws.add(buildStateless());
    } else if (player.state == FijkState.asyncPreparing || _isBuffer) {
      ws.add(buildStateless());
    } else if (player.state == FijkState.error) {
      ws.add(buildStateless());
    } else if (_imageProvider != null) {
      ws.add(buildStateless());
    }
    ws.add(buildGestureDetector(context));
    // if (widget.onBack != null) {
    //   ws.add();
    // }

    return Positioned.fromRect(
      rect: rect,
      child: Stack(children: ws),
    );
  }
}

class _FijkSlider extends StatefulWidget {
  final double value;
  final double cacheValue;

  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChangeEnd;

  final double min;
  final double max;

  final FijkSliderColors colors;

  const _FijkSlider({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.cacheValue = 0.0,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.colors = const FijkSliderColors(),
  })  : assert(value != null),
        assert(cacheValue != null),
        assert(min != null),
        assert(max != null),
        assert(min <= max),
        assert(value >= min && value <= max),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FijkSliderState();
  }
}

class _FijkSliderState extends State<_FijkSlider> {
  bool dragging = false;

  double dragValue;

  static const double margin = 2.0;

  @override
  Widget build(BuildContext context) {
    double v = widget.value / (widget.max - widget.min);
    double cv = widget.cacheValue / (widget.max - widget.min);

    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(left: margin, right: margin),
        height: double.infinity,
        width: double.infinity,
        color: Colors.transparent,
        child: CustomPaint(
          painter: _SliderPainter(v, cv, dragging, colors: widget.colors),
        ),
      ),
      onHorizontalDragStart: (DragStartDetails details) {
        setState(() {
          dragging = true;
        });
        dragValue = widget.value;
        if (widget.onChangeStart != null) {
          widget.onChangeStart(dragValue);
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        final box = context.findRenderObject() as RenderBox;
        final dx = details.localPosition.dx;
        dragValue = (dx - margin) / (box.size.width - 2 * margin);
        dragValue = max(0, min(1, dragValue));
        dragValue = dragValue * (widget.max - widget.min) + widget.min;
        if (widget.onChanged != null) {
          widget.onChanged(dragValue);
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        setState(() {
          dragging = false;
        });
        if (widget.onChangeEnd != null) {
          widget.onChangeEnd(dragValue);
        }
      },
    );
  }
}

/// Colors for the FijkSlider
class FijkSliderColors {
  const FijkSliderColors({
    this.playedColor = const Color.fromRGBO(255, 0, 0, 0.6),
    this.bufferedColor = const Color.fromRGBO(50, 50, 100, 0.4),
    this.cursorColor = const Color.fromRGBO(255, 0, 0, 0.8),
    this.baselineColor = const Color.fromRGBO(200, 200, 200, 0.5),
  });

  final Color playedColor;
  final Color bufferedColor;
  final Color cursorColor;
  final Color baselineColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FijkSliderColors &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;

  @override
  int get hashCode =>
      hashValues(playedColor, bufferedColor, cursorColor, baselineColor);
}

class _SliderPainter extends CustomPainter {
  final double v;
  final double cv;

  final bool dragging;
  final Paint pt = Paint();

  final FijkSliderColors colors;

  _SliderPainter(this.v, this.cv, this.dragging,
      {this.colors = const FijkSliderColors()})
      : assert(colors != null),
        assert(v != null),
        assert(cv != null);

  @override
  void paint(Canvas canvas, Size size) {
    double lineHeight = min(size.height / 2, 1);
    pt.color = colors.baselineColor;

    double radius = min(size.height / 2, 4);
    // draw background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0, size.height / 2 - lineHeight),
          Offset(size.width, size.height / 2 + lineHeight),
        ),
        Radius.circular(radius),
      ),
      pt,
    );

    final double value = v * size.width;

    // draw played part
    pt.color = colors.playedColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0, size.height / 2 - lineHeight),
          Offset(value, size.height / 2 + lineHeight),
        ),
        Radius.circular(radius),
      ),
      pt,
    );

    // draw cached part
    final double cacheValue = cv * size.width;
    if (cacheValue > value && cacheValue > 0) {
      pt.color = colors.bufferedColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(value, size.height / 2 - lineHeight),
            Offset(cacheValue, size.height / 2 + lineHeight),
          ),
          Radius.circular(radius),
        ),
        pt,
      );
    }

    // draw circle cursor
    pt.color = colors.cursorColor;
    pt.color = pt.color.withAlpha(max(0, pt.color.alpha - 50));
    radius = min(size.height / 2, dragging ? 10 : 5);
    canvas.drawCircle(Offset(value, size.height / 2), 10, pt);
    pt.color = colors.cursorColor;
    radius = min(size.height / 2, dragging ? 6 : 3);
    canvas.drawCircle(Offset(value, size.height / 2), radius, pt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SliderPainter && hashCode == other.hashCode;

  @override
  int get hashCode => hashValues(v, cv, dragging, colors);

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) {
    return hashCode != oldDelegate.hashCode;
  }
}
