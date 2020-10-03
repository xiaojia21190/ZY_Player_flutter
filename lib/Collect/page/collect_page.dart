import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/manhua/manhua_router.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/dimens.dart';
import 'package:ZY_Player_flutter/res/styles.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:ZY_Player_flutter/xiaoshuo/pages/xiaoshuo_detail_page.dart';
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
  TabController _tabController;
  PageController _pageController;
  CollectProvider _collectProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _pageController = PageController(initialPage: 0);
    _collectProvider = context.read<CollectProvider>();
    _collectProvider.setListDetailResource("collcetPlayer");
    Future.microtask(() => _collectProvider.getCollectData(_collectProvider.listDetailResource));
  }

  Widget getData(data, int index) {
    switch (index) {
      case 0:
        return ListTile(
          title: Text(data.title),
          subtitle: Text(data.leixing),
          leading: LoadImage(
            data.cover,
            fit: BoxFit.cover,
          ),
          onTap: () {
            Log.d('前往详情页');
            NavigatorUtils.push(context, '${PlayerRouter.detailPage}?url=${Uri.encodeComponent(data.url)}&title=${Uri.encodeComponent(data.title)}');
          },
        );
        break;
      case 1:
        return ListTile(
          title: Text(data.title),
          subtitle: Text(data.author),
          onTap: () {
            Log.d('前往详情页');
            Navigator.push(
                context,
                CupertinoPageRoute<dynamic>(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return XiaoShuoDetailPage(
                        xiaoshuoReource: data,
                      );
                    }));
          },
        );
        break;
      case 2:
        return ListTile(
          title: Text(data.title),
          subtitle: Text(data.author),
          trailing: Icon(Icons.keyboard_arrow_right),
          leading: LoadImage(
            data.cover,
            fit: BoxFit.cover,
          ),
          onTap: () {
            Log.d('前往详情页');
            NavigatorUtils.push(context, '${ManhuaRouter.detailPage}?url=${Uri.encodeComponent(data.url)}&title=${Uri.encodeComponent(data.title)}');
          },
        );
        break;
      default:
        return ListTile(
          title: Text(data.title),
          subtitle: Text(data.type),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Log.d('前往详情页');
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text("小说"),
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
        color: Color(0xfff5f5f5),
        child: PageView.builder(
            key: const Key('pageView'),
            itemCount: 3,
            onPageChanged: _onPageChange,
            controller: _pageController,
            itemBuilder: (_, pageIndex) {
              return Selector<CollectProvider, dynamic>(
                  builder: (_, list, __) {
                    return list.length > 0
                        ? ListView.builder(
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
                                        // 小说
                                        _collectProvider.removeXiaoshuoResource(list[index].url);
                                      } else if (pageIndex == 2) {
                                        // 漫画
                                        _collectProvider.removeCatlogResource(list[index].url);
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ],
                              );
                            })
                        : StateLayout(
                            type: StateType.empty,
                          );
                  },
                  selector: (_, store) => store.list);
            }),
      ),
    );
  }

  _onPageChange(int index) async {
    // 加载不同的数据
    switch (index) {
      case 0:
        _collectProvider.setListDetailResource("collcetPlayer");
        _collectProvider.getCollectData(_collectProvider.listDetailResource);
        break;
      case 1:
        _collectProvider.setListDetailResource("collcetXiaoshuo");
        _collectProvider.getCollectData(_collectProvider.xiaoshuo);
        break;
      case 2:
        _collectProvider.setListDetailResource("collcetManhua");
        _collectProvider.getCollectData(_collectProvider.manhuaCatlog);
        break;
      default:
    }
    _tabController.animateTo(index);
  }
}
