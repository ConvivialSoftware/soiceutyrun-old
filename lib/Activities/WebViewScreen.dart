
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class BaseWebViewScreen extends StatefulWidget {

  var pageURL;


  BaseWebViewScreen(this.pageURL);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return WebViewScreenState(pageURL);
  }
}

class WebViewScreenState extends BaseStatefulState<BaseWebViewScreen> {

  var pageURL;
  WebViewScreenState(this.pageURL);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('app_name')),
          backgroundColor: GlobalVariables.green,
          //centerTitle: true,
          leading: getIconButton(),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: GlobalVariables.white,
          ),
          child: /*WebView(
          onWebViewCreated: (WebViewController webViewController){
            _webViewCompleter.complete(webViewController);
          },
          initialUrl: url,
        ),*/WebviewScaffold(
            url: pageURL ,
          ),
        ),
      ),
    );
  }

  getIconButton() {
    return IconButton(
        icon: Icon(Icons.arrow_back, color: GlobalVariables.white),
        onPressed: () => Navigator.of(context).pop());
  }
}
