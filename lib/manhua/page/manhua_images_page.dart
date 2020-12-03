import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManhuaImagePage extends StatefulWidget {
  const ManhuaImagePage({
    Key key,
    @required this.url,
    @required this.title,
  }) : super(key: key);

  final String url;
  final String title;

  @override
  _ManhuaImagePageState createState() => _ManhuaImagePageState();
}

class _ManhuaImagePageState extends State<ManhuaImagePage> {
  BaseListProvider<String> _baseListProvider = BaseListProvider();

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.imageManhua,
      queryParameters: {"url": widget.url},
      onSuccess: (data) {
        _baseListProvider.addAll(List.generate(data.length, (index) => data[index]));
        if (_baseListProvider.list.length == 0) {
          _baseListProvider.setStateType(StateType.order);
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
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BaseListProvider<String>>(
        create: (_) => _baseListProvider,
        child: Scaffold(
            appBar: MyAppBar(
              title: widget.title,
            ),
            body: Consumer<BaseListProvider<String>>(builder: (_, _baseListProvider, __) {
              return DeerListView(
                  itemCount: _baseListProvider.list.length,
                  stateType: _baseListProvider.stateType,
                  onRefresh: _onRefresh,
                  pageSize: _baseListProvider.list.length,
                  hasMore: false,
                  itemBuilder: (_, index) {
                    return LoadImage(_baseListProvider.list[index]);
                  });
            })));
  }
}
