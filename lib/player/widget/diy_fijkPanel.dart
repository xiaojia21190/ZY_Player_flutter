import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:ZY_Player_flutter/event/event_bus.dart';
import 'package:ZY_Player_flutter/event/event_model.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/res/styles.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/utils.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:common_utils/common_utils.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:provider/provider.dart';

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
  return inHours > 0 ? "$inHours:$twoDigitMinutes:$twoDigitSeconds" : "$twoDigitMinutes:$twoDigitSeconds";
}

class DiyFijkPanel extends StatefulWidget {
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
  final bool isZhibo;

  const DiyFijkPanel(
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
      this.isZhibo = false,
      this.texPos})
      : assert(player != null),
        assert(hideDuration != null && hideDuration > 0 && hideDuration < 10000),
        super(key: key);

  @override
  _DiyFijkPanelState createState() => _DiyFijkPanelState();
}

class _DiyFijkPanelState extends State<DiyFijkPanel> {
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

  AppStateProvider appStateProvider;

  static const FijkSliderColors sliderColors = FijkSliderColors(
      cursorColor: Color.fromARGB(240, 250, 100, 10),
      playedColor: Color.fromARGB(200, 240, 90, 50),
      baselineColor: Color.fromARGB(100, 20, 20, 20),
      bufferedColor: Color.fromARGB(180, 200, 200, 200));

