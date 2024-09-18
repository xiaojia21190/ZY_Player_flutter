import 'package:ZY_Player_flutter/model/manhua_catlog_detail.dart';
import 'package:ZY_Player_flutter/model/manhua_detail.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';

class ManhuaProvider extends ChangeNotifier {
  List<String> _words = [];
  List<String> get words => _words;

  List<Types> _list = [];
  List<Types> get list => _list;

  ManhuaCatlogDetail _catLog = ManhuaCatlogDetail("", "", "", "", "", "", "", [], "");
  ManhuaCatlogDetail get catLog => _catLog;

  List<String> _images = [];
  List<String> get images => _images;

  StateType _state = StateType.empty;
  StateType get state => _state;

  String _actionName = "";
  String get actionName => _actionName;

  void setActionName(String actionName) {
    _actionName = actionName;
    notifyListeners();
  }

  setWords() {
    _words = SpUtil.getStringList("ManHuaWords", defValue: [])!;
  }

  setList(List<Types> list) {
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
    if (whereWord.isEmpty) {
      _words.add(word);
      SpUtil.putStringList("ManHuaWords", _words);
      notifyListeners();
    }
  }

  setManhuaDetail(ManhuaCatlogDetail manhuaCatlogDetail) {
    _catLog = manhuaCatlogDetail;
    notifyListeners();
  }

  setStateType(StateType stateType) {
    _state = stateType;
    notifyListeners();
  }

  setImages(List<String> images) {
    _images = images;
    notifyListeners();
  }
}
