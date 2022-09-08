import 'dart:async';

import 'package:ZY_Player_flutter/common/common.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/setting/setting_router.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/click_item.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/my_button.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';
import 'package:fradio_nullsafety/fradio_nullsafety.dart';
import 'package:intl/intl.dart';

/// design/8设置/index.html#artboard1
class AccountManagerPage extends StatefulWidget {
  @override
  _AccountManagerPageState createState() => _AccountManagerPageState();
}

class _AccountManagerPageState extends State<AccountManagerPage> {
  Timer? timer;
  int? tabIndex;
  List<String> money = ["1元7天", "5元一个月", "10三个月", "终身"];
  List<String> moneyInt = ["1元", "5元", "10元", "98元"];

  AppStateProvider? appStateProvider;
  @override
  void initState() {
    super.initState();
    appStateProvider = Store.value<AppStateProvider>(context);
  }

  Future checkStatus() async {
    await DioUtils.instance.requestNetwork(
      Method.get,
      HttpApi.queryJihuo,
      onSuccess: (data) async {
        if (data["order"] == "1") {
          SpUtil.putString(Constant.orderid, data["order"]);
          SpUtil.putString(Constant.jihuoDate, data["jihuoDate"]);
          timer?.cancel();
          Toast.show("激活会员成功！");
          if (mounted) {
            setState(() {});
          }
        }
      },
      onError: (code, msg) {},
    );
  }

  void _getChengMa() async {
    // 激活码
    appStateProvider!.setloadingState(true);
    await DioUtils.instance.requestNetwork(Method.post, HttpApi.zhjfu, params: {"zhifuType": tabIndex}, onSuccess: (data) {
      appStateProvider!.setloadingState(false);
      //点击前往支付宝
      NavigatorUtils.push(context, "${SettingRouter.payPage}?qrcode=${Uri.encodeComponent(data['qrCode'])}&money=${Uri.encodeComponent(moneyInt[tabIndex!])}");
      checkStatus();
      timer = Timer.periodic(const Duration(seconds: 10), (r) => checkStatus());
    }, onError: (_, __) {
      appStateProvider!.setloadingState(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        centerTitle: '会员管理',
      ),
      body: Column(
        children: <Widget>[
          ClickItem(onTap: () {}, title: '会员到期时间', content: "到期时间:${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(int.parse('${SpUtil.getString(Constant.jihuoDate)!}000')))}"),
          Gaps.vGap12,
          Container(
            padding: const EdgeInsets.all(10),
            child: const Text("享有播放视频，听书， 看电视直播，看小说，看漫画。"),
          ),
          Gaps.vGap12,
          SpUtil.getString(Constant.orderid) == "0"
              ? Column(
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: FRadio(
                                width: 80,
                                height: 80,
                                value: index,
                                groupValue: tabIndex,
                                onChanged: (int? value) {
                                  setState(() {
                                    tabIndex = value;
                                  });
                                },
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xffFEFDBB),
                                    Color(0xffFFE16C),
                                    Color(0xffEA9D1C),
                                    Color(0xffD46307),
                                  ],
                                  begin: Alignment(-0.1, -0.9),
                                  end: Alignment(1.0, 1.0),
                                  stops: [0.0, 0.2, 0.7, 1.0],
                                ),
                                selectedColor: const Color(0xffffc900),
                                hasSpace: false,
                                border: 2,
                                hoverChild: Text(
                                  money[index],
                                  style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 13),
                                ),
                                selectedChild: Text(money[index], style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 13)),
                                child: Text(
                                  money[index],
                                  style: const TextStyle(color: Colours.app_main, fontSize: 13),
                                ),
                              ),
                            );
                          }),
                    ),
                    Gaps.vGap12,
                    MyButton(
                      onPressed: () {
                        if (tabIndex == null) {
                          Toast.show("请选择套餐！");
                          return;
                        }
                        Toast.show("$tabIndex");
                        _getChengMa();
                      },
                      minHeight: 30,
                      minWidth: 200,
                      text: "购买会员",
                    ),
                    Gaps.vGap12,
                    const Text("购买成功后，等待刷新状态"),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}
