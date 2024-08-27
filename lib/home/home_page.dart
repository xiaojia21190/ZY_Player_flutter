import 'dart:async';

import 'package:ZY_Player_flutter/Collect/collect_router.dart';
import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/common/common.dart';
import 'package:ZY_Player_flutter/home/empty_webview.dart';
import 'package:ZY_Player_flutter/home/provider/home_provider.dart';
import 'package:ZY_Player_flutter/player/page/player_page.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/double_tap_back_exit_app.dart';
import 'package:ZY_Player_flutter/util/hex_color.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_update_dialog/flutter_update_dialog.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

class IconTitle {
  final IconData icon;
  final String title;
  IconTitle({required this.icon, required this.title});
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final List<Widget> _pageList = [const PlayerPage(), EmptyWebview()];

  final PageController _pageController = PageController();

  HomeProvider provider = HomeProvider();

  AppStateProvider? appStateProvider;
  PlayerProvider? playerProvider;
  CollectProvider? collectProvider;

  UpdateDialog? dialog;
  String currentUpdateUrl = "";
  String currentVersion = "";
  String nextVersion = "";
  String currentUpdateText = "";
  bool isUpdating = false;

  // TabController? _tabControllerColl;

  AnimationController? _animationController;
  Animation<double>? animation;
  CurvedAnimation? curve;

  final iconList = <IconTitle>[
    IconTitle(icon: Icons.play_circle_fill, title: "影视"),
    IconTitle(icon: Icons.favorite, title: "挂京东"),
  ];

  @override
  void initState() {
    // 获取更新数据
    // if (Device.isAndroid) {
    // checkUpDate();
    // } else {
    // ios 应用商店
    // }

    // 获取是否激活
    // checkJihuo();

    // 获得Player数据
    // appStateProvider = Store.value<AppStateProvider>(context);
    // playerProvider = Store.value<PlayerProvider>(context);
    // collectProvider = Store.value<CollectProvider>(context);
    // 初始化投屏数据
    appStateProvider?.initDlnaManager();

    Future.microtask(() async {
      appStateProvider?.getPlayerRecord();
      // await getUserInfo();
    });

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    curve = CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(
        0.5,
        1.0,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curve!);

    Future.delayed(
      const Duration(seconds: 1),
      () => _animationController?.forward(),
    );

    getLight();

    super.initState();
  }

  Future getLight() async {
    var light = await ScreenBrightness().current;
    ScreenBrightness().setAutoReset(true);
    ScreenBrightness().setAnimate(true);
    debugPrint("light:$light");
    appStateProvider?.setLightLevel(light);
  }

  // Future getUserInfo() async {
  //   await DioUtils.instance.requestNetwork(
  //     Method.get,
  //     HttpApi.queryUserInfo,
  //     onSuccess: (data) {
  //       List<XiaoshuoDetail> _xslist = [];
  //       JsonUtil.getObjectList(data["xslist"], (v) => _xslist.add(XiaoshuoDetail.fromJson(v as Map<String, dynamic>)));
  //       SpUtil.putObjectList("collcetXiaoshuo", _xslist);

  //       List<Playlist> _pylist = [];
  //       JsonUtil.getObjectList(data["playlist"], (v) => _pylist.add(Playlist.fromJson(v as Map<String, dynamic>)));
  //       SpUtil.putObjectList("collcetPlayer", _pylist);
  //       collectProvider?.setListDetailResource("collcetPlayer", _pylist);

  //       List<ManhuaCatlogDetail> _mhlist = [];
  //       JsonUtil.getObjectList(data["mhlist"], (v) => _mhlist.add(ManhuaCatlogDetail.fromJson(v as Map<String, dynamic>)));
  //       SpUtil.putObjectList("collcetManhua", _mhlist);
  //       collectProvider?.setListDetailResource("collcetManhua", _mhlist);

  //       List<AudioLoc> _tslist = [];
  //       JsonUtil.getObjectList(data["tslist"], (v) => _tslist.add(AudioLoc.fromJson(v as Map<String, dynamic>)));
  //       SpUtil.putObjectList("collcetTingshu", _tslist);
  //       collectProvider?.setListDetailResource("collcetTingshu", _tslist);
  //     },
  //     onError: (code, msg) {},
  //   );
  // }

