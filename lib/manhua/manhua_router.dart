import 'package:ZY_Player_flutter/manhua/page/manhua_detail_page.dart';
import 'package:ZY_Player_flutter/manhua/page/manhua_images_page.dart';
import 'package:ZY_Player_flutter/manhua/page/manhua_search_page.dart';
import 'package:fluro/fluro.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';

class ManhuaRouter implements IRouterProvider {
  static String searchPage = '/manhuSearch';
  static String detailPage = '/manhuaDetail';
  static String imagesPage = '/manhuaImage';

  @override
  void initRouter(FluroRouter router) {
    router.define(searchPage, handler: Handler(handlerFunc: (_, __) => const ManhuaSearchPage()));
    router.define(imagesPage,
        handler: Handler(handlerFunc: (_, params) => ManhuaImagePage(url: params['url']?.first, title: params['title']?.first)));
    router.define(detailPage,
        handler: Handler(handlerFunc: (_, params) => ManhuaDetailPage(url: params['url']?.first, title: params['title']?.first)));
  }
}
