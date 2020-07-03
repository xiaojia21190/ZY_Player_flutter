import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:flutter/material.dart';

class DetailProvider extends ChangeNotifier {
  DetailReource _detailReource;
  DetailReource get detailReource => _detailReource;

  String _playerUrl = "about:blank";
  String get playerUrl => _playerUrl;

  List<DetailReource> _listDetailResource = [];
  List<DetailReource> get listDetailResource => _listDetailResource;

  setDetailResource(DetailReource detailReourceData) {
    _detailReource = detailReourceData;
    _playerUrl = detailReourceData.videoList[0];
    notifyListeners();
  }

  setListDetailResource(List<DetailReource> data) {
    _listDetailResource = data;
    notifyListeners();
  }

  removeListDetailResource(DetailReource data) {
    _listDetailResource.remove(data);
    notifyListeners();
  }

  addListDetailResource(DetailReource data) {
    _listDetailResource.add(data);
    notifyListeners();
  }
}
