import 'package:ZY_Player_flutter/classification/classification_router.dart';
import 'package:ZY_Player_flutter/newest/provider/search_provider.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
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
  List<String> seratchWords = [];

  SearchProvider _searchProvider = SearchProvider();

  @override
  void initState() {
    super.initState();

    seratchWords = SpUtil.getStringList("seratchWords");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchProvider>(
        create: (_) => _searchProvider,
        child: Scaffold(
          appBar: SearchBar(
              hintText: '请输入资源名称查询',
              onPressed: (text) {
                Toast.show('搜索内容：$text');
                _searchProvider.addWors(text);
                SpUtil.putStringList("seratchWords", seratchWords);
                NavigatorUtils.push(context,
                    '${ClassificationtRouter.playerViewPage}?keywords=${Uri.encodeComponent(text)}&title=${Uri.encodeComponent(text)}&keyw=zuidazy');
              }),
          body: Container(
            child: Column(
              children: <Widget>[
                seratchWords.length > 0
                    ? Card(
                        shadowColor: Colors.blueAccent,
                        elevation: 2,
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text("历史搜索"),
                                IconButton(
                                    icon: Icon(Icons.delete_forever),
                                    onPressed: () {
                                      Log.d("删除搜索");
                                      _searchProvider.clearWords();
                                    })
                              ],
                            ),
                            Selector<SearchProvider, List>(
                                builder: (_, words, __) {
                                  return Wrap(
                                      spacing: 10,
                                      runSpacing: 5,
                                      children: words.map<Widget>((s) {
                                        return Chip(
                                          label: Text('$s'),
                                          onDeleted: () {
                                            //搜索关键词
                                            NavigatorUtils.push(context,
                                                '${ClassificationtRouter.playerViewPage}?keywords=${Uri.encodeComponent(s)}&title=${Uri.encodeComponent("搜索结果")}&keyw=${SpUtil.getString("selection")}');
                                          },
                                        );
                                      }).toList());
                                },
                                selector: (_, store) => store.words)
                          ],
                        ))
                    : Container()
              ],
            ),
          ),
        ));
  }
}
