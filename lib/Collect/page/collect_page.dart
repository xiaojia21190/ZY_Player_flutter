import 'dart:convert';

import 'package:ZY_Player_flutter/Collect/collect_router.dart';
import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/main.dart';
import 'package:ZY_Player_flutter/manhua/manhua_router.dart';
import 'package:ZY_Player_flutter/player/player_router.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/tingshu/tingshu_router.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../widgets/load_image.dart';

class CollectPage extends StatefulWidget {

  const CollectPage({
    Key? key,
    required this.catIndex,
  }) : super(key: key);

  final String catIndex;
  @override
  _CollectPageState createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> with AutomaticKeepAliveClientMixin<CollectPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  CollectProvider? _collectProvider;
  int changeIndex = 0;
  @override
  void initState() {
    _collectProvider = Store.value<CollectProvider>(context);
    changeIndex = int.parse(widget.catIndex);
    super.initState();
  }

  Widget getData(data, int index) {
    var bofang = "12万";
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          side: BorderSide(
            style: BorderStyle.solid,
            color: Colours.orange,
          )),
      child: ListTile(
        title: Text(data.title),
        subtitle: index == 1 ? Text("播放量:${data.bofang ?? bofang}") : Text(data.gengxin),
        trailing: Icon(Icons.keyboard_arrow_right),
        leading: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: LoadImage(
            data.cover,
            height: 60,
          ),
        ),
        onTap: () {
          Log.d('前往详情页');
          if (index == 1) {
            String jsonString = jsonEncode(data);
            NavigatorUtils.push(context, '${PlayerRouter.detailPage}?playerList=${Uri.encodeComponent(jsonString)}');
          } else if(index == 2) {
            NavigatorUtils.push(context, '${ManhuaRouter.detailPage}?url=${Uri.encodeComponent(data.url)}&title=${Uri.encodeComponent(data.title)}');
          }else{
            NavigatorUtils.push(context, '${TingshuRouter.detailPage}?url=${Uri.encodeComponent(data.url)}&title=${Uri.encodeComponent(data.title)}&cover=${Uri.encodeComponent(data.cover)}');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    super.build(context);
    return Scaffold(
      appBar: MyAppBar(centerTitle: changeIndex == 1 ? '影视收藏' : changeIndex == 2?'漫画收藏':'听书收藏' ,),
      body: Container(
        color: isDark ? Colours.dark_bg_gray_ : Color(0xfff5f5f5),
        child: Selector<CollectProvider, dynamic>(builder: (_, list, __) {
          return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, index) {
                return Slidable(
                  child: getData(list[index], changeIndex),
                  startActionPane: ActionPane(
                    // A motion is a widget used to control how the pane animates.
                    motion: const ScrollMotion(),

                    // A pane can dismiss the Slidable.
                    dismissible: DismissiblePane(onDismissed: () {}),

                    // All actions are defined in the children parameter.
                    children: [
                      // A SlidableAction can have an icon and/or a label.
                      SlidableAction(
                        onPressed: (__) {
                          // 取消收藏
                          if (changeIndex == 1) {
                            // 影视
                            _collectProvider!.removeResource(list[index].url);
                          } else if(changeIndex == 2) {
                            // 漫画
                            _collectProvider!.removeCatlogResource(list[index].url);
                          }else{
                            _collectProvider!.removeTingshu(list[index].id);
                          }
                          setState(() {});
                        },
                        backgroundColor: Color(0xFFFE4A48),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: '取消收藏',
                      ),
                    ],
                  ),
                );
              });
        }, selector: (_, store) {
          if (changeIndex == 1) {
            return store.listDetailResource;
          }else if(changeIndex == 2){
            return store.manhuaCatlog;
          }
          return store.list;
        }),
      ),
    );
  }
}
