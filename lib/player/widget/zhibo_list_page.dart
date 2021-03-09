import 'package:ZY_Player_flutter/model/zhibo_resource.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
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
                    crossAxisCount: 4, //每行几列
                    childAspectRatio: 0.9),
                itemCount: _zhiboListProvider.list.length,
                itemBuilder: (context, index) {
                  //要返回的item样式
                  return InkWell(
                    child: Column(
                      children: [
                        Gaps.vGap8,
                        Stack(
                          children: [
                            LoadImage(
                              _zhiboListProvider.list[index].cover,
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        Gaps.vGap8,
                        Container(
                          width: 100,
                          child: Text(
                            _zhiboListProvider.list[index].title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                    onTap: () {
                      NavigatorUtils.push(context,
                          '${PlayerRouter.detailZhiboPage}?url=${Uri.encodeComponent(_zhiboListProvider.list[index].url)}&title=${Uri.encodeComponent(_zhiboListProvider.list[index].title)}');
                    },
                  );
                },
              ));
        }));
  }
}
