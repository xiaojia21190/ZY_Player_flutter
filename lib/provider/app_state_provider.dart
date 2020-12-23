import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dlna/dlna/dlna.dart';
import 'package:flutter_dlna/flutter_dlna.dart';

class AppStateProvider extends ChangeNotifier {
  bool _loadingState = false;
  bool get loadingState => _loadingState;

  String _loadingText = "";
  String get loadingText => _loadingText;

  // 小说字体
  double _xsFontSize = 18;
  double get xsFontSize => _xsFontSize;
  // 小说字体大小
  Color _xsColor = Colours.qingcaolv;
  Color get xsColor => _xsColor;

  setConfig() {
    _xsFontSize = SpUtil.getDouble("xsfontsize", defValue: 18);
    _xsColor = Color(SpUtil.getInt("xscolor", defValue: 0xffE3EDCD));
  }

  setFontSize(double size) {
    _xsFontSize = size;
    SpUtil.putDouble("xsfontsize", size);
    notifyListeners();
  }

  setFontColor(Color color) {
    _xsColor = color;
    SpUtil.putInt("xscolor", color.value);
    notifyListeners();
  }

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

  String _searchText = "设备搜索超时";
  String get searchText => _searchText;

  Future initDlnaManager() async {
    await dlnaManager.init();
    dlnaManager.setSearchCallback((devices) {
      // 成功之后回调
      if (devices != null && devices.length > 0) {
        _searchText = "搜索成功，点击投屏按钮继续投屏";
        setDlnaDevices(devices);
      } else {
        _searchText = "设备搜索超时";
        setDlnaDevices([]);
      }
      notifyListeners();
    });
    await searchDlna();
  }

  Future searchDlna() async {
    _searchText = "正在搜索设备...";
    await dlnaManager.search();
    notifyListeners();
  }

  setSearchText(String text) {
    _searchText = text;
    notifyListeners();
  }
}
