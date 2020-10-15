import 'dart:async';
import 'dart:convert';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_catlog.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_resource.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:ZY_Player_flutter/xiaoshuo/provider/xiaoshuo_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class XiaoShuoDetailPage extends StatefulWidget {
  const XiaoShuoDetailPage({
    Key key,
    @required this.xiaoshuoResource,
  }) : super(key: key);

  final String xiaoshuoResource;

  @override
  _XiaoShuoDetailPageState createState() => _XiaoShuoDetailPageState();
}

class _XiaoShuoDetailPageState extends State<XiaoShuoDetailPage> {
  bool startedPlaying = false;

  BaseListProvider<XiaoshuoCatlog> _baseListProvider = BaseListProvider();
  XiaoShuoProvider _xiaoShuoProvider;
  CollectProvider _collectProvider;

  XiaoshuoResource _xiaoshuoResource;

  @override
  void initState() {
    super.initState();
    _xiaoshuoResource = jsonDecode(widget.xiaoshuoResource);
    _xiaoShuoProvider = Store.value<XiaoShuoProvider>(context);
    _collectProvider = Store.value<CollectProvider>(context);
    _collectProvider.setListDetailResource("collcetPlayer");
    _onRefresh();
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.searchXiaoshuozj,
      queryParameters: {"url": _xiaoshuoResource.url},
      onSuccess: (data) {
        List.generate(data.length, (i) => _baseListProvider.list.add(XiaoshuoCatlog.fromJson(data[i])));
        _xiaoShuoProvider.setAllZj(_baseListProvider.list);
        _baseListProvider.setHasMore(false);
        _baseListProvider.setStateType(StateType.empty);
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
  void dispose() {
    super.dispose();
  }

  bool getFilterData(XiaoshuoResource data) {
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
          _xiaoshuoResource.title,
        ),
        actions: <Widget>[
          Consumer<CollectProvider>(builder: (_, provider, __) {
            return IconButton(
                icon: getFilterData(_xiaoshuoResource)
                    ? Icon(
                        Icons.turned_in,
                        color: Colors.red,
                      )
                    : Icon(
                        Icons.turned_in_not,
                        color: Colors.red,
                      ),
                onPressed: () {
                  if (getFilterData(_xiaoshuoResource)) {
                    Log.d("点击取消");
                    provider.removeXiaoshuoResource(_xiaoshuoResource.url);
                  } else {
                    Log.d("点击收藏");
                    provider.addXiaoshuoResource(_xiaoshuoResource);
                  }
                });
          })
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: LoadImage(
                    _xiaoshuoResource.cover,
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${_xiaoshuoResource.title}"),
                    Text("作者：${_xiaoshuoResource.author}"),
                    Container(
                      width: 180,
                      child: Text(
                        "简介：${_xiaoshuoResource.jianjie}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 8,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          SliverFillRemaining(
              child: ChangeNotifierProvider<BaseListProvider<XiaoshuoCatlog>>(
                  create: (_) => _baseListProvider,
                  child: Consumer<BaseListProvider<XiaoshuoCatlog>>(builder: (_, _baseListProvider, __) {
                    return DeerListView(
                        itemCount: _baseListProvider.list.length,
                        stateType: _baseListProvider.stateType,
                        onRefresh: _onRefresh,
                        pageSize: _baseListProvider.list.length,
                        hasMore: _baseListProvider.hasMore,
                        itemBuilder: (_, index) {
                          return ListTile(
                            title: Text(_baseListProvider.list[index].title),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              _xiaoShuoProvider.setCurrentZj(_baseListProvider.list[index], index);
                            },
                          );
                        });
                  })))
        ],
      ),
    );
  }
}
