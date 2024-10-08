import 'package:ZY_Player_flutter/model/zhibo_resource.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../player_router.dart';

class ZhiboListPage extends StatefulWidget {
  const ZhiboListPage({Key? key}) : super(key: key);

  @override
  _ZhiboListPageState createState() => _ZhiboListPageState();
}

class _ZhiboListPageState extends State<ZhiboListPage> with AutomaticKeepAliveClientMixin<ZhiboListPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  final BaseListProvider<ZhiboResource> _zhiboListProvider = BaseListProvider();

  @override
  void initState() {
    _getZhiboList();
    super.initState();
  }

  Future _getZhiboList() async {
    _zhiboListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.getZhiboList,
      onSuccess: (data) {
        List.generate(data.length, (i) => _zhiboListProvider.list.add(ZhiboResource.fromJson(data[i])));
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

  Future _onRefresh() async {
    _zhiboListProvider.clear();
    _getZhiboList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider<BaseListProvider<ZhiboResource>>(
        create: (_) => _zhiboListProvider,
        child: Consumer<BaseListProvider<ZhiboResource>>(builder: (_, zhiboListProvider, __) {
          return zhiboListProvider.list.isNotEmpty
              ? MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: zhiboListProvider.list.length,
                    scrollDirection: Axis.horizontal,
                    itemExtent: Screen.widthOt,
                    itemBuilder: (__, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.only(left: 10, top: 5),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.red,
                                        highlightColor: Colors.yellow,
                                        child: Text(
                                          zhiboListProvider.list[index].name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )),
                                  Gaps.vGap8,
                                  Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      width: Screen.widthOt,
                                      child: Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        runSpacing: 10,
                                        spacing: 10,
                                        children: List.generate(
                                            zhiboListProvider.list[index].m3uResult.length,
                                            (i) => InkWell(
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: const BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: Text(
                                                      zhiboListProvider.list[index].m3uResult[i].title,
                                                      style: const TextStyle(fontSize: 12, color: Colors.white),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    NavigatorUtils.push(context, '${PlayerRouter.detailZhiboPage}?url=${Uri.encodeComponent(zhiboListProvider.list[index].m3uResult[i].url)}&title=${Uri.encodeComponent(zhiboListProvider.list[index].m3uResult[i].title)}');
                                                  },
                                                )).toList(),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ))
              : StateLayout(
                  type: zhiboListProvider.stateType,
                  onRefresh: _onRefresh,
                );
        }));
  }
}
