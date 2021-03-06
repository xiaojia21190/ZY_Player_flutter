import 'dart:convert';

import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:ZY_Player_flutter/player/widget/player_list_page.dart';
import 'package:ZY_Player_flutter/player/widget/zhibo_list_page.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/tingshu/page/tingshu_page.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage({Key key}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage>
    with AutomaticKeepAliveClientMixin<PlayerPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  PageController _pageController;

  PlayerProvider playerProvider;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    playerProvider = Store.value<PlayerProvider>(context);
    playerProvider.pageController = _pageController;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    super.build(context);
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Selector<PlayerProvider, List<SwiperList>>(
                builder: (_, list, __) {
                  return list.length > 0
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: 220,
                          child: Swiper(
                            autoplay: true,
                            itemBuilder: (BuildContext context, int index) {
                              return LoadImage(list[index].cover, fit: BoxFit.fitHeight);
                            },
                            itemCount: list.length,
                            pagination: new SwiperPagination(),
                            onTap: (index) {
                              String jsonString = jsonEncode(list[index]);
                              NavigatorUtils.push(
                                  context, '${PlayerRouter.detailPage}?playerList=${Uri.encodeComponent(jsonString)}');
                            },
                          ),
                        )
                      : Container();
                },
                selector: (_, store) => store.swiperList),
          ),
        ];
      },
      body: Container(
        color: isDark ? Colours.dark_bg_gray_ : Color(0xfff5f5f5),
        child: Selector<PlayerProvider, TabController>(
            builder: (_, tab, __) {
              return PageView.builder(
                  key: const Key('pageView'),
                  itemCount: 3,
                  onPageChanged: (index) => tab.animateTo(index),
                  controller: _pageController,
                  itemBuilder: (_, pageIndex) {
                    if (pageIndex == 0) {
                      return PlayerListPage();
                    } else if (pageIndex == 1) {
                      return ZhiboListPage();
                    }
                    return TingShuPage();
                  });
            },
            selector: (_, store) => store.tabController),
      ),
    );
  }
}
