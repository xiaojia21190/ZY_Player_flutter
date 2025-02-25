import 'dart:async';

import 'package:ZY_Player_flutter/net/net.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_cookie_manager_plus/webview_cookie_manager_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  final String title;
  final String url;

  @override
  // ignore: library_private_types_in_public_api
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> with WidgetsBindingObserver {
  late WebViewController _webViewController;
  final cookieManager = WebviewCookieManager();
  bool isLangu = true;
  bool isLoading = true;

  Timer? timer;

  @override
  void initState() {
    cookieManager.clearCookies();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..clearCache()
      ..clearLocalStorage()
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) async {
            Log.d(url);
            if (url.contains("https://bean.m.jd.com/bean/signIndex.action")) {
              final gotCookies = await cookieManager.getCookies('https://bean.m.jd.com/bean/signIndex.action');

              String ptPin = "";
              String ptKey = "";

              for (var item in gotCookies) {
                switch (item.name) {
                  case "pt_pin":
                    ptPin = item.value;
                    break;
                  case "pt_key":
                    ptKey = item.value;
                    break;
                  default:
                }
              }
              // 后台发送cookie
              Log.d("pt_pin======>$ptPin");
              Log.d("pt_key======>$ptKey");
              if (ptPin != "" && ptKey != "") {
                Clipboard.setData(ClipboardData(text: "pt_pin=$ptPin;pt_key=$ptKey;"));
                try {
                  // 直接发送链接
                  await DioUtils.instance.requestNetwork(Method.post, "api/saveCkLyq", queryParameters: {"value": "pt_pin=$ptPin;pt_key=$ptKey;"}, onSuccess: (data) {
                    Toast.show("上传成功,5s后退回到上一个页面!!!!!", duration: 5 * 1000);
                    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
                      if (mounted) {
                        NavigatorUtils.goBack(context);
                      }
                    });
                  }, onError: (_, msg) {
                    Toast.show(msg, duration: 3 * 1000);
                    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
                      NavigatorUtils.goBack(context);
                    });
                  });
                } catch (e) {}
              }
            }
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return; // really exit
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            title: Text(widget.title),
          ),
          body: SafeArea(
              child: Stack(
            children: <Widget>[
              isLoading
                  ? Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : WebViewWidget(controller: _webViewController),
            ],
          ))),
    );
  }
}
