import 'dart:convert';

import 'package:ZY_Player_flutter/model/resource_data.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/search_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class PlayerSearchPage extends StatefulWidget {
  @override
  _PlayerSearchPageState createState() => _PlayerSearchPageState();
}

class _PlayerSearchPageState extends State<PlayerSearchPage> {
  PlayerProvider _playerProvider;
  BaseListProvider<ResourceData> _baseListProvider = BaseListProvider();

  final FocusNode _focus = FocusNode();
  AppStateProvider _appStateProvider;
  int page = 1;
  String keywords = "";

  @override
  void initState() {
    _playerProvider = Store.value<PlayerProvider>(context);
    _appStateProvider = Store.value<AppStateProvider>(context);
    _baseListProvider.setStateType(StateType.empty);
    _playerProvider.setWords();
    super.initState();
  }

  Future getData() async {
    _appStateProvider.setloadingState(true);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.searchResource, queryParameters: {"keywords": keywords, "page": page},
        onSuccess: (resultList) {
      List.generate(resultList.length, (i) => _baseListProvider.add(ResourceData.fromJson(resultList[i])));
      if (resultList.length == 0) {
        _baseListProvider.setStateType(StateType.order);
      } else {
        _baseListProvider.setStateType(StateType.empty);
      }
      if (resultList.length < 10) {
        _baseListProvider.setHasMore(false);
      } else {
        _baseListProvider.setHasMore(true);
      }
      _appStateProvider.setloadingState(false);
    }, onError: (_, __) {
      _baseListProvider.setStateType(StateType.network);
      _appStateProvider.setloadingState(false);
    });
  }

  Future _onFresh() async {
    _baseListProvider.clear();
    page = 1;
    this.getData();
  }

  Future _onLoadMore() async {
    page++;
    this.getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);

    return Scaffold(
      appBar: SearchBar(
          focus: _focus,
          hintText: '请输入资源名称查询',
          isBack: true,
          onPressed: (text) {
            Toast.show('搜索内容：$text');
            if (text != null) {
              keywords = text;
              this._onFresh();
            }
          }),
      body: ChangeNotifierProvider<BaseListProvider<ResourceData>>(
          create: (_) => _baseListProvider,
          child: Consumer<BaseListProvider<ResourceData>>(builder: (_, _baseListProvider, __) {
            return DeerListView(
                itemCount: _baseListProvider.list.length,
                stateType: _baseListProvider.stateType,
                hasRefresh: false,
                loadMore: _onLoadMore,
                physics: AlwaysScrollableScrollPhysics(),
                pageSize: 10,
                hasMore: _baseListProvider.hasMore,
                itemBuilder: (_, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 60.0,
                      child: FadeInAnimation(
                          child: Card(
                              elevation: 2,
                              margin: EdgeInsets.all(10),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(10),
                                leading: LoadImage(
                                  _baseListProvider.list[index].cover,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                  _baseListProvider.list[index].title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  String jsonString = jsonEncode(_baseListProvider.list[index]);
                                  NavigatorUtils.push(context, '${PlayerRouter.detailPage}?playerList=${Uri.encodeComponent(jsonString)}');
                                },
                              ))),
                    ),
                  );
                });
          })),
    );
  }
}
