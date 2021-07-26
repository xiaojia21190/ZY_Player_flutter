import 'package:ZY_Player_flutter/model/manhua_catlog_detail.dart';
import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/model/ting_shu_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class CollectProvider extends ChangeNotifier {
  List<Playlist> _listDetailResource = [];
  List<Playlist> get listDetailResource => _listDetailResource;

  List<ManhuaCatlogDetail> _manhuaCatlog = [];
  List<ManhuaCatlogDetail> get manhuaCatlog => _manhuaCatlog;

  List<TingShuDetail> _list = [];
  List<TingShuDetail> get list => _list;

  setListDetailResource(String collect, dynamic result) async {
    switch (collect) {
      case "collcetPlayer":
        _listDetailResource.clear();
        _listDetailResource.addAll(result);
        break;
      case "collcetManhua":
        _manhuaCatlog.clear();
        _manhuaCatlog.addAll(result);
        break;
      case "collcetTingshu":
        _list.clear();
        _list.addAll(result);
        break;
      default:
    }
    notifyListeners();
  }

  addTingshu(TingShuDetail data) async {
    var glll = _listDetailResource.where((element) => element.url == data.url).toList().length;
    if (glll == 0) {
      _list.add(data);
      SpUtil.putObjectList("collcetTingshu", _list);
      await DioUtils.instance.requestNetwork(Method.post, HttpApi.changeCollect,
          params: {"content": JsonUtil.encodeObj(_list), "type": 2}, onSuccess: (data) {}, onError: (_, __) {});
      notifyListeners();
    }
  }

  removeTingshu(String url) async {
    _list.removeWhere((element) => element.url == url);
    SpUtil.putObjectList("collcetTingshu", _list);
    await DioUtils.instance.requestNetwork(Method.post, HttpApi.changeCollect,
        params: {"content": JsonUtil.encodeObj(_list), "type": 2}, onSuccess: (data) {}, onError: (_, __) {});
    notifyListeners();
  }

  addResource(Playlist data) async {
    var glll = _listDetailResource.where((element) => element.url == data.url).toList().length;
    if (glll == 0) {
      _listDetailResource.add(data);
      SpUtil.putObjectList("collcetPlayer", _listDetailResource);
      await DioUtils.instance.requestNetwork(Method.post, HttpApi.changeCollect,
          params: {"content": JsonUtil.encodeObj(_listDetailResource), "type": 1},
          onSuccess: (data) {},
          onError: (_, __) {});
      notifyListeners();
    }
  }

  removeResource(String url) async {
    _listDetailResource.removeWhere((element) => element.url == url);
    SpUtil.putObjectList("collcetPlayer", _listDetailResource);
    await DioUtils.instance.requestNetwork(Method.post, HttpApi.changeCollect,
        params: {"content": JsonUtil.encodeObj(_listDetailResource), "type": 1},
        onSuccess: (data) {},
        onError: (_, __) {});
    notifyListeners();
  }

  removeCatlogResource(String url) async {
    _manhuaCatlog.removeWhere((element) => element.url == url);
    SpUtil.putObjectList("collcetManhua", _manhuaCatlog);
    await DioUtils.instance.requestNetwork(Method.post, HttpApi.changeCollect,
        params: {"content": JsonUtil.encodeObj(_list), "type": 3}, onSuccess: (data) {}, onError: (_, __) {});
    notifyListeners();
  }

  addCatlogResource(ManhuaCatlogDetail data) async {
    var glll = _manhuaCatlog.where((element) => element.url == data.url).toList().length;
    if (glll == 0) {
      _manhuaCatlog.add(data);
      SpUtil.putObjectList("collcetManhua", _manhuaCatlog);
      await DioUtils.instance.requestNetwork(Method.post, HttpApi.changeCollect,
          params: {"content": JsonUtil.encodeObj(_manhuaCatlog), "type": 3}, onSuccess: (data) {}, onError: (_, __) {});
      notifyListeners();
    }
  }

  changeNoti() {
    notifyListeners();
  }

  TabController tabController;
  PageController pageController;
  int index;
}
