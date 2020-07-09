import 'package:ZY_Player_flutter/manhua/manhua_router.dart';
import 'package:ZY_Player_flutter/manhua/provider/manhua_provider.dart';
import 'package:ZY_Player_flutter/model/manhua_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/search_bar.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManhuaSearchPage extends StatefulWidget {
  @override
  _ManhuaSearchPageState createState() => _ManhuaSearchPageState();
}

class _ManhuaSearchPageState extends State<ManhuaSearchPage> with AutomaticKeepAliveClientMixin<ManhuaSearchPage>, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  ManhuaProvider _searchProvider;

  @override
  void initState() {
    super.initState();
    _searchProvider = context.read<ManhuaProvider>();
    _searchProvider.setWords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getSearchWords(String keywords) async {
    _searchProvider.setstate(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.searchManhua, queryParameters: {"keywords": keywords}, onSuccess: (resultList) {
      var data = List.generate(resultList.length, (index) => ManhuaDetail.fromJson(resultList[index]));
      _searchProvider.setList(data);
      _searchProvider.setstate(StateType.empty);
    }, onError: (_, __) {
      _searchProvider.setstate(StateType.network);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isDark = ThemeUtils.isDark(context);

    return Scaffold(
      appBar: SearchBar(
          isBack: false,
          hintText: '请输入漫画名称查询',
          onPressed: (text) {
            Toast.show('搜索内容：$text');
            if (text != "") {
              _searchProvider.addWors(text);
              getSearchWords(text);
            }
          }),
      body: Container(
        child: Column(
          children: <Widget>[
            Consumer<ManhuaProvider>(builder: (_, provider, __) {
              return provider.words.length > 0
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text("历史搜索"),
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: isDark ? Colours.dark_material_bg : Colours.dark_bg_gray,
                                ),
                                onPressed: () {
                                  Log.d("删除搜索");
                                  _searchProvider.clearWords();
                                })
                          ],
                        ),
                        Selector<ManhuaProvider, List>(
                            builder: (_, words, __) {
                              return Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Wrap(
                                    spacing: 10,
                                    runSpacing: 5,
                                    children: words.map<Widget>((s) {
                                      return InkWell(
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isDark ? Colours.dark_material_bg : Colours.bg_gray,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text('$s'),
                                        ),
                                        onTap: () {
                                          //搜索关键词
                                          getSearchWords(s);
                                        },
                                      );
                                    }).toList()),
                              );
                            },
                            selector: (_, store) => store.words)
                      ],
                    )
                  : Container();
            }),
            Expanded(child: Consumer<ManhuaProvider>(builder: (_, provider, __) {
              return provider.list.length > 0
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("搜索结果"),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: ScreenUtil.getInstance().getWidth(491),
                          child: ListView.builder(
                              itemCount: provider.list.length,
                              itemBuilder: (_, index) {
                                return ListTile(
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
                                );
                              }),
                        )
                      ],
                    )
                  : Center(
                      child: StateLayout(type: provider.state),
                    );
            }))
          ],
        ),

        //
      ),
    );
  }
}
