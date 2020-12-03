import 'dart:convert';

import 'package:ZY_Player_flutter/model/hot_home.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';

class HotDetailPage extends StatefulWidget {
  HotDetailPage({
    Key key,
    @required this.contentList,
    @required this.title,
  }) : super(key: key);

  final String contentList;
  final String title;

  @override
  _HotDetailPageState createState() => _HotDetailPageState();
}

class _HotDetailPageState extends State<HotDetailPage> {
  List<ContentList> _list = [];

  @override
  void initState() {
    var resuList = jsonDecode(widget.contentList);

    List.generate(resuList.length, (index) => _list.add(ContentList.fromJson(resuList[index])));

    super.initState();
  }

  Future getData() async {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: widget.title,
      ),
      body: SafeArea(
          child: ListView.builder(
              itemCount: _list.length,
              itemBuilder: (_, i) {
                return ListTile(
                  title: Text(
                    _list[i].title,
                  ),
                  subtitle: Text(_list[i].redu),
                  trailing: Icon(
                    Icons.keyboard_arrow_right,
                  ),
                  onTap: () {
                    NavigatorUtils.goWebViewPage(context, _list[i].title, _list[i].url, flag: "2");
                  },
                );
              })),
    );
  }
}
