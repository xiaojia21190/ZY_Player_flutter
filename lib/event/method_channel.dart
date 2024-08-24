import 'package:flutter/services.dart';

class FlutterPlugin {
  static const MethodChannel _channel =
      MethodChannel('flutter_method_channel');

  static toast(String msg) {
    _channel.invokeMethod('toast', msg);
  }
}
