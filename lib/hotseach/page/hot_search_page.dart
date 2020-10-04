import 'package:ZY_Player_flutter/hotseach/provider/hot_search_provider.dart';
import 'package:ZY_Player_flutter/model/hot_search.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/search_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HotSearchPage extends StatefulWidget {
  @override
  _HotSearchPageState createState() => _HotSearchPageState();
}

class _HotSearchPageState extends State<HotSearchPage> with AutomaticKeepAliveClientMixin<HotSearchPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  HotSearchProvider _hotSearchProvider = HotSearchProvider();
  BaseListProvider<HotSearch> _baseListProvider = BaseListProvider();

  int currentPage = 1;
  String searchText = '抖音';

  @override
  void initState() {
    super.initState();
    _hotSearchProvider.setWords();
  }

  Future getData(String keywords) async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.hotSearch,
      queryParameters: {"keywords": keywords, "page": currentPage},
      onSuccess: (data) {
        List.generate(data.length, (i) => _baseListProvider.list.add(HotSearch.fromJson(data[i])));
        _baseListProvider.setStateType(StateType.empty);
        _baseListProvider.setHasMore(false);
      },
      onError: (code, msg) {
        _baseListProvider.setStateType(StateType.network);
      },
    );
  }

  Future _onRefresh() async {
    currentPage = 1;
    _baseListProvider.clear();
    // 默认搜索抖音
    this.getData(searchText);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isDark = ThemeUtils.isDark(context);

    return ChangeNotifierProvider<HotSearchProvider>(
        create: (_) => _hotSearchProvider,
        child: Scaffold(
          appBar: SearchBar(
              hintText: '请输入热搜内容',
              onPressed: (text) {
                Toast.show('搜索内容：$text');
                if (text != null) {
                  _hotSearchProvider.addWors(text);
                  searchText = text;
                  this._onRefresh();
                }
              }),
          body: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Consumer<HotSearchProvider>(builder: (_, provider, __) {
                  return provider.words.length > 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Text("历史搜索"),
                                ),
                                IconButton(
                                    icon: Icon(
                                      Icons.delete_forever,
                                      color: isDark ? Colours.dark_red : Colours.dark_bg_gray,
                                    ),
                                    onPressed: () {
                                      Log.d("删除搜索");
                                      _hotSearchProvider.clearWords();
                                    })
                              ],
                            ),
                            Selector<HotSearchProvider, List>(
                                builder: (_, words, __) {
                                  return Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Wrap(
                                        spacing: 10,
                                        runSpacing: 5,
                                        children: words.map<Widget>((s) {
                                          return InkWell(
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: isDark ? Colours.dark_material_bg : Colours.bg_gray,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text('$s'),
                                            ),
                                            onTap: () {
                                              //搜索关键词
                                              Toast.show('搜索内容：$s');
                                              searchText = s;
                                              this._onRefresh();
                                            },
                                          );
                                        }).toList()),
                                  );
                                },
                                selector: (_, store) => store.words)
                          ],
                        )
                      : Container();
                }),
                Expanded(
                    child: ChangeNotifierProvider<BaseListProvider<HotSearch>>(
                        create: (_) => _baseListProvider,
                        child: Consumer<BaseListProvider<HotSearch>>(builder: (_, _baseListProvider, __) {
                          return DeerListView(
                              itemCount: _baseListProvider.list.length,
                              stateType: _baseListProvider.stateType,
                              onRefresh: _onRefresh,
                              pageSize: _baseListProvider.list.length,
                              hasMore: _baseListProvider.hasMore,
                              itemBuilder: (_, index) {
                                return ListTile(
                                  title: Text(_baseListProvider.list[index].title),
                                  subtitle: Text(_baseListProvider.list[index].shuming),
                                  trailing: Text(_baseListProvider.list[index].updatetime),
                                  leading: LoadImage(
                                    _baseListProvider.list[index].cover,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  onTap: () {
                                    Log.d('前往详情页');
                                    NavigatorUtils.goWebViewPage(context, _baseListProvider.list[index].title, _baseListProvider.list[index].url,
                                        flag: "2");
                                  },
                                );
                              });
                        })))
              ],
            ),
          ),
        ));
  }
}
