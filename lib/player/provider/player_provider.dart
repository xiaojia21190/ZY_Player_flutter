import 'package:ZY_Player_flutter/model/resource_data.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  List<String> _words = [];
  List<String> get words => _words;

  List<ResourceData> _list = [];
  List<ResourceData> get list => _list;

  StateType _stateType = StateType.empty;
  StateType get stateType => _stateType;

  setWords() {
    _words = SpUtil.getStringList("playerWords", defValue: []);
  }

  clearWords() {
    _words.clear();
    SpUtil.putStringList("playerWords", _words);
    notifyListeners();
  }

  addWors(String word) {
    if (word == "") {
      return;
    }
    var whereWord = _words.where((element) => element == word);
    if (whereWord.length == 0) {
      _words.add(word);
      SpUtil.putStringList("playerWords", _words);
      notifyListeners();
    }
  }

  setResource(List<ResourceData> list) {
    _list = list;
    notifyListeners();
  }

  void setStateType(StateType stateType) {
    _stateType = stateType;
    notifyListeners();
  }
}
