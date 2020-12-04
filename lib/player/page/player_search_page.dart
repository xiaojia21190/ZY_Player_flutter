import 'package:ZY_Player_flutter/model/resource_data.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/search_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerSearchPage extends StatefulWidget {
  @override
  _PlayerSearchPageState createState() => _PlayerSearchPageState();
}

class _PlayerSearchPageState extends State<PlayerSearchPage> {
  PlayerProvider _playerProvider;

  final FocusNode _focus = FocusNode();
  AppStateProvider _appStateProvider;

  @override
  void initState() {
    _playerProvider = Store.value<PlayerProvider>(context);
    _appStateProvider = Store.value<AppStateProvider>(context);

    _playerProvider.setWords();
    super.initState();
  }

  Future getData(String keywords) async {
    if (_playerProvider.stateType == StateType.loading) {
      Toast.show("正在搜索内容，请稍后");
      return;
    }
    _playerProvider.list.clear();
    // _playerProvider.setStateType(StateType.loading);
    _appStateProvider.setloadingState(true);

    await DioUtils.instance.requestNetwork(Method.get, HttpApi.searchResource, queryParameters: {"keywords": keywords, "key": "zuidazy", "page": 1},
        onSuccess: (resultList) {
      List.generate(resultList.length, (i) => _playerProvider.list.add(ResourceData.fromJson(resultList[i])));
      if (resultList.length == 0) {
        _playerProvider.setStateType(StateType.order);
      } else {
        _playerProvider.setStateType(StateType.empty);
      }
      _appStateProvider.setloadingState(false);
    }, onError: (_, __) {
      _playerProvider.setStateType(StateType.network);
      _appStateProvider.setloadingState(false);
    });
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
              _playerProvider.addWors(text);
              this.getData(text);
            }
          }),
      body: Container(
        child: Column(
          children: <Widget>[
            Consumer<PlayerProvider>(builder: (_, provider, __) {
              return provider.words.length > 0
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text("历史搜索"),
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: isDark ? Colours.dark_red : Colours.dark_bg_gray,
                                ),
                                onPressed: () {
                                  Log.d("删除搜索");
                                  _playerProvider.clearWords();
                                })
                          ],
                        ),
                        Selector<PlayerProvider, List>(
                            builder: (_, words, __) {
                              var startLen = words.length - 5 > 0 ? words.length - 5 : 0;
                              var endLen = words.length;
                              return Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Wrap(
                                    spacing: 10,
                                    runSpacing: 5,
                                    children: words
                                        .map<Widget>((s) {
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
                                              _focus.unfocus();
                                              this.getData(s);
                                            },
                                          );
                                        })
                                        .toList()
                                        .sublist(startLen, endLen)),
                              );
                            },
                            selector: (_, store) => store.words)
                      ],
                    )
                  : Container();
            }),
            Expanded(child: Consumer<PlayerProvider>(builder: (_, provider, __) {
              return provider.list.length > 0
                  ? GridView.builder(
                      //将所有子控件在父控件中填满
                      shrinkWrap: true,
                      //解决ListView嵌套GridView滑动冲突问题
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, //每行几列
                          childAspectRatio: 0.6),
                      itemCount: provider.list.length,
                      itemBuilder: (context, i) {
                        //要返回的item样式
                        return GestureDetector(
                          child: Column(
                            children: [
                              LoadImage(
                                provider.list[i].cover,
                                width: 110,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                height: 50,
                                child: Text(
                                  provider.list[i].title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                          onTap: () {
                            NavigatorUtils.push(context,
                                '${PlayerRouter.detailPage}?url=${Uri.encodeComponent(provider.list[i].url)}&title=${Uri.encodeComponent(provider.list[i].title)}');
                          },
                        );
                      },
                    )
                  : Center(
                      child: StateLayout(type: provider.stateType),
                    );
            }))
          ],
        ),
      ),
    );
  }
}
