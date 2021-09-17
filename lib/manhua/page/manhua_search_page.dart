import 'package:ZY_Player_flutter/manhua/manhua_router.dart';
import 'package:ZY_Player_flutter/manhua/provider/manhua_provider.dart';
import 'package:ZY_Player_flutter/model/manhua_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/search_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManhuaSearchPage extends StatefulWidget {
  @override
  _ManhuaSearchPageState createState() => _ManhuaSearchPageState();
}

class _ManhuaSearchPageState extends State<ManhuaSearchPage> {
  late ManhuaProvider _searchProvider;
  final FocusNode _focus = FocusNode();
  late AppStateProvider _appStateProvider;

  @override
  void initState() {
    super.initState();
    _searchProvider = Store.value<ManhuaProvider>(context);
    _appStateProvider = Store.value<AppStateProvider>(context);

    _searchProvider.setWords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getSearchWords(String keywords) async {
    _searchProvider.list.clear();
    _appStateProvider.setloadingState(true);

    await DioUtils.instance.requestNetwork(Method.get, HttpApi.searchManhua, queryParameters: {"keywords": keywords}, onSuccess: (resultList) {
      var data = List.generate(resultList.length, (index) => Types.fromJson(resultList[index]));
      if (data.length == 0) {
        _searchProvider.setStateType(StateType.order);
      } else {
        _searchProvider.setStateType(StateType.empty);
      }
      _searchProvider.setList(data);
      _appStateProvider.setloadingState(false);
    }, onError: (_, __) {
      _searchProvider.setStateType(StateType.network);
      _appStateProvider.setloadingState(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(
          focus: _focus,
          isBack: true,
          hintText: '请输入漫画名称查询',
          onPressed: (text) {
            Toast.show('搜索内容：$text');
            if (text != "") {
              getSearchWords(text);
            }
          }),
      body: Column(
        children: [
          Expanded(child: Consumer<ManhuaProvider>(builder: (_, provider, __) {
            return provider.list.length > 0
                ? ListView.builder(
                    itemCount: provider.list.length,
                    itemBuilder: (_, index) {
                      return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              side: BorderSide(
                                style: BorderStyle.solid,
                                color: Colours.orange,
                              )),
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(provider.list[index].title),
                            subtitle: Text(provider.list[index].author),
                            leading: LoadImage(
                              provider.list[index].cover,
                              fit: BoxFit.cover,
                            ),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              Log.d('前往详情页');
                              NavigatorUtils.push(context,
                                  '${ManhuaRouter.detailPage}?url=${Uri.encodeComponent(provider.list[index].url)}&title=${Uri.encodeComponent(provider.list[index].title)}');
                            },
                          ));
                    })
                : Center(
                    child: StateLayout(
                      type: provider.state,
                    ),
                  );
          }))
        ],
      ),
    );
  }
}
