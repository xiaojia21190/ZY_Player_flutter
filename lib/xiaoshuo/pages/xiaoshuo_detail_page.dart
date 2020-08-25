import 'dart:async';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
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
import 'package:url_launcher/url_launcher.dart';

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
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    context.read<CollectProvider>().setListDetailResource("collcetPlayer");
    _onRefresh();
  }

  Future getData() async {
    print(widget.xiaoshuoReource);
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      "https://bookshelf.html5.qq.com/api/migration/list_charpter?resourceid=${widget.xiaoshuoReource.resourceId}&start=$currentPage&serialnum=10000&sort=asc&t=202008251604",
      options: Options(headers: {"Referer": 'https://bookshelf.html5.qq.com/?t=native&ch=004645'}),
      onSuccess: (data) {
        List.generate(data["rows"].length, (i) => _baseListProvider.list.add(Rows.fromJson(data["rows"][i])));
        if (data["page_No"] == data["page_Count"]) {
          _baseListProvider.setHasMore(false);
        } else {
          _baseListProvider.setHasMore(true);
        }
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

  _launchURL(String prev) async {
    String url = "mttbrowser://$prev";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
                  ],
                )
              ],
            ),
          ),
          SliverFillRemaining(
              child: ChangeNotifierProvider<BaseListProvider<Rows>>(
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
                              // 打开qq浏览器
                              //https://bookshelf.html5.qq.com/?t=web&ch=004645#!/detail/1100648963/2811/wenxue_content"
                              _launchURL(
                                  'url=https://bookshelf.html5.qq.com/?t=web&ch=004645#!/detail/${_baseListProvider.list[index].resourceid}/${_baseListProvider.list[index].serialid}/wenxue_content');
                            },
                          );
                        });
                  })))
        ],
      ),
    );
  }
}
