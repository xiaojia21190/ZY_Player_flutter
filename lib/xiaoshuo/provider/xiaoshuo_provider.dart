import 'package:ZY_Player_flutter/model/xiaoshuo_chap.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class XiaoShuoProvider extends ChangeNotifier {
  List<XiaoshuoDetail> _xiaoshuos = [];
  List<XiaoshuoDetail> get xiaoshuo => _xiaoshuos;

  StateType _state = StateType.empty;
  StateType get state => _state;

  List<XiaoshuoDetail> _list = [];
  List<XiaoshuoDetail> get list => _list;

  XiaoshuoChap? _chplist;
  XiaoshuoChap? get chplist => _chplist;

  bool _currentOrder = false;
  bool get currentOrder => _currentOrder;

  String _shunxuText = "章节顺序-正序";
  String get shunxuText => _shunxuText;

  List<String> _readList = [];
  List<String> get readList => _readList;

  XiaoshuoDetail? _lastread;
  XiaoshuoDetail? get lastread => _lastread;

  setReadList(String readString) {
    _readList.removeWhere((element) => element == readString);
    _readList.add(readString);
    SpUtil.putStringList("readXiaoshuo1", _readList);
    notifyListeners();
  }

  setLastRead(XiaoshuoDetail xiaoshuoDetail) {
    _lastread = xiaoshuoDetail;
    SpUtil.putObject("lastread", _lastread!);
    notifyListeners();
  }

  getLastRead() {
    _lastread = SpUtil.getObj("lastread", (data) => XiaoshuoDetail.fromJson(data as Map<String, dynamic>));
  }

  getReadList() {
    var result = SpUtil.getStringList("readXiaoshuo1");
    if (result!.length > 0) {
      _readList.addAll(result);
    }
  }

  changeShunxu(bool shuxu, [bool flag = true]) {
    _currentOrder = shuxu;
    if (shuxu) {
      _shunxuText = "章节顺序-倒序";
    } else {
      _shunxuText = "章节顺序-正序";
    }
    if (flag) {
      notifyListeners();
    }
  }

  setStateType(StateType stateType) {
    _state = stateType;
    notifyListeners();
  }

  setListXiaoshuoResource() {
    var result = SpUtil.getObjList<XiaoshuoDetail>("collcetXiaoshuo", (data) => XiaoshuoDetail.fromJson(data as Map<String, dynamic>));
    if (result!.length > 0) {
      _xiaoshuos.addAll(result);
    }
  }

  removeXiaoshuoResource(String id) async {
    _xiaoshuos.removeWhere((element) => element.id == id);
    SpUtil.putObjectList("collcetXiaoshuo", _xiaoshuos);
    await DioUtils.instance.requestNetwork(Method.post, HttpApi.changeCollect,
        params: {"content": JsonUtil.encodeObj(_xiaoshuos), "type": 0}, onSuccess: (data) {}, onError: (_, __) {});
    notifyListeners();
  }

  addXiaoshuoResource(XiaoshuoDetail data) async {
    _xiaoshuos.add(data);
    SpUtil.putObjectList("collcetXiaoshuo", _xiaoshuos);
    await DioUtils.instance.requestNetwork(Method.post, HttpApi.changeCollect,
        params: {"content": JsonUtil.encodeObj(_xiaoshuos), "type": 0}, onSuccess: (data) {}, onError: (_, __) {});
    notifyListeners();
  }

  setList(List<XiaoshuoDetail> list) {
    _list = list;
    notifyListeners();
  }

  setChpList(XiaoshuoChap xiaoshuoChap) {
    _chplist = xiaoshuoChap;
    notifyListeners();
  }
}
