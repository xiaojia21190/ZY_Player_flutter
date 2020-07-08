import 'dart:developer';

import 'package:ZY_Player_flutter/Collect/provider/collect_provider.dart';
import 'package:ZY_Player_flutter/model/detail_reource.dart';
import 'package:ZY_Player_flutter/newest/newest_router.dart';
import 'package:ZY_Player_flutter/newest/provider/detail_provider.dart';
import 'package:ZY_Player_flutter/newest/widget/my_search_bar.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../widgets/load_image.dart';

class CollectPage extends StatefulWidget {
  @override
  _CollectPageState createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> {
  BaseListProvider<DetailReource> _baseListProvider = BaseListProvider();

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Future _onRefresh() async {
    // _baseListProvider.list.addAll(context.read<CollectProvider>().listDetailResource);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BaseListProvider<DetailReource>>(
        create: (_) => _baseListProvider,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colours.app_main,
            title: MySearchBar(),
          ),
          body: Consumer<BaseListProvider<DetailReource>>(builder: (_, provider, __) {
            return DeerListView(
                itemCount: _baseListProvider.list.length,
                stateType: _baseListProvider.stateType,
                onRefresh: _onRefresh,
                pageSize: 100,
                hasMore: false,
                itemBuilder: (_, index) {
                  return Slidable(
                    child: Container(
                      child: ListTile(
                        leading: LoadImage(_baseListProvider.list[index].cover),
                        title: Text(_baseListProvider.list[index].title),
                        subtitle: Text(_baseListProvider.list[index].leixing),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          Log.d('前往详情页');
                          NavigatorUtils.push(context,
                              '${NewestRouter.detailPage}?type=2&index=$index&title=${Uri.encodeComponent(_baseListProvider.list[index].title)}');
                        },
                      ),
                    ),
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: '取消收藏',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () {
                          // 取消收藏
                          _baseListProvider.list.remove(_baseListProvider.list[index]);
                          // context.read<CollectProvider>().removeResource(_baseListProvider.list[index]);
                        },
                      ),
                    ],
                  );
                });
          }),
        ));
  }
}
