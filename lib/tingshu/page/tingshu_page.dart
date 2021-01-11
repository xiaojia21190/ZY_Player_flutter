import 'package:ZY_Player_flutter/model/ting_shu_hot.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/tingshu/provider/tingshu_provider.dart';
import 'package:ZY_Player_flutter/tingshu/tingshu_router.dart';
import 'package:ZY_Player_flutter/util/persistent_header_delegate.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
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

class _TingShuPageState extends State<TingShuPage> with AutomaticKeepAliveClientMixin<TingShuPage>, SingleTickerProviderStateMixin {
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
    return Scaffold(
      body: SafeArea(
          child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            // 属性同 SliverAppBar
            pinned: true,
            floating: true,
            // 因为 SliverPersistentHeaderDelegate 是一个抽象类，所以需要自定义
            delegate: CustomSliverPersistentHeaderDelegate(
              max: 50.0,
              min: 0.0,
              child: GestureDetector(
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Center(
                      child: Text("点击搜索小说",
                          style: TextStyle(
                            shadows: [Shadow(color: Colors.redAccent, offset: Offset(6, 3), blurRadius: 10)],
                          )),
                    ),
                  ),
                  onTap: () => NavigatorUtils.push(context, TingshuRouter.searchPage)),
            ),
          ),
          SliverFillRemaining(
            child: ChangeNotifierProvider<BaseListProvider<AudiList>>(
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
                                child: GridView.builder(
                                  //将所有子控件在父控件中填满
                                  shrinkWrap: true,
                                  //解决ListView嵌套GridView滑动冲突问题
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3, //每行几列
                                      childAspectRatio: 0.58),
                                  itemCount: _baseListProvider.list[index].types.length,
                                  itemBuilder: (context, i) {
                                    //要返回的item样式
                                    return InkWell(
                                      child: Column(
                                        children: [
                                          LoadImage(
                                            _baseListProvider.list[index].types[i].cover,
                                            width: 100,
                                            height: 150,
                                            fit: BoxFit.cover,
                                          ),
                                          Gaps.vGap8,
                                          Text(
                                            _baseListProvider.list[index].types[i].title,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            _baseListProvider.list[index].types[i].author,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        NavigatorUtils.push(context,
                                            '${TingshuRouter.detailPage}?url=${Uri.encodeComponent(_baseListProvider.list[index].types[i].url)}&title=${Uri.encodeComponent(_baseListProvider.list[index].types[i].title)}');
                                      },
                                    );
                                  },
                                ),
                              )
                            ],
                          )),
                        ),
                      );
                    },
                    physics: AlwaysScrollableScrollPhysics(),
                  );
                })),
          )
        ],
      )),
    );
  }
}
