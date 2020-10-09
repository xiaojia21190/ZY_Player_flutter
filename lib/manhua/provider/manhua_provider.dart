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

  List<String> _images = [];
  List<String> get images => _images;

  List<String> _kanguozhangjie = [];
  List<String> get kanguozhangjie => _kanguozhangjie;

  StateType _state = StateType.loading;
  StateType get state => _state;

  String _shunxuText = "漫画章节顺序-倒序";
  String get shunxuText => _shunxuText;

  bool _currentOrder = false;
  bool get currentOrder => _currentOrder;

  setZhanghjie() {
    _kanguozhangjie = SpUtil.getStringList("KGzhangjie", defValue: []);
  }

  changeShunxu(bool shuxu) {
    _currentOrder = shuxu;
    if (shuxu) {
      _shunxuText = "漫画章节顺序-正序";
    } else {
      _shunxuText = "漫画章节顺序-倒序";
    }
    _catLog.catlogs = _catLog.catlogs.reversed.toList();

    notifyListeners();
  }

  String _actionName = "";
  String get actionName => _actionName;

  void setActionName(String actionName) {
    _actionName = actionName;
    notifyListeners();
  }

  saveZhangjie(String zhangjie) {
    _kanguozhangjie.add(zhangjie);
    SpUtil.putStringList("KGzhangjie", _kanguozhangjie);
    notifyListeners();
  }

  setWords() {
    _words = SpUtil.getStringList("ManHuaWords", defValue: []);
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

  setStateType(StateType stateType) {
    _state = stateType;
    notifyListeners();
  }

  setImages(List<String> images) {
    _images = images;
    notifyListeners();
  }
}
