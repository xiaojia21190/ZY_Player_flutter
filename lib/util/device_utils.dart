import 'package:universal_platform/universal_platform.dart';
// import 'package:flutter/foundation.dart';

/// https://medium.com/gskinner-team/flutter-simplify-platform-screen-size-detection-4cb6fc4f7ed1
class Device {
  // static bool get isDesktop => !isWeb && (isWindows || isLinux || isMacOS);
  //
  // static bool get isMobile => isAndroid || isIOS;
  //
  // static bool get isWeb => kIsWeb;
  //
  // static bool get isWindows => Platform.isWindows;
  //
  // static bool get isLinux => Platform.isLinux;
  //
  // static bool get isMacOS => Platform.isMacOS;
  //
  // static bool get isAndroid => Platform.isAndroid;
  //
  // static bool get isFuchsia => Platform.isFuchsia;
  //
  // static bool get isIOS => Platform.isIOS;

  static bool get isDesktop => !isWeb && (isWindows || isLinux || isMacOS);

  static bool get isMobile => isAndroid || isIOS;

  static bool get isWeb => UniversalPlatform.isWeb;

  static bool get isWindows => UniversalPlatform.isWindows;

  static bool get isLinux => UniversalPlatform.isLinux;

  static bool get isMacOS => UniversalPlatform.isMacOS;

  static bool get isAndroid => UniversalPlatform.isAndroid;

  static bool get isFuchsia => UniversalPlatform.isFuchsia;

  static bool get isIOS => UniversalPlatform.isIOS;

}
