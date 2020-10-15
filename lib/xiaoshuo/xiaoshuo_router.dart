import 'package:ZY_Player_flutter/xiaoshuo/pages/xiaoshuo_detail_page.dart';
import 'package:ZY_Player_flutter/xiaoshuo/pages/xiaoshuo_search_page.dart';
import 'package:fluro/fluro.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';

class XiaoshuoRouter implements IRouterProvider {
  static String searchPage = '/xiaoshuo_search';
  static String detailPage = '/xiaoshuo_detail';
  static String readePage = '/read_content';

  @override
  void initRouter(Router router) {
    router.define(searchPage, handler: Handler(handlerFunc: (_, __) => XiaoShuoSearchPage()));
    router.define(detailPage,
        handler: Handler(
            handlerFunc: (_, params) => XiaoShuoDetailPage(
                  xiaoshuoResource: params["contentList"]?.first,
                )));
  }
}
