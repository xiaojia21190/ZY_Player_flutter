import 'package:ZY_Player_flutter/Collect/collect_router.dart';
import 'package:ZY_Player_flutter/home/home_page.dart';
import 'package:ZY_Player_flutter/home/webview_page.dart';
import 'package:ZY_Player_flutter/login/login_router.dart';
import 'package:ZY_Player_flutter/manhua/manhua_router.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/routes/404.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';
import 'package:ZY_Player_flutter/setting/setting_router.dart';
import 'package:ZY_Player_flutter/xiaoshuo/xiaoshuo_router.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members
class Routes {
  static String home = '/home';
  static String webViewPage = '/webview';

  static final List<IRouterProvider> _listRouter = [];

  static void configureRoutes(FluroRouter router) {
    /// 指定路由跳转错误返回页
    router.notFoundHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      debugPrint('未找到目标页');
      return const PageNotFound();
    });

    router.define(home, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) => const Home()));

    router.define(webViewPage, handler: Handler(handlerFunc: (_, params) {
      final String title = params['title']!.first;
      final String url = params['url']!.first;
      return WebViewPage(title: title, url: url);
    }));

    _listRouter.clear();

    /// 各自路由由各自模块管理，统一在此添加初始化
    _listRouter.add(LoginRouter());
    _listRouter.add(SettingRouter());
    _listRouter.add(PlayerRouter());
    _listRouter.add(ManhuaRouter());
    _listRouter.add(XiaoShuoRouter());
    _listRouter.add(CollectRouter());

    /// 初始化路由
    for (var routerProvider in _listRouter) {
      routerProvider.initRouter(router);
    }
  }
}
