import 'package:ZY_Player_flutter/model/manhua_catlog_detail.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

import '../../model/detail_reource.dart';

class CollectProvider extends ChangeNotifier {
  List<dynamic> _listDetailResource = [];
  List<dynamic> get listDetailResource => _listDetailResource;

  setListDetailResource(String collect) {
    var result = [];
    switch (collect) {
      case "collcetPlayer":
        result = SpUtil.getObjList<DetailReource>(collect, (data) => DetailReource.fromJson(data));
        break;
      case "collcetManhua":
        result = SpUtil.getObjList<ManhuaCatlogDetail>(collect, (data) => ManhuaCatlogDetail.fromJson(data));
        break;
      default:
    }

    if (result.length > 0) {
      _listDetailResource.addAll(result);
    }
  }

  removeResource(String url, String collect) {
    _listDetailResource.removeWhere((element) => element.url == url);
    SpUtil.putObjectList(collect, _listDetailResource);
    notifyListeners();
  }

  addResource<T>(T data, String collect) {
    _listDetailResource.add(data);
    SpUtil.putObjectList(collect, _listDetailResource);
    notifyListeners();
  }

  changeNoti() {
    notifyListeners();
  }
}

enum CollectType {
  /// 影视
  yingshi,

  /// 小说
  xiaoshuo,

  /// 漫画
  manhua,
}
