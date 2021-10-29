import 'package:ZY_Player_flutter/common/common.dart';
import 'package:ZY_Player_flutter/event/event_bus.dart';
import 'package:ZY_Player_flutter/event/event_model.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/util/Loading.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_dlna/flutter_dlna.dart';
import 'package:intl/intl.dart';

class PlayerModel {
  final String name;
  final String videoId;
  final String cover;
  final String startAt;
  final String url;
  PlayerModel({required this.name, required this.cover, required this.url, required this.startAt, required this.videoId});

  PlayerModel.fromJson(Map<dynamic, dynamic> json)
      : name = json['name'],
        cover = json['cover'],
        startAt = json['startAt'],
        videoId = json['videoId'],
        url = json['url'];

  Map<dynamic, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'startAt': startAt,
        'cover': cover,
        'url': url,
        'videoId': videoId,
      };
}

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

  List<PlayerModel> _playerList = [];
  List<PlayerModel> get playerList => _playerList;

  double _opacityLevel = 0.0;
  double get opacityLevel => _opacityLevel;

  int playandzhibo = 0;

  setOpcity(double opc) {
    _opacityLevel = opc;
    notifyListeners();
  }

  getPlayerRecord() async {
    _playerList = SpUtil.getObjList<PlayerModel>("player_record", (data) => PlayerModel.fromJson(data), defValue: [])!;
    notifyListeners();
  }

  savePlayerRecord(PlayerModel playerModel) async {
    int index = _playerList.indexWhere((element) => element.url == playerModel.url);
    if (index >= 0) {
      _playerList[index] = playerModel;
    } else {
      _playerList.add(playerModel);
    }
    SpUtil.putObjectList("player_record", _playerList);

    List<String>? list = SpUtil.getStringList("saverecord");

    var indexa = list!.indexWhere((element) =>
        element.split("_")[0] == playerModel.videoId.split("_")[0] &&
        element.split("_")[1] == playerModel.videoId.split("_")[1] &&
        element.split("_")[2] == playerModel.videoId.split("_")[2]);
    var replaceText =
        "${playerModel.videoId.split("_")[0]}_${playerModel.videoId.split("_")[1]}_${playerModel.videoId.split("_")[2]}_${playerModel.startAt}";
    list[indexa] = replaceText;
    SpUtil.putStringList("saverecord", list);

    notifyListeners();
  }

  clearPlayerRecord() {
    SpUtil.putObjectList("player_record", []);
    _playerList = [];
    notifyListeners();
  }

  setConfig() {
    _xsFontSize = SpUtil.getDouble("xsfontsize", defValue: 18)!;
    _xsColor = Color(SpUtil.getInt("xscolor", defValue: 0xffCCF1CF)!);
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

  void setloadingState(bool state, [String text = "正在加载中..."]) {
    _loadingState = state;
    _loadingText = text;
    if (_loadingState) {
      Loading.show(_loadingText);
    } else {
      Loading.hide();
    }
    notifyListeners();
  }

  List _dlnaDevices = [];
  List get dlnaDevices => _dlnaDevices;

  setDlnaDevices(List list) {
    _dlnaDevices = list;
    if (list.length > 0) {
      // 通知可以打开投屏列表
      ApplicationEvent.event.fire(DeviceEvent(playandzhibo));
    }
    notifyListeners();
  }

  FlutterDlna _dlnaManager = FlutterDlna();
  FlutterDlna get dlnaManager => _dlnaManager;

  String _searchText = "点击开始搜索设备";
  String get searchText => _searchText;

  Future initDlnaManager() async {
    await dlnaManager.init();
    dlnaManager.setSearchCallback((devices) {
      // 成功之后回调
      if (devices != null && devices.length > 0) {
        _searchText = "搜索成功，点击投屏按钮继续投屏";
        Navigator.pop(Constant.navigatorKey.currentContext!);
        setDlnaDevices(devices);
      } else {
        _searchText = "设备搜索超时";
        setDlnaDevices([]);
      }
    });
  }

  Future searchDlna(int i) async {
    playandzhibo = i;
    _searchText = "正在搜索设备...";
    await dlnaManager.search();

    notifyListeners();
  }

  setSearchText(String text) {
    _searchText = text;
    notifyListeners();
  }

  String _nowTime = DateFormat('HH:mm').format(DateTime.now());
  String get nowTime => _nowTime;

  bool _verSwiper = false;
  bool get verSwiper => _verSwiper;
  String _verText = "快进到:";
  String get verText => _verText;

  bool _verLight = false;
  bool get verLight => _verLight;
  String _verLightText = "亮度:";
  String get verLightText => _verLightText;

  setVerSwiper(bool flag, String text) {
    _verSwiper = flag;
    _verText = text;
    notifyListeners();
  }

  setVerLight(bool flag, String text) {
    _verLight = flag;
    _verLightText = text;
    notifyListeners();
  }

  setTime() {
    _nowTime = DateFormat('HH:mm').format(DateTime.now());
    notifyListeners();
  }
}
