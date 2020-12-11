import 'package:ZY_Player_flutter/routes/router_init.dart';
import 'package:ZY_Player_flutter/zhibo/page/zhibo_detail_page.dart';
import 'package:fluro/fluro.dart';

class ZhiboRouter implements IRouterProvider {
  static String detailPage = '/zhibo_detail';

  @override
  void initRouter(FluroRouter router) {
    router.define(detailPage,
        handler: Handler(handlerFunc: (_, params) => ZhiboDetailPage(title: params['title']?.first, url: params['url']?.first)));
  }
}
