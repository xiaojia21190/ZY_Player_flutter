import 'package:ZY_Player_flutter/manhua/manhua_router.dart';
import 'package:ZY_Player_flutter/model/manhua_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/persistent_header_delegate.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManhuaPage extends StatefulWidget {
  ManhuaPage({Key key}) : super(key: key);

  @override
  _ManhuaPageState createState() => _ManhuaPageState();
}

class _ManhuaPageState extends State<ManhuaPage> with AutomaticKeepAliveClientMixin<ManhuaPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  BaseListProvider<ManhuaDetail> _baseListProvider = BaseListProvider();

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Future getData() async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.getHomeManhua,
      onSuccess: (data) {
        List.generate(data.length, (i) => _baseListProvider.list.add(ManhuaDetail.fromJson(data[i])));
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
    this.getData();
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
                      child: Text("点击搜索漫画",
                          style: TextStyle(
                            shadows: [Shadow(color: Colors.redAccent, offset: Offset(6, 3), blurRadius: 10)],
                          )),
                    ),
                  ),
                  onTap: () => NavigatorUtils.push(context, ManhuaRouter.searchPage)),
            ),
          ),
          SliverFillRemaining(
            child: ChangeNotifierProvider<BaseListProvider<ManhuaDetail>>(
                create: (_) => _baseListProvider,
                child: Consumer<BaseListProvider<ManhuaDetail>>(builder: (_, _baseListProvider, __) {
                  return DeerListView(
                      itemCount: _baseListProvider.list.length,
                      stateType: _baseListProvider.stateType,
                      onRefresh: _onRefresh,
                      pageSize: _baseListProvider.list.length,
                      hasMore: _baseListProvider.hasMore,
                      itemBuilder: (_, i) {
                        return ListTile(
                          title: Text(_baseListProvider.list[i].title),
                          subtitle: Text(_baseListProvider.list[i].author),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          leading: LoadImage(
                            _baseListProvider.list[i].cover,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          onTap: () {
                            NavigatorUtils.push(context,
                                '${ManhuaRouter.detailPage}?url=${Uri.encodeComponent(_baseListProvider.list[i].url)}&title=${Uri.encodeComponent(_baseListProvider.list[i].title)}');
                          },
                        );
                      });
                })),
          )
        ],
      )),
    );
  }
}
