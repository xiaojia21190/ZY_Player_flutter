import 'dart:async';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/provider/detail_provider.dart';
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

import '../../model/detail_reource.dart';

class PlayerDetailPage extends StatefulWidget {
  const PlayerDetailPage({
    Key key,
    @required this.url,
    @required this.title,
  }) : super(key: key);

  final String url;
  final String title;

  @override
  _PlayerDetailPageState createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  bool startedPlaying = false;

  DetailProvider _detailProvider = DetailProvider();

  @override
  void initState() {
    super.initState();
    context.read<CollectProvider>().setListDetailResource("collcetPlayer");
    initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future initData() async {
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.detailReource, queryParameters: {"key": "zuidazy", "url": widget.url},
        onSuccess: (data) {
      _detailProvider.setDetailResource(DetailReource.fromJson(data[0]));
      context.read<CollectProvider>().changeNoti();
    }, onError: (_, __) {});
  }

  bool getFilterData(DetailReource data) {
    if (data != null) {
      var result = context.read<CollectProvider>().listDetailResource.where((element) => element.url == data.url);
      return result.length > 0;
    }
    return false;
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
              Consumer<CollectProvider>(builder: (_, provider, __) {
                return IconButton(
                    icon: getFilterData(_detailProvider.detailReource)
                        ? Icon(
                            Icons.turned_in,
                            color: Colors.red,
                          )
                        : Icon(
                            Icons.turned_in_not,
                            color: Colors.red,
                          ),
                    onPressed: () {
                      if (getFilterData(_detailProvider.detailReource)) {
                        Log.d("点击取消");
                        provider.removeResource(_detailProvider.detailReource.url);
                      } else {
                        Log.d("点击收藏");
                        provider.addResource(_detailProvider.detailReource);
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
