import 'dart:convert';

import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:ZY_Player_flutter/player/widget/player_list_page.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety_flutter3/flutter_swiper_null_safety_flutter3.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage({Key? key}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with AutomaticKeepAliveClientMixin<PlayerPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  PlayerProvider? playerProvider;

  @override
  void initState() {
    super.initState();
    playerProvider = Store.value<PlayerProvider>(context);
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
                  return list.isNotEmpty
                      ? Swiper(
                          autoplay: true,
                          itemBuilder: (BuildContext context, int index) {
                            return LoadImage(list[index].cover, fit: BoxFit.fitHeight);
                          },
                          itemCount: list.length,
                          itemWidth: MediaQuery.of(context).size.width,
                          itemHeight: 250.0,
                          layout: SwiperLayout.TINDER,
                          onTap: (index) {
                            String jsonString = jsonEncode(list[index]);
                            NavigatorUtils.push(context, '${PlayerRouter.detailPage}?playerList=${Uri.encodeComponent(jsonString)}');
                          },
                        )
                      : Container();
                },
                selector: (_, store) => store.swiperList),
          ),
        ];
      },
      body: Container(
        color: isDark ? Colours.dark_bg_gray_ : Color(0xfff5f5f5),
        child: PlayerListPage(),
      ),
    );
  }
}
