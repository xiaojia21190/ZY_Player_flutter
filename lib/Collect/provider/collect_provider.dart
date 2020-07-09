import 'package:ZY_Player_flutter/model/manhua_catlog_detail.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

import '../../model/detail_reource.dart';

class CollectProvider extends ChangeNotifier {
  List<DetailReource> _listDetailResource = [];
  List<DetailReource> get listDetailResource => _listDetailResource;

  List<ManhuaCatlogDetail> _manhuaCatlog = [];
  List<ManhuaCatlogDetail> get manhuaCatlog => _manhuaCatlog;

  setListDetailResource(String collect) {
    switch (collect) {
      case "collcetPlayer":
        var result = SpUtil.getObjList<DetailReource>(collect, (data) => DetailReource.fromJson(data));
        if (result.length > 0) {
          _listDetailResource.addAll(result);
        }
        break;
      case "collcetManhua":
        var result = SpUtil.getObjList<ManhuaCatlogDetail>(collect, (data) => ManhuaCatlogDetail.fromJson(data));
        if (result.length > 0) {
          _manhuaCatlog.addAll(result);
        }
        break;
      default:
    }
  }

  removeResource(String url) {
    _listDetailResource.removeWhere((element) => element.url == url);
    SpUtil.putObjectList("collcetPlayer", _listDetailResource);
    notifyListeners();
  }

  removeCatlogResource(String url) {
    _manhuaCatlog.removeWhere((element) => element.url == url);
    SpUtil.putObjectList("collcetManhua", _listDetailResource);
    notifyListeners();
  }

  addResource(DetailReource data) {
    _listDetailResource.add(data);
    SpUtil.putObjectList("collcetPlayer", _listDetailResource);
    notifyListeners();
  }

  addCatlogResource(ManhuaCatlogDetail data) {
    _manhuaCatlog.add(data);
    SpUtil.putObjectList("collcetManhua", _manhuaCatlog);
    notifyListeners();
  }

  changeNoti() {
    notifyListeners();
  }
}
