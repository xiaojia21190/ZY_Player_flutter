import 'package:flutter/material.dart';
import 'package:ZY_Player_flutter/widgets/app_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';

class PageNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(
        centerTitle: '页面不存在',
      ),
      body: StateLayout(
        type: StateType.account,
        hintText: '页面不存在',
      ),
    );
  }
}
