import 'package:ZY_Player_flutter/model/zhibo_resource.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';

class ZhiboProvider extends ChangeNotifier {
  List<ZhiboResource> _list = [];
  List<ZhiboResource> get list => _list;

  StateType _stateType = StateType.empty;
  StateType get stateType => _stateType;

  setResource(List<ZhiboResource> list) {
    _list = list;
    notifyListeners();
  }

  void setStateType(StateType stateType) {
    _stateType = stateType;
    notifyListeners();
  }
}
