import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  const WebViewScreen({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  // This widget is the root of your application.
  late WebViewController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    // PlatformView.dispose;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('webview rebuilted\n\n');
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          print(' can go back--------->\n\n');
          _controller.goBack();
          return false;
        } else if (await _controller.canGoBack() == false) {
          print('popping off he cannot go back\n\n');

          Navigator.of(context).pop();
          // return true;
        }
        // _controller.goBack();
        return true;
      },
      child: Scaffold(
        // backgroundColor: Colors.white,
        // appBar: AppBar(
        // title: Text('WebView page'),
        // systemOverlayStyle: const SystemUiOverlayStyle(
        //   statusBarBrightness: Brightness.light,
        // ),
        //     ),
        body: SafeArea(
          child: WebView(
            initialUrl: widget.url,
            userAgent: "random",
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              // _controller.complete(webViewController);
              _controller = webViewController;
            },
            navigationDelegate: (NavigationRequest request) {
              // if (request.url.startsWith(widget.url)) {
              //   return NavigationDecision.navigate;
              // } else {
              _launchURL(request.url);
              return NavigationDecision.navigate;
              // }
            },
          ),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
