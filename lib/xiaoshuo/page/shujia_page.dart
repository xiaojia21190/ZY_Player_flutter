import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
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
    _xiaoShuoProvider.getReadList();
    _xiaoShuoProvider.getLastRead();
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
        children.add(BookshelfItemView(novel, "-1"));
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
          SliverToBoxAdapter(
            child: Selector<XiaoShuoProvider, XiaoshuoDetail>(
                builder: (_, lastread, __) {
                  return lastread != null
                      ? BookshelfHeader(lastread)
                      : Stack(
                          children: [
                            LoadImage(
                              "book/bookshelf_bg",
                              width: Screen.widthOt,
                              height: Screen.topSafeHeight + 200,
                            ),
                            Positioned(
                              top: 230 / 2,
                              left: Screen.widthOt / 2 - 60,
                              child: Text("点击加号添加小说"),
                            )
                          ],
                        );
                },
                selector: (_, store) => store.lastread),
          )
        ];
      },
      body: Container(
        color: isDark ? Colours.dark_bg_gray_ : Colours.lightGray,
        child: MyScrollView(
          children: [
            buildFavoriteView(_xiaoShuoProvider.xiaoshuo),
          ],
        ),
      ),
    );
  }
}
