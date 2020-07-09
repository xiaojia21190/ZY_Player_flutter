import 'package:ZY_Player_flutter/player/page/player_detail_page.dart';
import 'package:ZY_Player_flutter/player/page/player_search_page.dart';
import 'package:fluro/fluro.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';

class PlayerRouter implements IRouterProvider {
  static String searchPage = '/player_search';
  static String detailPage = '/player_detail';

  @override
  void initRouter(Router router) {
    router.define(searchPage, handler: Handler(handlerFunc: (_, __) => PlayerSearchPage()));
    router.define(detailPage,
        handler: Handler(handlerFunc: (_, params) => PlayerDetailPage(title: params['title']?.first, url: params['url']?.first)));
  }
}
