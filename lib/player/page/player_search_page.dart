import 'dart:convert';

import 'package:ZY_Player_flutter/model/resource_data.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
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
  PlayerProvider? _playerProvider;
  BaseListProvider<ResourceData> _baseListProvider = BaseListProvider();

  final FocusNode _focus = FocusNode();
  int page = 1;
  String keywords = "";

  @override
  void initState() {
    _playerProvider = Store.value<PlayerProvider>(context);
    _baseListProvider.setStateType(StateType.empty);
    _playerProvider!.setWords();
    super.initState();
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.searchResource, queryParameters: {"keywords": keywords, "page": page}, onSuccess: (resultList) {
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
    }, onError: (_, __) {
      _baseListProvider.setStateType(StateType.network);
    });
  }

  Future _onFresh() async {
    _baseListProvider.clear();
    page = 1;
    getData();
  }

  Future _onLoadMore() async {
    page++;
    getData();
  }

  @override
  void dispose() {
    _baseListProvider.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(
          focus: _focus,
          hintText: '请输入资源名称查询',
          isBack: true,
          onPressed: (text) {
            Toast.show('搜索内容：$text');
            if (text != "") {
              keywords = text;
              _onFresh();
            }
          }),
      body: Column(
        children: [
          Expanded(
              child: ChangeNotifierProvider<BaseListProvider<ResourceData>>(
                  create: (_) => _baseListProvider,
                  child: Consumer<BaseListProvider<ResourceData>>(builder: (_, baseListProvider, __) {
                    return DeerListView(
                        itemCount: baseListProvider.list.length,
                        stateType: baseListProvider.stateType,
                        hasRefresh: false,
                        onRefresh: _onFresh,
                        loadMore: _onLoadMore,
                        physics: const AlwaysScrollableScrollPhysics(),
                        pageSize: 10,
                        hasMore: baseListProvider.hasMore,
                        itemBuilder: (_, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 60.0,
                              child: FadeInAnimation(
                                  child: Card(
                                      elevation: 5,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          side: BorderSide(
                                            style: BorderStyle.solid,
                                            color: Colours.orange,
                                          )),
                                      margin: const EdgeInsets.all(10),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(10),
                                        leading: LoadImage(
                                          baseListProvider.list[index].cover,
                                          fit: BoxFit.cover,
                                        ),
                                        title: Text(
                                          baseListProvider.list[index].title,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          String jsonString = jsonEncode(baseListProvider.list[index]);
                                          NavigatorUtils.push(context, '${PlayerRouter.detailPage}?playerList=${Uri.encodeComponent(jsonString)}');
                                        },
                                      ))),
                            ),
                          );
                        });
                  })))
        ],
      ),
    );
  }
}
