import 'package:ZY_Player_flutter/tingshu/page/tingshu_detail_page.dart';
import 'package:ZY_Player_flutter/tingshu/page/tingshu_search_page.dart';
import 'package:fluro/fluro.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';

class TingshuRouter implements IRouterProvider {
  static String searchPage = '/tingshuSearch';
  static String detailPage = '/tingshuDetail';

  @override
  void initRouter(FluroRouter router) {
    router.define(searchPage, handler: Handler(handlerFunc: (_, __) => TingshuSearchPage()));
    router.define(detailPage,
        handler: Handler(
            handlerFunc: (_, params) => TingshuDetailPage(
                  url: params['url']!.first,
                  title: params['title']!.first,
                  cover: params['cover']!.first,
                )));
  }
}
