import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/gaps.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// design/8设置/index.html#artboard1
class PayPage extends StatefulWidget {
  const PayPage({
    Key? key,
    required this.qrcode,
    required this.money,
  }) : super(key: key);

  final String qrcode;
  final String money;

  @override
  _PayPageState createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  AppStateProvider? appStateProvider;
  @override
  void initState() {
    super.initState();
    appStateProvider = Store.value<AppStateProvider>(context);

    Future.microtask(() async {
      var url = Uri.parse("alipayqr://platformapi/startapp?saId=10000007&qrcode=${Uri.encodeComponent(widget.qrcode)}");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        centerTitle: '支付宝支付',
      ),
      body: Column(
        children: <Widget>[
          const Text("手机截图保存到相册使用扫码完成支付"),
          Gaps.vGap10,
          // QrImage(
          //   padding: const EdgeInsets.all(7),
          //   backgroundColor: Colors.white,
          //   data: widget.qrcode,
          //   size: 100,
          // ),
          Gaps.vGap10,
          Text("应付金额：${widget.money}"),
          Gaps.vGap10,
          const Text(
            "(支付完成需要耐心等待一会！！！)",
            style: TextStyle(color: Colors.red),
          ),
          Gaps.vGap10,
          const Divider(
            color: Colors.black12,
          ),
          Gaps.vGap15,
          const Text(
            "正在打开支付宝...",
          ),
          Gaps.vGap10,
          const Text(
            "如果没有打开支付宝",
          ),
          MyButton(
            onPressed: () async {
              var url = Uri.parse("alipayqr://platformapi/startapp?saId=10000007&qrcode=${Uri.encodeComponent(widget.qrcode)}");
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              } else {
                throw 'Could not launch $url';
              }
            },
            minHeight: 30,
            minWidth: 200,
            text: "点击重新唤起支付宝",
          ),
          Gaps.vGap10,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "如果自动打开支付宝无法支付 请关闭支付宝应用后 手动保存二维码 再次打开支付宝扫码支付！",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }
}
