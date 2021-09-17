import 'dart:convert';

import 'package:ZY_Player_flutter/model/xiaoshuo_chap.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/util/qs_common.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/utils.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:ZY_Player_flutter/xiaoshuo/provider/xiaoshuo_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../xiaoshuo_router.dart';

class XiaoShuoDetailPage extends StatefulWidget {
  XiaoShuoDetailPage({
    Key? key,
    required this.xiaoshuodetail,
  }) : super(key: key);

  final String xiaoshuodetail;

  @override
  _XiaoShuoDetailPageState createState() => _XiaoShuoDetailPageState();
}

class _XiaoShuoDetailPageState extends State<XiaoShuoDetailPage> {
  XiaoShuoProvider _xiaoShuoProvider = XiaoShuoProvider();
  BaseListProvider<XiaoshuoList> _baseListProvider = BaseListProvider();

  XiaoshuoDetail? _detail;

  String readLastZj = "";

  int page = 0;
  int total = 20;
  int reverse = 0;

  @override
  void initState() {
    _detail = XiaoshuoDetail.fromJson(jsonDecode(widget.xiaoshuodetail));
    _xiaoShuoProvider = Store.value<XiaoShuoProvider>(context);

    fetchData();
    findLastZj();
    Future.microtask(() => _xiaoShuoProvider.setLastRead(_detail!));
    super.initState();
  }

  findLastZj() {
    int index = _xiaoShuoProvider.readList.lastIndexWhere((element) => element.split("_")[0] == _detail!.id);
    readLastZj = "";
    if (index >= 0) {
      var readList = _xiaoShuoProvider.readList[index].split("_");
      if (readList.length >= 3) {
        readLastZj = readList[2];
      }
    }
  }

  @override
  void dispose() {
    _xiaoShuoProvider.changeShunxu(false, false);
    super.dispose();
  }

