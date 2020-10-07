import 'package:ZY_Player_flutter/hotseach/hot_router.dart';
import 'package:ZY_Player_flutter/model/hot_home.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/persistent_header_delegate.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HotPage extends StatefulWidget {
  HotPage({Key key}) : super(key: key);

  @override
  _HotPageState createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> with AutomaticKeepAliveClientMixin<HotPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  BaseListProvider<HotHome> _baseListProvider = BaseListProvider();

  @override
  void initState() {
    _onRefresh();
    super.initState();
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.HomeHot,
      onSuccess: (data) {
        List.generate(data.length, (i) => _baseListProvider.list.add(HotHome.fromJson(data[i])));
        _baseListProvider.setStateType(StateType.empty);
        if (data.length == 0) {
          _baseListProvider.setStateType(StateType.network);
        } else {
          _baseListProvider.setStateType(StateType.empty);
        }
        _baseListProvider.setHasMore(false);
      },
      onError: (code, msg) {
        _baseListProvider.setStateType(StateType.network);
      },
    );
  }

  Future _onRefresh() async {
    _baseListProvider.clear();
    // 默认搜索抖音
    this.getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Color(0xF7F8FA),
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
              child: GestureDetector(
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Center(
                      child: Text("点击搜索内容",
                          style: TextStyle(
                            shadows: [Shadow(color: Colors.redAccent, offset: Offset(6, 3), blurRadius: 10)],
                          )),
                    ),
                  ),
                  onTap: () => NavigatorUtils.push(context, HotRouter.searchPage)),
            ),
          ),
          SliverFillRemaining(
            child: ChangeNotifierProvider<BaseListProvider<HotHome>>(
                create: (_) => _baseListProvider,
                child: Consumer<BaseListProvider<HotHome>>(builder: (_, _baseListProvider, __) {
                  return DeerListView(
                      itemCount: _baseListProvider.list.length,
                      stateType: _baseListProvider.stateType,
                      onRefresh: _onRefresh,
                      pageSize: _baseListProvider.list.length,
                      hasMore: _baseListProvider.hasMore,
                      itemBuilder: (_, i) {
                        return Card(
                          color: Colors.deepOrange,
                          elevation: 10,
                          shadowColor: Colors.blueGrey[100],
                          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          child: Container(
                            height: ScreenUtil.getInstance().getWidth(500),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          LoadImage(
                                            _baseListProvider.list[i].zongheicon,
                                            width: 25,
                                            height: 25,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              _baseListProvider.list[i].zonghetitle,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  shadows: [Shadow(color: Colors.redAccent, offset: Offset(6, 3), blurRadius: 10)]),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _baseListProvider.list[i].update,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: ListView.builder(
                                        physics: ClampingScrollPhysics(),
                                        itemCount: _baseListProvider.list[i].contentList.length,
                                        itemBuilder: (_, index) {
                                          return ListTile(
                                            title: Text(
                                              _baseListProvider.list[i].contentList[index].title,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            subtitle: Text(
                                              _baseListProvider.list[i].contentList[index].redu,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            trailing: Icon(
                                              Icons.keyboard_arrow_right,
                                              color: Colors.white,
                                            ),
                                            onTap: () {
                                              NavigatorUtils.goWebViewPage(context, _baseListProvider.list[i].contentList[index].title,
                                                  _baseListProvider.list[i].contentList[index].url,
                                                  flag: "2");
                                            },
                                          );
                                        })),
                              ],
                            ),
                          ),
                        );
                      });
                })),
          )
        ],
      )),
    );
  }
}
