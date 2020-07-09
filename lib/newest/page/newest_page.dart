import 'package:ZY_Player_flutter/home/provider/player_resource_provider.dart';
import 'package:ZY_Player_flutter/model/resource_data.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/newest/newest_router.dart';
import 'package:ZY_Player_flutter/newest/widget/my_search_bar.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';

import '../../home/provider/player_resource_provider.dart';

enum ResourceFarther {
  zuidazy,
  okzy,
  subo,
  mahuazy,
  zuixinzy,
  ku123,
  zy135,
}

class NewestPage extends StatefulWidget {
  @override
  _NewestPageState createState() => _NewestPageState();
}

class _NewestPageState extends State<NewestPage> with AutomaticKeepAliveClientMixin<NewestPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  PlayerResourceProvider playerResourceProvider;
  BaseListProvider<ResourceData> _baseListProvider = BaseListProvider();
  List<String> tapsStr = [];

  ResourceFarther _selection = ResourceFarther.zuidazy;

  int _currentPage = 1;
  int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    SpUtil.putString("selection", "zuidazy");
    playerResourceProvider = context.read<PlayerResourceProvider>();
    getResData();
  }

  Future getResData() async {
    await playerResourceProvider.getPlayerResource();
    _onRefresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> getTabs(List<String> taps) {
    return List.generate(taps.length, (index) {
      tapsStr.add(taps[index]);
      return Text(taps[index]);
    });
  }

  Future getData() async {
    Log.d(playerResourceProvider.taps.toString());
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.newResource,
        queryParameters: {"key": playerResourceProvider.taps[_selection.index]["key"], "page": _currentPage}, onSuccess: (resultList) {
      _baseListProvider.setStateType(StateType.empty);
      _baseListProvider.setHasMore(true);
      List.generate(resultList.length, (i) => _baseListProvider.add(ResourceData.fromJson(resultList[i])));
    }, onError: (_, __) {
      _baseListProvider.setStateType(StateType.network);
    });
  }

  Future _onRefresh() async {
    _baseListProvider.clear();
    this.getData();
  }

  Future _loadMore() async {
    _currentPage++;
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isDark = ThemeUtils.isDark(context);
    final Color iconColor = isDark ? Colours.dark_text_gray : Colours.text_gray_c;

    return ChangeNotifierProvider<BaseListProvider<ResourceData>>(
        create: (_) => _baseListProvider,
        child: NestedScrollView(headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 230.0,
              pinned: true,
              centerTitle: true,
              title: MySearchBar(),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: <StretchMode>[
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
                background: Swiper(
                  autoplay: true,
                  itemWidth: MediaQuery.of(context).size.width,
                  itemCount: 3,
                  layout: SwiperLayout.STACK,
                  itemBuilder: (_, i) {
                    return GestureDetector(
                      onTap: () => Log.e("点击其他"),
                      child: ClipRRect(
                        child: LoadImage(
                          "http://img.haote.com/upload/20180918/2018091815372344164.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  pagination: SwiperPagination(builder: SwiperPagination.dots),
                ),
              ),
              actions: <Widget>[
                PopupMenuButton<ResourceFarther>(
                  onSelected: (ResourceFarther result) {
                    _selection = result;
                    SpUtil.putString("selection", playerResourceProvider.taps[_selection.index]["key"]);
                    this._onRefresh();
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: Colours.dark_app_main,
                  ),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<ResourceFarther>>[
                    const PopupMenuItem<ResourceFarther>(
                      value: ResourceFarther.zuidazy,
                      child: Text('最大资源网'),
                    ),
                    const PopupMenuItem<ResourceFarther>(
                      value: ResourceFarther.okzy,
                      child: Text('OK资源网'),
                    ),
                    const PopupMenuItem<ResourceFarther>(
                      value: ResourceFarther.subo,
                      child: Text('速播资源站'),
                    ),
                    const PopupMenuItem<ResourceFarther>(
                      value: ResourceFarther.mahuazy,
                      child: Text('麻花资源'),
                    ),
                    const PopupMenuItem<ResourceFarther>(
                      value: ResourceFarther.zuixinzy,
                      child: Text('最新资源网'),
                    ),
                    const PopupMenuItem<ResourceFarther>(
                      value: ResourceFarther.ku123,
                      child: Text('123资源网'),
                    ),
                    const PopupMenuItem<ResourceFarther>(
                      value: ResourceFarther.zy135,
                      child: Text('135资源网'),
                    ),
                  ],
                ),
              ],
            ),
          ];
        }, body: Consumer<BaseListProvider<ResourceData>>(builder: (_, _baseListProvider, __) {
          return DeerListView(
              itemCount: _baseListProvider.list.length,
              stateType: _baseListProvider.stateType,
              onRefresh: _onRefresh,
              loadMore: _loadMore,
              pageSize: _pageSize,
              hasMore: _baseListProvider.hasMore,
              itemBuilder: (_, index) {
                return ListTile(
                  title: Text(_baseListProvider.list[index].title),
                  subtitle: Text(_baseListProvider.list[index].type),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Log.d('前往详情页');
                    NavigatorUtils.push(context,
                        '${NewestRouter.detailPage}?url=${Uri.encodeComponent(_baseListProvider.list[index].url)}&title=${Uri.encodeComponent(_baseListProvider.list[index].title)}&type=1');
                  },
                );
              });
        })));
  }
}
