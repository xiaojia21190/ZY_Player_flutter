import 'package:ZY_Player_flutter/model/zhibo_resource.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../player_router.dart';

class ZhiboListPage extends StatefulWidget {
  @override
  _ZhiboListPageState createState() => _ZhiboListPageState();
}

class _ZhiboListPageState extends State<ZhiboListPage>
    with AutomaticKeepAliveClientMixin<ZhiboListPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  BaseListProvider<M3uResult> _zhiboListProvider = BaseListProvider();

  @override
  void initState() {
    this._getZhiboList();
    super.initState();
  }

  Future _getZhiboList() async {
    _zhiboListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.getZhiboList,
      onSuccess: (data) {
        List.generate(data[0]["m3uResult"].length,
            (i) => _zhiboListProvider.list.add(M3uResult.fromJson(data[0]["m3uResult"][i])));
        if (data.length == 0) {
          _zhiboListProvider.setStateType(StateType.network);
        } else {
          _zhiboListProvider.setStateType(StateType.empty);
        }
        setState(() {});
      },
      onError: (code, msg) {
        _zhiboListProvider.setStateType(StateType.network);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isDark = ThemeUtils.isDark(context);
    return ChangeNotifierProvider<BaseListProvider<M3uResult>>(
        create: (_) => _zhiboListProvider,
        child: Consumer<BaseListProvider<M3uResult>>(builder: (_, _zhiboListProvider, __) {
          return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: GridView.builder(
                //将所有子控件在父控件中填满
                shrinkWrap: true,
                //解决ListView嵌套GridView滑动冲突问题
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, //每行几列
                    childAspectRatio: 1),
                itemCount: _zhiboListProvider.list.length,
                itemBuilder: (context, index) {
                  //要返回的item样式
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 100),
                    columnCount: _zhiboListProvider.list.length,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.blueAccent, borderRadius: BorderRadius.all(Radius.circular(5))),
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(5),
                            child: InkWell(
                                onTap: () {
                                  NavigatorUtils.push(context,
                                      '${PlayerRouter.detailZhiboPage}?url=${Uri.encodeComponent(_zhiboListProvider.list[index].url)}&title=${Uri.encodeComponent(_zhiboListProvider.list[index].title)}');
                                },
                                child: Text(
                                  '${_zhiboListProvider.list[index].title}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark ? Colours.dark_text : Colors.white,
                                  ),
                                ))),
                      ),
                    ),
                  );
                },
              ));
        }));
  }
}
