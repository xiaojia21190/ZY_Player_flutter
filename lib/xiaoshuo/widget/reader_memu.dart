import 'dart:async';

import 'package:ZY_Player_flutter/event/event_bus.dart';
import 'package:ZY_Player_flutter/event/event_model.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_chap.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/click_item.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

class ColorCh {
  String name;
  Color color;
  ColorCh(this.name, this.color);
}

class ReaderMenu extends StatefulWidget {
  final String? title;
  final int? id;
  final int? chpId;
  final int? articleIndex;

  final VoidCallback? onTap;
  final VoidCallback? onPreviousArticle;
  final VoidCallback? onNextArticle;

  const ReaderMenu({Key? key, 
    this.articleIndex,
    this.title,
    this.chpId,
    this.id,
    this.onTap,
    this.onPreviousArticle,
    this.onNextArticle,
  }) : super(key: key);

  @override
  _ReaderMenuState createState() => _ReaderMenuState();
}

class _ReaderMenuState extends State<ReaderMenu> with SingleTickerProviderStateMixin {
  double? progressValue;
  bool isTipVisible = false;
  AppStateProvider? _appStateProvider;
  ScrollController scrollController = ScrollController();

  double light = 0;
  double maxLight = 0;
  bool lightSlider = false;
  bool colorSlider = false;
  bool sizeSlider = false;
  double fsise = 0;

  final List<ColorCh> _list = [
    ColorCh("银河白", Colours.yinhebai),
    ColorCh("杏仁黄", Colours.xingrenhuang),
    ColorCh("青草绿", Colours.qingcaolv),
    ColorCh("暗黑", Colours.cunhei),
  ];

  final List<XiaoshuoList> _list1 = [];

  Future? fetData;

  @override
  initState() {
    _appStateProvider = Store.value<AppStateProvider>(context);
    getLight();
    fsise = _appStateProvider!.xsFontSize;
    fetData = fetchData();
    super.initState();
  }

  @override
  void dispose() {
    ScreenBrightness().setScreenBrightness(light);
    super.dispose();
  }

  Future getLight() async {
    light = _appStateProvider!.lightLevel;
  }

