import 'dart:convert';
import 'dart:math';

import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/xiaoshuo/provider/xiaoshuo_provider.dart';
import 'package:flutter/material.dart';

import '../xiaoshuo_router.dart';
import 'bookshelf_cloud_widget.dart';

class BookshelfHeader extends StatefulWidget {
  final XiaoshuoDetail novel;

  BookshelfHeader(this.novel);

  @override
  _BookshelfHeaderState createState() => _BookshelfHeaderState();
}

class _BookshelfHeaderState extends State<BookshelfHeader> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  XiaoShuoProvider _xiaoShuoProvider = XiaoShuoProvider();

  @override
  initState() {
    _xiaoShuoProvider = Store.value<XiaoShuoProvider>(context);
    controller = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
    controller.forward();

    super.initState();
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = Screen.widthOt;
    var bgHeight = width / 0.9;
    var height = Screen.topSafeHeight + 200;
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: height - bgHeight,
            child: Image.asset(
              'assets/images/book/bookshelf_bg.png',
              fit: BoxFit.cover,
              width: width,
              height: bgHeight,
            ),
          ),
          Positioned(
            bottom: 0,
            child: BookshelfCloudWidget(
              animation: animation,
              width: width,
            ),
          ),
          buildContent(context),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    XiaoshuoDetail novel = this.widget.novel;

    var width = Screen.widthOt;
    return Container(
      width: width,
      padding: EdgeInsets.fromLTRB(15, Screen.topSafeHeight, 10, 10),
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          String jsonString = jsonEncode(novel);
          int index = _xiaoShuoProvider.readList.lastIndexWhere((element) => element.split("_")[0] == novel.id);
          if (index >= 0) {
            NavigatorUtils.push(context,
                '${XiaoShuoRouter.contentPage}?id=${novel.id}&chpId=${_xiaoShuoProvider.readList[index].split("_")[1]}&title=${Uri.encodeComponent(novel.name)}');
          } else {
            NavigatorUtils.push(context, '${XiaoShuoRouter.zjPage}?xiaoshuodetail=${Uri.encodeComponent(jsonString)}');
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DecoratedBox(
              child: LoadImage(
                novel.img,
                width: 130,
              ),
              decoration: BoxDecoration(boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 8)]),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10),
                  Text(novel.name, style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  Row(
                    children: <Widget>[
                      Text(' 读至${Random.secure().nextInt(100)}%     继续阅读 ',
                          style: TextStyle(fontSize: 14, color: Colours.paper)),
                      Image.asset('assets/images/book/bookshelf_continue_read.png'),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
