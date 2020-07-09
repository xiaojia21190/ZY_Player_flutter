import 'package:ZY_Player_flutter/classification/classification_router.dart';
import 'package:ZY_Player_flutter/newest/provider/search_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/search_bar.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchProvider _searchProvider = SearchProvider();

  @override
  void initState() {
    super.initState();
    _searchProvider.setWords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);

    return ChangeNotifierProvider<SearchProvider>(
        create: (_) => _searchProvider,
        child: Scaffold(
          appBar: SearchBar(
              isBack: true,
              hintText: '请输入资源名称查询',
              onPressed: (text) {
                Toast.show('搜索内容：$text');
                if (text != null) {
                  _searchProvider.addWors(text);
                  NavigatorUtils.push(context,
                      '${ClassificationtRouter.playerViewPage}?keywords=${Uri.encodeComponent(text)}&title=${Uri.encodeComponent(text)}&keyw=zuidazy');
                }
              }),
          body: Container(
            child: Column(
              children: <Widget>[
                Consumer<SearchProvider>(builder: (_, provider, __) {
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
                            Selector<SearchProvider, List>(
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
                })
              ],
            ),
          ),
        ));
  }
}
