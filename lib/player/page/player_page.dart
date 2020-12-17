import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/dimens.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/res/styles.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/persistent_header_delegate.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage({Key key}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with AutomaticKeepAliveClientMixin<PlayerPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  BaseListProvider<Types> _baseListProvider = BaseListProvider();
  List<SwiperList> _list = [];
  TabController _tabController;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _pageController = PageController(initialPage: 0);
    _onRefresh();
    _getZhiboList();
  }

  Future _getZhiboList() async {
    // await DioUtils.instance.requestNetwork(
    //   Method.get,
    //   HttpApi.getZhiboList,
    //   onSuccess: (data) {
    //     List.generate(data.length, (i) => _zhiboProvider.list.add(ZhiboResource.fromJson(data[i])));
    //     if (data.length == 0) {
    //       _zhiboProvider.setStateType(StateType.network);
    //     } else {
    //       _zhiboProvider.setStateType(StateType.empty);
    //     }
    //     setState(() {});
    //   },
    //   onError: (code, msg) {
    //     _zhiboProvider.setStateType(StateType.network);
    //   },
    // );
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.getHotList,
      onSuccess: (data) {
        List.generate(data["types"].length, (i) => _baseListProvider.list.add(Types.fromJson(data["types"][i])));
        List.generate(data["swiper"].length, (i) => _list.add(SwiperList.fromJson(data["swiper"][i])));
        setState(() {});
        if (data["types"].length == 0) {
          _baseListProvider.setStateType(StateType.network);
        } else {
          _baseListProvider.setStateType(StateType.empty);
        }
      },
      onError: (code, msg) {
        _baseListProvider.setStateType(StateType.network);
      },
    );
  }

  Future _onRefresh() async {
    _baseListProvider.clear();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    super.build(context);
    return ChangeNotifierProvider<BaseListProvider<Types>>(
        create: (_) => _baseListProvider,
        child: Scaffold(
          body: SafeArea(
              child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: true,
                expandedHeight: 300.0,
                elevation: 10,
                flexibleSpace: Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    return LoadImage(_list[index].cover);
                  },
                  itemCount: _list.length,
                  pagination: SwiperPagination.fraction,
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        NavigatorUtils.push(context, PlayerRouter.searchPage);
                      },
                      child: Icon(
                        Icons.search_sharp,
                        color: Colors.black,
                      ))
                ],
                // bottom: PreferredSize(
                //     child: Swiper(
                //       itemBuilder: (BuildContext context, int index) {
                //         return new Image.network(
                //           "http://via.placeholder.com/350x150",
                //           fit: BoxFit.fill,
                //         );
                //       },
                //       itemCount: 3,
                //       pagination: SwiperPagination(),
                //       control: SwiperControl(),
                //     ),
                //     preferredSize: Size.fromHeight(48.0)),
              ),
              SliverPersistentHeader(
                // 属性同 SliverAppBar
                pinned: true,
                floating: true,
                // 因为 SliverPersistentHeaderDelegate 是一个抽象类，所以需要自定义
                delegate: CustomSliverPersistentHeaderDelegate(
                  max: 45.0,
                  min: 0.0,
                  child: TabBar(
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                    controller: _tabController,
                    labelColor: Colours.red_selected_line,
                    unselectedLabelColor: Colors.black45,
                    labelStyle: TextStyles.textBold24,
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
                      _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
                    },
                  ),
                ),
              ),
              SliverFillRemaining(
                  child: Container(
                color: isDark ? Colours.dark_bg_gray_ : Color(0xfff5f5f5),
                child: PageView.builder(
                    key: const Key('pageView'),
                    itemCount: 2,
                    onPageChanged: _onPageChange,
                    controller: _pageController,
                    itemBuilder: (_, pageIndex) {
                      if (pageIndex == 0) {
                        return Consumer<BaseListProvider<Types>>(builder: (_, _baseListProvider, __) {
                          return DeerListView(
                              itemCount: _baseListProvider.list.length,
                              stateType: _baseListProvider.stateType,
                              onRefresh: _onRefresh,
                              physics: AlwaysScrollableScrollPhysics(),
                              pageSize: _baseListProvider.list.length,
                              hasMore: _baseListProvider.hasMore,
                              itemBuilder: (_, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              _baseListProvider.list[index].type,
                                              style: TextStyle(
                                                shadows: [Shadow(color: Colors.black, offset: Offset(6, 3), blurRadius: 10)],
                                                decoration: TextDecoration.underline,
                                                decorationColor: Colors.redAccent,
                                                decorationStyle: TextDecorationStyle.solid,
                                              ),
                                            ),
                                            padding: EdgeInsets.all(10),
                                          ),
                                          Container(
                                            child: GridView.builder(
                                              //将所有子控件在父控件中填满
                                              shrinkWrap: true,
                                              //解决ListView嵌套GridView滑动冲突问题
                                              physics: NeverScrollableScrollPhysics(),
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3, //每行几列
                                                  childAspectRatio: 0.69),
                                              itemCount: _baseListProvider.list[index].playlist.length,
                                              itemBuilder: (context, i) {
                                                //要返回的item样式
                                                return InkWell(
                                                  child: Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          LoadImage(
                                                            _baseListProvider.list[index].playlist[i].cover,
                                                            width: 140,
                                                            height: 200,
                                                            fit: BoxFit.cover,
                                                          ),
                                                          Positioned(
                                                              bottom: 0,
                                                              right: 0,
                                                              child: Container(
                                                                color: Colors.black45,
                                                                padding: EdgeInsets.all(5),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      _baseListProvider.list[index].playlist[i].bofang,
                                                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                                                    ),
                                                                    Gaps.hGap4,
                                                                    Text(
                                                                      _baseListProvider.list[index].playlist[i].qingxi,
                                                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                                                    )
                                                                  ],
                                                                ),
                                                              )),
                                                          Positioned(
                                                              top: 10,
                                                              left: 10,
                                                              child: Container(
                                                                color: Colors.black45,
                                                                padding: EdgeInsets.all(5),
                                                                child: Text(
                                                                  _baseListProvider.list[index].playlist[i].pingfen,
                                                                  style: TextStyle(fontSize: 14, color: Colors.white),
                                                                ),
                                                              ))
                                                        ],
                                                      ),
                                                      Gaps.vGap8,
                                                      Text(
                                                        _baseListProvider.list[index].playlist[i].title,
                                                        overflow: TextOverflow.ellipsis,
                                                      )
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    NavigatorUtils.push(context,
                                                        '${PlayerRouter.detailPage}?url=${Uri.encodeComponent(_baseListProvider.list[index].playlist[i].url)}&title=${Uri.encodeComponent(_baseListProvider.list[index].playlist[i].title)}');
                                                  },
                                                );
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        });
                      }
                      return Center(
                        child: Text("1231"),
                      );
                    }),
              ))
            ],
          )),
        ));
  }

  _onPageChange(int index) async {
    _tabController.animateTo(index);
  }
}
