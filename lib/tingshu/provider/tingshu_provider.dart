import 'package:ZY_Player_flutter/model/ting_shu_hot.dart';
import 'package:ZY_Player_flutter/model/ting_shu_search.dart';
import 'package:flutter/material.dart';

class TingShuProvider extends ChangeNotifier {
  List<Rmtj> _hotSearch = [];
  List<Rmtj> get hotSearch => _hotSearch;

  List<TingShuSearch> _list = [];
  List<TingShuSearch> get list => _list;

  setHotSearch(Rmtj hotse) {
    _hotSearch.add(hotse);
  }

  setSearchList(TingShuSearch tingShuSearch) {
    _list.add(tingShuSearch);
    notifyListeners();
  }
}
