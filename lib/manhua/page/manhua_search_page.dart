import 'package:ZY_Player_flutter/classification/classification_router.dart';
import 'package:ZY_Player_flutter/manhua/provider/manhua_provider.dart';
import 'package:ZY_Player_flutter/model/manhua_detail.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/newest/provider/search_provider.dart';
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

class _ManhuaSearchPageState extends State<ManhuaSearchPage> {
  ManhuaSearchProvider _searchProvider = ManhuaSearchProvider();

  @override
  void initState() {
    super.initState();
    _searchProvider.setWords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getSearchWords(String keywords) async {
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.searchManhua,
        queryParameters: {"keywords": keywords},
        onSuccess: (resultList) => {_searchProvider.setList(List.generate(resultList.legnth, (index) => ManhuaDetail.fromJson(resultList[index])))},
        onError: (_, __) {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);

    return ChangeNotifierProvider<ManhuaSearchProvider>(
        create: (_) => _searchProvider,
        child: Scaffold(
          appBar: SearchBar(
              hintText: '请输入漫画名称查询',
              onPressed: (text) {
                Toast.show('搜索内容：$text');
                _searchProvider.addWors(text);
                getSearchWords(text);
              }),
          body: Container(
            child: Column(
              children: <Widget>[
                Consumer<ManhuaSearchProvider>(builder: (_, provider, __) {
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
                            Selector<ManhuaSearchProvider, List>(
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
                                              NavigatorUtils.push(context,
                                                  '${ClassificationtRouter.playerViewPage}?keywords=${Uri.encodeComponent(s)}&title=${Uri.encodeComponent("搜索结果")}&keyw=${SpUtil.getString("selection")}');
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
                Expanded(child: Consumer<ManhuaSearchProvider>(builder: (_, provider, __) {
                  return provider.list.length > 0
                      ? ListView.builder(
                          itemCount: provider.list.length,
                          itemBuilder: (_, index) {
                            return ListTile(
                              title: Text(provider.list[index].title),
                              subtitle: Text(provider.list[index].author),
                              leading: LoadImage(provider.list[index].cover),
                              trailing: Icon(Icons.keyboard_arrow_right),
                              onTap: () {
                                Log.d('前往详情页');
                              },
                            );
                          })
                      : Center(
                          child: StateLayout(type: StateType.empty),
                        );
                }))
              ],
            ),

            //
          ),
        ));
  }
}
