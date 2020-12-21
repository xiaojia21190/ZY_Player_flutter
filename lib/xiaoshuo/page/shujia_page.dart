import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/my_scroll_view.dart';
import 'package:ZY_Player_flutter/xiaoshuo/provider/xiaoshuo_provider.dart';
import 'package:ZY_Player_flutter/xiaoshuo/widget/booksheif_header_view.dart';
import 'package:ZY_Player_flutter/xiaoshuo/widget/bookshelf_item_view.dart';
import 'package:ZY_Player_flutter/xiaoshuo/xiaoshuo_router.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShuJiaPage extends StatefulWidget {
  ShuJiaPage({Key key}) : super(key: key);

  @override
  _ShuJiaPageState createState() => _ShuJiaPageState();
}

class _ShuJiaPageState extends State<ShuJiaPage>
    with AutomaticKeepAliveClientMixin<ShuJiaPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  AnimationController controller;
  Animation<double> animation;

  XiaoShuoProvider _xiaoShuoProvider = XiaoShuoProvider();

  @override
  void initState() {
    controller = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
    _xiaoShuoProvider = Store.value<XiaoShuoProvider>(context);
    _xiaoShuoProvider.setListXiaoshuoResource();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget buildFavoriteView(List<XiaoshuoDetail> list) {
    List<Widget> children = [];
    if (list.length > 0) {
      list.forEach((novel) {
        children.add(BookshelfItemView(novel));
      });
    }
    var width = (Screen.widthOt - 15 * 2 - 24 * 2) / 3;
    children.add(GestureDetector(
      onTap: () {
        NavigatorUtils.push(context, '${XiaoShuoRouter.searchPage}');
      },
      child: Container(
        color: Colours.paper,
        width: width,
        height: width / 0.75,
        child: Image.asset('assets/images/book/bookshelf_add.png'),
      ),
    ));
    return Container(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
      child: Wrap(
        spacing: 23,
        children: children,
      ),
    );
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
            expandedHeight: ScreenUtil.getInstance().getWidth(230),
            flexibleSpace: Selector<XiaoShuoProvider, List<XiaoshuoDetail>>(
                builder: (_, xiaoList, __) {
                  return FlexibleSpaceBar(
                    // centerTitle: true,
                    // title: Text("12321"),
                    background: xiaoList.length > 0
                        ? BookshelfHeader(xiaoList[0])
                        : Center(
                            child: Text("点击加号添加小说"),
                          ),
                  );
                },
                selector: (_, store) => store.xiaoshuo),
            actions: [
              TextButton(
                  onPressed: () {
                    NavigatorUtils.push(context, '${XiaoShuoRouter.searchPage}');
                  },
                  child: Icon(
                    Icons.search_sharp,
                    color: Colours.text,
                  ))
            ],
          ),
        ];
      },
      body: Container(
        color: isDark ? Colours.dark_bg_gray_ : Colours.lightGray,
        child: Selector<XiaoShuoProvider, List<XiaoshuoDetail>>(
            builder: (_, xiaoList, __) {
              return MyScrollView(
                children: [
                  buildFavoriteView(xiaoList),
                ],
              );
            },
            selector: (_, store) => store.xiaoshuo),
      ),
    );
  }
}