  // gongGao(String gongao) async {
  //   return showElasticDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Material(
  //         type: MaterialType.transparency,
  //         child: Center(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Container(
  //                 decoration: const BoxDecoration(color: Colours.qingcaolv, borderRadius: BorderRadius.all(Radius.circular(10))),
  //                 width: 250,
  //                 height: 250,
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: <Widget>[
  //                     Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: Shimmer.fromColors(
  //                         baseColor: Colors.red,
  //                         highlightColor: Colors.yellow,
  //                         child: const Text(
  //                           "公告",
  //                           textAlign: TextAlign.center,
  //                           style: const TextStyle(
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Expanded(
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Text(
  //                           "$gongao",
  //                           softWrap: true,
  //                           style: const TextStyle(color: Colours.text, letterSpacing: 1.2),
  //                         ),
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               IconButton(
  //                   icon: const Icon(
  //                     Icons.close,
  //                     color: Colors.white,
  //                   ),
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   })
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // Future checkJihuo() async {
  //   await DioUtils.instance.requestNetwork(
  //     Method.get,
  //     HttpApi.queryJihuo,
  //     onSuccess: (data) {
  //       SpUtil.putString(Constant.orderid, data["order"]);
  //       SpUtil.putString(Constant.jihuoDate, data["jihuoDate"]);
  //     },
  //     onError: (code, msg) {},
  //   );
  // }

  // Future checkUpDate({bool jinru = false}) async {
  //   await DioUtils.instance.requestNetwork(
  //     Method.get,
  //     HttpApi.updateApp,
  //     onSuccess: (data) async {
  //       // 获得本地version
  //       PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //       currentVersion = packageInfo.version;

  //       // 对比version
  //       var checkResult = compareVersion(data["appVersion"], "$currentVersion");
  //       if (checkResult) {
  //         // 更新
  //         currentUpdateUrl = data["updateUrl"];
  //         nextVersion = data["appVersion"];
  //         currentUpdateText = data["updateText"];
  //         // String ignoreBb = SpUtil.getString("ignoreBb");
  //         // if (currentVersion != ignoreBb) {
  //         // }
  //         openUpdateDialog();
  //       } else {
  //         if (jinru) {
  //           Toast.show("已经是最新版本了");
  //         } else {
  //           gongGao(data["gonggao"]);
  //         }
  //       }
  //     },
  //     onError: (code, msg) {},
  //   );
  // }

  // openUpdateDialog() {
  //   if (dialog != null && dialog!.isShowing()) {
  //     return;
  //   }

  //   isUpdating = false;
  //   dialog = UpdateDialog.showUpdate(context,
  //       width: 250,
  //       title: "当前版本是$currentVersion,否升级到$nextVersion？",
  //       updateContent: currentUpdateText,
  //       titleTextSize: 14,
  //       contentTextSize: 12,
  //       buttonTextSize: 12,
  //       topImage: Image.asset('assets/images/bg_update_top.png'),
  //       extraHeight: 5,
  //       radius: 8,
  //       themeColor: const Color(0xFFFFAC5D),
  //       progressBackgroundColor: const Color(0x5AFFAC5D),
  //       isForce: true,
  //       enableIgnore: false,
  //       updateButtonText: '开始升级',
  //       onUpdate: tryOtaUpdate);
  // }

  // Future tryOtaUpdate() async {
  //   if (isUpdating) return;
  //   isUpdating = true;
  //   try {
  //     Toast.show("后台开始下载");
  //     OtaUpdate().execute(currentUpdateUrl, destinationFilename: "虱子聚合.apk").listen(
  //       (OtaEvent? event) {
  //         if (event!.status == OtaStatus.DOWNLOADING) {
  //           var value = event.value;
  //           dialog?.update(double.parse(value!) / 100);
  //         } else if (event.status == OtaStatus.INSTALLING) {
  //           Toast.show("升级成功");
  //         } else {
  //           Toast.show("升级失败，请从新下载");
  //           dialog?.dismiss();
  //           openUpdateDialog();
  //         }
  //       },
  //     );
  //   } catch (e) {
  //     Toast.show("升级失败，请从新下载");
  //     dialog?.dismiss();
  //     openUpdateDialog();
  //   }
  // }

  // bool compareVersion(String newVersion, String oldVersion) {
  //   var result1 = newVersion.split(".").join("");
  //   var result2 = oldVersion.split(".").join("");
  //   if (int.parse(result1) > int.parse(result2)) {
  //     return true;
  //   }
  //   return false;
  // }

  int _lastReportedPage = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // _showQQDialog() {
  //   GlobalKey qqerweima = GlobalKey();
  //   showElasticDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Material(
  //         type: MaterialType.transparency,
  //         child: Center(
  //           child: Column(
  @override
  Widget build(BuildContext context) {
    // final bool isDark = ThemeUtils.isDark(context);

    final String? theme = SpUtil.getString(Constant.theme);
    String themeMode;
    switch (theme) {
      case 'Dark':
        themeMode = '开启';
        break;
      case 'Light':
        themeMode = '关闭';
        break;
      default:
        themeMode = '跟随系统';
        break;
    }
    return ChangeNotifierProvider<HomeProvider>(
      create: (_) => provider,
      child: DoubleTapBackExitApp(
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              centerTitle: true,
              elevation: 2,
              title: Consumer<HomeProvider>(
                builder: (_, provider, __) {
                  switch (provider.value) {
                    case 0:
                      return const Text(
                        "影视",
                        style: TextStyle(color: Colors.white),
                      );
                    case 1:
                      return const Text(
                        "挂京东",
                        style: TextStyle(color: Colors.white),
                      );
                    default:
                      break;
                  }
                  return Container();
                },
              ),
              leading: IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState!.openDrawer();
                  }),
              actions: [
                Consumer<HomeProvider>(
                  builder: (_, provider, __) {
                    switch (provider.value) {
                      case 0:
                        return TextButton(
                          onPressed: () {
                            NavigatorUtils.push(context, '${CollectRouter.collectPage}?catIndex=1');
                          },
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                          ),
                        );
                    }
                    return Container();
                  },
                ),
                Consumer<HomeProvider>(
                  builder: (_, provider, __) {
                    switch (provider.value) {
                      case 0:
                        return TextButton(
                          onPressed: () {
                            NavigatorUtils.push(context, PlayerRouter.searchPage);
                          },
                          child: const Icon(
                            Icons.search_sharp,
                            color: Colors.white,
                          ),
                        );
                    }
                    return Container();
                  },
                )
              ],
            ),
            // floatingActionButton: ScaleTransition(
            //   scale: animation!,
            //   child: FloatingActionButton(
            //     elevation: 8,
            //     backgroundColor: HexColor('#FFA400'),
            //     child: const Text(
            //       "挂京东",
            //       style: TextStyle(color: Colors.white),
            //     ),
            //     onPressed: () {
            //       _animationController?.reset();
            //       _animationController?.forward();
            //       NavigatorUtils.goWebViewPage(
            //         context,
            //         "京东短信登陆",
            //         "https://bean.m.jd.com/bean/signIndex.action",
            //       );
            //     },
            //   ),
            // ),
            // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: Consumer<HomeProvider>(
              builder: (_, provider, __) {
                return AnimatedBottomNavigationBar.builder(
                  itemCount: iconList.length,
                  tabBuilder: (int index, bool isActive) {
                    final color = isActive ? HexColor('#FFA400') : Colors.white;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconList[index].icon,
                          size: 24,
                          color: color,
                        ),
                        const SizedBox(height: 4),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(iconList[index].title, maxLines: 1, style: TextStyle(color: color)))
                      ],
                    );
                  },
                  backgroundColor: HexColor('#373A36'),
                  activeIndex: provider.value,
                  splashColor: HexColor('#FFA400'),
                  notchAndCornersAnimation: animation,
                  splashSpeedInMilliseconds: 300,
                  notchSmoothness: NotchSmoothness.defaultEdge,
                  gapLocation: GapLocation.center,
                  leftCornerRadius: 0,
                  rightCornerRadius: 0,
                  onTap: (index) {
                    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  },
                );
              },
            ),
            // 使用PageView的原因参看 https://zhuanlan.zhihu.com/p/58582876
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                /// PageView的onPageChanged是监听ScrollUpdateNotification，会造成滑动中卡顿。这里修改为监听滚动结束再更新、
                if (notification.depth == 0 && notification is ScrollEndNotification) {
                  final PageMetrics metrics = notification.metrics as PageMetrics;
                  final int currentPage = (metrics.page ?? 0).round();
                  if (currentPage != _lastReportedPage) {
                    _lastReportedPage = currentPage;
                    provider.value = currentPage;
                  }
                }
                return false;
              },
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => provider.value == index,
                physics: const NeverScrollableScrollPhysics(),
                children: _pageList, // 禁止滑动
              ),
            )),
      ),
    );
  }

  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               RepaintBoundary(
  //                 key: qqerweima,
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     color: context.dialogBackgroundColor,
  //                   ),
  //                   width: 300,
  //                   height: 350,
  //                   child: Column(
  //                     children: <Widget>[
  //                       LoadImage(
  //                         "qq",
  //                         height: 350,
  //                         width: 400,
  //                         // width: ,
  //                         fit: BoxFit.fitWidth,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   TextButton(
  //                     child: const Text('点击加好友', style: TextStyle(color: Colors.white)),
  //                     onPressed: () async {
  //                       const url = "https://qm.qq.com/cgi-bin/qm/qr?k=CQQAk3iXGmdhvNPK0mWpZkIXSgYcJtOr&noverify=0";
  //                       if (await canLaunch(url)) {
  //                         await launch(url);
  //                       } else {
  //                         throw 'Could not launch $url';
  //                       }
  //                     },
  //                   ),
  //                 ],
  //               )
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
