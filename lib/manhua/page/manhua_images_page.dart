import 'package:ZY_Player_flutter/manhua/provider/manhua_provider.dart';
import 'package:ZY_Player_flutter/model/manhua_catlog_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/widgets/app_bar.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManhuaImagePage extends StatefulWidget {
  const ManhuaImagePage({
    Key key,
    @required this.index,
  }) : super(key: key);

  final String index;

  @override
  _ManhuaImagePageState createState() => _ManhuaImagePageState();
}

class _ManhuaImagePageState extends State<ManhuaImagePage> {
  ManhuaProvider _manhuaProvider;
  Catlogs catlogs;
  BaseListProvider<String> _baseListProvider = BaseListProvider();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _manhuaProvider = context.read<ManhuaProvider>();
    currentPage = int.parse(widget.index);
    catlogs = _manhuaProvider.catLog.catlogs[currentPage];
    _onRefresh();
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.imageManhua,
      queryParameters: {"url": catlogs.url},
      onSuccess: (data) {
        _baseListProvider.addAll(List.generate(data.length, (index) => data[index]));
        _baseListProvider.setHasMore(true);
      },
      onError: (code, msg) {
        _baseListProvider.setStateType(StateType.network);
      },
    );
  }

  Future _onRefresh() async {
    _baseListProvider.clear();
    this.getData();
  }

  Future _loadMore() async {
    currentPage++;
    catlogs = _manhuaProvider.catLog.catlogs[currentPage];
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BaseListProvider<String>>(
        create: (_) => _baseListProvider,
        child: Scaffold(
            appBar: MyAppBar(
              title: catlogs.text,
            ),
            body: Consumer<BaseListProvider<String>>(builder: (_, _baseListProvider, __) {
              return DeerListView(
                  itemCount: _baseListProvider.list.length,
                  stateType: _baseListProvider.stateType,
                  onRefresh: _onRefresh,
                  loadMore: _loadMore,
                  pageSize: _baseListProvider.list.length,
                  hasMore: _baseListProvider.hasMore,
                  itemBuilder: (_, index) {
                    return LoadImage(_baseListProvider.list[index]);
                  });
            })));
  }
}
