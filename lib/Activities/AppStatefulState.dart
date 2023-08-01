import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';

abstract class AppStatefulState<T extends StatefulWidget> extends State<T>{

  /* String _taskId,;
  ReceivePort _port = ReceivePort();*/
  bool downloading = false;
  //String downloadingStr = "No data";
  int downloadRate=0;
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

  void downloadAttachment(var url/*, var _localPath*/) async {
    GlobalFunctions.checkPermission(Permission.storage).then((value) async {
      if(value) {
        GlobalFunctions.showToast("Downloading attachment....");
        String localPath;
        if (Platform.isAndroid) {
          localPath = _localPath! + Platform.pathSeparator;
        }else{
          localPath = _localPath! + Platform.pathSeparator + "Download";
        }
        final savedDir = Directory(localPath);
        bool hasExisted = await savedDir.exists();
        if (!hasExisted) {
          savedDir.create();
        }

        String fileName = url.substring(url.lastIndexOf(Platform.pathSeparator) + 1);

        Dio dio = Dio();
        await dio.download(url, localPath+Platform.pathSeparator+fileName, onReceiveProgress: (rec, total) {
          setState(() {
            downloading = true;
            //print('Rac : '+rec.toString());
            //  print('total : '+total.toString());
            downloadRate =((rec/total)*100).toInt();
            print('downloadRate : '+downloadRate.toString());
            //downloadingStr = "Downloading File : $rec" ;
          });
        } );
        setState(() {
          downloading = false;
          //downloadingStr = "Completed";
          GlobalFunctions.showToast("Downloading completed");
          //launch('file://'+localPath+Platform.pathSeparator+fileName);
          // Navigator.of(context).pop();
        });
        _openDownloadedFile(localPath+Platform.pathSeparator+fileName);

        /*_taskId = await FlutterDownloader.enqueue(
          url: url,
          savedDir: localPath,
          headers: {"auth": "test_for_sql_encoding"},
          //fileName: "SocietyRunImage/Document",
          showNotification: true,
          // show download progress in status bar (for Android)
          openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
        );*/
      }else{
        GlobalFunctions.askPermission(Permission.storage)
            .then((value) {
          if (value) {
            downloadAttachment(url /*, _localPath*/);
          } else {
            GlobalFunctions.showToast(AppLocalizations.of(context)
                .translate('download_permission'));
          }
        });
      }

    });
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