import 'dart:async';
import 'dart:convert';

import 'package:ZY_Player_flutter/model/player_hot.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../player_router.dart';

class PlayerMorePage extends StatefulWidget {
  const PlayerMorePage({
    Key? key,
    required this.type,
  }) : super(key: key);

  final String type;

  @override
  _PlayerMorePageState createState() => _PlayerMorePageState();
}

class _PlayerMorePageState extends State<PlayerMorePage> with AutomaticKeepAliveClientMixin<PlayerMorePage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  BaseListProvider<Playlist> _baseListProvider = BaseListProvider();

  int groupValue = 0;
  int page = 1;
  String typeStr = "";

  bool _isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    _onRefresh();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getData() async {
    if (widget.type == "mv") {
      typeStr = "电影厅";
    } else if (widget.type == "tv") {
      typeStr = "电视剧";
    } else {
      typeStr = "动漫";
    }
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.piankuMoreData,
      queryParameters: {"type": widget.type, "status": groupValue, "page": page},
      onSuccess: (data) {
        List.generate(data.length, (i) => _baseListProvider.add(Playlist.fromJson(data[i])));
        if (data.length < 42) {
          hasMore = false;
        }
        setState(() {
          _isLoading = false;
        });
      },
      onError: (code, msg) {
        _baseListProvider.setStateType(StateType.network);
        _isLoading = false;
      },
    );
  }

  Future _onRefresh() async {
    _baseListProvider.clear();
    this.getData();
  }

  Future _loadMore() async {
    if (_isLoading) return;
    if (!hasMore) return;
    _isLoading = true;
    page++;
    await getData();
  }

  Future updateGroupValue(int? e) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      page = 1;
      groupValue = e!;
    });
    await _onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider<BaseListProvider<Playlist>>(
        create: (_) => _baseListProvider,
        child: Scaffold(
          appBar: MyAppBar(
            isBack: true,
            centerTitle: typeStr,
          ),
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [Radio(value: 0, groupValue: groupValue, onChanged: _isLoading ? null : updateGroupValue), Text("最近更新")],
                  ),
                  Row(
                    children: [Radio(value: 1, groupValue: groupValue, onChanged: _isLoading ? null : updateGroupValue), Text("加入时间")],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [Radio(value: 2, groupValue: groupValue, onChanged: _isLoading ? null : updateGroupValue), Text("评分最高")],
                  ),
                  Row(
                    children: [Radio(value: 3, groupValue: groupValue, onChanged: _isLoading ? null : updateGroupValue), Text("评分人数")],
                  ),
                ],
              ),
              Expanded(
                  child: NotificationListener(
                onNotification: (ScrollEndNotification note) {
                  /// 确保是垂直方向滚动，且滑动至底部
                  if (note.metrics.pixels == note.metrics.maxScrollExtent && note.metrics.axis == Axis.vertical) {
                    _loadMore();
                  }

                  return false;
                },
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.all(10),
                        sliver: SliverToBoxAdapter(
                          child: Consumer<BaseListProvider<Playlist>>(builder: (_, _baseListProvider, __) {
                            return _baseListProvider.list.length > 0
                                ? MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: Column(
                                      children: [
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          runSpacing: 20,
                                          spacing: 20,
                                          children: List.generate(
                                              _baseListProvider.list.length,
                                              (i) => InkWell(
                                                    child: Column(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            LoadImage(
                                                              _baseListProvider.list[i].cover,
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
                                                                        _baseListProvider.list[i].bofang,
                                                                        style: TextStyle(fontSize: 12, color: Colors.white),
                                                                      ),
                                                                      Gaps.hGap4,
                                                                      Text(
                                                                        _baseListProvider.list[i].qingxi,
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
                                                                      color: Colors.black45, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                                  child: Text(
                                                                    _baseListProvider.list[i].pingfen,
                                                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                                                  ),
                                                                ))
                                                          ],
                                                        ),
                                                        Gaps.vGap8,
                                                        Container(
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            _baseListProvider.list[i].title,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          width: 100,
                                                        )
                                                      ],
                                                    ),
                                                    onTap: () {
                                                      String jsonString = jsonEncode(_baseListProvider.list[i]);

                                                      NavigatorUtils.push(
                                                          context, '${PlayerRouter.detailPage}?playerList=${Uri.encodeComponent(jsonString)}');
                                                    },
                                                  )).toList(),
                                        ),
                                        MoreWidget(_baseListProvider.list.length, hasMore, 42)
                                      ],
                                    ))
                                : StateLayout(
                                    type: _baseListProvider.stateType,
                                    onRefresh: _onRefresh,
                                  );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
            ],
          ),
        ));
  }
}
