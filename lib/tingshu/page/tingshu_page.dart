import 'package:ZY_Player_flutter/model/ting_shu_hot.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/tingshu/provider/tingshu_provider.dart';
import 'package:ZY_Player_flutter/tingshu/tingshu_router.dart';
import 'package:ZY_Player_flutter/util/persistent_header_delegate.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class TingShuPage extends StatefulWidget {
  TingShuPage({Key key}) : super(key: key);

  @override
  _TingShuPageState createState() => _TingShuPageState();
}

class _TingShuPageState extends State<TingShuPage>
    with AutomaticKeepAliveClientMixin<TingShuPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  BaseListProvider<AudiList> _baseListProvider = BaseListProvider();
  TingShuProvider tingShuProvider;

  @override
  void initState() {
    super.initState();
    tingShuProvider = Store.value<TingShuProvider>(context);
    getData();
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.getXmlyHot,
      onSuccess: (data) {
        TingShuHot tingShuHot = TingShuHot.fromJson(data);
        List.generate(tingShuHot.audiList.length, (i) => _baseListProvider.add(tingShuHot.audiList[i]));
        List.generate(tingShuHot.rmtj.length, (i) => tingShuProvider.setHotSearch(tingShuHot.rmtj[i]));

        if (data.length == 0) {
          _baseListProvider.setStateType(StateType.network);
        } else {
          _baseListProvider.setStateType(StateType.empty);
        }
      },
      onError: (code, msg) {
        _baseListProvider.setStateType(StateType.network);
      },
    );
  }

  Future _onRefresh() async {
    _baseListProvider.clear();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider<BaseListProvider<AudiList>>(
        create: (_) => _baseListProvider,
        child: Consumer<BaseListProvider<AudiList>>(builder: (_, _baseListProvider, __) {
          return DeerListView(
            itemCount: _baseListProvider.list.length,
            stateType: _baseListProvider.stateType,
            onRefresh: _onRefresh,
            hasRefresh: false,
            pageSize: _baseListProvider.list.length,
            hasMore: _baseListProvider.hasMore,
            itemBuilder: (_, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.only(left: 10, top: 5),
                          child: Shimmer.fromColors(
                            baseColor: Colors.red,
                            highlightColor: Colors.yellow,
                            child: Text(
                              _baseListProvider.list[index].name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                      Gaps.vGap8,
                      Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 20,
                            spacing: 20,
                            children: List.generate(
                                _baseListProvider.list[index].types.length,
                                (i) => InkWell(
                                      child: Column(
                                        children: [
                                          LoadImage(
                                            _baseListProvider.list[index].types[i].cover,
                                            width: 100,
                                            height: 150,
                                            fit: BoxFit.cover,
                                          ),
                                          Gaps.vGap8,
                                          Container(
                                            width: 100,
                                            alignment: Alignment.center,
                                            child: Text(
                                              _baseListProvider.list[index].types[i].title,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Gaps.vGap8,
                                          Container(
                                            width: 100,
                                            alignment: Alignment.center,
                                            child: Text(
                                              _baseListProvider.list[index].types[i].author,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        NavigatorUtils.push(context,
                                            '${TingshuRouter.detailPage}?url=${Uri.encodeComponent(_baseListProvider.list[index].types[i].url)}&title=${Uri.encodeComponent(_baseListProvider.list[index].types[i].title)}');
                                      },
                                    )).toList(),
                          )),
                    ],
                  )),
                ),
              );
            },
            physics: AlwaysScrollableScrollPhysics(),
          );
        }));
  }
}
