import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  List<String> _words = [];
  List<String> get words => _words;

  setWords() {
    _words = SpUtil.getStringList("searchWords", defValue: []);
    notifyListeners();
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
}
