import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Constant {
  /// debug开关，上线需要关闭
  /// App运行在Release环境时，inProduction为true；当App运行在Debug和Profile环境时，inProduction为false
  static const bool inProduction = kReleaseMode;

  static bool isDriverTest = false;
  static bool isUnitTest = false;

  static const String data = 'data';
  static const String message = 'message';
  static const String code = 'code';

  static const String keyGuide = 'keyGuide';
  static const String email = 'email';
  static const String password = 'password';
  static const String accessToken = 'accessToken';
  static const String orderid = 'orderid';
  static const String jihuoDate = 'jihuoDate';
  static const String refreshToken = 'refreshToken';

  static const String theme = 'AppTheme';
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

NavigatorState get navigatorState => Constant.navigatorKey.currentState;
BuildContext get currentContext => navigatorState.context;
ThemeData get currentTheme => Theme.of(currentContext);
