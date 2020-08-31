import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    Key key,
    @required this.title,
    @required this.url,
    this.flag = "1",
  }) : super(key: key);

  final String title;
  final String url;
  final String flag;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController _webViewController;
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  bool isLangu = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.flag == "1") {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
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
              SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
              return Future.value(true);
            },
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: <Widget>[
                    WebView(
                      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
                      initialUrl: widget.url,
                      javascriptMode: JavascriptMode.disabled,
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
                            'document.querySelector("#dibecjqswyi").style = "display:none";document.querySelector("#dompcejubvkui").style = "display:none"');
                      },
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                        _webViewController = webViewController;
                      },
                    ),
                    isLoading
                        ? Container(
                            color: Colors.white,
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
                                  color: Colors.white,
                                  onPressed: () {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    Navigator.maybePop(context);
                                  },
                                ),
                                widget.flag == "1"
                                    ? IconButton(
                                        onPressed: () {
                                          if (!isLangu) {
                                            isLangu = true;
                                            SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
                                          } else {
                                            isLangu = false;
                                            SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                                          }
                                        },
                                        tooltip: '全屏',
                                        padding: const EdgeInsets.all(12.0),
                                        icon: Icon(
                                          Icons.aspect_ratio,
                                          color: Colors.red,
                                        ),
                                      )
                                    : Container()
                              ],
                            )),
                  ],
                )),
          );
        });
  }
}
