import 'package:ZY_Player_flutter/model/hot_search.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class HotSearchProvider extends ChangeNotifier {
  List<String> _words = [];
  List<String> get words => _words;

  List<HotSearch> _list = [];
  List<HotSearch> get list => _list;

  StateType _stateType = StateType.empty;
  StateType get stateType => _stateType;

  setWords() {
    _words = SpUtil.getStringList("hotSearchWords", defValue: []);
  }

  clearWords() {
    _words.clear();
    SpUtil.putStringList("hotSearchWords", _words);
    notifyListeners();
  }

  addWors(String word) {
    if (word == "") {
      return;
    }
    var whereWord = _words.where((element) => element == word);
    if (whereWord.length == 0) {
      _words.add(word);
      SpUtil.putStringList("hotSearchWords", _words);
      notifyListeners();
    }
  }

  setResource(List<HotSearch> list) {
    _list = list;
    notifyListeners();
  }

  void setStateType(StateType stateType) {
    _stateType = stateType;
    notifyListeners();
  }
}
