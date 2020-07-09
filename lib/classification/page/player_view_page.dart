import 'package:ZY_Player_flutter/model/resource_data.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/newest/newest_router.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerViewPage extends StatefulWidget {
  const PlayerViewPage({
    Key key,
    @required this.title,
    @required this.keyw,
    this.id,
    this.type = "1",
    this.keywords = "",
  }) : super(key: key);

  final String id;
  final String title;
  final String keyw;
  final String type;
  final String keywords;

  @override
  _PlayerViewPageState createState() => _PlayerViewPageState();
}

class _PlayerViewPageState extends State<PlayerViewPage> {
  BaseListProvider<ResourceData> _baseListProvider = BaseListProvider();
  int _currentPage = 1;
  int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    if (widget.type == "1") {
      await DioUtils.instance.requestNetwork(Method.get, HttpApi.viewReource,
          queryParameters: {"id": widget.id, "key": widget.keyw, "page": _currentPage}, onSuccess: (resultList) {
        _baseListProvider.setStateType(StateType.empty);
        _baseListProvider.setHasMore(true);
        List.generate(resultList.length, (i) => _baseListProvider.add(ResourceData.fromJson(resultList[i])));
      }, onError: (_, __) {
        _baseListProvider.setStateType(StateType.network);
      });
    } else {
      await DioUtils.instance.requestNetwork(Method.get, HttpApi.searchResource,
          queryParameters: {"keywords": widget.keywords, "key": widget.keyw, "page": _currentPage}, onSuccess: (resultList) {
        _baseListProvider.setStateType(StateType.empty);
        _baseListProvider.setHasMore(false);
        List.generate(resultList.length, (i) => _baseListProvider.add(ResourceData.fromJson(resultList[i])));
      }, onError: (_, __) {
        _baseListProvider.setStateType(StateType.network);
      });
    }
  }

  Future _onRefresh() async {
    _baseListProvider.clear();
    this.getData();
  }

  Future _loadMore() async {
    _currentPage++;
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BaseListProvider<ResourceData>>(
        create: (_) => _baseListProvider,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colours.app_main,
            title: Text(widget.title),
          ),
          body: Consumer<BaseListProvider<ResourceData>>(builder: (_, _baseListProvider, __) {
            return DeerListView(
                itemCount: _baseListProvider.list.length,
                stateType: _baseListProvider.stateType,
                onRefresh: _onRefresh,
                loadMore: _loadMore,
                pageSize: _pageSize,
                hasMore: _baseListProvider.hasMore,
                itemBuilder: (_, index) {
                  return ListTile(
                    title: Text(_baseListProvider.list[index].title),
                    subtitle: Text(_baseListProvider.list[index].type),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Log.d('前往详情页');
                      NavigatorUtils.push(context,
                          '${NewestRouter.detailPage}?url=${Uri.encodeComponent(_baseListProvider.list[index].url)}&key=${widget.keyw}&title=${Uri.encodeComponent(_baseListProvider.list[index].title)}&type=1');
                    },
                  );
                });
          }),
        ));
  }
}
