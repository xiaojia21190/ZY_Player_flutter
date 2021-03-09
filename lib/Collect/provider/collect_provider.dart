import 'package:ZY_Player_flutter/model/manhua_catlog_detail.dart';
import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/model/ting_shu_detail.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class CollectProvider extends ChangeNotifier {
  List<Playlist> _listDetailResource = [];
  List<Playlist> get listDetailResource => _listDetailResource;

  List<ManhuaCatlogDetail> _manhuaCatlog = [];
  List<ManhuaCatlogDetail> get manhuaCatlog => _manhuaCatlog;

  List<TingShuDetail> _list = [];
  List<TingShuDetail> get list => _list;

  setListDetailResource(String collect) {
    switch (collect) {
      case "collcetPlayer":
        var result = SpUtil.getObjList<Playlist>(collect, (data) => Playlist.fromJson(data));
        if (result.length > 0) {
          _listDetailResource.clear();
          _listDetailResource.addAll(result);
        }
        break;
      case "collcetManhua":
        var result = SpUtil.getObjList<ManhuaCatlogDetail>(collect, (data) => ManhuaCatlogDetail.fromJson(data));
        if (result.length > 0) {
          _manhuaCatlog.clear();
          _manhuaCatlog.addAll(result);
        }
        break;
      case "collcetTingshu":
        var result = SpUtil.getObjList<TingShuDetail>(collect, (data) => TingShuDetail.fromJson(data));
        if (result.length > 0) {
          _list.clear();
          _list.addAll(result);
        }
        break;
      default:
    }
  }

  addTingshu(TingShuDetail data) {
    var glll = _listDetailResource.where((element) => element.url == data.url).toList().length;
    if (glll == 0) {
      _list.add(data);
      SpUtil.putObjectList("collcetTingshu", _list);
      notifyListeners();
    }
  }

  removeTingshu(String url) {
    _list.removeWhere((element) => element.url == url);
    SpUtil.putObjectList("collcetTingshu", _list);
    notifyListeners();
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

  addResource(Playlist data) {
    var glll = _listDetailResource.where((element) => element.url == data.url).toList().length;
    if (glll == 0) {
      _listDetailResource.add(data);
      SpUtil.putObjectList("collcetPlayer", _listDetailResource);
      notifyListeners();
    }
  }

  addCatlogResource(ManhuaCatlogDetail data) {
    var glll = _manhuaCatlog.where((element) => element.url == data.url).toList().length;
    if (glll == 0) {
      _manhuaCatlog.add(data);
      SpUtil.putObjectList("collcetManhua", _manhuaCatlog);
      notifyListeners();
    }
  }

  changeNoti() {
    notifyListeners();
  }
}
