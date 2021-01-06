import 'dart:convert';

import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:ZY_Player_flutter/player/widget/player_list_page.dart';
import 'package:ZY_Player_flutter/player/widget/zhibo_list_page.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/dimens.dart';
import 'package:ZY_Player_flutter/res/styles.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/Loading.dart';
import 'package:ZY_Player_flutter/util/image_utils.dart';
import 'package:ZY_Player_flutter/util/persistent_header_delegate.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage({Key key}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage>
    with AutomaticKeepAliveClientMixin<PlayerPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  TabController _tabController;
  PageController _pageController;

  PlayerProvider playerProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _pageController = PageController(initialPage: 0);
    playerProvider = Store.value<PlayerProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    super.build(context);
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            forceElevated: innerBoxIsScrolled,
            centerTitle: true,
            elevation: 0,
            floating: false,
            pinned: true,
            snap: false,
            expandedHeight: ScreenUtil.getInstance().getWidth(150),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: TabBar(
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                controller: _tabController,
                labelColor: Colours.red_selected_line,
                unselectedLabelColor: Colours.text_gray,
                labelStyle: TextStyles.textBold16,
                unselectedLabelStyle: const TextStyle(
                  fontSize: Dimens.font_sp16,
                  color: Colours.red_selected_line,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Colours.red_selected_line,
                indicatorWeight: 1,
                tabs: const <Widget>[
                  Text("影视"),
                  Text("直播"),
                ],
                onTap: (index) {
                  if (!mounted) {
                    return;
                  }
                  playerProvider.setWaiMaiIndex(index);
                  _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
                },
              ),
              background: Selector<PlayerProvider, List<SwiperList>>(
                  builder: (_, list, __) {
                    return list.length > 0
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            child: Swiper(
                              autoplay: true,
                              itemBuilder: (BuildContext context, int index) {
                                return LoadImage(
                                  list[index].cover,
                                  fit: BoxFit.cover,
                                );
                              },
                              itemCount: list.length,
                              pagination: SwiperPagination.fraction,
                              onTap: (index) {
                                String jsonString = jsonEncode(list[index]);
                                NavigatorUtils.push(context,
                                    '${PlayerRouter.detailPage}?playerList=${Uri.encodeComponent(jsonString)}');
                              },
                            ),
                          )
                        : Container();
                  },
                  selector: (_, store) => store.swiperList),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    NavigatorUtils.push(context, PlayerRouter.searchPage);
                  },
                  child: Icon(
                    Icons.search_sharp,
                    color: Colours.text,
                  ))
            ],
          ),
          Selector<PlayerProvider, int>(
              builder: (_, index, __) {
                return SliverPersistentHeader(
                  delegate: CustomSliverPersistentHeaderDelegate(
                      min: 150,
                      max: 150,
                      child: GestureDetector(
                        onTap: () async {
                          String url = index == 0 ? "https://s.click.ele.me/6RwcEtu" : "https://dpurl.cn/Y4cGKOy";
                          bool isCan = await canLaunch(url);
                          if (isCan) {
                            await launch(url);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: index == 0
                              ? LoadImage("youhui2")
                              : LoadImage(
                                  "youhui1",
                                  format: ImageFormat.jpg,
                                  fit: BoxFit.fill,
                                ),
                        ),
                      )),
                );
              },
              selector: (_, store) => store.waimaiIndex)
        ];
      },
      body: Container(
        color: isDark ? Colours.dark_bg_gray_ : Color(0xfff5f5f5),
        child: PageView.builder(
            key: const Key('pageView'),
            itemCount: 2,
            onPageChanged: _onPageChange,
            controller: _pageController,
            itemBuilder: (_, pageIndex) {
              if (pageIndex == 0) {
                return PlayerListPage();
              }
              return ZhiboListPage();
            }),
      ),
    );
  }

  _onPageChange(int index) async {
    playerProvider.setWaiMaiIndex(index);
    _tabController.animateTo(index);
  }
}
