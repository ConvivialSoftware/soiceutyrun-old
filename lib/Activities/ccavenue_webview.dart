import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../GlobalClasses/CustomAppBar.dart';
import '../Models/ccavenue_response.dart';

class AvenueWebView extends StatefulWidget {
  final AvenueResponse avenu;
  final String title;

  final Function(String) onTransactionCompleted;
  const AvenueWebView(
      {Key? key,
      required this.avenu,
      required this.onTransactionCompleted,
      required this.title})
      : super(key: key);

  @override
  State<AvenueWebView> createState() => _AvenueWebViewState();
}

class _AvenueWebViewState extends State<AvenueWebView> {
  late WebViewController _controller;
  RxBool loadinProgress = true.obs;

  @override
  void initState() {
    super.initState();

    // #docregion webview_controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              loadinProgress.value = false;
            }
          },
          onPageFinished: (String url) {
            //transaction completed and check the status with merchant server
            if (url == widget.avenu.redirectUrl?.trim()) {
              Get.back();
              widget.onTransactionCompleted(widget.avenu.orderId ?? '');
            }
            if (url == widget.avenu.cancelUrl?.trim()) {
              //payment canceled
              Get.back();
              widget.onTransactionCompleted(widget.avenu.orderId ?? '');
            }
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_buildUrl()));
  }

  void goBack() async {
    Get.dialog(AlertDialog(
      title: Text('Are you sure?'),
      content: Text('Do you want to cancel the transaction?'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text('No'),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
            widget.onTransactionCompleted(widget.avenu.orderId ?? '');
          },
          child: Text('Yes'),
        ),
      ],
    ));
  }

  String _buildUrl() {
    //test url
    return 'https://test.ccavenue.com/transaction.do?command=initiateTransaction&encRequest=${widget.avenu.encVal}&access_code=${widget.avenu.accessCode}';
    // return 'https://secure.ccavenue.com/transaction.do?command=initiateTransaction&encRequest=${widget.avenu.encVal}&access_code=${widget.avenu.accessCode}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        goBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: CustomAppBar(
          title: widget.title,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: goBack,
          ),
        ),
        body: Obx(() => loadinProgress.value
            ? _getLoading()
            : WebViewWidget(controller: _controller)),
      ),
    );
  }

  Center _getLoading() => Center(
        child: CircularProgressIndicator(),
      );
}
