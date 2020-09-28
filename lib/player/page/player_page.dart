import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/persistent_header_delegate.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage({Key key}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  BaseListProvider<PlayerHot> _baseListProvider = BaseListProvider();

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.getHotList,
      onSuccess: (data) {
        List.generate(data.length, (i) => _baseListProvider.list.add(PlayerHot.fromJson(data[i])));
        if (data.length == 0) {
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
              child: GestureDetector(
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Center(
                      child: Text("点击搜索影片",
                          style: TextStyle(
                            shadows: [Shadow(color: Colors.redAccent, offset: Offset(6, 3), blurRadius: 10)],
                          )),
                    ),
                  ),
                  onTap: () => NavigatorUtils.push(context, PlayerRouter.searchPage)),
            ),
          ),
          SliverFillRemaining(
            child: ChangeNotifierProvider<BaseListProvider<PlayerHot>>(
                create: (_) => _baseListProvider,
                child: Consumer<BaseListProvider<PlayerHot>>(builder: (_, _baseListProvider, __) {
                  return DeerListView(
                      itemCount: _baseListProvider.list.length,
                      stateType: _baseListProvider.stateType,
                      onRefresh: _onRefresh,
                      pageSize: _baseListProvider.list.length,
                      hasMore: _baseListProvider.hasMore,
                      itemBuilder: (_, index) {
                        return Column(
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
                              height: ScreenUtil.getInstance().getWidth(380),
                              child: GridView.builder(
                                //将所有子控件在父控件中填满
                                shrinkWrap: true,
                                //解决ListView嵌套GridView滑动冲突问题
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, //每行几列
                                    childAspectRatio: 0.6),
                                itemCount: _baseListProvider.list[index].playlist.length,
                                itemBuilder: (context, i) {
                                  //要返回的item样式
                                  return GestureDetector(
                                    child: Column(
                                      children: [
                                        LoadImage(
                                          _baseListProvider.list[index].playlist[i].cover,
                                          width: 110,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                        Container(
                                          height: 50,
                                          child: Text(
                                            _baseListProvider.list[index].playlist[i].title,
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                        );
                      });
                })),
          )
        ],
      )),
    );
  }
}
