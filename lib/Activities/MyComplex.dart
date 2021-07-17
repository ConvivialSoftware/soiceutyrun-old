import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/Directory.dart';
import 'package:societyrun/Activities/ViewPollGraph.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Announcement.dart';
import 'package:societyrun/Models/CommitteeDirectory.dart';
import 'package:societyrun/Models/Documents.dart';
import 'package:societyrun/Models/EmergencyDirectory.dart';
import 'package:societyrun/Models/MyComplexResponse.dart';
import 'package:societyrun/Models/NeighboursDirectory.dart';
import 'package:societyrun/Models/Poll.dart';
import 'package:societyrun/Models/PollOption.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'base_stateful.dart';

class BaseMyComplex extends StatefulWidget {
  String pageName;

  //final int pageIndex;
  BaseMyComplex(this.pageName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyComplexState(pageName);
  }
}

class MyComplexState extends BaseStatefulState<BaseMyComplex>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  var name, _localPath;
  String _taskId;
  ReceivePort _port = ReceivePort();
  String _selectedItem;
  List<DropdownMenuItem<String>> _societyListItems =
      new List<DropdownMenuItem<String>>();

  ProgressDialog _progressDialog;
  ProgressDialog _downloadProgress;

  String pageName;

  bool isStoragePermission = false;

