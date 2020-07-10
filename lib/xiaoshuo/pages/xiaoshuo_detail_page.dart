import 'dart:async';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_catlog.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_reource.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/provider/detail_provider.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_button.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/detail_reource.dart';

class XiaoShuoDetailPage extends StatefulWidget {
  const XiaoShuoDetailPage({
    Key key,
    @required this.xiaoshuoReource,
  }) : super(key: key);

  final XiaoshuoReource xiaoshuoReource;

  @override
  _XiaoShuoDetailPageState createState() => _XiaoShuoDetailPageState();
}

class _XiaoShuoDetailPageState extends State<XiaoShuoDetailPage> {
  bool startedPlaying = false;

  BaseListProvider<Rows> _baseListProvider = BaseListProvider();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<CollectProvider>().setListDetailResource("collcetPlayer");
    _onRefresh();
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.imageManhua,
      queryParameters: {
        "url":
            'https://bookshelf.html5.qq.com/api/migration/list_charpter?resourceid=${widget.xiaoshuoReource.resourceId}&start=$currentPage&serialnum=2810&sort=asc&t=202007101626'
      },
      options: Options(headers: {"Referer": 'https://bookshelf.html5.qq.com/?t=native&ch=004645'}),
      onSuccess: (data) {
        _baseListProvider.add(Rows.fromJson(data["rows"]));
        if (data["pageNo"] == data["pageCount"]) {
          _baseListProvider.setHasMore(false);
        } else {
          _baseListProvider.setHasMore(true);
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

  Future _loadMore() async {
    currentPage++;
    this.getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool getFilterData(XiaoshuoReource data) {
    if (data != null) {
      var result = context.read<CollectProvider>().xiaoshuo.where((element) => element.url == data.url);
      return result.length > 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colours.app_main,
        title: Text(
          widget.xiaoshuoReource.title,
        ),
        actions: <Widget>[
          Consumer<CollectProvider>(builder: (_, provider, __) {
            return IconButton(
                icon: getFilterData(widget.xiaoshuoReource)
                    ? Icon(
                        Icons.turned_in,
                        color: Colors.red,
                      )
                    : Icon(
                        Icons.turned_in_not,
                        color: Colors.red,
                      ),
                onPressed: () {
                  if (getFilterData(widget.xiaoshuoReource)) {
                    Log.d("点击取消");
                    provider.removeXiaoshuoResource(widget.xiaoshuoReource.url);
                  } else {
                    Log.d("点击收藏");
                    provider.addXiaoshuoResource(widget.xiaoshuoReource);
                  }
                });
          })
        ],
      ),
      body: Consumer<DetailProvider>(builder: (_, provider, __) {
        return provider.detailReource != null
            ? CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Card(
                      shadowColor: Colors.blueAccent,
                      elevation: 2,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: ScreenUtil.getInstance().getWidth(310),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: LoadImage(
                                provider.detailReource.cover,
                                width: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    provider.detailReource.title,
                                    maxLines: 2,
                                  ),
                                  Text(
                                    provider.detailReource.qingxi,
                                    maxLines: 2,
                                    style: TextStyle(color: Colours.text_gray, fontSize: 12),
                                  ),
                                  Text(provider.detailReource.daoyan),
                                  Text(
                                    provider.detailReource.zhuyan,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(provider.detailReource.leixing),
                                  Text(provider.detailReource.diqu),
                                  Text(provider.detailReource.yuyan),
                                  Text(provider.detailReource.shangying),
                                  Text(provider.detailReource.pianchang != null
                                      ? '${provider.detailReource.pianchang}分钟'
                                      : ""),
                                  MyButton(
                                    onPressed: () {
                                      NavigatorUtils.goWebViewPage(
                                          context, provider.detailReource.title, provider.detailReource.videoList[0]);
                                    },
                                    text: "播放",
                                    fontSize: Dimens.font_sp16,
                                  )
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Card(
                      shadowColor: Colors.blueAccent,
                      elevation: 2,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[Text("剧情介绍"), Gaps.vGap10, Text(provider.detailReource.content)],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: provider.detailReource.videoList.length > 1
                        ? Card(
                            shadowColor: Colors.blueAccent,
                            elevation: 2,
                            child: Container(
                              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Text(
                                      "剧集选择",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  ChangeNotifierProvider<BaseListProvider<Rows>>(
                                      create: (_) => _baseListProvider,
                                      child: Consumer<BaseListProvider<Rows>>(builder: (_, _baseListProvider, __) {
                                        return DeerListView(
                                            itemCount: _baseListProvider.list.length,
                                            stateType: _baseListProvider.stateType,
                                            onRefresh: _onRefresh,
                                            loadMore: _loadMore,
                                            pageSize: _baseListProvider.list.length,
                                            hasMore: _baseListProvider.hasMore,
                                            itemBuilder: (_, index) {
                                              return ListTile(
                                                title: Text(_baseListProvider.list[index].serialname),
                                                trailing: Icon(Icons.keyboard_arrow_right),
                                                onTap: () {
                                                  NavigatorUtils.goWebViewPage(
                                                      context,
                                                      _baseListProvider.list[index].serialname,
                                                      'https://bookshelf.html5.qq.com/?t=web&ch=004645#!/detail/${_baseListProvider.list[index].resourceid}/${_baseListProvider.list[index].serialid}/wenxue_content?bookid=${_baseListProvider.list[index].resourceid}&uuid=${_baseListProvider.list[index].serialid}');
                                                },
                                              );
                                            });
                                      }))
                                ],
                              ),
                            ))
                        : Container(),
                  )
                ],
              )
            : StateLayout(type: StateType.loading);
      }),
    );
  }
}
