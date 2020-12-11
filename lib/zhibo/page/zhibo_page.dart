import 'dart:ui';

import 'package:ZY_Player_flutter/model/zhibo_resource.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:ZY_Player_flutter/zhibo/provider/zhibo_provider.dart';
import 'package:ZY_Player_flutter/zhibo/zhibo_router.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vertical_tabs/vertical_tabs.dart';

class ZhiboPage extends StatefulWidget {
  ZhiboPage({Key key}) : super(key: key);

  @override
  _ZhiboPageState createState() => _ZhiboPageState();
}

class _ZhiboPageState extends State<ZhiboPage> with AutomaticKeepAliveClientMixin<ZhiboPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  List<ZhiboResource> _baseListProvider = [];

  ZhiboProvider _zhiboProvider = ZhiboProvider();

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Future getData() async {
    _zhiboProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.getZhiboList,
      onSuccess: (data) {
        List.generate(data.length, (i) => _zhiboProvider.list.add(ZhiboResource.fromJson(data[i])));
        if (data.length == 0) {
          _zhiboProvider.setStateType(StateType.network);
        } else {
          _zhiboProvider.setStateType(StateType.empty);
        }
        setState(() {});
      },
      onError: (code, msg) {
        _zhiboProvider.setStateType(StateType.network);
      },
    );
  }

  Future _onRefresh() async {
    _baseListProvider.clear();
    this.getData();
  }

  List<Tab> tabHeader(List<ZhiboResource> list) {
    return List.generate(list.length, (index) => Tab(child: Text(list[index].name))).toList();
  }

  List<Widget> tabContent(List<ZhiboResource> list) {
    final ThemeData themeData = Theme.of(context);
    final bool isDark = themeData.brightness == Brightness.dark;
    return List.generate(
        list.length,
        (i) => Container(
                child: GridView.builder(
              //将所有子控件在父控件中填满
              shrinkWrap: true,
              //解决ListView嵌套GridView滑动冲突问题
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, //每行几列
                  childAspectRatio: 1),
              itemCount: list[i].m3uResult.length,
              itemBuilder: (context, index) {
                //要返回的item样式
                return GestureDetector(
                  child: Container(
                      width: ScreenUtil.getInstance().getWidth(120),
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.all(Radius.circular(5))),
                      alignment: Alignment.center,
                      child: Text(
                        list[i].m3uResult[index].title,
                        style: TextStyle(
                          color: isDark ? Colours.dark_text : Colors.white,
                        ),
                      )),
                  onTap: () {
                    NavigatorUtils.push(context,
                        '${ZhiboRouter.detailPage}?url=${Uri.encodeComponent(list[i].m3uResult[index].url)}&title=${Uri.encodeComponent(list[i].m3uResult[index].title)}');
                  },
                );
              },
            ))).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider<ZhiboProvider>(
        create: (_) => _zhiboProvider,
        child: Scaffold(
          appBar: MyAppBar(
            isBack: false,
            centerTitle: "直播",
          ),
          body: _zhiboProvider.list.length > 0
              ? SafeArea(
                  child: VerticalTabs(
                  tabsWidth: 150,
                  tabsElevation: 2,
                  backgroundColor: Colors.white10,
                  tabBackgroundColor: Colors.white,
                  disabledChangePageFromContentView: true,
                  changePageCurve: Curves.ease,
                  tabs: tabHeader(_zhiboProvider.list),
                  contents: tabContent(_zhiboProvider.list),
                ))
              : Center(
                  child: StateLayout(type: _zhiboProvider.stateType),
                ),
        ));
  }
}
