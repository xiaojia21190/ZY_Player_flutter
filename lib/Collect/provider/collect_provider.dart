import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

import '../../model/detail_reource.dart';

class CollectProvider extends ChangeNotifier {
  List<DetailReource> _listDetailResource = [];
  List<DetailReource> get listDetailResource => _listDetailResource;

  setListDetailResource() {
    var result = SpUtil.getObjList<DetailReource>("collcetPlayer", (data) => DetailReource.fromJson(data));

    if (result.length > 0) {
      _listDetailResource.addAll(result);
    }
  }

  removeResource(DetailReource data) {
    _listDetailResource.removeWhere((element) => element.url == data.url);
    SpUtil.putObjectList("collcetPlayer", _listDetailResource);
    notifyListeners();
  }

  addListResource(DetailReource data) {
    _listDetailResource.add(data);
    SpUtil.putObjectList("collcetPlayer", _listDetailResource);
    notifyListeners();
  }

  changeNoti() {
    notifyListeners();
  }
}
