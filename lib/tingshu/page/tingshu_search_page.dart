import 'package:ZY_Player_flutter/model/category_tab_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/tingshu/tingshu_router.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/search_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class TingshuSearchPage extends StatefulWidget {
  @override
  _TingshuSearchPageState createState() => _TingshuSearchPageState();
}

class _TingshuSearchPageState extends State<TingshuSearchPage> {
  final FocusNode _focus = FocusNode();

  BaseListProvider<CategoryTabDetail> _baseListProvider = BaseListProvider();

  int page = 1;
  String keywords = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _baseListProvider.clear();
    super.dispose();
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getXmlySearch, queryParameters: {"searchword": keywords, "page": page}, onSuccess: (resultList) {
      List.generate(resultList.length, (i) => _baseListProvider.add(CategoryTabDetail.fromJson(resultList[i])));
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
    await getData();
  }

  Future _onLoadMore() async {
    page++;
    await getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(
          focus: _focus,
          isBack: true,
          hintText: '请输入听书名称查询',
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
              child: ChangeNotifierProvider<BaseListProvider<CategoryTabDetail>>(
                  create: (_) => _baseListProvider,
                  child: Consumer<BaseListProvider<CategoryTabDetail>>(builder: (_, baseListProvider, __) {
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
                                          baseListProvider.list[index].coverImg,
                                          fit: BoxFit.cover,
                                        ),
                                        subtitle: Text(
                                          baseListProvider.list[index].title ?? baseListProvider.list[index].albumName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: Text(
                                          baseListProvider.list[index].artistName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        title: Text(
                                          baseListProvider.list[index].albumName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          NavigatorUtils.push(
                                              context, '${TingshuRouter.detailPage}?url=${Uri.encodeComponent(baseListProvider.list[index].albumId.toString())}&title=${Uri.encodeComponent(baseListProvider.list[index].albumName)}&cover=${Uri.encodeComponent(baseListProvider.list[index].coverImg)}');
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
