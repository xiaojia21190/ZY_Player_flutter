import 'dart:async';

import 'package:ZY_Player_flutter/net/net.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
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
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> with WidgetsBindingObserver {
  WebViewController? _webViewController;
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  final CookieManager cookieManager = CookieManager();

  bool isLangu = true;
  bool isLoading = true;

  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (context, snapshot) {
          return WillPopScope(
            onWillPop: () async {
              if (snapshot.hasData) {
                var canGoBack = await snapshot.data!.canGoBack();
                if (canGoBack) {
                  // 网页可以返回时，优先返回上一页
                  await snapshot.data!.goBack();
                  return Future.value(false);
                }
              }
              return Future.value(true);
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
                    WebView(
                      initialUrl: widget.url,
                      javascriptMode: JavascriptMode.unrestricted,
                      navigationDelegate: (NavigationRequest request) async {
                        return NavigationDecision.navigate;
                      },
                      onPageStarted: (String url) async {
                        Log.d(url);

                        if (url.indexOf("https://bean.m.jd.com/bean/signIndex.action") >= 0) {
                          final cookieManager = WebviewCookieManager();
                          final gotCookies = await cookieManager.getCookies('https://bean.m.jd.com/bean/signIndex.action');

                          String ptPin = "";
                          String ptKey = "";

                          for (var item in gotCookies) {
                            print(item);
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
                                timer = Timer.periodic(Duration(seconds: 5), (timer) {
                                  NavigatorUtils.goBack(context);
                                });
                              }, onError: (_, msg) {
                                Toast.show(msg, duration: 3 * 1000);
                                timer = Timer.periodic(Duration(seconds: 3), (timer) {
                                  NavigatorUtils.goBack(context);
                                });
                              });
                            } catch (e) {}
                          }
                        }
                        setState(() {
                          isLoading = true;
                        });
                      },
                      onPageFinished: (finish) async {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                        _webViewController = webViewController;
                        _webViewController?.clearCache();
                        cookieManager.clearCookies();
                      },
                    ),
                    isLoading
                        ? Container(
                            color: Colors.black26,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Container(),
                  ],
                ))),
          );
        });
  }
}
