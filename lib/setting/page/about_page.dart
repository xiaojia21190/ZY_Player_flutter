

import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/click_item.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: '关于我们',
      ),
      body: Column(
        children: <Widget>[
          Gaps.vGap50,
          const LoadImage("logo"),
          Gaps.vGap10,
          ClickItem(title: '公众号', content: '关注公众号《墨鱼玩》', onTap: () => Toast.show("关注公众号《墨鱼玩》")),
        ],
      ),
    );
  }
}
