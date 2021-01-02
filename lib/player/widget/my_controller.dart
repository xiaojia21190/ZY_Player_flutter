import 'dart:async';

import 'package:ZY_Player_flutter/event/event_bus.dart';
import 'package:ZY_Player_flutter/event/event_model.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/res/styles.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/utils.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/xiaoshuo/widget/batter_view.dart';
import 'package:chewie/chewie.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
// ignore: implementation_imports
import 'package:chewie/src/chewie_player.dart';
// ignore: implementation_imports
import 'package:chewie/src/chewie_progress_colors.dart';
// ignore: implementation_imports
import 'package:chewie/src/cupertino_progress_bar.dart';
// ignore: implementation_imports
import 'package:chewie/src/utils.dart';

import 'package:screen/screen.dart' as lightness;

class MyControls extends StatefulWidget {
  String title;
  int jujiLen;

  MyControls(this.title, this.jujiLen);

  @override
  State<StatefulWidget> createState() {
    return _MyMaterialControlsState();
  }
}

class _MyMaterialControlsState extends State<MyControls> {
  VideoPlayerValue _latestValue;
  double _latestVolume;
  bool _hideStuff = true;
  Timer _hideTimer;
  Timer _initTimer;
  Timer _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;
  static const lightColor = Color.fromRGBO(255, 255, 255, 0.85);
  static const darkColor = Colors.transparent;
  final barHeight = 48.0;
  final marginSize = 5.0;
  Offset _initialSwipeOffset;
  Offset _finalSwipeOffset;

  bool _verSwiper = false;
  String _verText = "快进到:";

  Offset _initialVerLightOffset;
  Offset _finalVerLightOffset;
  bool _verLight = false;
  String _verLightText = "亮度:";
  double light = 0;

  VideoPlayerController controller;
  ChewieController chewieController;

  AppStateProvider appStateProvider;

  @override
  void initState() {
    appStateProvider = Store.value<AppStateProvider>(context);
    getLight();
    super.initState();
  }

