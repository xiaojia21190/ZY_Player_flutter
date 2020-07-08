import 'package:ZY_Player_flutter/model/manhua_detail.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class ManhuaSearchProvider extends ChangeNotifier {
  List<String> _words = [];
  List<String> get words => _words;

  List<ManhuaDetail> _list = [];
  List<ManhuaDetail> get list => _list;

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
}
