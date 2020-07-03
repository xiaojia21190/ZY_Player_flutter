import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  List<String> _words = [];
  List<String> get words => _words;

  setWords(List<String> words) {
    _words = words;
    notifyListeners();
  }

  clearWords() {
    _words.clear();
    notifyListeners();
  }

  addWors(String word) {
    _words.add(word);
    notifyListeners();
  }
}
