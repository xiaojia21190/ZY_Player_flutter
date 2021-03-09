import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/setting/setting_router.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/load_image.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerRecordPage extends StatefulWidget {
  @override
  _PlayerRecordPageState createState() => _PlayerRecordPageState();
}

class _PlayerRecordPageState extends State<PlayerRecordPage> {
  AppStateProvider appStateProvider;

  @override
  void initState() {
    appStateProvider = Store.value<AppStateProvider>(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        actionName: "清空记录",
        centerTitle: '观看记录',
        onPressed: () {
          appStateProvider.clearPlayerRecord();
        },
      ),
      body: Selector<AppStateProvider, List<PlayerModel>>(
          builder: (_, recordList, __) {
            return recordList.length > 0
                ? ListView.builder(
                    itemCount: recordList.length,
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
                            title: Text(recordList[index].name),
                            subtitle: Text(
                                "播放进度:  ${Duration(seconds: int.parse(recordList[index].startAt)).toString().split(".")[0]}"),
                            leading: LoadImage(
                              recordList[index].cover,
                              fit: BoxFit.cover,
                            ),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              // 前往播放页面
                              NavigatorUtils.push(context,
                                  "${SettingRouter.playerVideoPage}?url=${Uri.encodeComponent(recordList[index].url)}&title=${Uri.encodeComponent(recordList[index].name)}&videoId=${Uri.encodeComponent(recordList[index].videoId)}&cover=${Uri.encodeComponent(recordList[index].cover)}&startAt=${Uri.encodeComponent(recordList[index].startAt)}");
                            },
                          ));
                    })
                : Container();
          },
          selector: (_, store) => store.playerList),
    );
  }
}