/*
  bool isAnnouncementTabAPICall = false;
  bool isMeetingsTabAPICall = false;
  bool isPollTabAPICall = false;
  bool isDocumentsTabAPICall = false;
  bool isDirectoryTabAPICall = false;
  bool isEventsTabAPICall = false;*/

  MyComplexState(this.pageName);

  @override
  void initState() {
    print(">>>>>>>PAGENAME $pageName");
    getDisplayName();
    getLocalPath();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission = value;
    });
    //flutterDownloadInitialize();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabSelection);
    print('pageName : ' + pageName.toString());
    if (pageName == null) {
      _handleTabSelection();
    }

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {
        if (status == DownloadTaskStatus.complete) {
          _openDownloadedFile(_taskId).then((success) {
            if (!success) {
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: text('Cannot open this file')));
            }
          });
        } else {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: text('Download failed!')));
        }
      });
    });

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  @override
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
  }

  void downloadAttachment(var url, var _localPath) async {
    GlobalFunctions.showToast("Downloading attachment....");
    String localPath = _localPath + Platform.pathSeparator + "Download";
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    _taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: localPath,
      headers: {"auth": "test_for_sql_encoding"},
      //fileName: "SocietyRunImage/Document",
      showNotification: true,
      // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
  }

  Future<bool> _openDownloadedFile(String id) {
    GlobalFunctions.showToast("Downloading completed");
    return FlutterDownloader.open(taskId: id);
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    if (pageName != null) {
      try {
        redirectToPage(pageName);
      } catch (e) {
        print(e);
      }
    }
    // TODO: implement build
    return ChangeNotifierProvider<MyComplexResponse>.value(
      value: Provider.of<MyComplexResponse>(context),
      child: Consumer<MyComplexResponse>(builder: (context, value, child) {
        return Builder(
          builder: (context) => Scaffold(
            backgroundColor: GlobalVariables.veryLightGray,
            appBar: AppBar(
              backgroundColor: GlobalVariables.green,
              centerTitle: true,
              leading: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: AppIcon(
                  Icons.arrow_back,
                  iconColor: GlobalVariables.white,
                ),
              ),
              title: text(AppLocalizations.of(context).translate('my_complex'),
                  textColor: GlobalVariables.white,
                  fontSize: GlobalVariables.textSizeMedium),
              bottom: getTabLayout(),
              elevation: 0,
            ),
            body: TabBarView(controller: _tabController, children: <Widget>[
              getNewsBoardLayout(value),
              getMeetingsLayout(value),
              getPollSurveyLayout(value),
              getDocumentsLayout(value),
              getDirectoryLayout(value),
              getEventsLayout(value),
            ]),
          ),
        );
      }),
    );
  }

  getTabLayout() {
    return PreferredSize(
      preferredSize: Size.fromHeight(40.0),
      child: TabBar(
        tabs: [
          Tab(
            text: AppLocalizations.of(context).translate('announcement'),
          ),
          Tab(
            text: AppLocalizations.of(context).translate('meetings'),
          ),
          Tab(
            text: AppLocalizations.of(context).translate('poll_survey'),
          ),
          Tab(
            text: AppLocalizations.of(context).translate('documents'),
          ),
          Tab(
            text: AppLocalizations.of(context).translate('directory'),
          ),
          Tab(
            text: AppLocalizations.of(context).translate('events'),
          ),
        ],
        controller: _tabController,
        unselectedLabelColor: GlobalVariables.white30,
        indicatorColor: GlobalVariables.white,
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: true,
        labelColor: GlobalVariables.white,
      ),
    );
  }

  getNewsBoardLayout(MyComplexResponse value) {
    print('getNewsBoardLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 150.0),
        value.isLoading
            ? GlobalFunctions.loadingWidget(context)
            : getNewsBoardListDataLayout(value),
      ],
    );
  }

  getNewsBoardListDataLayout(MyComplexResponse value) {
    print('getNewsBoardListDataLayout Tab Call');
    return value.announcementList.length > 0
        ? Container(
            //padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 8),
            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      itemCount: value.announcementList.length,
                      itemBuilder: (context, position) {
                        return getNewsBoardListItemLayout(position, value);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          )
        : /*GlobalFunctions.noDataFoundLayout(context, "No Data Found")*/ Container();
  }

  getNewsBoardListItemLayout(var position, MyComplexResponse value) {
    return AppContainer(
      isListItem: true,
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                    child: value.announcementList[position].USER_PHOTO.isEmpty
                        ? AppAssetsImage(
                            GlobalVariables.componentUserProfilePath,
                            imageWidth: 40.0,
                            imageHeight: 40.0,
                            borderColor: GlobalVariables.transparent,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 20.0,
                          )
                        : AppNetworkImage(
                            value.announcementList[position].USER_PHOTO,
                            imageWidth: 40.0,
                            imageHeight: 40.0,
                            borderColor: GlobalVariables.transparent,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 20.0,
                          )),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    padding: EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: primaryText(
                            value.announcementList[position].USER_NAME,
                            fontSize: GlobalVariables.textSizeSMedium,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: IntrinsicHeight(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: text(
                                    value.announcementList[position].BLOCK
                                                .length >
                                            0
                                        ? value.announcementList[position].BLOCK
                                                .toString() +
                                            value
                                                .announcementList[position].FLAT
                                                .toString()
                                        : 'Maintainnance Staff',
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeVerySmall,
                                  ),
                                ),
                                VerticalDivider(),
                                Container(
                                  child: text(
                                    value.announcementList[position].C_DATE,
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeVerySmall,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            alignment: Alignment.topLeft,
            child: primaryText(
              value.announcementList[position].SUBJECT,
            ),
          ),
          SizedBox(height: 8,),
          Container(
              child: htmlText(
            value.announcementList[position].DESCRIPTION,
            textColor: GlobalVariables.grey,
            fontSize: GlobalVariables.textSizeSMedium,
          )),
          value.announcementList[position].ATTACHMENT.length > 0
              ? Divider()
              : Container(),
          value.announcementList[position].ATTACHMENT.length > 0
              ? InkWell(
                  onTap: () {
                    String url = value.announcementList[position].ATTACHMENT;

                    print("storagePermiassion : " +
                        isStoragePermission.toString());
                    if (isStoragePermission) {
                      downloadAttachment(url, _localPath);
                    } else {
                      GlobalFunctions.askPermission(Permission.storage)
                          .then((value) {
                        if (value) {
                          downloadAttachment(url, _localPath);
                        } else {
                          GlobalFunctions.showToast(AppLocalizations.of(context)
                              .translate('download_permission'));
                        }
                      });
                    }
                  },
                  child: Row(
                    children: <Widget>[
                      AppIcon(
                        Icons.attach_file,
                        iconColor: GlobalVariables.mediumGreen,
                      ),
                      text(
                        "Attachment",
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeSmall,
                      )
                    ],
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  getNewsTypeColor(String newsType) {
    switch (newsType.toLowerCase().trim()) {
      case "category":
        {
          return GlobalVariables.skyBlue;
        }
        break;
      case "category1":
        {
          return GlobalVariables.orangeYellow;
        }
        break;
      case "category2":
        {
          return GlobalVariables.red;
        }
        break;
      default:
        return GlobalVariables.skyBlue;
        break;
    }
  }

  /* getNewsBordListData() {
    _newsBoardList = [
      NewsBoard(
          username: "Ashish Wayker",
          blockFlatNo: "AA102",
          date: "10/02/2020",
          newsType: "Category",
          newsTitle: "Holi Celebration",
          newsDesc:
              "We are planning to celebrate Holi festival this year at Society compound",
          likeCount: "0",
          commentCount: "0"),
      NewsBoard(
          username: "Ashish Wayker",
          blockFlatNo: "AA102",
          date: "10/02/2020",
          newsType: "Category1",
          newsTitle: "Holi Celebration",
          newsDesc:
              "We are planning to celebrate Holi festival this year at Society compound",
          likeCount: "0",
          commentCount: "0"),
      NewsBoard(
          username: "Ashish Wayker",
          blockFlatNo: "AA102",
          date: "10/02/2020",
          newsType: "Category2",
          newsTitle: "Holi Celebration",
          newsDesc:
              "We are planning to celebrate Holi festival this year at Society compound",
          likeCount: "0",
          commentCount: "0"),
      NewsBoard(
          username: "Ashish Wayker",
          blockFlatNo: "AA102",
          date: "10/02/2020",
          newsType: "Category",
          newsTitle: "Holi Celebration",
          newsDesc:
              "We are planning to celebrate Holi festival this year at Society compound",
          likeCount: "0",
          commentCount: "0"),
      NewsBoard(
          username: "Ashish Wayker",
          blockFlatNo: "AA102",
          date: "10/02/2020",
          newsType: "Category1",
          newsTitle: "Holi Celebration",
          newsDesc:
              "We are planning to celebrate Holi festival this year at Society compound",
          likeCount: "0",
          commentCount: "0"),
      NewsBoard(
          username: "Ashish Wayker",
          blockFlatNo: "AA102",
          date: "10/02/2020",
          newsType: "Category2",
          newsTitle: "Holi Celebration",
          newsDesc:
              "We are planning to celebrate Holi festival this year at Society compound",
          likeCount: "0",
          commentCount: "0"),
    ];
  }
*/

  getMeetingsLayout(MyComplexResponse value) {
    print('getMeetingsLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 150.0),
        value.isLoading
            ? GlobalFunctions.loadingWidget(context)
            : getMeetingsListDataLayout(value),
      ],
    );
  }

  getMeetingsListDataLayout(MyComplexResponse value) {
    print('getMeetingsListDataLayout Tab Call');
    return value.meetingList.length > 0
        ? Container(
            margin: EdgeInsets.only(top: 8),
            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      itemCount: value.meetingList.length,
                      itemBuilder: (context, position) {
                        return getMeetingsListItemLayout(position, value);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          )
        : Container();
  }

  getMeetingsListItemLayout(var position, MyComplexResponse value) {
    return AppContainer(
      isListItem: true,
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                    child: value.meetingList[position].USER_PHOTO.isEmpty
                        ? AppAssetsImage(
                            GlobalVariables.componentUserProfilePath,
                            imageWidth: 40.0,
                            imageHeight: 40.0,
                            borderColor: GlobalVariables.transparent,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 20.0,
                          )
                        : AppNetworkImage(
                            value.meetingList[position].USER_PHOTO,
                            imageWidth: 40.0,
                            imageHeight: 40.0,
                            borderColor: GlobalVariables.transparent,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 20.0,
                          ) /*Image.asset(
                    GlobalVariables.componentUserProfilePath,
                    width: 26,
                    height: 26,
                  ),*/
                    ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    padding: EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: primaryText(
                            value.meetingList[position].USER_NAME,
                            fontSize: GlobalVariables.textSizeSMedium,
                            /*textColor: GlobalVariables.green,
                            fontWeight: FontWeight.bold,*/
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: IntrinsicHeight(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: text(
                                    value.meetingList[position].BLOCK.length > 0
                                        ? value.meetingList[position].BLOCK
                                                .toString() +
                                            ' ' +
                                            value.meetingList[position].FLAT
                                                .toString()
                                        : 'Maintainnance Staff',
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeVerySmall,
                                  ),
                                ),
                                VerticalDivider(),
                                Container(
                                  child: text(
                                    value.meetingList[position].C_DATE,
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeVerySmall,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16,),
          Container(
              alignment: Alignment.topLeft,
              child: primaryText(value.meetingList[position].SUBJECT,)),
          SizedBox(height: 8,),
          htmlText(
            value.meetingList[position].DESCRIPTION,
            textColor: GlobalVariables.grey,
            fontSize: GlobalVariables.textSizeSMedium,
          ),
          SizedBox(height: 8,),
          Column(
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: AppIcon(
                        Icons.location_on,
                        iconColor: GlobalVariables.mediumGreen,
                        iconSize: GlobalVariables.textSizeNormal,
                      ),
                    ),
                    SizedBox(width: 8,),
                    /*Container(
                      child: text(
                        "Venue : ",
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeSMedium,
                      ),
                    ),*/
                    Container(
                      child: text(
                        value.meetingList[position].VENUE,
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeSMedium,
                          textStyleHeight: 1.0
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4,),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AppIcon(
                        Icons.date_range,
                        iconColor: GlobalVariables.mediumGreen,
                        iconSize: GlobalVariables.textSizeNormal,
                      ),
                    ),
                    SizedBox(width: 8,),
                /*    Container(
                      child: text(
                        "Date : ",
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeSMedium,
                      ),
                    )*/
                    Container(
                      child: text(
                        value.meetingList[position]
                            .START_DATE /*+' to '+ value.meetingList[position].END_DATE*/,
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeSMedium,
                          textStyleHeight: 1.0
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4,),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AppIcon(
                        Icons.access_time,
                        iconColor: GlobalVariables.mediumGreen,
                        iconSize: GlobalVariables.textSizeNormal,
                      ),
                    ),
                    SizedBox(width: 8,),
                    Container(
                      child: text(
                        value.meetingList[position]
                            .Start_Time /*+' to '+ value.meetingList[position].END_TIME*/,
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeSMedium,
                          textStyleHeight: 1.0
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          value.meetingList[position].ATTACHMENT.length > 0
              ? Divider()
              : Container(),
          value.meetingList[position].ATTACHMENT.length > 0
              ? InkWell(
                  onTap: () {
                    String url = value.meetingList[position].ATTACHMENT;

                    print("storagePermiassion : " +
                        isStoragePermission.toString());
                    if (isStoragePermission) {
                      downloadAttachment(url, _localPath);
                    } else {
                      GlobalFunctions.askPermission(Permission.storage)
                          .then((value) {
                        if (value) {
                          downloadAttachment(url, _localPath);
                        } else {
                          GlobalFunctions.showToast(AppLocalizations.of(context)
                              .translate('download_permission'));
                        }
                      });
                    }
                  },
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Container(
                            child: AppIcon(
                          Icons.attach_file,
                          iconColor: GlobalVariables.mediumGreen,
                        )),
                        SizedBox(width: 4,),
                        Container(
                          child: text(
                            "Attachment",
                            textColor: GlobalVariables.green,
                            fontSize: GlobalVariables.textSizeSmall,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  getPollSurveyLayout(MyComplexResponse value) {
    print('getPollSurveyLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 150.0),
        value.isLoading
            ? GlobalFunctions.loadingWidget(context)
            : getPollSurveyListDataLayout(value),
      ],
    );
  }

  getPollSurveyListDataLayout(MyComplexResponse value) {
    print('getPollSurveyListDataLayout Tab Call');
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 8),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: value.pollList.length,
                itemBuilder: (context, position) {
                  return getPollSurveyListItemLayout(position, value);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getPollSurveyListItemLayout(var position, MyComplexResponse value) {
    print('>>>>> ' + position.toString());

    print('EXPIRY_DATE : ' +
        GlobalFunctions.isDateSameOrGrater(value.pollList[position].EXPIRY_DATE)
            .toString());
    print('SECRET_POLL : ' + value.pollList[position].SECRET_POLL.toString());
    print('VOTED_TO : ' + value.pollList[position].VOTED_TO.length.toString());
    if (!GlobalFunctions.isDateExpireForPoll(
            value.pollList[position].EXPIRY_DATE) &&
        (value.pollList[position].VOTED_TO.length > 0) &&
        value.pollList[position].SECRET_POLL.toLowerCase() == 'no') {
      print('>>> 1st');
      value.pollList[position].isGraphView = true;
    }
    if (GlobalFunctions.isDateExpireForPoll(
        value.pollList[position].EXPIRY_DATE)) {
      print('>>> 2nd');
      value.pollList[position].isGraphView = true;
    }

    if (!GlobalFunctions.isDateExpireForPoll(
            value.pollList[position].EXPIRY_DATE) &&
        (value.pollList[position].VOTED_TO.length == 0)) {
      print('>>> 3rd');
      value.pollList[position].isGraphView = false;
    }

    if (!GlobalFunctions.isDateExpireForPoll(
            value.pollList[position].EXPIRY_DATE) &&
        (value.pollList[position].VOTED_TO.length > 0) &&
        value.pollList[position].SECRET_POLL.toLowerCase() == 'yes') {
      print('>>> 4th');
      value.pollList[position].isGraphView = false;
    }

    print('>>>>> ' + position.toString());
    print('>>>>> value.pollList[position].VOTED_TO.length : ' +
        value.pollList[position].VOTED_TO.length.toString());
    return AppContainer(
      isListItem: true,
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: value.pollList[position].USER_PHOTO.isEmpty
                      ? AppAssetsImage(
                          GlobalVariables.componentUserProfilePath,
                          imageWidth: 40.0,
                          imageHeight: 40.0,
                          borderColor: GlobalVariables.transparent,
                          borderWidth: 1.0,
                          fit: BoxFit.cover,
                          radius: 20.0,
                        )
                      : AppNetworkImage(
                          value.pollList[position].USER_PHOTO,
                          imageWidth: 40.0,
                          imageHeight: 40.0,
                          borderColor: GlobalVariables.transparent,
                          borderWidth: 1.0,
                          fit: BoxFit.cover,
                          radius: 20.0,
                        ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    padding: EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: primaryText(value.pollList[position].USER_NAME,
                                  fontSize: GlobalVariables.textSizeSMedium,
                              ),
                            ),
                            Container(
                              //margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: !GlobalFunctions.isDateSameOrGrater(
                                      value.pollList[position].EXPIRY_DATE)
                                      ? GlobalVariables.green
                                      : GlobalVariables.red,
                                  shape: BoxShape.circle),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: IntrinsicHeight(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: text(
                                    value.pollList[position].BLOCK +
                                        ' ' +
                                        value.pollList[position].FLAT,
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeVerySmall,
                                  ),
                                ),
                                VerticalDivider(),
                                Container(
                                  child: text(
                                    value.pollList[position].C_DATE,
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeVerySmall,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16,),
          Container(
            alignment: Alignment.topLeft,
            child: primaryText(value.pollList[position].POLL_Q,),
          ),
          SizedBox(height: 8,),
          Container(
            alignment: Alignment.topLeft,
            child: htmlText(
              value.pollList[position].DESCRIPTION,
              textColor: GlobalVariables.grey,
              fontSize: GlobalVariables.textSizeSMedium,
            ),
          ),
          SizedBox(height: 8,),
          getVoteLayout(position, value),
          SizedBox(height: 4,),
          Divider(),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Row(
                    children: <Widget>[
                      (!GlobalFunctions.isDateSameOrGrater(
                                  value.pollList[position].EXPIRY_DATE) &&
                              (value.pollList[position].VOTED_TO.length > 0) &&
                              value.pollList[position].SECRET_POLL
                                      .toLowerCase() ==
                                  'yes')
                          ? Container(
                              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                // crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  text(
                                    "VOTED",
                                    textColor: GlobalVariables.red,
                                    fontSize: GlobalVariables.textSizeSmall,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  text(
                                    "  (Result On " +
                                        GlobalFunctions.convertDateFormat(
                                            value
                                                .pollList[position].EXPIRY_DATE,
                                            "dd MMM yy") +
                                        ")",
                                    textColor: GlobalVariables.green,
                                    fontSize: GlobalVariables.textSizeSmall,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              value.pollList[position].isGraphView
                  ? InkWell(
                      onTap: () {
                        List<PollOption> _optionList = List<PollOption>.from(
                            value.pollList[position].OPTION
                                .map((i) => PollOption.fromJson(i)));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BaseViewPollGraph(
                                    value.pollList[position], _optionList)));
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                          //  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: GlobalFunctions.isDateSameOrGrater(
                                        value.pollList[position].EXPIRY_DATE) &&
                                    (value.pollList[position].VOTED_TO.length >
                                        0)
                                ? text(
                                    "See Poll Result",
                                    textColor: GlobalVariables.green,
                                    fontSize: GlobalVariables.textSizeSmall,
                                    fontWeight: FontWeight.bold,
                                  )
                                : Container(),
                          ),
                          SizedBox(width: 8,),
                          Container(
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.all(8),
                            //margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            decoration: BoxDecoration(
                              color: GlobalVariables.green,
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: AppIcon(
                              Icons.remove_red_eye,
                              iconColor: GlobalVariables.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              (value.pollList[position].VOTED_TO.length == 0) &&
                      value.pollList[position].VOTE_PERMISSION.toLowerCase() ==
                          'yes' &&
                      !GlobalFunctions.isDateSameOrGrater(
                          value.pollList[position].EXPIRY_DATE)
                  ? InkWell(
                      onTap: () {
                        String optionId = '';
                        List<PollOption> _optionList = List<PollOption>.from(
                            value.pollList[position].OPTION
                                .map((i) => PollOption.fromJson(i)));
                        for (int i = 0; i < _optionList.length; i++) {
                          if (_optionList[i].ANS_ID ==
                              value.pollList[position].View_VOTED_TO) {
                            optionId = _optionList[i].ANS_ID;
                            _optionList[i].VOTES =
                                (int.parse(_optionList[i].VOTES) + 1)
                                    .toString();
                            break;
                          }
                        }

                        addPollVote(value.pollList[position].ID, optionId,
                            position, _optionList, value);
                      },
                      child: Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        decoration: BoxDecoration(
                          color: GlobalVariables.green,
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: AppIcon(
                          Icons.send,
                          iconColor: GlobalVariables.white,
                        ),
                      ),
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );
  }

  getDirectoryLayout(MyComplexResponse value) {
    print('getDirectoryLayout Tab Call');
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
              context, 150.0),
          value.isLoading
              ? GlobalFunctions.loadingWidget(context)
              : getDirectoryListDataLayout(value),
        ],
      ),
    );
  }

  getSearchFilerLayout() {
    return Visibility(
      visible: false,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.mediumGreen,
                        width: 3.0,
                      )),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: TextField(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          hintText: "Search",
                          hintStyle:
                              TextStyle(color: GlobalVariables.veryLightGray),
                          border: InputBorder.none,
                          suffixIcon: AppIcon(
                            Icons.search,
                            iconColor: GlobalVariables.mediumGreen,
                          )),
                    ),
                  )),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.mediumGreen,
                        width: 3.0,
                      )),
                  child: Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: ButtonTheme(
                      //alignedDropdown: true,
                      child: DropdownButton(
                        items: _societyListItems,
                        onChanged: changeDropDownItem,
                        value: _selectedItem,
                        underline: SizedBox(),
                        icon: AppIcon(
                          Icons.arrow_drop_down,
                          iconColor: GlobalVariables.mediumGreen,
                        ),
                        isExpanded: true,
                        hint: text(
                          'Category',
                          textColor: GlobalVariables.veryLightGray,
                        ), //iconSize: 20,
                      ),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  void changeDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    /*setState(() {
      _selectedItem = value;
      print('_selctedItem:' + _selectedItem.toString());
      for (int i = 0; i < _societyList.length; i++) {
        if (_selectedItem == _societyList[i].ID) {
          _selectedSocietyLogin = _societyList[i];
          _selectedSocietyLogin.PASSWORD = password;
          GlobalFunctions.saveDataToSharedPreferences(_selectedSocietyLogin);
          print('for _selctedItem:' + _selectedItem);
          getDuesData();
          break;
        }
      }
    });*/
  }

  getDirectoryListDataLayout(MyComplexResponse value) {
    print('getDirectoryListDataLayout Tab Call');
    return value.directoryList.length > 0
        ? Container(
      margin: EdgeInsets.only(top: 8),
          child: Builder(
              builder: (context) => ListView.builder(
                     physics: NeverScrollableScrollPhysics(),
                    itemCount: value.directoryList.length,
                    itemBuilder: (context, position) {
                      return getDirectoryListItemLayout(position, value);
                    }, //  scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                  )),
        )
        : Container();
  }

  getDirectoryListItemLayout(int position, MyComplexResponse value) {

    String type = value.directoryList[position].directoryType;

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(16.0,8.0,16.0,8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(
                type,
                textColor:
                    position == 0 ? GlobalVariables.white : GlobalVariables.black,
                fontSize: GlobalVariables.textSizeMedium,
                fontWeight: FontWeight.bold,
              ),
              InkWell(
                  onTap: (){
                    if (type != 'Near By Shops') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BaseDirectory(value.directoryList[position])));
                    }
                  },
                  child: smallTextContainerOutlineLayout(AppLocalizations.of(context).translate('see_all'))),
            ],
          ),
        ),
        AppContainer(
          isListItem: true,
          child: Column(
            children: <Widget>[
              Builder(
                  builder: (context) => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: value.directoryList[position]
                          .directoryTypeWiseList.length,
                      itemBuilder: (context, childPosition) {
                        return getDirectoryTypeWiseItemLayout(
                            position, childPosition, type, value);
                      })),
            ],
          ),
        )
      ],
    );
  }

  getDirectoryTypeWiseItemLayout(
    int position,
    int childPosition,
    String type,
    MyComplexResponse value,
  ) {

    String name = '', field = '', permission = '';
    if (type == 'Committee') {
      name = value
          .directoryList[position].directoryTypeWiseList[childPosition].NAME;

      field = value
          .directoryList[position].directoryTypeWiseList[childPosition].POST;

    }

    if (type == 'Emergency') {
      name = value.directoryList[position].directoryTypeWiseList[childPosition]
                  .Name ==
              null
          ? ''
          : value.directoryList[position].directoryTypeWiseList[childPosition]
              .Name;

      field = value.directoryList[position].directoryTypeWiseList[childPosition]
                  .Category ==
              null
          ? ''
          : value.directoryList[position].directoryTypeWiseList[childPosition]
              .Category;

      print('name : ' + name);
      print('field : ' + field);

    }

    if (type == 'Neighbours') {
      name = value
          .directoryList[position].directoryTypeWiseList[childPosition].NAME;

      field = value.directoryList[position].directoryTypeWiseList[childPosition]
              .BLOCK +
          "-" +
          value.directoryList[position].directoryTypeWiseList[childPosition]
              .FLAT;

    }

    if (type == 'Near By Shops') {
      name = value
          .directoryList[position].directoryTypeWiseList[childPosition].name;

      field = value
          .directoryList[position].directoryTypeWiseList[childPosition].field;
    }
    if (name == null) name = '';

    if (field == null) field = '';


    return Container(
      //width: 200,
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          type == 'Near By Shops'
              ? Container(
                  child: getSearchFilerLayout(),
                )
              : Container(),
          Container(
            //height: 30,
            child: Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.topLeft, //height: 10,
                    child: primaryText(
                      name,
                      // textColor: GlobalVariables.green,
                      // fontSize: GlobalVariables.textSizeMedium,
                      // maxLine: 1,
                    ),
                  ),
                ),
                SizedBox(width: 2,),
                Flexible(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.topRight,
                    child: text(
                      field,
                      textColor: GlobalVariables.grey,
                      fontSize: GlobalVariables.textSizeSMedium,
                      maxLine: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          childPosition != value.directoryList[position].directoryTypeWiseList.length-1 ?  Divider() : SizedBox(),
        ],
      ),
    );
  }

  /* getDocumentsLayout() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 150.0),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width:
                        MediaQuery.of(context).size.width / 1.1, //height: 50,
                    margin: EdgeInsets.fromLTRB(
                        0, MediaQuery.of(context).size.height / 15, 0, 0),
                    decoration: BoxDecoration(
                      color: GlobalVariables.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    //child: getSearchFilerLayout(),
                  ),
                ),
                getDocumentListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }*/

  /* getDocumentListDataLayout() {
    return  Align(
      alignment: Alignment.center,
      child: Container(
        child: Text('Coming Soon...',style: TextStyle(
            color: GlobalVariables.black,fontSize: 18,fontWeight: FontWeight.bold
        ),),
      ),
    );*/ /*Container(
      // color: GlobalVariables.grey,
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 6, 10, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: value.documentList.length,
                itemBuilder: (context, position) {
                  return getDocumentListItemLayout(position);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );*/ /*
  }

  getDocumentListItemLayout(int position) {
    // int _default;

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          alignment: Alignment.topLeft,
          child: Text(
            value.documentList[position].docTypes,
            style: TextStyle(color: GlobalVariables.green, fontSize: 20),
          ),
        ),
        Container(
          // padding: EdgeInsets.all(5),
          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),

          // color: GlobalVariables.grey,
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width / 0.5,
                padding: EdgeInsets.all(
                    10), // margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                //color: GlobalVariables.white,
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: Builder(
                    builder: (context) => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: value.documentList[position].documentList.length,
                        itemBuilder: (context, childPosition) {
                          return getDocumentTypeWiseItemLayout(
                              position, childPosition);
                        })),
              ),
              Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                      10), //margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  //color: GlobalVariables.white,
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          AppLocalizations.of(context).translate('view_more'),
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        child: Icon(
                          Icons.fast_forward,
                          color: GlobalVariables.green,
                        ),
                      )
                    ],
                  )),
            ],
          ),
        )
      ],
    );
  }

  getDocumentTypeWiseItemLayout(int position, int childPosition,) {
    return Container(
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            //crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(5, 5, 0, 3),
                alignment: Alignment.topLeft, //height: 10,
                //color: GlobalVariables.grey,
                child: SvgPicture.asset(GlobalVariables.pdfBackIconPath),
              ),
              Flexible(
                  flex: 3,
                  child: Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 0, 3),
                      alignment: Alignment.topLeft, //height: 10,
                      //color: GlobalVariables.grey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              value.documentList[position]
                                  .documentList[childPosition]
                                  .docTitle,
                              style: TextStyle(
                                color: GlobalVariables.green,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              value.documentList[position]
                                  .documentList[childPosition]
                                  .docDesc,
                              style: TextStyle(
                                  color: GlobalVariables.veryLightGray,
                                  fontSize: 14),
                            ),
                          )
                        ],
                      ))),
              Flexible(
                  flex: 1,
                  child: Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 5, 3),
                      alignment: Alignment.topRight, // height: 10,
                      //  color: GlobalVariables.lightGreen,
                      child: SvgPicture.asset(
                        GlobalVariables.downloadIconPath,
                        color: GlobalVariables.mediumGreen,
                        width: 25,
                        height: 25,
                      ))),
            ],
          ),
        ],
      ),
    );
  }

  getDocumentsListData() {
    value.documentList = [
      Documents(docTypes: "Own Documents", documentList: [
        DocumentsTypeWiseData(
          docTitle: "Rent Agreement",
          docDesc: "Posted by : Ashish",
        ),
        DocumentsTypeWiseData(
          docTitle: "Maintenance Receipt-Mar20",
          docDesc: "Posted by : Ashish",
        ),
        DocumentsTypeWiseData(
          docTitle: "Maintenance Receipt-Feb20",
          docDesc: "Posted by : Ashish",
        ),
        DocumentsTypeWiseData(
          docTitle: "Booking Confirmation",
          docDesc: "Posted by : Ashish",
        ),
      ]),
      Documents(docTypes: "Other Documents", documentList: [
        DocumentsTypeWiseData(
          docTitle: "AGM Notice 2019-20",
          docDesc: "Posted by : Ashish",
        ),
        DocumentsTypeWiseData(
          docTitle: "Financial Report 2018-19",
          docDesc: "Posted by : Ashish",
        ),
        DocumentsTypeWiseData(
          docTitle: "Water Circular",
          docDesc: "Posted by : Ashish",
        ),
      ]),
    ];
  }*/

  getEventsLayout(MyComplexResponse value) {
    print('getEventsLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 150.0),
    /*    Align(
          alignment: Alignment.topCenter,
          child: Container(
            width:
                MediaQuery.of(context).size.width / 1.1, // height: 50,
            margin: EdgeInsets.fromLTRB(
                10, MediaQuery.of(context).size.height / 15, 10, 0),
            decoration: BoxDecoration(
              color: GlobalVariables.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            // child: getSearchFilerLayout(),
          ),
        ),*/
        value.isLoading
            ? GlobalFunctions.loadingWidget(context)
            : getEventsDataLayout(value),
      ],
    );
  }

  getEventsDataLayout(MyComplexResponse value) {
    print('getEventsDataLayout Tab Call');
    return /*Align(
      alignment: Alignment.center,
      child: Container(
        child: Text('Coming Soon...',style: TextStyle(
            color: GlobalVariables.black,fontSize: 18,fontWeight: FontWeight.bold
        ),),
      ),
    );*/
        value.eventList.length > 0
            ? Container(
                margin: EdgeInsets.only(top:8),
                child: Builder(
                    builder: (context) => ListView.builder(
                          // scrollDirection: Axis.vertical,
                          itemCount: value.eventList.length,
                          itemBuilder: (context, position) {
                            return getEventsListItemLayout(position, value);
                          }, //  scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        )),
              )
            : Container();
  }

  getEventsListItemLayout(var position, MyComplexResponse value) {
    // int _default;

    return AppContainer(
      isListItem: true,
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                    child: value.eventList[position].USER_PHOTO.isEmpty
                        ? AppAssetsImage(
                            GlobalVariables.componentUserProfilePath,
                            imageWidth: 40.0,
                            imageHeight: 40.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 20.0,
                          )
                        : AppNetworkImage(
                            value.eventList[position].USER_PHOTO,
                            imageWidth: 40.0,
                            imageHeight: 40.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 40.0,
                          )),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    padding: EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: primaryText(
                            value.eventList[position].USER_NAME,
                            fontSize: GlobalVariables.textSizeSMedium,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: IntrinsicHeight(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: text(
                                    value.eventList[position].BLOCK.length > 0
                                        ? value.eventList[position].BLOCK +
                                            ' ' +
                                            value.eventList[position].FLAT
                                        : "Maintannance Staff",
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeVerySmall,
                                  ),
                                ),
                                VerticalDivider(),
                                Container(
                                  child: text(
                                    value.eventList[position].C_DATE,
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeVerySmall,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16,),
          Container(
            alignment: Alignment.topLeft,
            child: primaryText(value.eventList[position].SUBJECT,),
          ),
          SizedBox(height: 8,),
          Container(
            alignment: Alignment.topLeft,
            child: htmlText(
              value.eventList[position].DESCRIPTION,
              textColor: GlobalVariables.grey,
              fontSize: GlobalVariables.textSizeSMedium,
            )
          ),
          SizedBox(height: 8,),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: AppIcon(
                      Icons.location_on,
                      iconColor: GlobalVariables.mediumGreen,
                      iconSize: GlobalVariables.textSizeNormal,
                    ),
                  ),
                 SizedBox(width: 8,),
                  Container(
                    child: text(
                      value.eventList[position].VENUE,
                      textColor: GlobalVariables.green,
                      fontSize: GlobalVariables.textSizeSMedium,
                      textStyleHeight: 1.0
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4,),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AppIcon(
                        Icons.date_range,
                        iconColor: GlobalVariables.mediumGreen,
                        iconSize: GlobalVariables.textSizeNormal,
                      ),
                    ),
                    SizedBox(width: 8,),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 3, 0, 0),
                      child: text(
                        value.eventList[position].START_DATE +
                            ' to ' +
                            value.eventList[position].END_DATE,
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeSMedium,
                          textStyleHeight: 1.0
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4,),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AppIcon(
                        Icons.access_time,
                        iconColor: GlobalVariables.mediumGreen,
                        iconSize: GlobalVariables.textSizeNormal,
                      ),
                    ),
                    SizedBox(width: 8,),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 3, 0, 0),
                      child: text(
                        value.eventList[position].START_TIME +
                            ' to ' +
                            value.eventList[position].END_TIME,
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeSMedium,
                          textStyleHeight: 1.0
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          value.eventList[position].ATTACHMENT.length > 0
              ? Container(
                  height: 2,
                  color: GlobalVariables.mediumGreen,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Divider(
                    height: 2,
                  ),
                )
              : Container(),
          value.eventList[position].ATTACHMENT.length > 0
              ? InkWell(
                  onTap: () {
                    String url = value.eventList[position].ATTACHMENT;

                    print("storagePermiassion : " +
                        isStoragePermission.toString());
                    if (isStoragePermission) {
                      downloadAttachment(url, _localPath);
                    } else {
                      GlobalFunctions.askPermission(Permission.storage)
                          .then((value) {
                        if (value) {
                          downloadAttachment(url, _localPath);
                        } else {
                          GlobalFunctions.showToast(AppLocalizations.of(context)
                              .translate('download_permission'));
                        }
                      });
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      children: <Widget>[
                        Container(
                            child: AppIcon(
                          Icons.attach_file,
                          iconColor: GlobalVariables.mediumGreen,
                        )),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: text(
                            "Attachment",
                            textColor: GlobalVariables.green,
                            fontSize: GlobalVariables.textSizeVerySmall,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Future<void> getDisplayName() async {
    name = await GlobalFunctions.getDisplayName();
    setState(() {});
  }

  void getLocalPath() {
    GlobalFunctions.localPath().then((value) {
      print("External Directory Path" + value.toString());
      _localPath = value;
    });
  }

  void redirectToPage(String item) {
    // print(">>>>>>>${item}");
    if (item == AppLocalizations.of(context).translate('my_complex')) {
      //Redirect to my Unit
      _tabController.animateTo(0);
    } else if (item == AppLocalizations.of(context).translate('announcement')) {
      //Redirect to  NewsBoard
      _tabController.animateTo(0);
    } else if (item == AppLocalizations.of(context).translate('meetings')) {
      //Redirect to  PollSurvey
      _tabController.animateTo(1);
    } else if (item == AppLocalizations.of(context).translate('poll_survey')) {
      //Redirect to  PollSurvey
      _tabController.animateTo(2);
    } else if (item == AppLocalizations.of(context).translate('documents')) {
      //Redirect to  Directory
      _tabController.animateTo(3);
    } else if (item == AppLocalizations.of(context).translate('directory')) {
      //Redirect to  Document
      _tabController.animateTo(4);
    } else if (item == AppLocalizations.of(context).translate('events')) {
      //Redirect to  Events
      _tabController.animateTo(5);
    } else {
      _tabController.animateTo(0);
    }

    if (pageName != null) {
      pageName = null;
      if (_tabController.index == 0) {
        _handleTabSelection();
      }
    }
  }

  void _handleTabSelection() {
    print('Call _handleTabSelection');
    //if(_tabController.indexIsChanging){
    _callAPI(_tabController.index);
    //}
  }

  void _callAPI(int index) {
    print('_callAPI pageName : ' + pageName.toString());
    print('_callAPI index : ' + index.toString());
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        switch (index) {
          case 0:
            {
              Provider.of<MyComplexResponse>(context, listen: false)
                  .getAnnouncementData('Announcement');
            }
            break;
          case 1:
            {
              //if (!isMeetingsTabAPICall) {
              Provider.of<MyComplexResponse>(context, listen: false)
                  .getAnnouncementData('Meeting');
              // getMeetingData('Meeting');
              //}
            }
            break;
          case 2:
            {
              //if (!isPollTabAPICall) {
              Provider.of<MyComplexResponse>(context, listen: false)
                  .getAnnouncementPollData('Poll');
              // getAnnouncementPollData('Poll');
              //}
            }
            break;
          case 3:
            {
              // if (!isDocumentsTabAPICall) {
              Provider.of<MyComplexResponse>(context, listen: false)
                  .getDocumentData();
              //}
            }
            break;
          case 4:
            {
              //if (!isDirectoryTabAPICall) {
              //getNeighboursDirectoryData();
              Provider.of<MyComplexResponse>(context, listen: false)
                  .getAllMemberDirectoryData();
              //}
            }
            break;
          case 5:
            {
              //  if (!isEventsTabAPICall) {
              Provider.of<MyComplexResponse>(context, listen: false)
                  .getAnnouncementData('Event');
              //getEventData('Event');
              // }
            }
            break;
        }
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  getDocumentsLayout(MyComplexResponse value) {
    print('MyDocumentsLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 150.0), //ticketOpenClosedLayout(),
        // documentOwnCommonLayout(),
        value.isLoading
            ? GlobalFunctions.loadingWidget(context)
            : getDocumentListDataLayout(value),
      ],
    );
  }

  getDocumentListDataLayout(MyComplexResponse value) {
    print('getDocumentListDataLayout Tab Call');
    return Container(
      margin : EdgeInsets.only(top: 8),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: value.documentList.length,
                itemBuilder: (context, position) {
                  return getDocumentListItemLayout(position, value);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  /* Container(
                  child: Container(
                    child: SvgPicture.asset(
                      GlobalVariables.pdfIconPath,
                      color: GlobalVariables.mediumGreen,
                      width: 25,
                      height: 40,
                    ),
                  ),
                ),*/
  getDocumentListItemLayout(int position, MyComplexResponse value) {
    print('getDocumentListItemLayout Tab Call');
    return AppContainer(
      isListItem: true,
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  flex:2,
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: primaryText(
                      value.documentList[position].TITLE,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: text(
                        value.documentList[position]
                            .DOCUMENT_CATEGORY,
                        textColor: GlobalVariables.white,
                        fontSize: GlobalVariables.textSizeSmall),
                    decoration: BoxDecoration(
                        color: getDocumentTypeColor(value
                            .documentList[position]
                            .DOCUMENT_CATEGORY),
                        borderRadius: BorderRadius.circular(5)),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 16,),
          Container(
            alignment: Alignment.topLeft,
            child: secondaryText(
              value.documentList[position].DESCRIPTION,
            ),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              /*  Visibility(
                visible:false,
                child: Row(
                  children: <Widget>[
                    Container(
                        child: SvgPicture.asset(
                          GlobalVariables.downloadIconPath,
                          color: GlobalVariables.lightGray,
                          width: 25,
                          height: 20,
                        )),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text(
                          "Document Name",
                          style: TextStyle(color: GlobalVariables.mediumGreen)),
                    ),
                  ],
                ),
              ),*/
              value.documentList[position].DOCUMENT.length != null
                  ? Container(
                      // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: InkWell(
                        onTap: () {
                          print("storagePermiassion : " +
                              isStoragePermission.toString());
                          if (isStoragePermission) {
                            downloadAttachment(
                                value.documentList[position].DOCUMENT,
                                _localPath);
                          } else {
                            GlobalFunctions.askPermission(Permission.storage)
                                .then((value1) {
                              if (value1) {
                                downloadAttachment(
                                    value.documentList[position].DOCUMENT,
                                    _localPath);
                              } else {
                                GlobalFunctions.showToast(
                                    AppLocalizations.of(context)
                                        .translate('download_permission'));
                              }
                            });
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                child: AppIcon(
                              Icons.attach_file,
                              iconColor: GlobalVariables.mediumGreen,
                            )),
                            SizedBox(width: 4,),
                            Container(
                              child: text(
                                "Attachment",
                                textColor: GlobalVariables.green,
                                fontSize: GlobalVariables.textSizeSmall,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(width: 4,),
              text(
                  value.documentList[position].USER_NAME == null
                      ? 'Posted By: - '
                      : 'Posted By: ' +
                          value.documentList[position].USER_NAME,
                  textColor: GlobalVariables.grey,
                  fontSize: GlobalVariables.textSizeSmall),
            ],
          )
        ],
      ),
    );
  }

  getDocumentTypeColor(String type) {
    switch (type.toLowerCase().trim()) {
      case "others":
        return GlobalVariables.skyBlue;
        break;
      case "financial":
        return GlobalVariables.orangeYellow;
        break;
      case "agm-em":
        return GlobalVariables.green;
        break;
      default:
        return GlobalVariables.skyBlue;
        break;
    }
  }

  getVoteLayout(int position, MyComplexResponse value) {
    //  print("value.pollList[position].SECRET_POLL : "+value.pollList[position].SECRET_POLL.toString());
    // print("value.pollList[position].OPTION : "+value.pollList[position].OPTION.toString());
    List<PollOption> _optionList = List<PollOption>.from(
        value.pollList[position].OPTION.map((i) => PollOption.fromJson(i)));
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Container(
            //color: GlobalVariables.lightGray,
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _optionList.length,
                itemBuilder: (BuildContext context, int i) {
                  return getPollOptionListItemLayout(
                      position, _optionList[i], value);
                }),
          ),
        ),
      ],
    );
  }

  getPollOptionListItemLayout(
      int position, PollOption pollOption, MyComplexResponse value) {
    if (value.pollList[position].VOTED_TO.length > 0) {
      if (pollOption.ANS_ID.toString().toLowerCase() ==
          value.pollList[position].VOTED_TO.toLowerCase()) {
        pollOption.isSelected = true;
      } else {
        pollOption.isSelected = false;
      }
    } else if (value.pollList[position].View_VOTED_TO.length > 0) {
      if (pollOption.ANS_ID.toString().toLowerCase() ==
          value.pollList[position].View_VOTED_TO.toLowerCase()) {
        pollOption.isSelected = true;
      } else {
        pollOption.isSelected = false;
      }
    } else {
      pollOption.isSelected = false;
    }

    return InkWell(
      //  splashColor: GlobalVariables.mediumGreen,
      onTap: () {
        if (value.pollList[position].VOTE_PERMISSION.toLowerCase() == 'yes') {
          setState(() {
            pollOption.isSelected = true;
            value.pollList[position].View_VOTED_TO = pollOption.ANS_ID;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: pollOption.isSelected == true
                            ? GlobalVariables.green
                            : GlobalVariables.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: pollOption.isSelected == true
                              ? GlobalVariables.green
                              : GlobalVariables.mediumGreen,
                          width: 2.0,
                        )),
                    child: AppIcon(
                      Icons.check,
                      iconColor: pollOption.isSelected == true
                          ? GlobalVariables.white
                          : GlobalVariables.transparent,
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: text(
                        pollOption.ANS == null ? '' : pollOption.ANS,
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addPollVote(String pollId, String optionId, int position,
      List<PollOption> optionList, MyComplexResponse myComplexValue) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();
    _progressDialog.show();
    restClient
        .addPollVote(societyId, userId, block, flat, pollId, optionId)
        .then((value) async {
      _progressDialog.hide();
      print('Response : ' + value.toString());
      if (value.status) {
        myComplexValue.pollList[position].VOTED_TO = optionId;
        myComplexValue.pollList[position].VOTE_PERMISSION = 'NO';

        if (myComplexValue.pollList[position].SECRET_POLL.toLowerCase() ==
            'yes') {
          setState(() {});
          GlobalFunctions.showToast(value.message +
              '. You can view result of poll after ' +
              myComplexValue.pollList[position].EXPIRY_DATE);
        } else {
          setState(() {});
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseViewPollGraph(
                      myComplexValue.pollList[position], optionList)));
        }
      } else {
        GlobalFunctions.showToast(value.message);
      }
    });
  }
}
