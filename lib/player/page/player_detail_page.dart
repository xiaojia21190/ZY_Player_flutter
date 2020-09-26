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
import 'package:ZY_Player_flutter/widgets/app_bar.dart';
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
  CollectProvider _collectProvider;

  String actionName = "";

  @override
  void initState() {
    super.initState();
    _collectProvider = context.read<CollectProvider>();
    _collectProvider.setListDetailResource("collcetPlayer");
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
      _detailProvider.setJuji();
      _collectProvider.changeNoti();
      if (getFilterData(_detailProvider.detailReource)) {
        actionName = "点击取消";
      } else {
        actionName = "点击收藏";
      }
      setState(() {});
    }, onError: (_, __) {});
  }

  bool getFilterData(DetailReource data) {
    if (data != null) {
      var result = _collectProvider.listDetailResource.where((element) => element.url == data.url).toList();
      return result.length > 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final bool isDark = themeData.brightness == Brightness.dark;

    return ChangeNotifierProvider<DetailProvider>(
        create: (_) => _detailProvider,
        child: Scaffold(
          appBar: MyAppBar(
              centerTitle: widget.title,
              actionName: actionName,
              onPressed: () {
                if (getFilterData(_detailProvider.detailReource)) {
                  Log.d("点击取消");
                  _collectProvider.removeResource(_detailProvider.detailReource.url);
                  actionName = "点击收藏";
                } else {
                  Log.d("点击收藏");
                  _collectProvider.addResource(
                    _detailProvider.detailReource,
                  );
                  actionName = "点击取消";
                  setState(() {});
                }
              }),
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
                                          NavigatorUtils.goWebViewPage(context, provider.detailReource.title, provider.detailReource.videoList[0],
                                              flag: "1");
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
                                          return Container(
                                            width: ScreenUtil.getInstance().getWidth(80),
                                            padding: EdgeInsets.all(5),
                                            color: _detailProvider.kanguojuji.contains("${widget.url}_$index") ? Colors.red : Colours.text_gray_c,
                                            alignment: Alignment.center,
                                            child: InkWell(
                                                onTap: () {
                                                  _detailProvider.saveJuji("${widget.url}_$index");
                                                  NavigatorUtils.goWebViewPage(
                                                      context, provider.detailReource.title, provider.detailReource.videoList[index],
                                                      flag: "1");
                                                  Log.d(index.toString());
                                                },
                                                child: Text(
                                                  '第${index + 1}集',
                                                  style: TextStyle(
                                                    color: isDark ? Colours.dark_text : Colors.white,
                                                  ),
                                                )),
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