  @override
  void initState() {
    super.initState();
    appStateProvider = Store.value<AppStateProvider>(context);
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
    if (playing != _playing || prepared != _prepared || value.state == FijkState.asyncPreparing) {
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

  bool _allowHorizontal = false;
  Duration _moveFromPos;
  double _moveToMs;
  double _moveDelta;
  String _moveToTime = "调整进度...";
  double _moveTimeOpacity = 0;
  int _maxMoveMs = 0;
  void _onHorizontalDragStart(DragStartDetails details) async {
    // 只有播放器在准备或者正在播放时允许滑动
    if (!player.isPlayable() && player.state != FijkState.asyncPreparing) {
      return;
    }
    _allowHorizontal = true;
    _moveFromPos = _currentPos;
    _moveToMs = _moveFromPos.inMilliseconds.toDouble();
    _moveDelta = 0;
    _maxMoveMs = 12 * 60 * 1000; // 每次最多滑动12分钟
    if (_maxMoveMs > player.value.duration.inMilliseconds) {
      _maxMoveMs = player.value.duration.inMilliseconds;
    }
    _moveToTime = "调整进度...";
    setState(() {
      _moveTimeOpacity = 1.0;
      _hideStuff = !_hideStuff;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // 只有播放器在准备或者正在播放时允许滑动
    if (!_allowHorizontal || (!player.isPlayable() && player.state != FijkState.asyncPreparing)) {
      return;
    }
    // 累计计算偏移量
    _moveDelta += details.delta.dx;
    // 用百分比计算出当前的时间
    _moveToMs = _moveFromPos.inMilliseconds + (_moveDelta / panelWidth() * 2) * _maxMoveMs;
    String currentSecond = DateUtil.formatDateMs(
      (_moveToMs).toInt(),
      isUtc: true,
      format: 'HH:mm:ss',
    );
    if (_moveDelta >= 0) {
      _moveToTime = '快进至：$currentSecond';
    } else {
      _moveToTime = '快退至：$currentSecond';
    }
    setState(() {
      _moveTimeOpacity = 1.0;
      _hideStuff = false;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) async {
    if (!_allowHorizontal || (!player.isPlayable() && player.state != FijkState.asyncPreparing)) {
      return;
    }
    _allowHorizontal = false;
    _currentPos = Duration(milliseconds: _moveToMs.toInt());
    player.seekTo(_moveToMs.toInt());
    setState(() {
      _hideStuff = !_hideStuff;
      _moveTimeOpacity = 0.0;
    });
  }

  void onVerticalDragStartFun(DragStartDetails d) {
    if (d.localPosition.dx > panelWidth() / 2) {
      // right, volume
      _dragLeft = false;
      FijkVolume.getVol().then((v) {
        if (widget.data != null && !widget.data.contains(_FijkData._fijkViewPanelVolume)) {
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
        if (widget.data != null && !widget.data.contains(_FijkData._fijkViewPanelBrightness)) {
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
    Icon icon = (player.state == FijkState.started) ? Icon(Icons.pause) : Icon(Icons.play_arrow);
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
    Icon icon = player.value.fullScreen ? Icon(Icons.fullscreen_exit) : Icon(Icons.fullscreen);
    bool fullScreen = player.value.fullScreen;
    return IconButton(
      padding: EdgeInsets.all(0),
      iconSize: fullScreen ? height : height * 0.8,
      color: Color(0xFFFFFFFF),
      icon: icon,
      onPressed: () {
        player.value.fullScreen ? player.exitFullScreen() : player.enterFullScreen();
      },
    );
  }

  Widget buildTimeText(BuildContext context, double height) {
    String text = "${_duration2String(_currentPos)}" + "/${_duration2String(_duration)}";
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

    Widget moveIndicator = AnimatedOpacity(
      opacity: _moveTimeOpacity,
      duration: Duration(milliseconds: 500),
      child: Container(
        child: Text(
          _moveToTime,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );

    if (fullScreen && widget.snapShot) {
      centerWidget = Row(
        children: <Widget>[
          Expanded(child: centerChild),
          moveIndicator,
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
    } else {
      centerWidget = Row(children: <Widget>[Expanded(child: centerChild), moveIndicator, Expanded(child: centerChild)]);
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
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragEnd: _onHorizontalDragEnd,
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
        : Rect.fromLTRB(max(0.0, widget.texPos.left), max(0.0, widget.texPos.top),
            min(widget.viewSize.width, widget.texPos.right), min(widget.viewSize.height, widget.texPos.bottom));
    return rect;
  }

  double panelHeight() {
    if (player.value.fullScreen || (true == widget.fill)) {
      return widget.viewSize.height;
    } else {
      return min(widget.viewSize.height, widget.texPos.bottom) - max(0.0, widget.texPos.top);
    }
  }

  double panelWidth() {
    if (player.value.fullScreen || (true == widget.fill)) {
      return widget.viewSize.width;
    } else {
      return min(widget.viewSize.width, widget.texPos.right) - max(0.0, widget.texPos.left);
    }
  }

  Widget buildBack(BuildContext context) {
    if ((_duration != null && _duration.inMilliseconds > 0) || widget.isZhibo) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.only(left: 5),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xDDFFFFFF),
            ),
            onPressed: widget.onBack,
          ),
          FlatButton.icon(
              onPressed: () async {
                // 点击显示投屏数据
                if (!widget.isZhibo) {
                  player.stop();
                }
                if (appStateProvider.dlnaDevices.length == 0) {
                  // 没有搜索到
                  searchDialog();
                } else {
                  // 搜索到了
                  dlnaDevicesDialog();
                }
              },
              icon: Icon(
                Icons.present_to_all_sharp,
                color: Colors.white,
              ),
              label: Text(
                "投屏",
                style: TextStyle(color: Colors.white),
              ))
        ],
      );
    }
  }

  dlnaDevicesDialog() {
    showElasticDialog<void>(
      context: context,
      builder: (BuildContext context) {
        const OutlinedBorder buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0)));
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: context.dialogBackgroundColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              width: 270.0,
              height: ScreenUtil.getInstance().getWidth(300),
              padding: const EdgeInsets.only(top: 24.0),
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
                      const Text(
                        '可以投屏的设备',
                        style: TextStyles.textBold18,
                      ),
                      Gaps.vGap16,
                      Expanded(
                        child: Selector<AppStateProvider, List>(
                            builder: (_, devices, __) {
                              return Column(
                                children: List.generate(
                                  devices.length,
                                  (index) => Expanded(
                                    child: TextButton(
                                      child: Text(devices[index].deviceName),
                                      onPressed: () {
                                        ApplicationEvent.event
                                            .fire(DeviceEvent(devices[index].uuid, devices[index].deviceName));
                                      },
                                    ),
                                  ),
                                ).toList(),
                              );
                            },
                            selector: (_, store) => store.dlnaDevices),
                      )
                    ],
                  )),
            ),
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
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
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
              Gaps.vGap8,
              Text(
                "播放源已损坏",
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
            decoration: BoxDecoration(border: Border.all(color: Colors.yellowAccent, width: 3)),
            child: Image(height: 200, fit: BoxFit.contain, image: _imageProvider),
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
      other is FijkSliderColors && runtimeType == other.runtimeType && hashCode == other.hashCode;

  @override
  int get hashCode => hashValues(playedColor, bufferedColor, cursorColor, baselineColor);
}

class _SliderPainter extends CustomPainter {
  final double v;
  final double cv;

  final bool dragging;
  final Paint pt = Paint();

  final FijkSliderColors colors;

  _SliderPainter(this.v, this.cv, this.dragging, {this.colors = const FijkSliderColors()})
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
    canvas.drawCircle(Offset(value, size.height / 2), radius, pt);
    pt.color = colors.cursorColor;
    radius = min(size.height / 2, dragging ? 6 : 3);
    canvas.drawCircle(Offset(value, size.height / 2), radius, pt);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is _SliderPainter && hashCode == other.hashCode;

  @override
  int get hashCode => hashValues(v, cv, dragging, colors);

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) {
    return hashCode != oldDelegate.hashCode;
  }
}
