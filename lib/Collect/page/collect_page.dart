import 'dart:developer';

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

class CollectPage extends StatefulWidget {
  @override
  _CollectPageState createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> {
  DetailProvider _detailProvider = DetailProvider();

  BaseListProvider<DetailReource> _baseListProvider = BaseListProvider();

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Future _onRefresh() async {
    var list = SpUtil.getObjList<DetailReource>("collcetPlayer", (data) => DetailReource.fromJson(data));
    _baseListProvider.list.addAll(list);
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
            actions: <Widget>[
              Selector<DetailProvider, List>(
                  builder: (_, listData, __) {
                    return IconButton(
                        icon: listData.contains(_detailProvider.detailReource)
                            ? Icon(
                                Icons.turned_in,
                                color: Colors.red,
                              )
                            : Icon(
                                Icons.turned_in_not,
                                color: Colors.red,
                              ),
                        onPressed: () {
                          if (listData.contains(_detailProvider.detailReource)) {
                            Log.d("点击取消");
                            listData.remove(_detailProvider.detailReource);
                          } else {
                            Log.d("点击收藏");
                            listData.add(_detailProvider.detailReource);
                          }
                          SpUtil.putObjectList("collcetPlayer", listData);
                        });
                  },
                  selector: (_, store) => store.listDetailResource)
            ],
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
                          SpUtil.putObjectList("collcetPlayer", _baseListProvider.list);
                        },
                      ),
                    ],
                  );
                });
          }),
        ));
  }
}
