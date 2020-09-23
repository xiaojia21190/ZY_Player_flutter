import 'dart:async';

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
    if (widget.flag == "1") {
      SystemChrome.setEnabledSystemUIOverlays([]);
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    } else {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("--" + state.toString());
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        _webViewController.evaluateJavascript('document.querySelector("#a1").getAttribute("class").indexOf("paused");').then((value) {
          if (int.parse(value) == -1) {
            _webViewController.evaluateJavascript('document.querySelector(".dplayer-play-icon").click()');
          }
        });
        break;
      case AppLifecycleState.detached:
        break;
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
                body: Stack(
                  children: <Widget>[
                    WebView(
                      initialUrl: widget.url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onPageStarted: (aa) {
                        setState(() {
                          isLoading = true;
                        });
                      },
                      onPageFinished: (finish) {
                        setState(() {
                          isLoading = false;
                        });
                        _webViewController.evaluateJavascript(
                            'document.querySelector("#dibecjqswyi").style = "display:none";document.querySelector("#dompcejubvkui").style = "display:none";await document.body.requestFullscreen()');
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
                        : Positioned(
                            top: 20,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                BackButton(
                                  color: Colors.redAccent,
                                  onPressed: () {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    Navigator.maybePop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                  ],
                )),
          );
        });
  }
}
