import 'package:ZY_Player_flutter/classification/classification_router.dart';
import 'package:ZY_Player_flutter/home/provider/player_resource_provider.dart';
import 'package:ZY_Player_flutter/newest/newest_router.dart';
import 'package:ZY_Player_flutter/newest/widget/my_search_bar.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassificationPage extends StatefulWidget {
  @override
  _ClassificationPageState createState() => _ClassificationPageState();
}

class _ClassificationPageState extends State<ClassificationPage>
    with AutomaticKeepAliveClientMixin<ClassificationPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  PlayerResourceProvider playerResourceProvider;
  int _clickIndex = 0;

  @override
  void initState() {
    super.initState();
    playerResourceProvider = context.read<PlayerResourceProvider>();
    Log.d(playerResourceProvider.taps.toString());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: MySearchBar(),
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.blueAccent))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: ScreenUtil.getInstance().getWidth(90),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.blueAccent)),
                    ),
                    child: ListView.builder(
                        itemCount: playerResourceProvider.taps.length,
                        itemBuilder: (_, index) {
                          return InkWell(
                              onTap: () {
                                Log.d("111");
                                setState(() {
                                  _clickIndex = index;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.symmetric(vertical: 5),
                                // color: Colors.blueAccent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    _clickIndex == index
                                        ? Container(
                                            color: Colors.red,
                                            padding: EdgeInsets.only(top: 10, bottom: 10),
                                            width: 4,
                                          )
                                        : Container(
                                            width: 4,
                                          ),
                                    Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Text(
                                        playerResourceProvider.taps[index]["name"],
                                        style: TextStyle(color: Colours.dark_line),
                                      ),
                                    )
                                  ],
                                ),
                              ));
                        }),
                  ),
                  Expanded(
                      child: Wrap(
                    spacing: 12, // 主轴(水平)方向间距
                    runSpacing: 10, // 纵轴（垂直）方向间距
                    alignment: WrapAlignment.start, //沿主轴方向居中
                    children: List.generate(playerResourceProvider.resourceList[_clickIndex].tags.length, (index) {
                      return InkWell(
                        onTap: () {
                          var tagsData = playerResourceProvider.resourceList[_clickIndex].tags[index];
                          NavigatorUtils.push(context,
                              '${ClassificationtRouter.playerViewPage}?id=${tagsData.id}&title=${Uri.encodeComponent(tagsData.title)}&keyw=${playerResourceProvider.resourceList[_clickIndex].key}');
                        },
                        child: Chip(
                          avatar: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                playerResourceProvider.resourceList[_clickIndex].tags[index].title.substring(0, 1),
                                style: TextStyle(fontSize: 12),
                              )),
                          label: Text(playerResourceProvider.resourceList[_clickIndex].tags[index].title),
                        ),
                      );
                    }).toList(),
                  )),
                ],
              ),
            )));
  }
}
