import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/setting/provider/setting_provider.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PlayerVideoPage extends StatefulWidget {
  const PlayerVideoPage({
    Key? key,
    required this.title,
    required this.url,
    required this.cover,
    required this.startAt,
    required this.videoId,
  }) : super(key: key);

  final String title;
  final String url;
  final String cover;
  final String startAt;
  final String videoId;

  @override
  _PlayerVideoPageState createState() => _PlayerVideoPageState();
}

class _PlayerVideoPageState extends State<PlayerVideoPage> {
  AppStateProvider? appStateProvider;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  SettingProvider settingProvider = SettingProvider();

  @override
  void initState() {
    appStateProvider = Store.value<AppStateProvider>(context);
    playerVideo();
    super.initState();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _videoPlayerController?.removeListener(_videoListener);

    super.dispose();
  }

  playerVideo() async {
    var startAt = Duration(seconds: int.parse(widget.startAt));
    _videoPlayerController = VideoPlayerController.network(widget.url);

    await _videoPlayerController!.initialize();
    _videoPlayerController!.addListener(_videoListener);

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      allowedScreenSleep: false,
      looping: false,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      startAt: startAt,
    );
  }

  void _videoListener() async {
    if (_videoPlayerController!.value.isInitialized) {
      if (!settingProvider.value) {
        settingProvider.value = true;
      }

      // 存储播放记录
      PlayerModel playerModel = PlayerModel(
          videoId: widget.videoId,
          name: widget.title,
          url: widget.url,
          cover: widget.cover,
          startAt: "${_videoPlayerController!.value.position.inSeconds}");
      appStateProvider!.savePlayerRecord(playerModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingProvider>(
        create: (_) => settingProvider,
        child: Scaffold(
            backgroundColor: Colors.black,
            appBar: MyAppBar(
              centerTitle: widget.title,
            ),
            body: Stack(children: [
              Center(
                child: Container(
                    color: Colors.black,
                    width: Screen.widthOt,
                    height: 300,
                    child: Selector<SettingProvider, bool>(
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
                        selector: (_, store) => store.value)),
              )
            ])));
  }
}
