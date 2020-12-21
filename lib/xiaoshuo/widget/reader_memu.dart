import 'dart:async';

import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart' as lightness;

class ColorCh {
  String name;
  Color color;
  ColorCh(this.name, this.color);
}

class ReaderMenu extends StatefulWidget {
  // final List<Chapter> chapters;
  final String title;
  final int articleIndex;

  final VoidCallback onTap;
  final VoidCallback onPreviousArticle;
  final VoidCallback onNextArticle;
  // final void Function(Chapter chapter) onToggleChapter;

  ReaderMenu({
    // this.chapters,
    this.articleIndex,
    this.title,
    this.onTap,
    this.onPreviousArticle,
    this.onNextArticle,
    // this.onToggleChapter
  });

  @override
  _ReaderMenuState createState() => _ReaderMenuState();
}

class _ReaderMenuState extends State<ReaderMenu> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  double progressValue;
  bool isTipVisible = false;

  double light = 0;
  double maxLight = 0;
  String _lightNm;
  bool lightSlider = false;
  bool colorSlider = false;

  List<ColorCh> _list = [
    ColorCh("银河白", Colours.yinhebai),
    ColorCh("杏仁黄", Colours.xingrenhuang),
    ColorCh("秋叶褐", Colours.qinyehe),
    ColorCh("胭脂红", Colours.yanzhihong),
    ColorCh("青草绿", Colours.qingcaolv),
    ColorCh("海天蓝", Colours.haitianlan),
    ColorCh("葛巾紫", Colours.geqinzi),
    ColorCh("极光灰", Colours.jiguanghui)
  ];

  @override
  initState() {
    super.initState();

    // progressValue = this.widget.articleIndex / (this.widget.chapters.length - 1);
    animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    animationController.forward();
    this.getLight();
  }

  Future getLight() async {
    light = await lightness.Screen.brightness;
  }

  @override
  void didUpdateWidget(ReaderMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // progressValue = this.widget.articleIndex / (this.widget.chapters.length - 1);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  hide() {
    animationController.reverse();
    Timer(Duration(milliseconds: 200), () {
      this.widget.onTap();
    });
    setState(() {
      isTipVisible = false;
    });
  }

  buildTopView(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration:
            BoxDecoration(color: Colours.paper, boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 8)]),
        height: Screen.navigationBarHeight - 40,
        padding: EdgeInsets.fromLTRB(20, 0, 5, 0),
        child: Row(
          children: <Widget>[
            Container(
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
              child: Text(widget.title),
            )),
            // Container(
            //   width: 21,
            //   child: Image.asset('assets/images/book/read_icon_voice.png'),
            // ),
            // Container(
            //   width: 21,
            //   child: Image.asset('assets/images/book/read_icon_more.png'),
            // ),
          ],
        ),
      ),
    );
  }

  // int currentArticleIndex() {
  //   return ((this.widget.chapters.length - 1) * progressValue).toInt();
  // }
  //
  // buildProgressTipView() {
  //   if (!isTipVisible) {
  //     return Container();
  //   }
  //   Chapter chapter = this.widget.chapters[currentArticleIndex()];
  //   double percentage = chapter.index / (this.widget.chapters.length - 1) * 100;
  //   return Container(
  //     decoration: BoxDecoration(color: Color(0xff00C88D), borderRadius: BorderRadius.circular(5)),
  //     margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
  //     padding: EdgeInsets.all(15),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: <Widget>[
  //         Text(chapter.title, style: TextStyle(color: Colors.white, fontSize: 16)),
  //         Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(color: Colours.lightGray, fontSize: 12)),
  //       ],
  //     ),
  //   );
  // }

  previousArticle() {
    if (this.widget.articleIndex == 0) {
      Toast.show('已经是第一章了');
      return;
    }
    this.widget.onPreviousArticle();
    setState(() {
      isTipVisible = true;
    });
  }

  nextArticle() {
    // if (this.widget.articleIndex == this.widget.chapters.length - 1) {
    //   Toast.show('已经是最后一章了');
    //   return;
    // }
    // this.widget.onNextArticle();
    // setState(() {
    //   isTipVisible = true;
    // });
  }

  // buildProgressView() {
  //   return Container(
  //     padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
  //     child: Row(
  //       children: <Widget>[
  //         GestureDetector(
  //           onTap: previousArticle,
  //           child: Container(
  //             padding: EdgeInsets.all(20),
  //             child: Image.asset('img/read_icon_chapter_previous.png'),
  //           ),
  //         ),
  //         Expanded(
  //           child: Slider(
  //             value: progressValue,
  //             onChanged: (double value) {
  //               setState(() {
  //                 isTipVisible = true;
  //                 progressValue = value;
  //               });
  //             },
  //             onChangeEnd: (double value) {
  //               Chapter chapter = this.widget.chapters[currentArticleIndex()];
  //               this.widget.onToggleChapter(chapter);
  //             },
  //             activeColor: Colours.primary,
  //             inactiveColor: Colours.gray,
  //           ),
  //         ),
  //         GestureDetector(
  //           onTap: nextArticle,
  //           child: Container(
  //             padding: EdgeInsets.all(20),
  //             child: Image.asset('img/read_icon_chapter_next.png'),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  buildLightProgress() {
    return Slider(
      value: light,
      onChanged: (v) {
        setState(() {
          light = v;
          lightness.Screen.setBrightness(v);
        });
      },
      label: "亮度:$light", //气泡的值
      divisions: 10, //进度条上显示多少个刻度点
      max: 1,
      min: 0,
    );
  }

  buildColor() {
    return Container(
      width: Screen.widthOt,
      height: 80,
      color: Colors.black45,
      padding: EdgeInsets.only(top: 20),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(
            _list.length,
            (index) => GestureDetector(
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        color: _list[index].color,
                      ),
                      Text(
                        _list[index].name,
                        style: TextStyle(color: Colors.white),
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
          // buildProgressTipView(),
          lightSlider ? buildLightProgress() : Container(),
          colorSlider ? buildColor() : Container(),
          Container(
            decoration:
                BoxDecoration(color: Colours.paper, boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 8)]),
            padding: EdgeInsets.only(bottom: Screen.bottomSafeHeight),
            child: Column(
              children: <Widget>[
                // buildProgressView(),
                buildBottomMenus(),
              ],
            ),
          )
        ],
      ),
    );
  }

  buildBottomMenus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        buildBottomItem('目录', 'book/read_icon_catalog', 0),
        buildBottomItem('亮度', 'book/read_icon_brightness', 1),
        buildBottomItem('字体', 'book/read_icon_font', 2),
        buildBottomItem('设置', 'book/read_icon_setting', 3),
      ],
    );
  }

  buildBottomItem(String title, String icon, int index) {
    return GestureDetector(
      onTap: () async {
        switch (index) {
          case 0:
            break;
          case 1:
            setState(() {
              lightSlider = true;
            });
            break;
          case 2:
            setState(() {
              colorSlider = true;
            });
            break;
          case 3:
            break;
          default:
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7),
        child: Column(
          children: <Widget>[
            LoadImage(
              icon,
              height: 21,
            ),
            Text(title, style: TextStyle(fontSize: 12, color: Colours.darkGray)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          buildTopView(context),
          buildBottomView(),
        ],
      ),
    );
  }
}
