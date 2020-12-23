import 'package:ZY_Player_flutter/event/event_bus.dart';
import 'package:ZY_Player_flutter/event/event_model.dart';
import 'package:ZY_Player_flutter/model/manhua_detail.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_chap.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_content.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/util/ReaderPageAgent.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/my_scroll_view.dart';
import 'package:ZY_Player_flutter/xiaoshuo/provider/xiaoshuo_provider.dart';
import 'package:ZY_Player_flutter/xiaoshuo/widget/batter_view.dart';
import 'package:ZY_Player_flutter/xiaoshuo/widget/reader_memu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class XiaoShuoContentPage extends StatefulWidget {
  XiaoShuoContentPage({
    Key key,
    @required this.id,
    @required this.chpId,
    @required this.title,
  }) : super(key: key);

  final String id;
  final String chpId;
  final String title;

  @override
  _XiaoShuoContentPageState createState() => _XiaoShuoContentPageState();
}

class _XiaoShuoContentPageState extends State<XiaoShuoContentPage> {
  AppStateProvider _appStateProvider;
  XiaoShuoProvider _xiaoShuoProvider;
  BaseListProvider<XiaoshuoContent> _baseListProvider = BaseListProvider();

  List<Map<String, int>> chpPage;
  double opacityLevel = 0.0;

  bool hasMore = false;
  int chapid = 0;
  String title = "";

  @override
  void initState() {
    _appStateProvider = Store.value<AppStateProvider>(context);
    _xiaoShuoProvider = Store.value<XiaoShuoProvider>(context);
    _appStateProvider.setConfig();
    title = widget.title;
    fetchData(int.parse(widget.chpId));
    ApplicationEvent.event.on<LoadXiaoShuoEvent>().listen((event) {
      _baseListProvider.clear();
      title = event.title;
      opacityLevel = 0.0;
      setState(() {});
      fetchData(event.chpId);
    });
    super.initState();
  }

  Future fetchData([int chaId]) async {
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getxiaoshuoDetail, queryParameters: {"id": widget.id, "capid": chaId},
        onSuccess: (result) {
      _xiaoShuoProvider.setReadList(XiaoshuoList(result["cid"], result["cname"], 1));
      _baseListProvider.add(XiaoshuoContent.fromJson(result));
    }, onError: (_, __) {});
  }

  Future loadMore() async {
    if (_baseListProvider.list[_baseListProvider.list.length - 1].nid != -1) {
      fetchData(_baseListProvider.list[_baseListProvider.list.length - 1].nid);
    } else {
      _baseListProvider.setHasMore(false);
      setState(() {});
      Toast.show("已经到最后了");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AppStateProvider, Color>(
        builder: (_, colorCh, __) {
          return Scaffold(
              backgroundColor: colorCh,
              body: SafeArea(
                child: Stack(
                  children: <Widget>[
                    ReaderOverlayer(title: title, page: 1, topSafeHeight: Screen.topSafeHeight),
                    buildContent(),
                    AnimatedOpacity(
                      opacity: opacityLevel,
                      duration: new Duration(milliseconds: 300),
                      child: ReaderMenu(title: title, id: widget.id),
                    )
                  ],
                ),
              ));
        },
        selector: (_, store) => store.xsColor);
  }

  buildContent() {
    return ChangeNotifierProvider<BaseListProvider<XiaoshuoContent>>(
        create: (_) => _baseListProvider,
        child: Consumer2<BaseListProvider<XiaoshuoContent>, AppStateProvider>(builder: (_, _baseListProvider, appStateProvider, __) {
          return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: DeerListView(
                itemCount: _baseListProvider.list.length,
                stateType: _baseListProvider.stateType,
                // onRefresh: _onRefresh,
                hasRefresh: false,
                pageSize: _baseListProvider.list.length,
                hasMore: _baseListProvider.hasMore,
                loadMore: loadMore,
                itemBuilder: (_, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                          child: GestureDetector(
                              onTap: () {
                                opacityLevel = opacityLevel == 0 ? 1.0 : 0.0;
                                setState(() {});
                              },
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Text(_baseListProvider.list[index].cname, style: TextStyle(fontSize: 14, color: Colours.golden)),
                                  ),
                                  Container(
                                    color: Colors.transparent,
                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                    child: Text.rich(
                                      TextSpan(children: [
                                        TextSpan(
                                            text: _baseListProvider.list[index].content,
                                            style: TextStyle(
                                                fontSize: appStateProvider.xsFontSize,
                                                color: appStateProvider.xsColor == Colors.black ? Colours.dark_text : Colours.text))
                                      ]),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ],
                              ))),
                    ),
                  );
                },
              ));
        }));
  }
}

class ReaderOverlayer extends StatelessWidget {
  final String title;
  final int page;
  final double topSafeHeight;

  ReaderOverlayer({this.title, this.page, this.topSafeHeight});

  @override
  Widget build(BuildContext context) {
    var format = DateFormat('HH:mm');
    var time = format.format(DateTime.now());

    return Container(
      padding: EdgeInsets.fromLTRB(15, 10 + topSafeHeight, 15, 10 + Screen.bottomSafeHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: Container()),
          Row(
            children: <Widget>[
              BatteryView(),
              SizedBox(width: 10),
              Text(time, style: TextStyle(fontSize: 11, color: Colours.golden)),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }
}
