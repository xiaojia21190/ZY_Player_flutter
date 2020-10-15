import 'package:ZY_Player_flutter/model/resource_data.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_catlog.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_resource.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class XiaoShuoProvider extends ChangeNotifier {
  List<String> _words = [];
  List<String> get words => _words;

  List<XiaoshuoResource> _list = [];
  List<XiaoshuoResource> get list => _list;

  List<XiaoshuoCatlog> _allZj = [];
  List<XiaoshuoCatlog> get allZj => _allZj;

  StateType _stateType = StateType.empty;
  StateType get stateType => _stateType;

  XiaoshuoCatlog _currentxszj;
  XiaoshuoCatlog get currentxszj => _currentxszj;

  XiaoshuoCatlog _prevxszj;
  XiaoshuoCatlog get prevxszj => _prevxszj;

  XiaoshuoCatlog _nextxszj;
  XiaoshuoCatlog get nextxszj => _nextxszj;

  setWords() {
    _words = SpUtil.getStringList("xiaoshuoWords", defValue: []);
  }

  clearWords() {
    _words.clear();
    SpUtil.putStringList("xiaoshuoWords", _words);
    notifyListeners();
  }

  addWors(String word) {
    if (word == "") {
      return;
    }
    var whereWord = _words.where((element) => element == word);
    if (whereWord.length == 0) {
      _words.add(word);
      SpUtil.putStringList("xiaoshuoWords", _words);
      notifyListeners();
    }
  }

  setResource(List<XiaoshuoResource> list) {
    _list = list;
    notifyListeners();
  }

  setAllZj(List<XiaoshuoCatlog> list) {
    _allZj = list;
    notifyListeners();
  }

  void setStateType(StateType stateType) {
    _stateType = stateType;
    notifyListeners();
  }

  void setCurrentZj(XiaoshuoCatlog current, int index) {
    _currentxszj = current;
    if (index == 0) {
      _prevxszj = null;
    } else {
      _prevxszj = _allZj[index - 1];
    }

    if (index == _allZj.length - 1) {
      _nextxszj = null;
    } else {
      _nextxszj = _allZj[index + 1];
    }
    notifyListeners();
  }
}
