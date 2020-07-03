import 'package:ZY_Player_flutter/classification/page/classification_page.dart';
import 'package:ZY_Player_flutter/classification/page/player_view_page.dart';
import 'package:fluro/fluro.dart';
import 'package:ZY_Player_flutter/routes/router_init.dart';

class ClassificationtRouter implements IRouterProvider {
  static String classificationPage = '/classification';
  static String playerViewPage = '/playerView';

  @override
  void initRouter(Router router) {
    router.define(classificationPage, handler: Handler(handlerFunc: (_, __) => ClassificationPage()));
    router.define(playerViewPage,
        handler: Handler(
            handlerFunc: (_, params) => PlayerViewPage(
                id: params['id']?.first,
                title: params['title']?.first,
                keyw: params['keyw']?.first,
                type: params["type"]?.first,
                keywords: params["keywords"]?.first)));
  }
}
