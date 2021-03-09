import 'dart:async';
import 'dart:convert';

import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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

  @override
  void dispose() {
    super.dispose();
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
          return _baseListProvider.list.length > 0
              ? MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
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
                                    padding: EdgeInsets.only(left: 10, top: 5),
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.red,
                                      highlightColor: Colors.yellow,
                                      child: Text(
                                        _baseListProvider.list[index].type,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )),
                                Gaps.vGap8,
                                Container(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      runSpacing: 20,
                                      spacing: 20,
                                      children: List.generate(
                                          _baseListProvider.list[index].playlist.length,
                                          (i) => InkWell(
                                                child: Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        LoadImage(
                                                          _baseListProvider.list[index].playlist[i].cover,
                                                          width: 100,
                                                          height: 150,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        Positioned(
                                                            bottom: 0,
                                                            right: 0,
                                                            child: Container(
                                                              color: Colors.black45,
                                                              padding: EdgeInsets.all(2),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    _baseListProvider.list[index].playlist[i].bofang,
                                                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                                                  ),
                                                                  Gaps.hGap4,
                                                                  Text(
                                                                    _baseListProvider.list[index].playlist[i].qingxi,
                                                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                                                  )
                                                                ],
                                                              ),
                                                            )),
                                                        Positioned(
                                                            top: 10,
                                                            left: 10,
                                                            child: Container(
                                                              padding: EdgeInsets.all(5),
                                                              decoration: BoxDecoration(
                                                                  color: Colors.black45,
                                                                  borderRadius: BorderRadius.all(Radius.circular(5))),
                                                              child: Text(
                                                                _baseListProvider.list[index].playlist[i].pingfen,
                                                                style: TextStyle(fontSize: 12, color: Colors.white),
                                                              ),
                                                            ))
                                                      ],
                                                    ),
                                                    Gaps.vGap8,
                                                    Container(
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        _baseListProvider.list[index].playlist[i].title,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      width: 100,
                                                    )
                                                  ],
                                                ),
                                                onTap: () {
                                                  String jsonString =
                                                      jsonEncode(_baseListProvider.list[index].playlist[i]);

                                                  NavigatorUtils.push(context,
                                                      '${PlayerRouter.detailPage}?playerList=${Uri.encodeComponent(jsonString)}');
                                                },
                                              )).toList(),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ))
              : StateLayout(
                  type: _baseListProvider.stateType,
                  onRefresh: _onRefresh,
                );
        }));
  }
}