  Future fetchData() async {
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getSearchXszjDetail, queryParameters: {"id": widget.id, "page": -1, "reverse": "1"}, onSuccess: (resultList) {
      XiaoshuoChap result = XiaoshuoChap.fromJson(resultList);
      List.generate(result.xiaoshuoList.length, (index) => _list1.add(result.xiaoshuoList[index]));
    }, onError: (_, __) {
      Toast.show("接口异常");
    });
    return _list1;
  }

  buildTopView(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(color: Colours.paper, boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 8)]),
        height: Screen.navigationBarHeight - 40,
        padding: const EdgeInsets.fromLTRB(20, 0, 5, 0),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 21,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset('assets/images/book/pub_back_gray.png'),
              ),
            ),
            Expanded(
                child: Container(
              child: Text(widget.title!),
            )),
          ],
        ),
      ),
    );
  }

  buildLightProgress() {
    return Container(
        width: Screen.widthOt,
        height: _appStateProvider!.opacityLevel == 1.0 ? 80 : 0,
        color: Colors.black87,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "当前亮度:${(light * 100).toInt()}%",
            style: const TextStyle(color: Colors.white),
          ),
          Slider(
            value: light,
            onChanged: (v) {
              setState(() {
                light = v;
                ScreenBrightness().setScreenBrightness(light);
              });
            },
            label: "亮度:${(light * 100).toInt()}%", //气泡的值
            max: 1,
            min: 0,
          )
        ]));
  }

  buildSize() {
    return Container(
      width: Screen.widthOt,
      height: _appStateProvider!.opacityLevel == 1.0 ? 80 : 0,
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "当前字体大小:$fsise",
            style: const TextStyle(color: Colors.white),
          ),
          Slider(
            value: fsise,
            onChanged: (v) {
              setState(() {
                fsise = v;
                _appStateProvider!.setFontSize(v);
              });
            },
            label: "字体大小:$fsise", //气泡的值
            divisions: 20, //进度条上显示多少个刻度点
            max: 30,
            min: 10,
          )
        ],
      ),
    );
  }

  buildColor() {
    return Container(
      width: Screen.widthOt,
      height: _appStateProvider!.opacityLevel == 1.0 ? 80 : 0,
      color: Colors.black87,
      padding: const EdgeInsets.only(top: 20),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 1,
        runSpacing: 1,
        children: List.generate(
            _list.length,
            (index) => GestureDetector(
                  onTap: () {
                    _appStateProvider!.setFontColor(_list[index].color);
                    setState(() {});
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(color: _list[index].color, borderRadius: BorderRadius.circular(8.0), border: _appStateProvider!.xsColor == _list[index].color ? Border.all(color: Colors.redAccent, width: 3) : Border.all(color: Colors.transparent)),
                      ),
                      Text(
                        _list[index].name,
                        style: const TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                )),
      ),
    );
  }

  buildBottomView() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: <Widget>[
          lightSlider ? buildLightProgress() : Container(),
          colorSlider ? buildColor() : Container(),
          sizeSlider ? buildSize() : Container(),
          Container(
            decoration: const BoxDecoration(color: Colours.paper, boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 8)]),
            padding: EdgeInsets.only(bottom: Screen.bottomSafeHeight),
            child: Column(
              children: <Widget>[
                //buildProgressView(),
                buildBottomMenus(),
              ],
            ),
          )
        ],
      ),
    );
  }

  buildBottomMenus() {
    final bool isDark = ThemeUtils.isDark(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        buildBottomItem(
            '目录',
            'book/read_icon_catalog',
            () => {
                  showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      elevation: 10,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return Container(
                          height: 550,
                          decoration: BoxDecoration(color: isDark ? Colours.dark_app_main : Colours.app_main, borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
                          child: Column(
                            children: [
                              _list.isNotEmpty
                                  ? TextButton(
                                      onPressed: () {
                                        var index = _list1.indexWhere((element) => element.id == widget.chpId);
                                        scrollController.animateTo(50.0 * index - 80, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                                      },
                                      child: const Text("去当前"))
                                  : Container(),
                              Expanded(
                                  child: FutureBuilder(
                                future: fetData,
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    if (snapshot.hasData && snapshot.data.length > 0) {
                                      return ListView.builder(
                                        controller: scrollController,
                                        itemExtent: 50,
                                        itemBuilder: (context, index) {
                                          return ClickItem(
                                            slected: widget.chpId == snapshot.data[index].id,
                                            title: snapshot.data[index].name,
                                            onTap: () {
                                              ApplicationEvent.event.fire(LoadXiaoShuoEvent(snapshot.data[index].id, snapshot.data[index].name));
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                        itemCount: snapshot.data.length,
                                      );
                                    } else {
                                      return Container(
                                        alignment: Alignment.center,
                                        child: TextButton(onPressed: fetchData, child: const Text('点击刷新章节')),
                                      );
                                    }
                                  } else {
                                    return Container(alignment: Alignment.center, child: const CircularProgressIndicator());
                                  }
                                },
                              ))
                            ],
                          ),
                        );
                      })
                }),
        buildBottomItem(
            '亮度',
            'book/read_icon_brightness',
            () => {
                  setState(() {
                    lightSlider = !lightSlider;
                    colorSlider = false;
                    sizeSlider = false;
                  })
                }),
        buildBottomItem(
            '字体',
            'book/read_icon_font',
            () => {
                  setState(() {
                    lightSlider = false;
                    colorSlider = false;
                    sizeSlider = !sizeSlider;
                  })
                }),
        buildBottomItem(
            '颜色',
            'book/read_icon_setting',
            () => {
                  setState(() {
                    lightSlider = false;
                    colorSlider = !colorSlider;
                    sizeSlider = false;
                  })
                }),
      ],
    );
  }

  buildBottomItem(String title, String icon, Function callClick) {
    return GestureDetector(
      onTap: () async {
        callClick();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          children: <Widget>[
            LoadImage(
              icon,
              height: 21,
            ),
            Text(title, style: const TextStyle(fontSize: 12, color: Colours.darkGray)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AppStateProvider, double>(
        builder: (_, value, __) {
          return AnimatedOpacity(
            opacity: value,
            duration: const Duration(milliseconds: 300),
            child: Stack(children: <Widget>[
              buildTopView(context),
              buildBottomView(),
            ]),
          );
        },
        selector: (_, store) => store.opacityLevel);
  }
}
