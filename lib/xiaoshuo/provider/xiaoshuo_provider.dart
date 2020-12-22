import 'package:ZY_Player_flutter/model/xiaoshuo_chap.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
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

  XiaoshuoChap _chplist;
  XiaoshuoChap get chplist => _chplist;

  bool _currentOrder = false;
  bool get currentOrder => _currentOrder;

  String _shunxuText = "小说章节顺序-正序";
  String get shunxuText => _shunxuText;

  List<XiaoshuoList> _readList = [];
  List<XiaoshuoList> get readList => _readList;

  XiaoshuoDetail _lastread;
  XiaoshuoDetail get lastread => _lastread;

  setReadList(XiaoshuoList xiaoshuoList) {
    if (_readList.where((element) => element.id == xiaoshuoList.id).toList().length == 0) {
      _readList.add(xiaoshuoList);
      SpUtil.putObjectList("readXiaoshuo", _readList);
      notifyListeners();
    }
  }

  setLastRead(XiaoshuoDetail xiaoshuoDetail) {
    _lastread = xiaoshuoDetail;
    SpUtil.putObject("lastread", _lastread);
    notifyListeners();
  }

  getLastRead() {
    _lastread = SpUtil.getObj("lastread", (data) => XiaoshuoDetail.fromJson(data));
    notifyListeners();
  }

  getReadList() {
    var result = SpUtil.getObjList<XiaoshuoList>("readXiaoshuo", (data) => XiaoshuoList.fromJson(data));
    if (result.length > 0) {
      _readList.addAll(result);
    }
  }

  changeShunxu(bool shuxu) {
    _currentOrder = shuxu;
    if (shuxu) {
      _shunxuText = "小说章节顺序-倒序";
    } else {
      _shunxuText = "小说章节顺序-正序";
    }

    notifyListeners();
  }

  setStateType(StateType stateType) {
    _state = stateType;
    notifyListeners();
  }

  setListXiaoshuoResource() {
    var result = SpUtil.getObjList<XiaoshuoDetail>("collcetXiaoshuo", (data) => XiaoshuoDetail.fromJson(data));
    if (result.length > 0) {
      _xiaoshuos.addAll(result);
    }
  }

  removeXiaoshuoResource(String id) {
    _xiaoshuos.removeWhere((element) => element.id == id);
    SpUtil.putObjectList("collcetXiaoshuo", _xiaoshuos);
    notifyListeners();
  }

  addXiaoshuoResource(XiaoshuoDetail data) {
    _xiaoshuos.add(data);
    SpUtil.putObjectList("collcetXiaoshuo", _xiaoshuos);
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
