import 'dart:async';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/manhua/provider/manhua_provider.dart';
import 'package:ZY_Player_flutter/model/manhua_catlog_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_button.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManhuaDetailPage extends StatefulWidget {
  const ManhuaDetailPage({
    Key key,
    @required this.url,
    @required this.title,
  }) : super(key: key);

  final String url;
  final String title;

  @override
  _ManhuaDetailPageState createState() => _ManhuaDetailPageState();
}

class _ManhuaDetailPageState extends State<ManhuaDetailPage> {
  bool startedPlaying = false;

  ManhuaProvider _manhuaProvider = ManhuaProvider();

  @override
  void initState() {
    super.initState();
    context.read<CollectProvider>().setListDetailResource("collcetManhua");
    initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future initData() async {
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.detailReource,
        queryParameters: {"key": SpUtil.getString("selection"), "url": widget.url}, onSuccess: (data) {
      _manhuaProvider.setManhuaDetail(ManhuaCatlogDetail.fromJson(data[0]));
      context.read<CollectProvider>().changeNoti();
    }, onError: (_, __) {});
  }

  bool getFilterData(ManhuaCatlogDetail data) {
    if (data != null) {
      var result = context.read<CollectProvider>().listDetailResource.where((element) => element.url == data.url);
      return result.length > 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ManhuaProvider>(
        create: (_) => _manhuaProvider,
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
                    icon: getFilterData(_manhuaProvider.catLog)
                        ? Icon(
                            Icons.turned_in,
                            color: Colors.red,
                          )
                        : Icon(
                            Icons.turned_in_not,
                            color: Colors.red,
                          ),
                    onPressed: () {
                      if (getFilterData(_manhuaProvider.catLog)) {
                        Log.d("点击取消");
                        provider.removeResource(_manhuaProvider.catLog.url, "collcetManhua");
                      } else {
                        Log.d("点击收藏");
                        provider.addResource(_manhuaProvider.catLog, "collcetManhua");
                      }
                    });
              })
            ],
          ),
          body: Consumer<ManhuaProvider>(builder: (_, provider, __) {
            return provider.catLog != null
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
                                    provider.catLog.cover,
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
                                        provider.catLog.author,
                                        maxLines: 2,
                                      ),
                                      Text(
                                        provider.catLog.gengxin,
                                        maxLines: 2,
                                        style: TextStyle(color: Colours.text_gray, fontSize: 12),
                                      ),
                                      Text(provider.catLog.gengxinTime),
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
                              children: <Widget>[Text("剧情介绍"), Gaps.vGap10, Text(provider.catLog.content)],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: provider.catLog.catlogs.length > 1
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
                                        children: List.generate(provider.catLog.catlogs.length, (index) {
                                          return InkWell(
                                            onTap: () {},
                                            child: Container(
                                              width: ScreenUtil.getInstance().getWidth(70),
                                              margin: EdgeInsets.only(right: 10),
                                              child: MyButton(
                                                onPressed: () {},
                                                text: '${provider.catLog.catlogs[index].text}',
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
