import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class DetailProvider extends ChangeNotifier {
  DetailReource _detailReource;
  DetailReource get detailReource => _detailReource;

  String _playerUrl = "about:blank";
  String get playerUrl => _playerUrl;

  List<String> _kanguojuji = [];
  List<String> get kanguojuji => _kanguojuji;

  bool _playState = false;
  bool get playState => _playState;

  StateType _stateType = StateType.empty;
  StateType get stateType => _stateType;

  String _actionName = "";
  String get actionName => _actionName;

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
    _kanguojuji = SpUtil.getStringList("KGjuji", defValue: []);
  }

  saveJuji(String juji) {
    if (!_kanguojuji.contains(juji)) {
      _kanguojuji.add(juji);
      SpUtil.putStringList("KGjuji", _kanguojuji);
      notifyListeners();
    }
  }

  setDetailResource(DetailReource detailReourceData) {
    _detailReource = detailReourceData;
    _playerUrl = detailReourceData.videoList[0];
    notifyListeners();
  }
}
