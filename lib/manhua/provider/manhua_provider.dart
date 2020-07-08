import 'package:ZY_Player_flutter/model/manhua_catlog_detail.dart';
import 'package:ZY_Player_flutter/model/manhua_detail.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class ManhuaProvider extends ChangeNotifier {
  List<String> _words = [];
  List<String> get words => _words;

  List<ManhuaDetail> _list = [];
  List<ManhuaDetail> get list => _list;

  ManhuaCatlogDetail _catLog;
  ManhuaCatlogDetail get catLog => _catLog;

  StateType _state = StateType.empty;
  StateType get state => _state;

  setWords() {
    _words = SpUtil.getStringList("ManHuaWords", defValue: []);
    notifyListeners();
  }

  setList(List<ManhuaDetail> list) {
    _list = list;
    notifyListeners();
  }

  clearWords() {
    _words.clear();
    SpUtil.putStringList("ManHuaWords", _words);
    notifyListeners();
  }

  addWors(String word) {
    if (word == "") {
      return;
    }
    var whereWord = _words.where((element) => element == word);
    if (whereWord.length == 0) {
      _words.add(word);
      SpUtil.putStringList("ManHuaWords", _words);
      notifyListeners();
    }
  }

  setManhuaDetail(ManhuaCatlogDetail manhuaCatlogDetail) {
    _catLog = manhuaCatlogDetail;
    notifyListeners();
  }

  setstate(StateType stateType) {
    _state = stateType;
    notifyListeners();
  }
}
