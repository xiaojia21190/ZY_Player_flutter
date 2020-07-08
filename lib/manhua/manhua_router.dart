import 'package:ZY_Player_flutter/manhua/page/manhua_search_page.dart';
import 'package:fluro/fluro.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';

class ManhuaRouter implements IRouterProvider {
  static String searchPage = '/search';
  static String detailPage = '/detail';
  static String imagesPage = '/image';

  @override
  void initRouter(Router router) {
    router.define(searchPage, handler: Handler(handlerFunc: (_, __) => ManhuaSearchPage()));
    // router.define(imagesPage, handler: Handler(handlerFunc: (_, __) => ManhuaSearchPage()));
    // router.define(detailPage, handler: Handler(handlerFunc: (_, params) => ManhuaSearchPage(url: params['url']?.first)));
  }
}
