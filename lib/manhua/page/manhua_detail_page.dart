import 'dart:async';
import 'dart:typed_data';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/manhua/provider/manhua_detail_provider.dart';
import 'package:ZY_Player_flutter/model/manhua_catlog_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/util/qs_common.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  ManhuaDetailProvider _manhuaProvider = ManhuaDetailProvider();
  CollectProvider _collectProvider;
  String actionName = "";

  int yueduIndex = 0;

  @override
  void initState() {
    super.initState();
    yueduIndex = 0;
    _collectProvider = Store.value<CollectProvider>(context);
    _collectProvider.setListDetailResource("collcetManhua");

    initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future initData() async {
    _manhuaProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.detailManhua, queryParameters: {"url": widget.url},
        onSuccess: (data) {
      _manhuaProvider.setManhuaDetail(ManhuaCatlogDetail.fromJson(data));
      _manhuaProvider.setZhanghjie();
      if (getFilterData(_manhuaProvider.catLog)) {
        _manhuaProvider.setActionName("取消");
      } else {
        _manhuaProvider.setActionName("收藏");
      }
      _manhuaProvider.setStateType(StateType.empty);
    }, onError: (_, __) {
      _manhuaProvider.setStateType(StateType.network);
    });
  }

  Future refresh() async {
    await initData();
  }

  bool getFilterData(ManhuaCatlogDetail data) {
    if (data != null) {
      var result = _collectProvider.manhuaCatlog.where((element) => element.url == data.url).toList();
      return result.length > 0;
    }
    return false;
  }

  Widget buildShare(String image, String title) {
    GlobalKey haibaoKey2 = GlobalKey();
    return TextButton.icon(
        onPressed: () => {
              showElasticDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return Material(
                    type: MaterialType.transparency,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RepaintBoundary(
                            key: haibaoKey2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.dialogBackgroundColor,
                              ),
                              width: 300,
                              height: 430,
                              child: Column(
                                children: <Widget>[
                                  LoadImage(
                                    image,
                                    height: 320,
                                    width: 300,
                                    // width: ,
                                    fit: BoxFit.cover,
                                  ),
                                  Expanded(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("分享 虱子聚合"),
                                          Container(
                                            child: Text(
                                              "$title",
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            ),
                                          ),
                                          Text("点击复制链接"),
                                          Text("或者保存到相册分享")
                                        ],
                                      ),
                                      QrImage(
                                        padding: EdgeInsets.all(7),
                                        backgroundColor: Colors.white,
                                        data:
                                            "http://hall.moitech.cn/shizhijuhe/index.html#/upload?random=${DateTime.now()}",
                                        size: 100,
                                      ),
                                    ],
                                  ))
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                child: const Text('点击复制链接', style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          "http://hall.moitech.cn/shizhijuhe/index.html#/upload?random=${DateTime.now()}"));
                                  Toast.show("复制链接成功，快去分享吧");
                                },
                              ),
                              TextButton(
                                child: const Text('保存到相册', style: TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  ByteData byteData = await QSCommon.capturePngToByteData(haibaoKey2);
                                  // 保存
                                  var result = await QSCommon.saveImageToCamera(byteData);
                                  if (result["isSuccess"]) {
                                    Toast.show("保存成功, 快去分享吧");
                                  } else {
                                    Toast.show("保存失败");
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            },
        icon: Icon(Icons.share),
        label: Text("分享漫画"));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final bool isDark = themeData.brightness == Brightness.dark;
    return ChangeNotifierProvider<ManhuaDetailProvider>(
        create: (_) => _manhuaProvider,
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Selector<ManhuaDetailProvider, String>(
                  builder: (_, actionName, __) {
                    return MyAppBar(
                        centerTitle: widget.title,
                        actionName: actionName,
                        onPressed: () {
                          if (getFilterData(_manhuaProvider.catLog)) {
                            _collectProvider.removeCatlogResource(_manhuaProvider.catLog.url);
                            _manhuaProvider.setActionName("收藏");
                          } else {
                            _collectProvider.addCatlogResource(
                              _manhuaProvider.catLog,
                            );
                            _manhuaProvider.setActionName("取消");
                          }
                        });
                  },
                  selector: (_, store) => store.actionName)),
          body: Consumer<ManhuaDetailProvider>(builder: (_, provider, __) {
            return provider.catLog != null
                ? CustomScrollView(
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Container(
                          height: 100,
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
                      SliverToBoxAdapter(
                        child: buildShare(provider.catLog.cover, provider.catLog.title),
                      ),
                      SliverToBoxAdapter(
                        child: Gaps.vGap8,
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(provider.catLog.content),
                              Row(
                                children: [
                                  Text(provider.shunxuText),
                                  IconButton(
                                      icon: Icon(provider.currentOrder
                                          ? Icons.vertical_align_bottom_rounded
                                          : Icons.vertical_align_top_rounded),
                                      onPressed: () {
                                        provider.changeShunxu(!provider.currentOrder);
                                      })
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(10),
                        sliver: AnimationLimiter(
                          child: SliverGrid(
                            //Grid
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, //Grid按两列显示
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  columnCount: provider.catLog.catlogs.length,
                                  child: ScaleAnimation(
                                    child: FadeInAnimation(
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: _manhuaProvider.kanguozhangjie.contains(
                                                      "${widget.url}_${provider.currentOrder ? index : provider.catLog.catlogs.length - index}")
                                                  ? Colors.redAccent
                                                  : Colors.blueAccent,
                                              borderRadius: BorderRadius.all(Radius.circular(5))),
                                          alignment: Alignment.center,
                                          child: InkWell(
                                              onTap: () {
                                                _manhuaProvider.saveZhangjie(
                                                    "${widget.url}_${provider.currentOrder ? index : provider.catLog.catlogs.length - index}");
                                                NavigatorUtils.push(context,
                                                    '${ManhuaRouter.imagesPage}?title=${Uri.encodeComponent(provider.catLog.catlogs[index].text)}&url=${Uri.encodeComponent(provider.catLog.catlogs[index].url)}');
                                              },
                                              child: Text(
                                                '${provider.catLog.catlogs[index].text}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: isDark ? Colours.dark_text : Colors.white,
                                                ),
                                              ))),
                                    ),
                                  ),
                                );
                                //创建子widget
                              },
                              childCount: provider.catLog.catlogs.length,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : StateLayout(type: provider.state, onRefresh: refresh);
          }),
        ));
  }
}
