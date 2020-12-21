import 'dart:convert';
import 'package:ZY_Player_flutter/model/xiaoshuo_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/utils/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/search_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:ZY_Player_flutter/xiaoshuo/provider/xiaoshuo_provider.dart';
import 'package:ZY_Player_flutter/xiaoshuo/xiaoshuo_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class XiaoShuoSearchSearchPage extends StatefulWidget {
  @override
  _XiaoShuoSearchSearchPageState createState() => _XiaoShuoSearchSearchPageState();
}

class _XiaoShuoSearchSearchPageState extends State<XiaoShuoSearchSearchPage> {
  XiaoShuoProvider _xiaoShuoProvider;
  final FocusNode _focus = FocusNode();
  AppStateProvider _appStateProvider;

  String currentSearchWords = "";

  @override
  void initState() {
    super.initState();
    _xiaoShuoProvider = Store.value<XiaoShuoProvider>(context);
    _appStateProvider = Store.value<AppStateProvider>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getSearchWords(String keywords) async {
    _appStateProvider.setloadingState(true);

    await DioUtils.instance.requestNetwork(Method.get, HttpApi.searchXiaoshuo, queryParameters: {"keywords": keywords}, onSuccess: (resultList) {
      var data = List.generate(resultList.length, (index) => XiaoshuoDetail.fromJson(resultList[index]));
      if (data.length == 0) {
        _xiaoShuoProvider.setStateType(StateType.order);
      } else {
        _xiaoShuoProvider.setStateType(StateType.empty);
      }
      _xiaoShuoProvider.setList(data);
      _appStateProvider.setloadingState(false);
    }, onError: (_, __) {
      _xiaoShuoProvider.setStateType(StateType.network);
      _appStateProvider.setloadingState(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);

    return Scaffold(
      appBar: SearchBar(
          focus: _focus,
          isBack: true,
          hintText: '请输入小说名称或者作者',
          onPressed: (text) {
            Toast.show('搜索内容：$text');
            if (text != "") {
              getSearchWords(text);
            }
          }),
      body: Consumer<XiaoShuoProvider>(builder: (_, provider, __) {
        return provider.list.length > 0
            ? ListView.builder(
                itemCount: provider.list.length,
                itemBuilder: (_, index) {
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(provider.list[index].name),
                      subtitle: Text(provider.list[index].author),
                      leading: LoadImage(
                        provider.list[index].img,
                        fit: BoxFit.cover,
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        String jsonString = jsonEncode(provider.list[index]);
                        NavigatorUtils.push(context, '${XiaoShuoRouter.zjPage}?xiaoshuodetail=${Uri.encodeComponent(jsonString)}');
                      },
                    ),
                  );
                })
            : Center(
                child: StateLayout(
                  type: provider.state,
                ),
              );
      }),
    );
  }
}
