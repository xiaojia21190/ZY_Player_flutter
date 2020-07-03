import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

import '../newest_router.dart';

class MySearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => NavigatorUtils.push(context, NewestRouter.searchPage),
      child: Container(
        height: 40,
        width: ScreenUtil.getInstance().getWidth(400),
        decoration: BoxDecoration(
          color: Colours.bg_gray,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
              child: Image.asset(
                'assets/images/order_search.png',
                color: Colours.text_gray_c,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 40),
              child: Text(
                "点击搜索",
                style: TextStyle(color: Colours.text_gray_c, fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }
}
