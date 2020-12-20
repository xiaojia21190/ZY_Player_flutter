import 'package:ZY_Player_flutter/xiaoshuo/page/xiaoshuo_deail_page.dart';
import 'package:ZY_Player_flutter/xiaoshuo/page/xiaoshuo_search_page.dart';
import 'package:fluro/fluro.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';

class XiaoShuoRouter implements IRouterProvider {
  static String searchPage = '/xiaoshuoSearch';
  static String zjPage = '/xiaoshuoZj';
  static String contentPage = '/xiaoshuoContent';

  @override
  void initRouter(FluroRouter router) {
    router.define(searchPage, handler: Handler(handlerFunc: (_, __) => XiaoShuoSearchSearchPage()));
    router.define(zjPage, handler: Handler(handlerFunc: (_, params) => XiaoShuoDetailPage(xiaoshuodetail: params['xiaoshuodetail']?.first)));
    // router.define(contentPage,
    //     handler: Handler(handlerFunc: (_, params) => ManhuaDetailPage(url: params['url']?.first, title: params['title']?.first)));
  }
}
