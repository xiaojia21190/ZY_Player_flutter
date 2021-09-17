import 'dart:async';

import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/routes/routers.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _initSplash();
    startTime();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initSplash() {}

  // 开屏广告倒计时
  startTime() {
    _timer = Timer(Duration(milliseconds: 2200), () {
      _timer.cancel();
      NavigatorUtils.push(context, '${Routes.home}', replace: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: ThemeUtils.getBackgroundColor(context),
        child: const LoadAssetImage(
          'ic_background',
          fit: BoxFit.cover,
        ));
  }
}
