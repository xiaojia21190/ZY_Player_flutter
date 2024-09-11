import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManhuaImagePage extends StatefulWidget {
  const ManhuaImagePage({
    Key? key,
    this.url,
    this.title,
  }) : super(key: key);

  final String? url;
  final String? title;

  @override
  _ManhuaImagePageState createState() => _ManhuaImagePageState();
}

class _ManhuaImagePageState extends State<ManhuaImagePage> {
  final BaseListProvider<String> _baseListProvider = BaseListProvider();

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
        if (_baseListProvider.list.isEmpty) {
          _baseListProvider.setStateType(StateType.order);
        } else {
          _baseListProvider.setStateType(StateType.empty);
        }
      },
      onError: (code, msg) {
        Toast.show(msg);
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
    return ChangeNotifierProvider<BaseListProvider<String>>(
        create: (_) => _baseListProvider,
        child: Scaffold(
            appBar: MyAppBar(
              title: widget.title!,
            ),
            body: Column(
              children: [
                Expanded(child: Consumer<BaseListProvider<String>>(builder: (_, baseListProvider, __) {
                  return DeerListView(
                      itemCount: baseListProvider.list.length,
                      stateType: baseListProvider.stateType,
                      onRefresh: _onRefresh,
                      pageSize: baseListProvider.list.length,
                      hasMore: false,
                      itemBuilder: (_, index) {
                        return LoadImage(
                          baseListProvider.list[index],
                          isManhua: true,
                        );
                      });
                })),
              ],
            )));
  }
}
