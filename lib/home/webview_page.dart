import 'dart:async';
import 'dart:io';

import 'package:ZY_Player_flutter/util/device_utils.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    Key key,
    @required this.title,
    @required this.url,
    @required this.flag,
  }) : super(key: key);

  final String title;
  final String url;
  final String flag;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> with WidgetsBindingObserver {
  WebViewController _webViewController;
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  bool isLangu = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Device.isAndroid) WebView.platform = SurfaceAndroidWebView();
    if (widget.flag == "1") {
      SystemChrome.setEnabledSystemUIOverlays([]);
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    } else {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (context, snapshot) {
          return WillPopScope(
            onWillPop: () async {
              if (snapshot.hasData) {
                var canGoBack = await snapshot.data.canGoBack();
                if (canGoBack) {
                  // 网页可以返回时，优先返回上一页
                  await snapshot.data.goBack();
                  return Future.value(false);
                }
              }
              SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
              SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
              return Future.value(true);
            },
            child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: MyAppBar(
                  title: widget.title,
                ),
                body: SafeArea(
                    child: Stack(
                  children: <Widget>[
                    WebView(
                      initialUrl: widget.url,
                      javascriptMode: JavascriptMode.unrestricted,
                      navigationDelegate: (NavigationRequest request) {
                        if (request.url.contains("https://m.weibo.cn/login")) {
                          // 微博禁止跳转
                          return NavigationDecision.prevent;
                        } else if (request.url.contains("open=1&utm_medium=QA&utm_content=expand_answer1")) {
                          // 知乎禁止跳转 oia/answers
                          return NavigationDecision.prevent;
                        } else if (request.url.contains("oia/answers")) {
                          // 知乎禁止跳转 oia/answers
                          return NavigationDecision.prevent;
                        } else if (request.url.contains("http://")) {
                          return NavigationDecision.navigate;
                        } else if (request.url.contains("https://")) {
                          return NavigationDecision.navigate;
                        }
                        return NavigationDecision.prevent;
                      },
                      onPageStarted: (String url) {
                        setState(() {
                          isLoading = true;
                        });
                      },
                      onPageFinished: (finish) {
                        setState(() {
                          isLoading = false;
                        });
                        // _webViewController.evaluateJavascript("document.querySelector('.ModalWrap').style = 'display:none'");
                      },
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                        _webViewController = webViewController;
                      },
                    ),
                    isLoading
                        ? Container(
                            color: Colors.black26,
                            child: Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.black26,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ))),
          );
        });
  }
}
