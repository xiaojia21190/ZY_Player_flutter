import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/model/zhibo_resource.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  List<String> _words = [];
  List<String> get words => _words;

  List<SwiperList> _swiperList = [];
  List<SwiperList> get swiperList => _swiperList;

  List<M3uResult> _zhiboList = [];
  List<M3uResult> get zhiboList => _zhiboList;

  StateType _stateType = StateType.empty;
  StateType get stateType => _stateType;

  TabController tabController;
  PageController pageController;

  int index;

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

  setSwiperList(List<SwiperList> list) {
    _swiperList = list;
    notifyListeners();
  }

  setZhiboList(List<M3uResult> list) {
    _zhiboList = list;
    notifyListeners();
  }

  void setStateType(StateType stateType) {
    _stateType = stateType;
    notifyListeners();
  }
}
