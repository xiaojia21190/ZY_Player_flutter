import 'package:flutter/services.dart';

class FlutterPlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_method_channel');

  static toast(String msg) {
    _channel.invokeMethod('toast', msg);
  }
}
