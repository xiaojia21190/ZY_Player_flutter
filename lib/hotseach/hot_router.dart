import 'package:ZY_Player_flutter/hotseach/page/hot_detail_page.dart';
import 'package:ZY_Player_flutter/hotseach/page/hot_search_page.dart';
import 'package:fluro/fluro.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';

class HotRouter implements IRouterProvider {
  static String searchPage = '/hot_search_page';
  static String hotDetailPage = '/hot_detail_page';

  @override
  void initRouter(Router router) {
    router.define(searchPage, handler: Handler(handlerFunc: (_, params) => HotSearchPage()));
    router.define(hotDetailPage,
        handler: Handler(
            handlerFunc: (_, params) => HotDetailPage(
                  contentList: params["contentList"]?.first,
                  title: params["title"]?.first,
                )));
  }
}
