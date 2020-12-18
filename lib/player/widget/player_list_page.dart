import 'dart:convert';

import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../player_router.dart';

class PlayerListPage extends StatefulWidget {
  @override
  _PlayerListPageState createState() => _PlayerListPageState();
}

class _PlayerListPageState extends State<PlayerListPage>
    with AutomaticKeepAliveClientMixin<PlayerListPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  BaseListProvider<Types> _baseListProvider = BaseListProvider();

  List<SwiperList> _list = [];
  PlayerProvider _playerProvider;

  @override
  void initState() {
    _onRefresh();
    _playerProvider = Store.value<PlayerProvider>(context);
    super.initState();
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.getHotList,
      onSuccess: (data) {
        List.generate(data["types"].length, (i) => _baseListProvider.add(Types.fromJson(data["types"][i])));
        List.generate(data["swiper"].length, (i) => _list.add(SwiperList.fromJson(data["swiper"][i])));
        _playerProvider.setSwiperList(_list);
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
    super.build(context);
    return ChangeNotifierProvider<BaseListProvider<Types>>(
        create: (_) => _baseListProvider,
        child: Consumer<BaseListProvider<Types>>(builder: (_, _baseListProvider, __) {
          return ListView.builder(
            itemCount: _baseListProvider.list.length,
            itemBuilder: (__, index) {
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
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  String jsonString = jsonEncode(_baseListProvider.list[index].playlist[i]);
                                  NavigatorUtils.push(context,
                                      '${PlayerRouter.detailPage}?playerList=${Uri.encodeComponent(jsonString)}');
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
            },
          );
        }));
  }
}
