import 'package:ZY_Player_flutter/model/xiaoshuo_chap.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';

class XiaoShuoProvider extends ChangeNotifier {
  List<XiaoshuoDetail> _xiaoshuos = [];
  List<XiaoshuoDetail> get xiaoshuo => _xiaoshuos;

  StateType _state = StateType.empty;
  StateType get state => _state;

  List<XiaoshuoDetail> _list = [];
  List<XiaoshuoDetail> get list => _list;

  XiaoshuoChap _chplist;
  XiaoshuoChap get chplist => _chplist;

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
