import 'dart:convert';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/manhua/manhua_router.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/dimens.dart';
import 'package:ZY_Player_flutter/res/styles.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../widgets/load_image.dart';

class CollectPage extends StatefulWidget {
  @override
  _CollectPageState createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage>
    with AutomaticKeepAliveClientMixin<CollectPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  TabController _tabController;
  PageController _pageController;
  CollectProvider _collectProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _pageController = PageController(initialPage: 0);
    _collectProvider = Store.value<CollectProvider>(context);
    _collectProvider.setListDetailResource("collcetPlayer");
    _collectProvider.setListDetailResource("collcetManhua");
  }

  Widget getData(data, int index) {
    return ListTile(
      title: Text(data.title),
      subtitle: index == 0 ? null : Text(data.leixing),
      trailing: Icon(Icons.keyboard_arrow_right),
      leading: Container(
        // decoration: BoxDecoration(border: Border.all(color: Colors.red)),
        height: 200,
        width: 100,
        padding: EdgeInsets.all(5),
        child: LoadImage(
          data.cover,
          fit: BoxFit.fill,
        ),
      ),
      onTap: () {
        Log.d('前往详情页');
        if (index == 0) {
          String jsonString = jsonEncode(data);
          NavigatorUtils.push(context, '${PlayerRouter.detailPage}?playerList=${Uri.encodeComponent(jsonString)}');
        } else {
          NavigatorUtils.push(context,
              '${ManhuaRouter.detailPage}?url=${Uri.encodeComponent(data.url)}&title=${Uri.encodeComponent(data.title)}');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TabBar(
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          controller: _tabController,
          labelColor: Colours.red_selected_line,
          unselectedLabelColor: Color(0xff646566),
          labelStyle: TextStyles.textBold16,
          unselectedLabelStyle: const TextStyle(
            fontSize: Dimens.font_sp16,
            color: Colours.red_selected_line,
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Colours.red_selected_line,
          indicatorWeight: 3,
          tabs: const <Widget>[
            Text("影视"),
            Text("漫画"),
          ],
          onTap: (index) {
            if (!mounted) {
              return;
            }
            _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
          },
        ),
      ),
      body: Container(
        color: isDark ? Colours.dark_bg_gray_ : Color(0xfff5f5f5),
        child: PageView.builder(
            key: const Key('pageView'),
            itemCount: 2,
            onPageChanged: _onPageChange,
            controller: _pageController,
            itemBuilder: (_, pageIndex) {
              return Selector<CollectProvider, dynamic>(
                  builder: (_, list, __) {
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
                                    _collectProvider.removeResource(list[index].url);
                                  } else if (pageIndex == 1) {
                                    // 漫画
                                    _collectProvider.removeCatlogResource(list[index].url);
                                  }
                                  setState(() {});
                                },
                              ),
                            ],
                          );
                        });
                  },
                  selector: (_, store) => pageIndex == 0 ? store.listDetailResource : store.manhuaCatlog);
            }),
      ),
    );
  }

  _onPageChange(int index) async {
    switch (index) {
      case 0:
        _collectProvider.setListDetailResource("collcetPlayer");
        break;
      case 1:
        _collectProvider.setListDetailResource("collcetManhua");
        break;
      default:
        break;
    }
    _tabController.animateTo(index);
  }
}
