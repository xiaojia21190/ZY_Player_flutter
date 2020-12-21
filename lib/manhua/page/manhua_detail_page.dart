import 'dart:async';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/manhua/provider/manhua_detail_provider.dart';
import 'package:ZY_Player_flutter/model/manhua_catlog_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/my_card.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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

  ManhuaDetailProvider _manhuaProvider = ManhuaDetailProvider();
  CollectProvider _collectProvider;
  String actionName = "";

  @override
  void initState() {
    super.initState();
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
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.detailManhua, queryParameters: {"url": widget.url}, onSuccess: (data) {
      _manhuaProvider.setManhuaDetail(ManhuaCatlogDetail.fromJson(data));
      _manhuaProvider.setZhanghjie();
      if (getFilterData(_manhuaProvider.catLog)) {
        _manhuaProvider.setActionName("点击取消");
      } else {
        _manhuaProvider.setActionName("点击收藏");
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
                            Log.d("点击取消");
                            _collectProvider.removeCatlogResource(_manhuaProvider.catLog.url);
                            _manhuaProvider.setActionName("点击收藏");
                          } else {
                            Log.d("点击收藏");
                            _collectProvider.addCatlogResource(
                              _manhuaProvider.catLog,
                            );
                            _manhuaProvider.setActionName("点击取消");
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
                                      icon: Icon(provider.currentOrder ? Icons.vertical_align_bottom_rounded : Icons.vertical_align_top_rounded),
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
                        padding: const EdgeInsets.all(5),
                        sliver: AnimationLimiter(
                          child: SliverGrid(
                            //Grid
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, //Grid按两列显示
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 1.5,
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
