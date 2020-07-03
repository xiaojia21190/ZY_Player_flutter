import 'package:ZY_Player_flutter/model/player_reource.dart';
import 'package:flutter/material.dart';

import '../../net/dio_utils.dart';
import '../../net/http_api.dart';

class PlayerResourceProvider extends ChangeNotifier {
  List<PlayerReource> _resourceList = [];
  List<PlayerReource> get resourceList => _resourceList;

  Map<String, dynamic> _resKeyMap = new Map();
  Map<String, dynamic> get resKeyMap => _resKeyMap;

  List<Map<String, dynamic>> _taps = [];
  List<Map<String, dynamic>> get taps => _taps;

  setPlayerResource(List<PlayerReource> resourceList) {
    _resourceList = resourceList;
    _resourceList.forEach((element) {
      _resKeyMap[element.key] = element;
    });

    notifyListeners();
  }

  setTaps(List<PlayerReource> resourceList) {
    resourceList.forEach((element) {
      _taps.add({"name": element.name, "key": element.key});
    });
    notifyListeners();
  }

  Future getPlayerResource() async {
    return await DioUtils.instance.requestNetwork(Method.get, HttpApi.allResource, onSuccess: (data) {
      List<PlayerReource> resultList = [];
      List.generate(data.length, (index) => resultList.add(PlayerReource.fromJson(data[index])));
      this.setPlayerResource(resultList);
      this.setTaps(resultList);
    }, onError: (_, __) {
      print('$_, $__');
    });
  }
}
