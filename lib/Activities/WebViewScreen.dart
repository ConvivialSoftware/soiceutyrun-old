
import 'package:flutter/material.dart';
//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BaseWebViewScreen extends StatefulWidget {

  var pageURL;


  BaseWebViewScreen(this.pageURL);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return WebViewScreenState(pageURL);
  }
}

class WebViewScreenState extends State<BaseWebViewScreen> {
  late WebViewController _controller;

  var pageURL;
  WebViewScreenState(this.pageURL);

  @override
  void initState() {
     _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {

          },

          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(pageURL));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Builder(
      builder: (context) => Scaffold(
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('app_name'),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: GlobalVariables.white,
          ),
          child: WebViewWidget(controller: _controller,)
        ),
      ),
    );
  }
}
