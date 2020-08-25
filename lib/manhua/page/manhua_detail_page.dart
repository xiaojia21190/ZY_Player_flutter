import 'dart:async';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/manhua/provider/manhua_provider.dart';
import 'package:ZY_Player_flutter/model/manhua_catlog_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/widgets/app_bar.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../manhua_router.dart';

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

  ManhuaProvider _manhuaProvider;
  CollectProvider _collectProvider;
  String actionName = "点击收藏";

  @override
  void initState() {
    super.initState();
    _manhuaProvider = context.read<ManhuaProvider>();
    _collectProvider = context.read<CollectProvider>();
    _collectProvider.setListDetailResource("collcetManhua");
    initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future initData() async {
    _manhuaProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.detailManhua, queryParameters: {"url": widget.url}, onSuccess: (data) {
      _manhuaProvider.setManhuaDetail(ManhuaCatlogDetail.fromJson(data));
      _collectProvider.changeNoti();
      _manhuaProvider.setZhanghjie();
    }, onError: (_, __) {
      _manhuaProvider.setStateType(StateType.network);
    });
  }

  bool getFilterData(ManhuaCatlogDetail data) {
    if (data != null) {
      var result = _collectProvider.listDetailResource.where((element) => element.url == data.url);
      return result.length > 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final bool isDark = themeData.brightness == Brightness.dark;
    return Scaffold(
      appBar: MyAppBar(
        centerTitle: widget.title,
        actionName: actionName,
        onPressed: () {
          if (getFilterData(_manhuaProvider.catLog)) {
            Log.d("点击取消");
            _collectProvider.removeCatlogResource(_manhuaProvider.catLog.url);
            actionName = "点击取消";
          } else {
            Log.d("点击收藏");
            _collectProvider.addCatlogResource(
              _manhuaProvider.catLog,
            );
            actionName = "点击收藏";
          }
          setState(() {});
        },
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
                        height: ScreenUtil.getInstance().getWidth(100),
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            LoadImage(
                              provider.catLog.cover,
                              width: 100,
                              fit: BoxFit.contain,
                            ),
                            Expanded(
                                child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    provider.catLog.author,
                                  ),
                                  Text(
                                    provider.catLog.gengxin,
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
                          children: <Widget>[Text(provider.catLog.content)],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(5),
                    sliver: SliverGrid(
                      //Grid
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, //Grid按两列显示
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          //创建子widget
                          return Container(
                              color: _manhuaProvider.kanguozhangjie.contains("${widget.url}_$index") ? Colours.dark_text_gray : Colours.text_gray_c,
                              alignment: Alignment.center,
                              child: InkWell(
                                  onTap: () {
                                    _manhuaProvider.saveZhangjie("${widget.url}_$index");
                                    NavigatorUtils.push(context, '${ManhuaRouter.imagesPage}?index=$index');
                                  },
                                  child: Text(
                                    '${provider.catLog.catlogs[index].text}',
                                    style: TextStyle(
                                      color: isDark ? Colours.dark_text : Colors.white,
                                    ),
                                  )));
                        },
                        childCount: provider.catLog.catlogs.length,
                      ),
                    ),
                  ),
                ],
              )
            : StateLayout(type: provider.state);
      }),
    );
  }
}
