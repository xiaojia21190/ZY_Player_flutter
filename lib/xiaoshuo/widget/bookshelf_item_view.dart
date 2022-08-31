import 'dart:convert';

import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/base_dialog.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:flutter/material.dart';

import '../xiaoshuo_router.dart';

class BookshelfItemView extends StatelessWidget {
  final XiaoshuoDetail novel;
  final String readChapId;
  final Function removeChap;
  const BookshelfItemView(this.novel, this.readChapId, {Key? key, required this.removeChap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = (Screen.widthOt - 15 * 2 - 24 * 2) / 3;
    return GestureDetector(
      onLongPress: () {
        // 长按点击删除
        Toast.show("长按点击删除");
        showDialog(
            context: context,
            builder: (_) {
              return BaseDialog(
                  title: "删除图书",
                  onPressed: () {
                    removeChap();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "是否删除${novel.name}",
                    style: const TextStyle(fontSize: 18),
                  ));
            });
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
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DecoratedBox(
              decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 5)]),
              child: LoadImage(
                novel.img,
                width: width,
                height: width / 0.75,
              ),
            ),
            const SizedBox(height: 10),
            Text(novel.name, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
