import 'dart:convert';

import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:flutter/material.dart';

import '../xiaoshuo_router.dart';

class BookshelfItemView extends StatelessWidget {
  final XiaoshuoDetail novel;
  final String readChapId;
  BookshelfItemView(this.novel, this.readChapId);

  @override
  Widget build(BuildContext context) {
    var width = (Screen.widthOt - 15 * 2 - 24 * 2) / 3;
    return GestureDetector(
      onLongPress: () {
        // 长按点击删除
        Log.e("长按点击删除");
      },
      onTap: () {
        String jsonString = jsonEncode(novel);
        // 最后看到的是第几章，跳转到当前章节
        // if (readChapId != "-1") {
        //   NavigatorUtils.push(context,
        //       '${XiaoShuoRouter.contentPage}?id=${novel.id}&chpId=$readChapId&title=${Uri.encodeComponent(novel.name)}');
        // } else {
        //
        // }
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
