import 'dart:convert';

import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:flutter/material.dart';

import '../xiaoshuo_router.dart';

class BookshelfItemView extends StatelessWidget {
  final XiaoshuoDetail novel;
  BookshelfItemView(this.novel);

  @override
  Widget build(BuildContext context) {
    var width = (Screen.widthOt - 15 * 2 - 24 * 2) / 3;
    return GestureDetector(
      onTap: () {
        String jsonString = jsonEncode(novel);
        NavigatorUtils.push(context, '${XiaoShuoRouter.zjPage}?xiaoshuodetail=${Uri.encodeComponent(jsonString)}');
      },
      child: Container(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DecoratedBox(
              child: LoadImage(
                novel.img,
                width: width,
                height: width / 0.75,
              ),
              decoration: BoxDecoration(boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 5)]),
            ),
            SizedBox(height: 10),
            Text(novel.name, style: TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
