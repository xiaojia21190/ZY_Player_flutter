import 'dart:convert';

import 'package:ZY_Player_flutter/model/xiaoshuo_chap.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_scroll_view.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:ZY_Player_flutter/xiaoshuo/provider/xiaoshuo_provider.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:provider/provider.dart';

class XiaoShuoDetailPage extends StatefulWidget {
  XiaoShuoDetailPage({
    Key key,
    @required this.xiaoshuodetail,
  }) : super(key: key);

  final String xiaoshuodetail;

  @override
  _XiaoShuoDetailPageState createState() => _XiaoShuoDetailPageState();
}

class _XiaoShuoDetailPageState extends State<XiaoShuoDetailPage> {
  XiaoShuoProvider _xiaoShuoProvider;

  XiaoshuoDetail _detail;

  int page = 0;

  @override
  void initState() {
    _detail = XiaoshuoDetail.fromJson(jsonDecode(widget.xiaoshuodetail));
    _xiaoShuoProvider = Store.value<XiaoShuoProvider>(context);
    fetchData();
    super.initState();
  }

  Future fetchData() async {
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getSearchXszjDetail, queryParameters: {"id": _detail.id, "page": page},
        onSuccess: (resultList) {
      if (resultList == null) {
        _xiaoShuoProvider.setStateType(StateType.order);
      } else {
        _xiaoShuoProvider.setStateType(StateType.empty);
      }
      _xiaoShuoProvider.setChpList(XiaoshuoChap.fromJson(resultList));
    }, onError: (_, __) {
      _xiaoShuoProvider.setStateType(StateType.network);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    return Scaffold(
      backgroundColor: isDark ? Colours.dark_bg_color : Colours.white,
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                forceElevated: innerBoxIsScrolled,
                centerTitle: true,
                backgroundColor: Colours.dark_bg_color,
                elevation: 0,
                floating: false,
                pinned: true,
                snap: false,
                expandedHeight: ScreenUtil.getInstance().getWidth(200),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    _detail.name,
                  ),
                  background: LoadImage(_detail.img),
                ),
                actions: [
                  Selector<XiaoShuoProvider, List<XiaoshuoDetail>>(
                      builder: (_, list, __) {
                        return TextButton(
                            onPressed: () {
                              if (list.where((element) => element.id == _detail.id).toList().length > 0) {
                                _xiaoShuoProvider.removeXiaoshuoResource(_detail.id);
                              } else {
                                _xiaoShuoProvider.addXiaoshuoResource(_detail);
                              }
                            },
                            child: TextButton(
                                onPressed: null,
                                child: list.where((element) => element.id == _detail.id).toList().length > 0
                                    ? Text(
                                        "移出书架",
                                        style: TextStyle(color: Colours.white),
                                      )
                                    : Text(
                                        "加入书架",
                                        style: TextStyle(color: Colours.white),
                                      )));
                      },
                      selector: (_, store) => store.xiaoshuo)
                ],
              ),
            ];
          },
          body: SliverFixedExtentList(
            itemExtent: 50.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.lightBlue[100 * (index % 9)],
                  child: Text('list item $index'),
                );
              },
            ),
          )
          // Column(
          //   children: [
          //     Container(
          //       width: Screen.widthOt,
          //       margin: EdgeInsets.all(10),
          //       child: GestureDetector(
          //         onTap: () {
          //           Toast.show(_detail.lastChapter);
          //         },
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               "最新章节",
          //               style: TextStyles.textBold16,
          //             ),
          //             Text(
          //               _detail.lastChapter,
          //               style: TextStyles.textBold16,
          //             )
          //           ],
          //         ),
          //       ),
          //     ),
          //     Expanded(
          //       child: Selector<XiaoShuoProvider, XiaoshuoChap>(
          //           builder: (_, chp, __) {
          //             return chp != null
          //                 ? Column(
          //                     children: [
          //                       Text(
          //                         chp.name,
          //                         style: TextStyles.textBold16,
          //                       ),
          //                       // ListView.builder(
          //                       //   itemBuilder: (_, index) {
          //                       //     return Text(chp.chpList[index].name);
          //                       //   },
          //                       //   itemCount: chp.chpList.length,
          //                       // )
          //                     ],
          //                   )
          //                 : StateLayout(type: _xiaoShuoProvider.state);
          //           },
          //           selector: (_, store) => store.chplist),
          //     )
          //   ],
          // ),
          ),
    );
  }
}
