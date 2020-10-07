import 'package:ZY_Player_flutter/hotseach/page/hot_search_page.dart';
import 'package:fluro/fluro.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';

class HotRouter implements IRouterProvider {
  static String searchPage = '/hot_search';
  static String hotPage = '/hot_page';

  @override
  void initRouter(Router router) {
    router.define(searchPage, handler: Handler(handlerFunc: (_, __) => HotSearchPage()));
  }
}
