import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/manhua/provider/manhua_provider.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/provider/theme_provider.dart';
import 'package:ZY_Player_flutter/tingshu/provider/tingshu_provider.dart';
import 'package:ZY_Player_flutter/xiaoshuo/provider/xiaoshuo_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//状态管理
class Store {
  Store._internal();

  //全局初始化
  static init(Widget child) {
    //多个Provider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CollectProvider>(create: (_) => CollectProvider()),
        ChangeNotifierProvider<ManhuaProvider>(create: (_) => ManhuaProvider()),
        ChangeNotifierProvider<PlayerProvider>(create: (_) => PlayerProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<AppStateProvider>(create: (_) => AppStateProvider()),
        ChangeNotifierProvider<TingShuProvider>(create: (_) => TingShuProvider()),
        ChangeNotifierProvider<XiaoShuoProvider>(create: (_) => XiaoShuoProvider()),
      ],
      child: child,
    );
  }

  //获取值 context.read
  static T value<T>(BuildContext context) {
    return context.read<T>();
  }

  //监听值-获取值 context.watch
  static T watch<T>(BuildContext context) {
    return context.watch<T>();
  }
}
