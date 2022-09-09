import 'package:ZY_Player_flutter/model/audio_detail.dart';
import 'package:ZY_Player_flutter/model/category_tab.dart';
import 'package:ZY_Player_flutter/model/category_tab_detail.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';

class TingShuProvider extends ChangeNotifier {
  List<CategoryTabDetail> _list = [];
  List<CategoryTabDetail> get list => _list;

  StateType _state = StateType.empty;
  StateType get state => _state;

  List<AudioDetail> _tingShuDetail = [];
  List<AudioDetail> get tingshudetail => _tingShuDetail;

  String _actionName = "";
  String get actionName => _actionName;

  List<String> _kanguozhangjie = [];
  List<String> get kanguozhangjie => _kanguozhangjie;

  bool _isInitPlayer = false;
  bool get isInitPlayer => _isInitPlayer;

  String _lastTingshu = "";
  String get lastTingshu => _lastTingshu;

  List<String> _saveRecord = [];
  List<String> get saveRecord => _saveRecord;

  double _jindu = 0;
  double get jindu => _jindu;

  List<CategoryTab> _tabs = [];
  List<CategoryTab> get tabs => _tabs;

  setTab(List<CategoryTab> tabs) {
    _tabs = tabs;
    notifyListeners();
  }

  setJindu(double jindu) {
    _jindu = jindu;
    notifyListeners();
  }

  saveRecordNof(String record) {
    var index = -1;
    for (var i = 0; i < _saveRecord.length; i++) {
      var splitEle = _saveRecord[i].split("_");
      var splitEle1 = record.split("_");
      if (splitEle[0] == splitEle1[0] && splitEle[1] == splitEle1[1]) {
        index = i;
        break;
      }
    }
    if (index < 0) {
      _saveRecord.add(record);
      SpUtil.putStringList("saverecord_ts", _saveRecord);
    } else {
      _saveRecord[index] = record;
      SpUtil.putStringList("saverecord_ts", _saveRecord);
    }
  }

  String getRecord(String playerList) {
    var record = '0';
    for (var i = 0; i < _saveRecord.length; i++) {
      var splitEle = _saveRecord[i].split("_");
      var splitEle1 = playerList.split("_");
      if (splitEle[0] == splitEle1[0] && splitEle[1] == splitEle1[1]) {
        record = splitEle[2];
        break;
      }
    }
    return record;
  }

  void setInitPlayer(bool state, {bool not = true}) {
    _isInitPlayer = state;
    if (not) notifyListeners();
  }

  setTingshu(String url) {
    _kanguozhangjie = SpUtil.getStringList("KGTingshu", defValue: [])!;
    _saveRecord = SpUtil.getStringList("saverecord_ts", defValue: [])!;
    var index = _kanguozhangjie.lastIndexWhere((element) => element.split("_")[0] == url);
    if (index >= 0) {
      _lastTingshu = _kanguozhangjie[index];
    }

    notifyListeners();
  }

  changeLastTs() {
    _lastTingshu = "";
  }

  saveTingshu(String zhangjie, String url) {
    if (_kanguozhangjie.contains(zhangjie)) return;
    _kanguozhangjie.add(zhangjie);
    SpUtil.putStringList("KGTingshu", _kanguozhangjie);

    var index = _kanguozhangjie.lastIndexWhere((element) => element.split("_")[0] == url);
    if (index >= 0) {
      _lastTingshu = _kanguozhangjie[index];
    }

    notifyListeners();
  }

  setActionName(String actionName) {
    _actionName = actionName;
    notifyListeners();
  }

  setStateType(StateType stateType) {
    _state = stateType;
    notifyListeners();
  }

  setTingshuDetail(List<AudioDetail> tingShuDetail) {
    _tingShuDetail = tingShuDetail;
    notifyListeners();
  }
}
