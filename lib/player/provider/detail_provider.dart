import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class DetailProvider extends ChangeNotifier {
  DetailReource _detailReource;
  DetailReource get detailReource => _detailReource;

  String _playerUrl = "about:blank";
  String get playerUrl => _playerUrl;

  List<String> _kanguojuji = [];
  List<String> get kanguojuji => _kanguojuji;

  bool _playState = false;
  bool get playState => _playState;

  setPlayState(bool state) {
    _playState = state;
    notifyListeners();
  }

  setJuji() {
    _kanguojuji = SpUtil.getStringList("KGjuji", defValue: []);
  }

  saveJuji(String juji) {
    if (!_kanguojuji.contains(juji)) {
      _kanguojuji.add(juji);
      SpUtil.putStringList("KGjuji", _kanguojuji);
      notifyListeners();
    }
  }

  setDetailResource(DetailReource detailReourceData) {
    _detailReource = detailReourceData;
    _playerUrl = detailReourceData.videoList[0];
    notifyListeners();
  }
}
