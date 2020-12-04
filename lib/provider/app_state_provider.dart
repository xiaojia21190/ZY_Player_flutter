import 'package:flutter/cupertino.dart';
import 'package:flutter_dlna/dlna/dlna.dart';
import 'package:flutter_dlna/flutter_dlna.dart';

class AppStateProvider extends ChangeNotifier {
  bool _loadingState = false;
  bool get loadingState => _loadingState;

  String _loadingText = "";
  String get loadingText => _loadingText;

  void setloadingState(bool state, [String text]) {
    _loadingState = state;
    _loadingText = text;
    notifyListeners();
  }

  List<DLNADevice> _dlnaDevices = [];
  List<DLNADevice> get dlnaDevices => _dlnaDevices;

  setDlnaDevices(List<DLNADevice> list) {
    _dlnaDevices = list;
    notifyListeners();
  }

  FlutterDlna _dlnaManager = FlutterDlna();
  FlutterDlna get dlnaManager => _dlnaManager;

  Future initDlnaManager() async {
    await dlnaManager.init();
    dlnaManager.setSearchCallback((devices) {
      // 成功之后回调
      if (devices != null && devices.length > 0) {
        _dlnaDevices = devices;
      } else {
        _dlnaDevices = [];
      }
    });

    dlnaManager.search();
  }
}