  Future fetchData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getSearchXszjDetail,
        queryParameters: {"id": _detail!.id, "page": page, "reverse": reverse}, onSuccess: (resultList) {
      if (resultList == null) {
        _baseListProvider.setStateType(StateType.order);
      } else {
        _baseListProvider.setStateType(StateType.empty);
      }
      XiaoshuoChap result = XiaoshuoChap.fromJson(resultList);

      List.generate(result.xiaoshuoList.length, (index) => _baseListProvider.add(result.xiaoshuoList[index]));
      page = result.page;
      total = result.total;
    }, onError: (_, __) {
      _baseListProvider.setStateType(StateType.network);
    });
  }

  Future _onLoadMore() async {
    page++;
    fetchData();
  }

  Future _refush(bool flag) async {
    page = 0;
    if (flag) {
      reverse = 1;
    } else {
      reverse = 0;
    }
    _baseListProvider.clear();
    fetchData();
  }

  Widget buildShare(String image, String title) {
    GlobalKey haibaoKey3 = GlobalKey();
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
                            key: haibaoKey3,
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
                                        data: "https://crawel.lppfk.top/static/index.html",
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
                                  Clipboard.setData(ClipboardData(text: "https://crawel.lppfk.top/static/index.html"));
                                  Toast.show("复制链接成功，快去分享吧");
                                },
                              ),
                              TextButton(
                                child: const Text('保存到相册', style: TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  ByteData? byteData = await QSCommon.capturePngToByteData(haibaoKey3);
                                  // 保存
                                  var result = await QSCommon.saveImageToCamera(byteData!);
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
        label: Text("分享小说"));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                forceElevated: innerBoxIsScrolled,
                centerTitle: true,
                elevation: 0,
                floating: false,
                pinned: true,
                snap: false,
                leading: Semantics(
                  label: '返回',
                  child: SizedBox(
                    width: 48.0,
                    height: 48.0,
                    child: InkWell(
                      onTap: () {
                        Navigator.maybePop(context);
                      },
                      borderRadius: BorderRadius.circular(24.0),
                      child: Padding(
                        key: const Key('search_back'),
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          "assets/images/ic_back_black.png",
                          color: isDark ? Colours.dark_text : Colours.dark_text,
                        ),
                      ),
                    ),
                  ),
                ),
                expandedHeight: 250,
                flexibleSpace: FlexibleSpaceBar(
                  background: LoadImage(_detail!.img),
                ),
                actions: [
                  buildShare(_detail!.img, _detail!.name),
                ],
              ),
              SliverPersistentHeader(
                  pinned: true,
                  floating: false,
                  delegate: PersistentHeaderBuilder(
                      builder: (ctx, offset) => GestureDetector(
                            onTap: () {
                              _xiaoShuoProvider.setReadList("${_detail!.id}_${_detail!.lastChapterId}_${_detail!.lastChapter}");
                              NavigatorUtils.push(context,
                                  '${XiaoShuoRouter.contentPage}?id=${_detail!.id}&chpId=${_detail!.lastChapterId}&title=${Uri.encodeComponent(_detail!.lastChapter)}');
                            },
                            child: Container(
                              alignment: Alignment.center,
                              color: Colours.orange,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "最新章节",
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                  Text(
                                    _detail!.lastChapter,
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ))),
              readLastZj != ""
                  ? SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: () {
                          int index = _xiaoShuoProvider.readList.lastIndexWhere((element) => element.split("_")[0] == _detail!.id);
                          NavigatorUtils.pushResult(context,
                              '${XiaoShuoRouter.contentPage}?id=${_detail!.id}&chpId=${_xiaoShuoProvider.readList[index].split("_")[1]}&title=${Uri.encodeComponent(_xiaoShuoProvider.readList[index].split("_")[2])}',
                              (res) {
                            findLastZj();
                            setState(() {});
                          });
                        },
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          color: Colours.qingcaolv,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "最后阅读章节",
                                style: TextStyle(fontSize: 14, color: Colours.text_gray),
                              ),
                              Text(
                                readLastZj,
                                style: TextStyle(fontSize: 14, color: Colours.text_gray),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverToBoxAdapter(),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: [
                          Selector<XiaoShuoProvider, String>(
                              builder: (_, text, __) {
                                return Text(text);
                              },
                              selector: (_, store) => store.shunxuText),
                          Selector<XiaoShuoProvider, bool>(
                              builder: (_, order, __) {
                                return IconButton(
                                    icon: Icon(order ? Icons.vertical_align_top_rounded : Icons.vertical_align_bottom_rounded),
                                    onPressed: () {
                                      _xiaoShuoProvider.changeShunxu(!order);
                                      _refush(!order);
                                    });
                              },
                              selector: (_, store) => store.currentOrder),
                        ],
                      ),
                      Consumer<XiaoShuoProvider>(
                          builder: (_, provider, __) => TextButton(
                              onPressed: () {
                                if (provider.xiaoshuo.where((element) => element.id == _detail!.id).toList().length > 0) {
                                  _xiaoShuoProvider.removeXiaoshuoResource(_detail!.id);
                                } else {
                                  _xiaoShuoProvider.addXiaoshuoResource(_detail!);
                                }
                              },
                              child: Text(
                                provider.xiaoshuo.where((element) => element.id == _detail!.id).toList().length > 0 ? "移出书架" : "加入书架",
                              ))),
                    ],
                  ),
                ),
              )
            ];
          },
          body: ChangeNotifierProvider<BaseListProvider<XiaoshuoList>>(
              create: (_) => _baseListProvider,
              child: Consumer<BaseListProvider<XiaoshuoList>>(builder: (_, _baseListProvider, __) {
                return MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: DeerListView(
                        itemCount: _baseListProvider.list.length,
                        stateType: _baseListProvider.stateType,
                        hasRefresh: false,
                        loadMore: _onLoadMore,
                        pageSize: 20,
                        onRefresh: () => _refush(false),
                        hasMore: _baseListProvider.hasMore,
                        itemBuilder: (_, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Consumer<XiaoShuoProvider>(
                                    builder: (_, provider, __) => ListTile(
                                          selected: provider.readList
                                                      .where((element) => element.split("_")[1] == "${_baseListProvider.list[index].id}")
                                                      .toList()
                                                      .length >
                                                  0
                                              ? true
                                              : false,
                                          onTap: () {
                                            provider.setReadList(
                                                "${_detail!.id}_${_baseListProvider.list[index].id}_${_baseListProvider.list[index].name}");
                                            NavigatorUtils.pushResult(context,
                                                '${XiaoShuoRouter.contentPage}?id=${_detail!.id}&chpId=${_baseListProvider.list[index].id}&title=${Uri.encodeComponent(_baseListProvider.list[index].name)}',
                                                (res) {
                                              findLastZj();
                                              setState(() {});
                                            });
                                          },
                                          title: Text(_baseListProvider.list[index].name),
                                        )),
                              ),
                            ),
                          );
                        }));
              }))),
    );
  }
}

class PersistentHeaderBuilder extends SliverPersistentHeaderDelegate {
  final double max;
  final double min;
  final Widget Function(BuildContext context, double offset) builder;

  PersistentHeaderBuilder({this.max = 60, this.min = 40, required this.builder}) : assert(max >= min && builder != null);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context, shrinkOffset);
  }

  @override
  double get maxExtent => max;

  @override
  double get minExtent => min;

  @override
  bool shouldRebuild(covariant PersistentHeaderBuilder oldDelegate) =>
      max != oldDelegate.max || min != oldDelegate.min || builder != oldDelegate.builder;
}
