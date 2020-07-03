import 'package:ZY_Player_flutter/newest/page/detail_page.dart';
import 'package:ZY_Player_flutter/newest/page/newest_page.dart';
import 'package:ZY_Player_flutter/newest/page/search_page.dart';
import 'package:fluro/fluro.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';

class NewestRouter implements IRouterProvider {
  static String newestPage = '/newest';
  static String searchPage = '/search';
  static String detailPage = '/detail';

  @override
  void initRouter(Router router) {
    router.define(newestPage, handler: Handler(handlerFunc: (_, __) => NewestPage()));
    router.define(searchPage, handler: Handler(handlerFunc: (_, __) => SearchPage()));
    router.define(detailPage,
        handler: Handler(
            handlerFunc: (_, params) =>
                DetailPage(title: params['title']?.first, index: params['index']?.first, type: params['type']?.first, url: params['url']?.first)));
  }
}
