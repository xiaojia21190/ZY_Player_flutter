import 'dart:convert';

import 'package:ZY_Player_flutter/model/xiaoshuo_chap.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:ZY_Player_flutter/xiaoshuo/provider/xiaoshuo_provider.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../xiaoshuo_router.dart';

class XiaoShuoDetailPage extends StatefulWidget {
  XiaoShuoDetailPage({
    Key key,
    @required this.xiaoshuodetail,
  }) : super(key: key);

  final String xiaoshuodetail;

  @override
  _XiaoShuoDetailPageState createState() => _XiaoShuoDetailPageState();
}

class _XiaoShuoDetailPageState extends State<XiaoShuoDetailPage> {
  XiaoShuoProvider _xiaoShuoProvider = XiaoShuoProvider();
  BaseListProvider<XiaoshuoList> _baseListProvider = BaseListProvider();

  XiaoshuoDetail _detail;

  int page = 0;
  int total = 20;
  int reverse = 0;

  @override
  void initState() {
    _detail = XiaoshuoDetail.fromJson(jsonDecode(widget.xiaoshuodetail));
    _xiaoShuoProvider = Store.value<XiaoShuoProvider>(context);
    _xiaoShuoProvider.getReadList();
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    _xiaoShuoProvider.changeShunxu(false);
    super.dispose();
  }

  Future fetchData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getSearchXszjDetail,
        queryParameters: {"id": _detail.id, "page": page, "reverse": reverse}, onSuccess: (resultList) {
      if (resultList == null) {
        _baseListProvider.setStateType(StateType.order);
      } else {
        _baseListProvider.setStateType(StateType.empty);
      }
      XiaoshuoChap result = XiaoshuoChap.fromJson(resultList);

      List.generate(result.xiaoshuoList.length, (index) => _baseListProvider.add(result.xiaoshuoList[index]));
      page = result.page;
      total = result.total;
    }, onError: (_, __) {
      _baseListProvider.setStateType(StateType.network);
    });
  }

  Future _onLoadMore() async {
    page++;
    fetchData();
  }

  Future _refush(bool flag) async {
    page = 0;
    if (flag) {
      reverse = 1;
    } else {
      reverse = 0;
    }
    _baseListProvider.clear();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    return Scaffold(
      backgroundColor: isDark ? Colours.dark_bg_color : Colours.white,
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                forceElevated: innerBoxIsScrolled,
                centerTitle: true,
                backgroundColor: Colours.dark_bg_color,
                elevation: 0,
                floating: false,
                pinned: true,
                snap: false,
                expandedHeight: ScreenUtil.getInstance().getWidth(250),
                flexibleSpace: FlexibleSpaceBar(
                  background: LoadImage(_detail.img),
                ),
                actions: [
                  Consumer<XiaoShuoProvider>(
                      builder: (_, provider, __) => TextButton(
                          onPressed: () {
                            if (provider.xiaoshuo.where((element) => element.id == _detail.id).toList().length > 0) {
                              _xiaoShuoProvider.removeXiaoshuoResource(_detail.id);
                            } else {
                              _xiaoShuoProvider.addXiaoshuoResource(_detail);
                            }
                          },
                          child: Text(
                            provider.xiaoshuo.where((element) => element.id == _detail.id).toList().length > 0
                                ? "移出书架"
                                : "加入书架",
                            style: TextStyle(color: Colours.white),
                          )))
                ],
              ),
              SliverPersistentHeader(
                  pinned: true,
                  floating: false,
                  delegate: PersistentHeaderBuilder(
                      builder: (ctx, offset) => GestureDetector(
                            onTap: () {
                              _xiaoShuoProvider
                                  .setReadList(XiaoshuoList(int.parse(_detail.lastChapterId), _detail.lastChapter, 1));
                            },
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.orangeAccent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "最新章节",
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                  Text(
                                    _detail.lastChapter,
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ))),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Selector<XiaoShuoProvider, String>(
                          builder: (_, text, __) {
                            return Text(text);
                          },
                          selector: (_, store) => store.shunxuText),
                      Selector<XiaoShuoProvider, bool>(
                          builder: (_, order, __) {
                            return IconButton(
                                icon: Icon(
                                    order ? Icons.vertical_align_top_rounded : Icons.vertical_align_bottom_rounded),
                                onPressed: () {
                                  _xiaoShuoProvider.changeShunxu(!order);
                                  _refush(!order);
                                });
                          },
                          selector: (_, store) => store.currentOrder),
                    ],
                  ),
                ),
              )
            ];
          },
          body: ChangeNotifierProvider<BaseListProvider<XiaoshuoList>>(
              create: (_) => _baseListProvider,
              child: Consumer<BaseListProvider<XiaoshuoList>>(builder: (_, _baseListProvider, __) {
                return MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: DeerListView(
                        itemCount: _baseListProvider.list.length,
                        stateType: _baseListProvider.stateType,
                        hasRefresh: false,
                        loadMore: _onLoadMore,
                        pageSize: 20,
                        hasMore: _baseListProvider.hasMore,
                        itemBuilder: (_, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Consumer<XiaoShuoProvider>(
                                    builder: (_, provider, __) => ListTile(
                                          selected: provider.readList
                                                      .where(
                                                          (element) => element.id == _baseListProvider.list[index].id)
                                                      .toList()
                                                      .length >
                                                  0
                                              ? true
                                              : false,
                                          onTap: () {
                                            provider.setReadList(_baseListProvider.list[index]);
                                            NavigatorUtils.push(context,
                                                '${XiaoShuoRouter.contentPage}?id=${_detail.id}&chpId=${_baseListProvider.list[index].id}&title=${Uri.encodeComponent(_baseListProvider.list[index].name)}');
                                          },
                                          title: Text(_baseListProvider.list[index].name),
                                        )),
                              ),
                            ),
                          );
                        }));
              }))),
    );
  }
}

class PersistentHeaderBuilder extends SliverPersistentHeaderDelegate {
  final double max;
  final double min;
  final Widget Function(BuildContext context, double offset) builder;

  PersistentHeaderBuilder({this.max = 80, this.min = 40, @required this.builder})
      : assert(max >= min && builder != null);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context, shrinkOffset);
  }

  @override
  double get maxExtent => max;

  @override
  double get minExtent => min;

  @override
  bool shouldRebuild(covariant PersistentHeaderBuilder oldDelegate) =>
      max != oldDelegate.max || min != oldDelegate.min || builder != oldDelegate.builder;
}
