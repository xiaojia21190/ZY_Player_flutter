import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';

class DetailProvider extends ChangeNotifier {
  final List<DetailReource> _detailReource = [];
  List<DetailReource> get detailReource => _detailReource;

  final List<Playlist> _playerList = [];
  List<Playlist> get playerList => _playerList;

  List<String> _kanguojuji = []; // 已经看过的剧集列表
  List<String> get kanguojuji => _kanguojuji;

  List<String> _saveRecord = [];
  List<String> get saveRecord => _saveRecord;

  bool _playState = false;
  bool get playState => _playState;

  StateType _stateType = StateType.empty;
  StateType get stateType => _stateType;

  String _actionName = "";
  String get actionName => _actionName;

  bool _isInitPlayer = false;

  bool get isInitPlayer => _isInitPlayer;

  int _chooseYuanIndex = 0;
  int get chooseYuanIndex => _chooseYuanIndex;

  void setChooseYuanIndex(int index) {
    _chooseYuanIndex = index;
    notifyListeners();
  }

  void setInitPlayer(bool state) {
    _isInitPlayer = state;
    notifyListeners();
  }

  void setActionName(String actionName) {
    _actionName = actionName;
    notifyListeners();
  }

  void setStateType(StateType stateType) {
    _stateType = stateType;
    notifyListeners();
  }

  setPlayState(bool state) {
    _playState = state;
    notifyListeners();
  }

  setJuji() {
    _kanguojuji = SpUtil.getStringList("KGjuji", defValue: [])!;
    _saveRecord = SpUtil.getStringList("saverecord", defValue: [])!;
  }

  saveJuji(String juji) {
    if (!_kanguojuji.contains(juji)) {
      _kanguojuji.add(juji);
      SpUtil.putStringList("KGjuji", _kanguojuji);
      notifyListeners();
    }
  }

  saveRecordNof(String record) {
    var index = -1;
    for (var i = 0; i < _saveRecord.length; i++) {
      var splitEle = _saveRecord[i].split("_");
      var splitEle1 = record.split("_");
      if (splitEle[0] == splitEle1[0] && splitEle[1] == splitEle1[1] && splitEle[2] == splitEle1[2]) {
        index = i;
        break;
      }
    }
    if (index < 0) {
      _saveRecord.add(record);
      SpUtil.putStringList("saverecord", _saveRecord);
    } else {
      _saveRecord[index] = record;
      SpUtil.putStringList("saverecord", _saveRecord);
    }
  }

  String getRecord(String playerList) {
    var record = "0";
    for (var i = 0; i < _saveRecord.length; i++) {
      var splitEle = _saveRecord[i].split("_");
      var splitEle1 = playerList.split("_");
      if (splitEle[0] == splitEle1[0] && splitEle[1] == splitEle1[1] && splitEle[2] == splitEle1[2]) {
        record = splitEle[3];
        break;
      }
    }
    return record;
  }

  addDetailResource(DetailReource detailReourceData) {
    _detailReource.add(detailReourceData);
    notifyListeners();
  }
}
