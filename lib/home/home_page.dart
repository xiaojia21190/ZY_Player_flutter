import 'package:ZY_Player_flutter/Collect/page/collect_page.dart';
import 'package:ZY_Player_flutter/home/provider/home_provider.dart';
import 'package:ZY_Player_flutter/manhua/page/manhua_page.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/player/page/player_page.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/device_utils.dart';
import 'package:ZY_Player_flutter/util/double_tap_back_exit_app.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_update_dialog/flutter_update_dialog.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> _pageList;

  final List<String> _appBarTitles = ['影视', '小说', '动漫', '收藏'];
  final PageController _pageController = PageController();

  HomeProvider provider = HomeProvider();

  List<BottomNavigationBarItem> _list;
  List<BottomNavigationBarItem> _listDark;

  UpdateDialog dialog;
  OtaEvent currentEvent;
  String currentUpdateUrl = "";
  String currentVersion = "";
  String currentUpdateText = "";

  @override
  void initState() {
    super.initState();
    // 获取更新数据
    if (Device.isAndroid) {
      checkUpDate();
    } else {
      // ios 应用商店
    }
    // 获得Player数据
    initData();
    // 初始化投屏数据
    Store.value<AppStateProvider>(context).initDlnaManager();
  }

  Future checkUpDate() async {
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.updateApp,
      onSuccess: (data) async {
        // 获得本地version
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String version = packageInfo.version;

        // 对比version
        var checkResult = compareVersion(data["appVersion"], "$version");
        if (checkResult) {
          // 更新
          currentUpdateUrl = data["updateUrl"];
          currentVersion = data["appVersion"];
          currentUpdateText = data["updateText"];
          String ignoreBb = SpUtil.getString("ignoreBb");
          if (currentVersion != ignoreBb) {
            openUpdateDiolog();
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
    dialog = UpdateDialog.showUpdate(context,
        width: 250,
        title: "是否升级到$currentVersion版本？",
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
        enableIgnore: true,
        updateButtonText: '开始升级',
        ignoreButtonText: '忽略此版本', onIgnore: () {
      Log.d("忽略");
      SpUtil.putString("ignoreBb", currentVersion);
      dialog.dismiss();
    }, onUpdate: tryOtaUpdate);
  }

  Future tryOtaUpdate() async {
    try {
      Toast.show("开始下载版本");
      OtaUpdate().execute(currentUpdateUrl, destinationFilename: "虱子聚合").listen(
        (OtaEvent event) {
          if (event.status == OtaStatus.DOWNLOADING) {
            dialog.update(double.parse(event.value) / 100);
          } else if (event.status == OtaStatus.INSTALLING) {
            Toast.show("升级成功");
          } else if (event.status == OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
            tryOtaUpdate();
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
      print('Failed to make OTA update. Details: $e');
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
    _pageList = [PlayerPage(), ManhuaPage(), ManhuaPage(), CollectPage()];
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
            'home/resou',
            width: 25.0,
            color: Colours.unselected_item_color,
          ),
          const LoadAssetImage(
            'home/resou',
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
        [
          const LoadAssetImage(
            'home/shoucang',
            width: 25.0,
            color: Colours.unselected_item_color,
          ),
          const LoadAssetImage(
            'home/shoucang',
            width: 25.0,
            color: Colours.app_main,
          ),
        ]
      ];
      _list = List.generate(4, (i) {
        return BottomNavigationBarItem(
            icon: _tabImages[i][0],
            activeIcon: _tabImages[i][1],
            title: Padding(
              padding: const EdgeInsets.only(top: 1.5),
              child: Text(
                _appBarTitles[i],
                key: Key(_appBarTitles[i]),
              ),
            ));
      });
    }
    return _list;
  }

  List<BottomNavigationBarItem> _buildDarkBottomNavigationBarItem() {
    if (_listDark == null) {
      var _tabImagesDark = [
        [
          const LoadAssetImage('home/video', width: 25.0),
          const LoadAssetImage(
            'home/video',
            width: 25.0,
            color: Colours.dark_app_main,
          ),
        ],
        [
          const LoadAssetImage('home/resou', width: 25.0),
          const LoadAssetImage(
            'home/resou',
            width: 25.0,
            color: Colours.dark_app_main,
          ),
        ],
        [
          const LoadAssetImage('home/dongman', width: 25.0),
          const LoadAssetImage(
            'home/dongman',
            width: 25.0,
            color: Colours.dark_app_main,
          ),
        ],
        [
          const LoadAssetImage('home/shoucang', width: 25.0),
          const LoadAssetImage(
            'home/shoucang',
            width: 25.0,
            color: Colours.dark_app_main,
          ),
        ]
      ];

      _listDark = List.generate(4, (i) {
        return BottomNavigationBarItem(
            icon: _tabImagesDark[i][0],
            activeIcon: _tabImagesDark[i][1],
            title: Padding(
              padding: const EdgeInsets.only(top: 1.5),
              child: Text(
                _appBarTitles[i],
                key: Key(_appBarTitles[i]),
              ),
            ));
      });
    }
    return _listDark;
  }

  int _lastReportedPage = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    return ChangeNotifierProvider<HomeProvider>(
      create: (_) => provider,
      child: DoubleTapBackExitApp(
        child: Scaffold(
            bottomNavigationBar: Consumer<HomeProvider>(
              builder: (_, provider, __) {
                return BottomNavigationBar(
                  backgroundColor: ThemeUtils.getBackgroundColor(context),
                  items: isDark ? _buildDarkBottomNavigationBarItem() : _buildBottomNavigationBarItem(),
                  type: BottomNavigationBarType.fixed,
                  currentIndex: provider.value,
                  elevation: 5.0,
                  iconSize: 21.0,
                  selectedFontSize: Dimens.font_sp10,
                  unselectedFontSize: Dimens.font_sp10,
                  selectedItemColor: Theme.of(context).primaryColor,
                  unselectedItemColor: isDark ? Colours.dark_unselected_item_color : Colours.unselected_item_color,
                  onTap: (index) => _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease),
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
