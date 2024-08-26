import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:flutter/material.dart';

class EmptyWebview extends StatelessWidget {
  const EmptyWebview();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          NavigatorUtils.goWebViewPage(
            context,
            "京东短信登陆",
            "https://bean.m.jd.com/bean/signIndex.action",
          );
        },
        child: const Center(
          child: Text('点击京东短信登陆', style: TextStyle(fontSize: 20, color: Colors.red)),
        ),
      ),
    );
  }
}