  Future getLight() async {
    light = await lightness.Screen.brightness;
  }

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder(
              context,
              chewieController.videoPlayerController.value.errorDescription,
            )
          : Center(
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        onDoubleTap: () {
          controller.pause();
        },
        onTap: () => _cancelAndRestartTimer(),
        child: AbsorbPointer(
            absorbing: _hideStuff,
            child: Stack(
              children: [
                Column(
                  children: <Widget>[
                    _buildHeader(context, this.widget.title),
                    _latestValue != null && !_latestValue.isPlaying && _latestValue.duration == null || _latestValue.isBuffering
                        ? const Expanded(
                            child: const Center(
                              child: const CircularProgressIndicator(),
                            ),
                          )
                        : _buildHitArea(),
                    _buildBottomBar(context),
                  ],
                ),
                Align(
                  child: (_hideStuff && !chewieController.isFullScreen)
                      ? Container(
                          color: darkColor,
                          height: 0,
                          child: Row(
                            children: [_buildProgressBar()],
                          ),
                        )
                      : Container(),
                  alignment: Alignment.bottomCenter,
                ),
                // 滑动进度
                Align(
                  child: _verSwiper && controller.value.isPlaying
                      ? Container(
                          height: 30,
                          width: 120,
                          decoration: BoxDecoration(color: Colours.dark_bg_color, borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              _verText,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : Container(),
                  alignment: Alignment.center,
                ),
                Align(
                  child: _verLight
                      ? Container(
                          height: 30,
                          width: 80,
                          decoration: BoxDecoration(color: Colours.dark_bg_color, borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              _verLightText,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : Container(),
                  alignment: Alignment.center,
                ),
                // 播放完成
                Align(
                  child: _latestValue.duration.inSeconds == _latestValue.position.inSeconds && widget.jujiLen > 1
                      ? _buildPlayNext(controller)
                      : _latestValue.duration.inSeconds == _latestValue.position.inSeconds
                          ? Container(
                              child: Center(
                                child: Text(
                                  "${widget.title} 播放完成",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : Container(),
                  alignment: Alignment.center,
                ),
                Align(
                  child: chewieController.isFullScreen
                      ? Container(
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
                        )
                      : Container(),
                  alignment: Alignment.topLeft,
                ),
              ],
            )),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
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
                                      child: Text(devices[index]["name"]),
                                      onPressed: () {
                                        _playPause();
                                        ApplicationEvent.event.fire(DeviceEvent(devices[index]["id"], devices[index]["name"], widget.jujiLen));
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
                title: Text(words, textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
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

  AnimatedOpacity _buildHeader(BuildContext context, String title) {
    return new AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: new Duration(milliseconds: 300),
      child: new Container(
        color: darkColor,
        height: barHeight,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FlatButton.icon(
                onPressed: () async {
                  // 取消全屏
                  chewieController.exitFullScreen();
                  // 点击显示投屏数据
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
        ),
      ),
    );
  }

  AnimatedOpacity _buildBottomBar(
    BuildContext context,
  ) {
    final iconColor = Theme.of(context).textTheme.button.color;
    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        height: barHeight,
        color: darkColor,
        child: Row(
          children: <Widget>[
            _buildPlayPause(controller),
            // _buildPlayNext(controller),
            chewieController.isLive
                ? Expanded(
                    child: const Text(
                    'LIVE',
                    style: TextStyle(color: lightColor),
                  ))
                : _buildPosition(iconColor),
            chewieController.isLive ? const SizedBox() : _buildProgressBar(),
            chewieController.allowMuting ? _buildMuteButton(controller) : Container(),
            chewieController.allowFullScreen ? _buildExpandButton() : Container(),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: Container(
          height: barHeight,
          margin: EdgeInsets.only(right: 12.0),
          padding: EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Center(
            child: ImageIcon(
              AssetImage(chewieController.isFullScreen ? "assets/images/fullscreen_exit.png" : "assets/images/fullscreen_enter.png"),
              size: 32.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildHitArea() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_latestValue != null && _latestValue.isPlaying) {
            if (_displayTapped) {
              setState(() {
                _hideStuff = true;
              });
            } else
              _cancelAndRestartTimer();
          } else {
            _playPause();

            setState(() {
              _hideStuff = true;
            });
          }
        },
        child: _latestValue.duration.inSeconds != _latestValue.position.inSeconds
            ? Container(
                color: Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _latestValue != null && !_latestValue.isPlaying && !_dragging ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: GestureDetector(
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: ImageIcon(
                            AssetImage("assets/images/video_play.png"),
                            size: 64.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ),
    );
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            height: barHeight,
            padding: EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: ImageIcon(
              AssetImage((_latestValue != null && _latestValue.volume > 0) ? "assets/images/voice_ok.png" : "assets/images/voice_stop.png"),
              size: 32.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(VideoPlayerController controller) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: EdgeInsets.only(left: 8.0, right: 4.0),
        padding: EdgeInsets.only(
          left: 2.0,
          right: 12.0,
        ),
        child: ImageIcon(
          AssetImage(controller.value.isPlaying ? "assets/images/video_stop.png" : "assets/images/video_play.png"),
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  GestureDetector _buildPlayNext(VideoPlayerController controller) {
    return GestureDetector(
      onTap: _playNext,
      child: Container(
        height: barHeight + 15,
        width: 130,
        decoration: BoxDecoration(color: Colours.dark_bg_color, borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.only(left: 2.0, right: 8.0),
        padding: EdgeInsets.only(
          left: 2.0,
          right: 2.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageIcon(
              AssetImage("assets/images/video_next.png"),
              color: Colors.white,
              size: 32,
            ),
            Gaps.vGap5,
            Text(
              "点击切换下一集",
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position = _latestValue != null && _latestValue.position != null ? _latestValue.position : Duration.zero;
    final duration = _latestValue != null && _latestValue.duration != null ? _latestValue.duration : Duration.zero;

    return Padding(
      padding: EdgeInsets.only(right: 20.0),
      child: Text(
        '${formatDuration(position)} / ${formatDuration(duration)}',
        style: TextStyle(fontSize: 11.0, color: lightColor),
      ),
    );
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _initialSwipeOffset = details.globalPosition;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _finalSwipeOffset = details.globalPosition;
    if (_initialSwipeOffset != null) {
      final offsetDifference = _initialSwipeOffset.dx - _finalSwipeOffset.dx;
      String fintext = "";
      _verSwiper = true;
      // 最多滑动20分钟
      var offsetAbs = offsetDifference.abs() / Screen.widthOt;

      fintext = offsetDifference < 0 ? "快进到：" : "后退到：";
      if (offsetDifference < 0) {
        var endTime = offsetAbs * (controller.value.duration.inSeconds - controller.value.position.inSeconds);
        _verText = "$fintext${Duration(seconds: controller.value.position.inSeconds + endTime.toInt()).toString().split(".")[0]}";
      } else {
        var endTime = offsetAbs * (controller.value.position.inSeconds);
        _verText = "$fintext${Duration(seconds: controller.value.position.inSeconds - endTime.toInt()).toString().split(".")[0]}";
      }
    }
    setState(() {});
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_initialSwipeOffset != null) {
      final offsetDifference = _initialSwipeOffset.dx - _finalSwipeOffset.dx;
      var offsetAbs = offsetDifference.abs() / Screen.widthOt;
      if (offsetDifference > 0) {
        var endTime = offsetAbs * (controller.value.position.inSeconds);
        if (controller.value.isPlaying) {
          Log.d(Duration(seconds: controller.value.position.inSeconds - endTime.toInt()).toString());
          controller.position.then((value) => {controller.seekTo(value - Duration(seconds: endTime.toInt()))});
        }
      } else {
        var endTime = offsetAbs * (controller.value.duration.inSeconds - controller.value.position.inSeconds);
        if (Duration(seconds: controller.value.position.inSeconds + endTime.toInt()) <= controller.value.duration) {
          Log.d(Duration(seconds: controller.value.position.inSeconds + endTime.toInt()).toString());
          if (controller.value.isPlaying) {
            controller.position.then((value) => {controller.seekTo(value + Duration(seconds: endTime.toInt()))});
          }
        }
      }
    }
    _verSwiper = false;
    setState(() {});
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _verLight = true;
    _initialVerLightOffset = details.globalPosition;
    setState(() {});
  }

  Future _onVerticalDragUpdate(DragUpdateDetails details) async {
    _finalVerLightOffset = details.globalPosition;
    final offsetDifference = _initialVerLightOffset.dy - _finalVerLightOffset.dy;
    var offsetAbs = offsetDifference.abs() / ScreenUtil.getInstance().getWidth(300);
    // Log.d(offsetAbs.toString());
    var entLight;
    if (offsetDifference > 0) {
      entLight = light + offsetAbs;
      if (entLight >= 1) {
        entLight = 1.0;
      }
      lightness.Screen.setBrightness(entLight);
    } else {
      entLight = light - offsetAbs;
      if (entLight <= 0) {
        entLight = 0.0;
      }
      lightness.Screen.setBrightness(entLight);
    }
    _verLightText = "亮度：${(entLight * 100).toInt()}%";
    setState(() {});
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_initialVerLightOffset != null) {
      getLight();
      _verLight = false;
      setState(() {});
    }
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
      _displayTapped = true;
    });
  }

  Future<Null> _initialize() async {
    controller.addListener(_updateState);
    _updateState();

    if ((controller.value != null && controller.value.isPlaying) || chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      chewieController.toggleFullScreen();
      _showAfterExpandCollapseTimer = Timer(Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playNext() {
    // 点击切换下一集
    ApplicationEvent.event.fire(ChangeJujiEvent());
  }

  void _playPause() {
    bool isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration(seconds: 0));
          }
          controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() {
    setState(() {
      _latestValue = controller.value;
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: _hideStuff ? 0 : 10.0),
        child: CupertinoVideoProgressBar(
          controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });

            _hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideTimer();
          },
          colors: ChewieProgressColors(
            playedColor: Colors.red,
            handleColor: Colors.blue,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.lightGreenAccent,
          ),
        ),
      ),
    );
  }
}
