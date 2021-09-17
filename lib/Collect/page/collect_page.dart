import 'dart:convert';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/manhua/manhua_router.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../widgets/load_image.dart';

class CollectPage extends StatefulWidget {
  @override
  _CollectPageState createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> with AutomaticKeepAliveClientMixin<CollectPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  PageController? _pageController;
  CollectProvider? _collectProvider;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);

    _collectProvider = Store.value<CollectProvider>(context);
    _collectProvider!.pageController = _pageController!;
    super.initState();
  }

  Widget getData(data, int index) {
    var bofang = "12万";
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          side: BorderSide(
            style: BorderStyle.solid,
            color: Colours.orange,
          )),
      child: ListTile(
        title: Text(data.title),
        subtitle: index == 0 ? Text("播放量:${data.bofang ?? bofang}") : Text(data.gengxin),
        trailing: Icon(Icons.keyboard_arrow_right),
        leading: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: LoadImage(
            data.cover,
            height: 60,
          ),
        ),
        onTap: () {
          Log.d('前往详情页');
          if (index == 0) {
            String jsonString = jsonEncode(data);
            NavigatorUtils.push(context, '${PlayerRouter.detailPage}?playerList=${Uri.encodeComponent(jsonString)}');
          } else {
            NavigatorUtils.push(context, '${ManhuaRouter.detailPage}?url=${Uri.encodeComponent(data.url)}&title=${Uri.encodeComponent(data.title)}');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    super.build(context);
    return Scaffold(
      body: Container(
        color: isDark ? Colours.dark_bg_gray_ : Color(0xfff5f5f5),
        child: Selector<CollectProvider, TabController>(
            builder: (_, tab, __) {
              return PageView.builder(
                  key: const Key('pageView'),
                  itemCount: 2,
                  onPageChanged: (index) {
                    tab.animateTo(index);
                    _collectProvider!.index = index;
                  },
                  controller: _pageController,
                  itemBuilder: (_, pageIndex) {
                    return Selector<CollectProvider, dynamic>(builder: (_, list, __) {
                      return ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (_, index) {
                            return Slidable(
                              child: getData(list[index], pageIndex),
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: 0.25,
                              secondaryActions: <Widget>[
                                IconSlideAction(
                                  caption: '取消收藏',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () {
                                    // 取消收藏
                                    if (pageIndex == 0) {
                                      // 影视
                                      _collectProvider!.removeResource(list[index].url);
                                    } else {
                                      // 漫画
                                      _collectProvider!.removeCatlogResource(list[index].url);
                                    }
                                    setState(() {});
                                  },
                                ),
                              ],
                            );
                          });
                    }, selector: (_, store) {
                      if (pageIndex == 0) {
                        return store.listDetailResource;
                      }
                      return store.manhuaCatlog;
                    });
                  });
            },
            selector: (_, store) => store.tabController),
      ),
    );
  }
}
