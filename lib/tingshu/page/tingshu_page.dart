import 'package:ZY_Player_flutter/model/category_tab.dart';
import 'package:ZY_Player_flutter/model/category_tab_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/tingshu/provider/tingshu_provider.dart';
import 'package:ZY_Player_flutter/tingshu/tingshu_router.dart';
import 'package:ZY_Player_flutter/util/persistent_header_delegate.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/widgets/bubble_tab_indicator.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class TingShuPage extends StatefulWidget {
  TingShuPage({Key? key}) : super(key: key);

  @override
  _TingShuPageState createState() => _TingShuPageState();
}

class _TingShuPageState extends State<TingShuPage> with AutomaticKeepAliveClientMixin<TingShuPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  List<CategoryTabDetail> _tabDetails = [];
  late TingShuProvider tingShuProvider;

  TabController? _tabControllerColl;
  PageController? _pageController = PageController();

  List<CategoryTab> _tabs = [];
  String currentUrl = "";
  int page = 1;

  StateType _stateType = StateType.loading;
  @override
  void initState() {
    super.initState();
    tingShuProvider = Store.value<TingShuProvider>(context);
    getData();
  }

  Future getData() async {
    // _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.getXmlyHot,
      onSuccess: (data) async {
        _tabControllerColl = TabController(length: data.length, vsync: this);
        List.generate(data.length, (index) => _tabs.add(CategoryTab.fromJson(data[index])));
        tingShuProvider.setTab(_tabs);
        await getDetailData(_tabs[0].url);
      },
      onError: (code, msg) {
        debugPrint('code:$code,msg:$msg');
      },
    );
  }

  Future getDetailData(String url) async {
    currentUrl = url;
    _stateType = StateType.loading;
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.getXmlyHotDetail,
      queryParameters: {
        "url": Uri.decodeComponent(url),
        "pn": page,
      },
      onSuccess: (data) {
        List.generate(data.length, (index) => _tabDetails.add(CategoryTabDetail.fromJson(data[index])));
        if (data.length == 0) {
          _stateType = StateType.network;
        } else {
          _stateType = StateType.empty;
        }
        setState(() {});
      },
      onError: (code, msg) {
        _stateType = StateType.network;
      },
    );
  }

  Future _onLoadMore() async {
    page++;
    await getDetailData(currentUrl);
  }

  Future _onRefresh() async {
    _tabDetails.clear();
    await getDetailData(currentUrl);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isDark = ThemeUtils.isDark(context);
    return Scaffold(
      body: SafeArea(
          child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            // 属性同 SliverAppBar
            pinned: true,
            floating: true,
            // 因为 SliverPersistentHeaderDelegate 是一个抽象类，所以需要自定义
            delegate: CustomSliverPersistentHeaderDelegate(
                max: 50.0,
                min: 0.0,
                child: Selector<TingShuProvider, List<CategoryTab>>(
                    builder: (_, tab, __) {
                      return tab.length > 0
                          ? TabBar(
                              controller: _tabControllerColl,
                              isScrollable: true,
                              labelPadding: EdgeInsets.all(12.0),
                              indicatorSize: TabBarIndicatorSize.label,
                              labelColor: Colours.white,
                              unselectedLabelColor: isDark ? Colors.white : Colors.black,
                              indicator: BubbleTabIndicator(),
                              tabs: tab.map((e) => Text(e.type)).toList(),
                              onTap: (index) async {
                                if (!mounted) {
                                  return;
                                }
                                // tabIndex
                                _pageController?.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);

                                _tabDetails.clear();
                                await getDetailData(tab[index].url);
                              },
                            )
                          : Container();
                    },
                    selector: (_, store) => store.tabs)),
          ),
          SliverFillRemaining(
              child: PageView.builder(
                  key: const Key('pageView'),
                  itemCount: _tabs.length,
                  onPageChanged: (index) async {
                    _tabDetails.clear();
                    _tabControllerColl?.animateTo(index, duration: Duration(milliseconds: 300));
                    await getDetailData(_tabs[index].url);
                  },
                  controller: _pageController,
                  itemBuilder: (_, pageIndex) {
                    return DeerListView(
                      itemCount: _tabDetails.length,
                      stateType: _stateType,
                      onRefresh: _onRefresh,
                      hasRefresh: true,
                      loadMore: _onLoadMore,
                      pageSize: _tabDetails.length,
                      hasMore: true,
                      itemBuilder: (_, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                                child: Card(
                                    elevation: 5.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        side: BorderSide(
                                          style: BorderStyle.solid,
                                          color: Colours.yellow,
                                        )),
                                    margin: EdgeInsets.all(5),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(5),
                                      leading: LoadImage(
                                        _tabDetails[index].coverImg,
                                        fit: BoxFit.cover,
                                      ),
                                      subtitle: Text(
                                        _tabDetails[index].title ?? _tabDetails[index].albumName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Text(
                                        _tabDetails[index].artistName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      title: Text(
                                        _tabDetails[index].albumName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () {
                                        NavigatorUtils.push(context, '${TingshuRouter.detailPage}?url=${Uri.encodeComponent(_tabDetails[index].albumId.toString())}&title=${Uri.encodeComponent(_tabDetails[index].albumName)}&cover=${Uri.encodeComponent(_tabDetails[index].coverImg)}');
                                      },
                                    ))),
                          ),
                        );
                      },
                      physics: AlwaysScrollableScrollPhysics(),
                    );
                  }))
        ],
      )),
    );
  }
}
