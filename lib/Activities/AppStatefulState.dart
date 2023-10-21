import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file_safe/open_file_safe.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class AppStatefulState<T extends StatefulWidget> extends State<T> {
  /* String _taskId,;
  ReceivePort _port = ReceivePort();*/
  bool downloading = false;
  //String downloadingStr = "No data";
  int downloadRate = 0;
  String? _localPath;

  @override
  void initState() {
    GlobalFunctions.localPath().then((value) {
      print("External Directory Path" + value.toString());
      _localPath = value;
    });
    /* IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {
        if (status == DownloadTaskStatus.complete) {
          _openDownloadedFile(_taskId).then((success) {
            if (!success) {
              print('Cannot open this file');
              //Scaffold.of(context).showSnackBar(SnackBar(content: text('Cannot open this file')));
            }
          });
        } else {
          print('Download failed!');
          //Scaffold.of(context).showSnackBar(SnackBar(content: text('Download failed!')));
        }
      });
    });

    FlutterDownloader.registerCallback(downloadCallback);*/
    super.initState();
  }

  /*@override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
    IsolateNameServer.lookupPortByName('downloader_send_port');
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');

    send.send([id, status, progress]);
  }*/

  void downloadAttachment(var url /*, var _localPath*/) async {
    print('Download URL : ' + url);
    try {
      launchUrl(Uri.parse(url),
          mode: Platform.isAndroid
              ? LaunchMode.externalNonBrowserApplication
              : LaunchMode.inAppWebView);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _openDownloadedFile(String path) async {
    await OpenFile.open(path);
    //print('message : '+message.toString());
    // return message.t;
  }
/* ProgressDialog _progressDownloadDialog;
  @override
  Widget build(BuildContext context) {
    _progressDownloadDialog = GlobalFunctions.getDownLoadProgressDialogInstance(context,);
    if(downloading){
      _progressDownloadDialog.show();
    }else{
      _progressDownloadDialog.hide();
    }
    return
  }*/
}
