import 'dart:typed_data';

import 'package:ZY_Player_flutter/Collect/collect_router.dart';
import 'package:ZY_Player_flutter/Collect/page/collect_page.dart';
import 'package:ZY_Player_flutter/common/common.dart';
import 'package:ZY_Player_flutter/home/provider/home_provider.dart';
import 'package:ZY_Player_flutter/manhua/manhua_router.dart';
import 'package:ZY_Player_flutter/manhua/page/manhua_page.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/page/player_page.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/player/provider/player_provider.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/setting/setting_router.dart';
import 'package:ZY_Player_flutter/tingshu/page/tingshu_page.dart';
import 'package:ZY_Player_flutter/tingshu/tingshu_router.dart';
import 'package:ZY_Player_flutter/util/device_utils.dart';
import 'package:ZY_Player_flutter/util/double_tap_back_exit_app.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/click_item.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/xiaoshuo/page/shujia_page.dart';
import 'package:ZY_Player_flutter/xiaoshuo/xiaoshuo_router.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_update_dialog/flutter_update_dialog.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  List<Widget> _pageList;

  final List<String> _appBarTitles = ['影视', '小说', '动漫', '收藏'];
  final PageController _pageController = PageController();

  HomeProvider provider = HomeProvider();

  List<BottomNavigationBarItem> _list;
  List<BottomNavigationBarItem> _listDark;
  AppStateProvider appStateProvider;
  PlayerProvider playerProvider;

  UpdateDialog dialog;
  OtaEvent currentEvent;
  String currentUpdateUrl = "";
  String currentVersion = "";
  String nextVersion = "";
  String currentUpdateText = "";
  bool isUpdating = false;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 获取更新数据
    if (Device.isAndroid) {
      checkUpDate();
    } else {
      // ios 应用商店
    }
    // 获取公告数据

    // 获得Player数据
    initData();
    appStateProvider = Store.value<AppStateProvider>(context);
    playerProvider = Store.value<PlayerProvider>(context);
    // 初始化投屏数据
    appStateProvider.initDlnaManager();
    _tabController = TabController(vsync: this, length: 3);
    playerProvider.tabController = _tabController;

    Future.microtask(() {
      appStateProvider.getPlayerRecord();
    });
  }

  Future checkUpDate({bool jinru = false}) async {
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.updateApp,
      onSuccess: (data) async {
        // 获得本地version
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        currentVersion = packageInfo.version;

        // 对比version
        var checkResult = compareVersion(data["appVersion"], "$currentVersion");
        if (checkResult) {
          // 更新
          currentUpdateUrl = data["updateUrl"];
          nextVersion = data["appVersion"];
          currentUpdateText = data["updateText"];
          // String ignoreBb = SpUtil.getString("ignoreBb");
          // if (currentVersion != ignoreBb) {
          // }
          openUpdateDiolog();
        } else {
          if (jinru) {
            Toast.show("已经是最新版本了");
          }
        }
      },
      onError: (code, msg) {},
    );
  }

  openUpdateDiolog() {
    if (dialog != null && dialog.isShowing()) {
      return;
    }
    isUpdating = false;
    dialog = UpdateDialog.showUpdate(context,
        width: 250,
        title: "当前版本是$currentVersion,否升级到$nextVersion？",
        updateContent: "$currentUpdateText",
        titleTextSize: 14,
        contentTextSize: 12,
        buttonTextSize: 12,
        topImage: Image.asset('assets/images/bg_update_top.png'),
        extraHeight: 5,
        radius: 8,
        themeColor: Color(0xFFFFAC5D),
        progressBackgroundColor: Color(0x5AFFAC5D),
        isForce: false,
        enableIgnore: false,
        updateButtonText: '开始升级',
        onUpdate: tryOtaUpdate);
  }

  Future tryOtaUpdate() async {
    if (isUpdating) return;
    isUpdating = true;
    try {
      Toast.show("后台开始下载");
      OtaUpdate().execute(currentUpdateUrl, destinationFilename: "虱子聚合.apk").listen(
        (OtaEvent event) {
          if (event.status == OtaStatus.DOWNLOADING) {
            dialog.update(double.parse(event.value) / 100);
          } else if (event.status == OtaStatus.INSTALLING) {
            Toast.show("升级成功");
          } else {
            Toast.show("升级失败，请从新下载");
            dialog.dismiss();
            openUpdateDiolog();
          }
        },
      );
    } catch (e) {
      Toast.show("升级失败，请从新下载");
      dialog.dismiss();
      openUpdateDiolog();
    }
  }

  bool compareVersion(String newVersion, String oldVersion) {
    var result1 = newVersion.split(".").join("");
    var result2 = oldVersion.split(".").join("");
    if (int.parse(result1) > int.parse(result2)) {
      return true;
    }
    return false;
  }

  void initData() {
    _pageList = [PlayerPage(), ShuJiaPage(), ManhuaPage()];
  }

  List<BottomNavigationBarItem> _buildBottomNavigationBarItem() {
    if (_list == null) {
      var _tabImages = [
        [
          const LoadAssetImage(
            'home/video',
            width: 25.0,
            color: Colours.unselected_item_color,
          ),
          const LoadAssetImage(
            'home/video',
            width: 25.0,
            color: Colours.app_main,
          ),
        ],
        [
          const LoadAssetImage(
            'home/xiaoshuo',
            width: 25.0,
            color: Colours.unselected_item_color,
          ),
          const LoadAssetImage(
            'home/xiaoshuo',
            width: 25.0,
            color: Colours.app_main,
          ),
        ],
        [
          const LoadAssetImage(
            'home/dongman',
            width: 25.0,
            color: Colours.unselected_item_color,
          ),
          const LoadAssetImage(
            'home/dongman',
            width: 25.0,
            color: Colours.app_main,
          ),
        ],
      ];
      _list = List.generate(3, (i) {
        return BottomNavigationBarItem(icon: _tabImages[i][0], activeIcon: _tabImages[i][1], label: _appBarTitles[i]);
      });
    }
    return _list;
  }

  List<BottomNavigationBarItem> _buildDarkBottomNavigationBarItem() {
    if (_listDark == null) {
      var _tabImagesDark = [
        [
          const LoadAssetImage(
            'home/video',
            width: 25.0,
            color: Colours.white,
          ),
          const LoadAssetImage(
            'home/video',
            width: 25.0,
            color: Colours.dark_app_main,
          ),
        ],
        [
          const LoadAssetImage(
            'home/xiaoshuo',
            width: 25.0,
            color: Colours.white,
          ),
          const LoadAssetImage(
            'home/xiaoshuo',
            width: 25.0,
            color: Colours.dark_app_main,
          ),
        ],
        [
          const LoadAssetImage(
            'home/dongman',
            width: 25.0,
            color: Colours.white,
          ),
          const LoadAssetImage(
            'home/dongman',
            width: 25.0,
            color: Colours.dark_app_main,
          ),
        ],
      ];

      _listDark = List.generate(3, (i) {
        return BottomNavigationBarItem(
            icon: _tabImagesDark[i][0], activeIcon: _tabImagesDark[i][1], label: _appBarTitles[i]);
      });
    }
    return _listDark;
  }

  int _lastReportedPage = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _showQQDialog() {
    GlobalKey qqerweima = GlobalKey();
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
                  key: qqerweima,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.dialogBackgroundColor,
                    ),
                    width: 300,
                    height: 350,
                    child: Column(
                      children: <Widget>[
                        LoadImage(
                          "qq",
                          height: 350,
                          width: 400,
                          // width: ,
                          fit: BoxFit.fitWidth,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: const Text('点击直接进入加入qq群', style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        const url =
                            "mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26jump_from%3Dwebapi%26k%3D" +
                                "IJq1PRxEMXFtGPZotuORjjOaHPh0HZgS";
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                        //
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);

    final String theme = SpUtil.getString(Constant.theme);
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
                      return Selector<PlayerProvider, PageController>(
                          builder: (_, tab, __) {
                            return TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              labelPadding: EdgeInsets.all(12.0),
                              indicatorSize: TabBarIndicatorSize.label,
                              labelColor: Colours.app_main,
                              unselectedLabelColor: isDark ? Colors.white : Colors.black,
                              tabs: const <Widget>[
                                Text("影视"),
                                Text("直播"),
                                Text("听书"),
                              ],
                              onTap: (index) {
                                if (!mounted) {
                                  return;
                                }
                                playerProvider.index = index;
                                tab?.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
                              },
                            );
                          },
                          selector: (_, store) => store.pageController);
                      break;
                    case 1:
                      return Text("书架");
                      break;
                    case 2:
                      return Text("漫画");
                      break;
                    default:
                      break;
                  }
                  return Container();
                },
              ),
              leading: IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  }),
              actions: [
                Consumer<HomeProvider>(
                  builder: (_, provider, __) {
                    switch (provider.value) {
                      case 0:
                        return TextButton(
                            onPressed: () {
                              if (playerProvider.index == 2) {
                                NavigatorUtils.push(context, TingshuRouter.searchPage);
                              } else {
                                NavigatorUtils.push(context, PlayerRouter.searchPage);
                              }
                            },
                            child: Icon(
                              Icons.search_sharp,
                            ));
                        break;
                      case 1:
                        return TextButton(
                            onPressed: () {
                              NavigatorUtils.push(context, XiaoShuoRouter.searchPage);
                            },
                            child: Icon(
                              Icons.search_sharp,
                            ));
                        break;
                      case 2:
                        return TextButton(
                            onPressed: () {
                              NavigatorUtils.push(context, ManhuaRouter.searchPage);
                            },
                            child: Icon(
                              Icons.search_sharp,
                            ));
                        break;
                    }
                    return Container();
                  },
                )
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colours.app_main,
                      ),
                      child: Text(
                        '虱子聚合',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      )),
                  ClickItem(
                    title: '收藏',
                    onTap: () => NavigatorUtils.push(context, CollectRouter.collectPage),
                  ),
                  ClickItem(title: '观看记录', onTap: () => NavigatorUtils.push(context, SettingRouter.playerRecordPage)),
                  ClickItem(
                      title: '夜间模式',
                      content: themeMode,
                      onTap: () => NavigatorUtils.push(context, SettingRouter.themePage)),
                  ClickItem(title: '检查更新', content: currentVersion, onTap: () => checkUpDate(jinru: true)),
                  ClickItem(
                    title: '加入qq群',
                    onTap: () => _showQQDialog(),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Consumer<HomeProvider>(
              builder: (_, provider, __) {
                return BottomNavigationBar(
                  backgroundColor: ThemeUtils.getBackgroundColor(context),
                  items: isDark ? _buildDarkBottomNavigationBarItem() : _buildBottomNavigationBarItem(),
                  type: BottomNavigationBarType.shifting,
                  currentIndex: provider.value,
                  elevation: 10.0,
                  iconSize: 21.0,
                  selectedFontSize: Dimens.font_sp12,
                  unselectedFontSize: Dimens.font_sp12,
                  selectedItemColor: Theme.of(context).primaryColor,
                  unselectedItemColor: isDark ? Colours.dark_text : Colours.unselected_item_color,
                  onTap: (index) =>
                      _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease),
                );
              },
            ),
            // 使用PageView的原因参看 https://zhuanlan.zhihu.com/p/58582876
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                /// PageView的onPageChanged是监听ScrollUpdateNotification，会造成滑动中卡顿。这里修改为监听滚动结束再更新、
                if (notification.depth == 0 && notification is ScrollEndNotification) {
                  final PageMetrics metrics = notification.metrics;
                  final int currentPage = metrics.page.round();
                  if (currentPage != _lastReportedPage) {
                    _lastReportedPage = currentPage;
                    provider.value = currentPage;
                  }
                }
                return false;
              },
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => provider.value = index,
                children: _pageList,
                physics: NeverScrollableScrollPhysics(), // 禁止滑动
              ),
            )),
      ),
    );
  }
}
