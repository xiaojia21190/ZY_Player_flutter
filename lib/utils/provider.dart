import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'sputils.dart';

//状态管理
class Store {
  Store._internal();

  //全局初始化
  static init(Widget child) {
    //多个Provider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppTheme(getDefaultTheme())),
        ChangeNotifierProvider.value(value: AppStatus(TAB_HOME_INDEX)),
      ],
      child: child,
    );
  }

  //获取值 context.read
  static T value<T>(BuildContext context) {
    return context.read()<T>();
  }

  //监听值-获取值 context.watch
  static T watch<T>(BuildContext context) {
    return context.watch()<T>();
  }
}

MaterialColor getDefaultTheme() {
  return AppTheme.materialColors[SPUtils.getThemeIndex()];
}

///主题
class AppTheme with ChangeNotifier {
  static final List<MaterialColor> materialColors = [
    Colors.blue,
    Colors.lightBlue,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.grey,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
    Colors.lime
  ];

  MaterialColor _themeColor;

  AppTheme(this._themeColor);

  void setColor(MaterialColor color) {
    _themeColor = color;
    notifyListeners();
  }

  void changeColor(int index) {
    _themeColor = materialColors[index];
    SPUtils.saveThemeIndex(index);
    notifyListeners();
  }

  get themeColor => _themeColor;
}

///主页
const int TAB_HOME_INDEX = 0;

///分类
const int TAB_CATEGORY_INDEX = 1;

///活动
const int TAB_ACTIVITY_INDEX = 2;

///消息
const int TAB_MESSAGE_INDEX = 3;

///我的
const int TAB_PROFILE_INDEX = 4;

///应用状态
class AppStatus with ChangeNotifier {
  //主页tab的索引
  int _tabIndex;

  AppStatus(this._tabIndex);

  int get tabIndex => _tabIndex;

  set tabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }
}
