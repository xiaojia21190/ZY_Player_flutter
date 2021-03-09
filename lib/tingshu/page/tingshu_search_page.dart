import 'dart:ui';

import 'package:ZY_Player_flutter/model/ting_shu_search.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/tingshu/provider/tingshu_provider.dart';
import 'package:ZY_Player_flutter/tingshu/tingshu_router.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TingshuSearchPage extends StatefulWidget {
  @override
  _TingshuSearchPageState createState() => _TingshuSearchPageState();
}

class _TingshuSearchPageState extends State<TingshuSearchPage> {
  final FocusNode _focus = FocusNode();
  AppStateProvider _appStateProvider;
  TingShuProvider _searchProvider;

  @override
  void initState() {
    super.initState();
    _searchProvider = Store.value<TingShuProvider>(context);
    _appStateProvider = Store.value<AppStateProvider>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getSearchWords(String keywords, String api) async {
    _focus.unfocus();
    _searchProvider.list.clear();
    _appStateProvider.setloadingState(true);

    await DioUtils.instance.requestNetwork(Method.get, api, queryParameters: {"searchword": keywords},
        onSuccess: (resultList) {
      List.generate(
          resultList.length, (index) => _searchProvider.setSearchList(TingShuSearch.fromJson(resultList[index])));
      _appStateProvider.setloadingState(false);
    }, onError: (_, __) {
      _appStateProvider.setloadingState(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchBar(
          focus: _focus,
          isBack: true,
          hintText: '请输入小说或作者名称查询',
          onPressed: (text) {
            Toast.show('搜索内容：$text');
            if (text != "") {
              getSearchWords(text, HttpApi.getXmlySearch);
            }
          }),
      body: Column(
        children: [
          Wrap(
            runSpacing: -10,
            children: List.generate(
                _searchProvider.hotSearch.length,
                (index) => TextButton(
                      onPressed: () => getSearchWords(_searchProvider.hotSearch[index].url, HttpApi.getXmlyHotSearch),
                      child: Text(_searchProvider.hotSearch[index].name),
                      style: ButtonStyle(textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontSize: 12))),
                    )).toList(),
          ),
          Expanded(child: Consumer<TingShuProvider>(builder: (_, provider, __) {
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
                                  '${TingshuRouter.detailPage}?url=${Uri.encodeComponent(provider.list[index].url)}&title=${Uri.encodeComponent(provider.list[index].title)}');
                            },
                          ));
                    })
                : Container();
          }))
        ],
      ),
    );
  }
}
