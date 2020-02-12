import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:share/share.dart';

Future main() async {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  InAppWebViewController webView;
  double progress = 0;
  final textFieldController = TextEditingController();
  FocusNode nodeOne = FocusNode();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
          child: Scaffold(
        body: WillPopScope(
            onWillPop: _handleBack,
            child: Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: TextField(
                              controller: textFieldController,
                              focusNode: nodeOne,
                              keyboardType: TextInputType.url,
                              onSubmitted: _changeUrl,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20),
                              ))),
                      IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  (progress != 1.0)
                      ? LinearProgressIndicator(value: progress)
                      : LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.transparent)),
                  Expanded(
                    child: Container(
                      child: InAppWebView(
                        initialUrl: "https://flutter.io/",
                        onWebViewCreated: (InAppWebViewController controller) {
                          webView = controller;
                        },
                        onLoadStart:
                            (InAppWebViewController controller, String url) {
                          setState(() {
                            textFieldController.text = url;
                          });
                        },
                        onProgressChanged:
                            (InAppWebViewController controller, int progress) {
                          setState(() {
                            this.progress = progress / 100;
                          });
                          if (progress == 100) {
                            webView.injectScriptCode(_pullToRefreshCode);
                          }
                        },
                      ),
                    ),
                  ),
                ].where((Object o) => o != null).toList(),
              ),
            )),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _handleRefresh,
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: _handleShare,
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: _handleSearch,
              ),
              IconButton(
                icon: Icon(Icons.crop_square),
                onPressed: () {},
              ),
            ],
          ),
        ),
      )),
    );
  }

  Future<bool> _handleBack() async {
    if (webView != null) {
      await webView.goBack();
      return false;
    }

    return false;
  }

  _handleRefresh() {
    if (webView != null) {
      webView.reload();
    }
  }

  _handleShare() {
    Share.share("Shared from Flutter Browser: ${textFieldController.text}");
  }

  _handleSearch() {
    FocusScope.of(context).requestFocus(nodeOne);
    textFieldController.selection = TextSelection(
        baseOffset: 0, extentOffset: textFieldController.text.length);
  }

  _changeUrl(String text) {
    if (webView != null) {
      webView.loadUrl(text);
    }
  }

  static final String _pullToRefreshCode = """
      let shouldReload = false;
      document.addEventListener("touchstart", e => {
        scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        if (scrollTop === 0) {
          shouldReload = true;
        }
      })
      document.addEventListener("touchend", e => {
        scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        if (shouldReload && scrollTop === 0) {
          location.reload();
        }
      })
    """;
}
