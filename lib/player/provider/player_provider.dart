import 'package:ZY_Player_flutter/model/resource_data.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  List<String> _words = [];
  List<String> get words => _words;

  List<ResourceData> _list = [];
  List<ResourceData> get list => list;

  setWords() {
    _words = SpUtil.getStringList("searchWords", defValue: []);
  }

  clearWords() {
    _words.clear();
    SpUtil.putStringList("searchWords", _words);
    notifyListeners();
  }

  addWors(String word) {
    var whereWord = _words.where((element) => element == word);
    if (whereWord.length == 0) {
      _words.add(word);
      SpUtil.putStringList("searchWords", _words);
      notifyListeners();
    }
  }

  setResource(List<ResourceData> list) {
    _list = list;
    notifyListeners();
  }
}
