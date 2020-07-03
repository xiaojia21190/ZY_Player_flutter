import 'dart:async';

import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/newest/provider/detail_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_button.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    Key key,
    this.url,
    @required this.title,
    this.type,
    this.index,
  }) : super(key: key);

  final String url;
  final String title;
  final String type;
  final String index;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool startedPlaying = false;

  DetailProvider _detailProvider = DetailProvider();
  List<DetailReource> _listDetail = [];

  @override
  void initState() {
    super.initState();
    _listDetail = SpUtil.getObjList<DetailReource>("collcetPlayer", (data) => DetailReource.fromJson(data));
    _detailProvider.setListDetailResource(_listDetail);
    if (widget.type == "1") {
      initData();
    } else {
      _detailProvider.setDetailResource(_listDetail[int.parse(widget.index)]);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future initData() async {
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.detailReource,
        queryParameters: {"key": SpUtil.getString("selection"), "url": widget.url}, onSuccess: (data) {
      _detailProvider.setDetailResource(DetailReource.fromJson(data[0]));
    }, onError: (_, __) {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DetailProvider>(
        create: (_) => _detailProvider,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colours.app_main,
            title: Text(
              widget.title,
            ),
            actions: <Widget>[
              Selector<DetailProvider, List<DetailReource>>(
                  builder: (_, listData, __) {
                    return IconButton(
                        icon: listData.contains(_detailProvider.detailReource)
                            ? Icon(
                                Icons.turned_in,
                                color: Colors.red,
                              )
                            : Icon(
                                Icons.turned_in_not,
                                color: Colors.red,
                              ),
                        onPressed: () {
                          if (listData.contains(_detailProvider.detailReource)) {
                            Log.d("点击取消");
                            listData.remove(_detailProvider.detailReource);
                          } else {
                            Log.d("点击收藏");
                            listData.add(_detailProvider.detailReource);
                          }
                          SpUtil.putObjectList("collcetPlayer", listData);
                        });
                  },
                  selector: (_, store) => store.listDetailResource)
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
                            height: ScreenUtil.getInstance().getWidth(300),
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
                                      Row(
                                        children: <Widget>[
                                          Text(provider.detailReource.title),
                                          Text(
                                            provider.detailReource.qingxi,
                                            style: TextStyle(color: Colours.text_gray, fontSize: 12),
                                          ),
                                        ],
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
                                      Text(provider.detailReource.pianchang != null ? '${provider.detailReource.pianchang}分钟' : ""),
                                      MyButton(
                                        onPressed: () {
                                          NavigatorUtils.goWebViewPage(context, provider.detailReource.title, provider.detailReource.videoList[0]);
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
                                      Wrap(
                                        spacing: 4, // 主轴(水平)方向间距
                                        runSpacing: 10, // 纵轴（垂直）方向间距
                                        alignment: WrapAlignment.start, //沿主轴方向居中
                                        children: List.generate(provider.detailReource.videoList.length, (index) {
                                          return InkWell(
                                            onTap: () {
                                              NavigatorUtils.goWebViewPage(
                                                  context, provider.detailReource.title, provider.detailReource.videoList[index]);
                                              Log.d(index.toString());
                                            },
                                            child: Container(
                                              width: ScreenUtil.getInstance().getWidth(70),
                                              margin: EdgeInsets.only(right: 10),
                                              child: MyButton(
                                                onPressed: () {
                                                  NavigatorUtils.goWebViewPage(
                                                      context, provider.detailReource.title, provider.detailReource.videoList[index]);
                                                  Log.d(index.toString());
                                                },
                                                text: '第${index + 1}集',
                                              ),
                                            ),
                                          );
                                        }),
                                      )
                                    ],
                                  ),
                                ))
                            : Container(),
                      )
                    ],
                  )
                : StateLayout(type: StateType.loading);
          }),
        ));
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final SizedBox child;

  StickyTabBarDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: this.child,
    );
  }

  @override
  double get maxExtent => this.child.height;

  @override
  double get minExtent => this.child.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
