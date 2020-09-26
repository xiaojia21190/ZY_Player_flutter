import 'dart:async';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_catlog.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_reource.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/app_bar.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  BaseListProvider<XiaoshuoCatlog> _baseListProvider = BaseListProvider();
  String currentValue = "0";

  List<XiaoshuoCatlog> nzjUrl = [];
  List<XiaoshuoCatlog> fyzjUrl = [];
  CollectProvider _collectProvider;

  String actionName = "";

  @override
  void initState() {
    super.initState();
    _collectProvider = context.read<CollectProvider>();
    _collectProvider.setListDetailResource("collcetXiaoshuo");
    getFirstData();
  }

  Future getFirstData() async {
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.searchXiaoshuozj,
      queryParameters: {"url": widget.xiaoshuoReource.url},
      onSuccess: (data) {
        List.generate(data["nzjUrl"].length, (i) => nzjUrl.add(XiaoshuoCatlog.fromJson(data["nzjUrl"][i])));
        List.generate(data["fyzjUrl"].length, (i) => fyzjUrl.add(XiaoshuoCatlog.fromJson(data["fyzjUrl"][i])));
        _onRefresh();
        if (getFilterData(widget.xiaoshuoReource)) {
          actionName = "点击取消";
        } else {
          actionName = "点击收藏";
        }
      },
      onError: (code, msg) {},
    );
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.getSearchXszjDetail,
      queryParameters: {"url": fyzjUrl[int.parse(currentValue)].url},
      onSuccess: (data) {
        List.generate(data.length, (i) => _baseListProvider.list.add(XiaoshuoCatlog.fromJson(data[i])));
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

  bool getFilterData(XiaoshuoReource data) {
    if (data != null) {
      var result = context.read<CollectProvider>().xiaoshuo.where((element) => element.url == data.url).toList();
      return result.length > 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
          centerTitle: widget.xiaoshuoReource.title,
          actionName: actionName,
          onPressed: () {
            if (getFilterData(widget.xiaoshuoReource)) {
              Log.d("点击取消");
              _collectProvider.removeXiaoshuoResource(widget.xiaoshuoReource.url);
              actionName = "点击收藏";
            } else {
              Log.d("点击收藏");
              _collectProvider.addXiaoshuoResource(
                widget.xiaoshuoReource,
              );
              actionName = "点击取消";
            }
            setState(() {});
          }),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: LoadImage(
                    widget.xiaoshuoReource.cover,
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${widget.xiaoshuoReource.title}"),
                    Text("作者：${widget.xiaoshuoReource.author}"),
                    Container(
                      width: 180,
                      child: Text(
                        "简介：${widget.xiaoshuoReource.jianjie}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 8,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text("最新章节"),
                ),
                nzjUrl.length > 0 || fyzjUrl.length > 0
                    ? Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: ScreenUtil.getInstance().getWidth(50),
                            child: ListView.builder(
                                itemCount: nzjUrl.length,
                                itemBuilder: (_, index) {
                                  return ListTile(
                                    title: Text(nzjUrl[index].title),
                                    trailing: Icon(Icons.keyboard_arrow_right),
                                    onTap: () {
                                      NavigatorUtils.goWebViewPage(context, nzjUrl[index].title, nzjUrl[index].url, flag: "2");
                                    },
                                  );
                                }),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.keyboard_arrow_left),
                                  onPressed: () {
                                    // 上一页
                                    if (currentValue == "1") {
                                      Toast.show('已经到了第一页了');
                                      return;
                                    }
                                    currentValue = "${int.parse(currentValue) - 1}";
                                    setState(() {});
                                  }),
                              DropdownButton(
                                items: List.generate(
                                    fyzjUrl.length,
                                    (index) => DropdownMenuItem(
                                          child: Text(
                                            fyzjUrl[index].title,
                                            style: TextStyle(color: currentValue == "1" ? Colors.blueGrey : Colors.black),
                                          ),
                                          value: "$index",
                                        )),
                                hint: new Text("提示信息"), // 当没有初始值时显示
                                onChanged: (selectValue) {
                                  //选中后的回调
                                  currentValue = selectValue;
                                  // 获取data
                                  _onRefresh();
                                  setState(() {});
                                },
                                value: "0",
                                iconSize: 30,
                                elevation: 10, //设置阴影
                                style: new TextStyle(
                                    //设置文本框里面文字的样式
                                    color: Colors.blue,
                                    fontSize: 15),
                              ),
                              IconButton(
                                  icon: Icon(Icons.keyboard_arrow_right),
                                  onPressed: () {
                                    // 下一页
                                    if (currentValue == "${fyzjUrl.length}") {
                                      Toast.show('已经到了最后一页了');
                                      return;
                                    }
                                    currentValue = "${int.parse(currentValue) + 1}";
                                    setState(() {});
                                  }),
                            ],
                          )
                        ],
                      )
                    : StateLayout(type: StateType.loading)
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
                              NavigatorUtils.goWebViewPage(context, _baseListProvider.list[index].title, _baseListProvider.list[index].url,
                                  flag: "2");
                            },
                          );
                        });
                  })))
        ],
      ),
    );
  }
}
