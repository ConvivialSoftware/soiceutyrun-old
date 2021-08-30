import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Comments.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'HelpDesk.dart';

class BaseComplaintInfoAndComments extends StatefulWidget {
  Complaints _complaint;
  final bool isAssignComplaint;

  //final String ticketId;
  BaseComplaintInfoAndComments(this._complaint, this.isAssignComplaint);

  BaseComplaintInfoAndComments.ticketNo(
      String ticketId, this.isAssignComplaint) {
    print('Ticket No :' + ticketId);
    _complaint = Complaints();
    _complaint.TICKET_NO = ticketId;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ComplaintInfoAndCommentsState(_complaint, isAssignComplaint);
  }
}

class ComplaintInfoAndCommentsState
    extends BaseStatefulState<BaseComplaintInfoAndComments> {
  var userId, photo = "", _localPath;
  List<Complaints> _complaintsList = new List<Complaints>();
  List<Comments> _commentsList = new List<Comments>();
  List<ComplaintStatus> _complaintStatusList = new List<ComplaintStatus>();
  Complaints complaints;

  ProgressDialog _progressDialog;
  final bool isAssignComplaint;

  bool isStoragePermission = false;

  ComplaintInfoAndCommentsState(this.complaints, this.isAssignComplaint);

  TextEditingController commentController = TextEditingController();

  String _complaintType;
  String _selectedItem;
  List<DropdownMenuItem<String>> _complaintStatusListItems =
      new List<DropdownMenuItem<String>>();

  bool isComment = false;
  String _taskId;
  ReceivePort _port = ReceivePort();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getUserId();
    getLocalPath();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission = value;
    });
    if (isAssignComplaint) getComplaintStatus();
    //getCommentsList();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getUserCommentData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
    if (complaints.SUBJECT != null) {
      _complaintType = complaints.STATUS;
    }
    print('_complaintType : '+_complaintType.toString());
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
    // TODO: implement build

    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);

    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: AppIcon(
              Icons.arrow_back,
              iconColor: GlobalVariables.white,
            ),
          ),
          title: text(
            AppLocalizations.of(context).translate('complaint') +
                " #" +
                complaints.TICKET_NO,
           textColor: GlobalVariables.white, fontSize: GlobalVariables.textSizeMedium
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 200.0),
        getComplaintInfoCommentLayout(),
        addCommentLayout(),
      ],
    );
  }

  getComplaintInfoCommentLayout() {
    // _selectedItem = complaints.STATUS;
    print('value ' + _complaintType.toString());
    print('attchment ' + complaints.ATTACHMENT.toString());
    return SingleChildScrollView(
      controller: _scrollController,
      child: complaints.SUBJECT != null
          ? Column(
            children: <Widget>[
              AppContainer(
                child: Column(
                  //mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                        // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: text(
                            complaints.STATUS,
                           textColor: GlobalVariables.white,
                            fontSize: GlobalVariables.textSizeSmall,
                          ),
                          decoration: BoxDecoration(
                              color: getTicketCategoryColor(
                                      complaints.STATUS),
                              borderRadius:
                                  BorderRadius.circular(5)),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           /* AppIcon(
                              Icons.date_range_rounded,
                              iconColor: GlobalVariables.grey,
                              iconSize: 20.0,
                            ),*/
                           // SizedBox(width: 3,),
                            Container(
                              child: text(
                                  GlobalFunctions
                                      .convertDateFormat(
                                      complaints.DATE,
                                      "dd-MM-yyyy"),
                                  textColor: GlobalVariables.grey,
                                  fontSize: GlobalVariables.textSizeSmall
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: primaryText(complaints.SUBJECT,),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: secondaryText(
                        complaints.DESCRIPTION,
                      ),
                    ),
                    isAssignComplaint
                        ? Divider()
                        : SizedBox(),
                    isAssignComplaint
                        ? Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    child: text(
                                      'Name: ',
                                      textColor: GlobalVariables
                                              .green,
                                          fontSize: GlobalVariables.textSizeSmall,
                                    ),
                                  ),
                                  Container(
                                    child: text(complaints.NAME,
                                        textColor: GlobalVariables
                                                .grey,
                                            fontSize: GlobalVariables.textSizeSmall),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: text(
                                      'Unit No: ',
                                      textColor: GlobalVariables
                                              .green,
                                          fontSize: GlobalVariables.textSizeSmall,
                                    ),
                                  ),
                                  Container(
                                    child: text(
                                      complaints.BLOCK +
                                          ' ' +
                                          complaints.FLAT,
                                      textColor:
                                            GlobalVariables.grey,
                                        fontSize: GlobalVariables.textSizeSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : SizedBox(),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: <Widget>[
                            Container(
                              child: text(
                                'Category: ',
                                textColor: GlobalVariables.green,
                                    fontSize: GlobalVariables.textSizeSmall,
                              ),
                            ),
                            Container(
                              child: text(
                                complaints.CATEGORY,
                                textColor: GlobalVariables.grey,
                                  fontSize: GlobalVariables.textSizeSmall,
                              ),
                            ),
                          ],
                        ),
                        complaints.ATTACHMENT!=null && complaints.ATTACHMENT.length>0 ? InkWell(
                          onTap: () {
                            if(complaints.ATTACHMENT!=null) {
                              String url = complaints.ATTACHMENT;
                              if (isStoragePermission) {
                                downloadAttachment(
                                    url, _localPath);
                              } else {
                                GlobalFunctions.askPermission(
                                    Permission.storage)
                                    .then((value) {
                                  if (value) {
                                    downloadAttachment(
                                        url, _localPath);
                                  } else {
                                    GlobalFunctions.showToast(
                                        AppLocalizations.of(
                                            context)
                                            .translate(
                                            'download_permission'));
                                  }
                                });
                              }
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  alignment: Alignment.topRight,
                                  //margin: EdgeInsets.fromLTRB(5, 15, 5, 0),
                                  child: AppIcon(
                                    Icons.attach_file,
                                    iconColor: GlobalVariables.mediumGreen,
                                    iconSize: 20.0,
                                  )),
                              Container(
                                //margin: EdgeInsets.fromLTRB(5, 15, 5, 0),
                                child: text(
                                  "Attachment",
                                  textColor: GlobalVariables.green,
                                  fontSize: GlobalVariables.textSizeVerySmall,
                                ),
                              )
                            ],
                          ),
                        ) : SizedBox(),
                      ],
                    ),
                  ],
                ),
              ),
              isAssignComplaint && complaints.STATUS.toLowerCase() == 'close' ? SizedBox()
               : Visibility(
                visible:complaints.STATUS.toLowerCase() == 'new' ||
                        complaints.STATUS.toLowerCase() == 'reopen' ||
                        complaints.STATUS.toLowerCase() == 'in progress' ||
                        complaints.STATUS.toLowerCase() == 'close' ||
                        complaints.STATUS.toLowerCase() == 'on hold'
                    ? true
                    : false,
                child: AppContainer(
                  isListItem: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      isAssignComplaint
                          ? Flexible(
                              flex: 2,
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                decoration: BoxDecoration(
                                    color: GlobalVariables.white,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    border: Border.all(
                                      color: GlobalVariables.mediumGreen,
                                      width: 2.0,
                                    )),
                                child: ButtonTheme(
                                  child: DropdownButton(
                                    items: _complaintStatusListItems,
                                    onChanged: changeDropDownItem,
                                    isExpanded: true,
                                    value: _selectedItem,
                                    icon: AppIcon(
                                      Icons.keyboard_arrow_down,
                                      iconColor: GlobalVariables.mediumGreen,
                                    ),
                                    underline: SizedBox(),
                                    /* hint: Text(
                        _selectedItem == null ? AppLocalizations.of(context).translate('status') : _selectedItem,
                        style: TextStyle(
                            color: GlobalVariables.lightGray,
                            fontSize: 12),
                      ),*/
                                  ),
                                ),
                              ),
                            )
                          : complaints.STATUS.toLowerCase() == 'new' ||
                                  complaints.STATUS.toLowerCase() ==
                                      'reopen' ||
                                  complaints.STATUS.toLowerCase() ==
                                      'in progress' || complaints.STATUS.toLowerCase() == 'on hold'
                              ? Flexible(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _complaintType.toLowerCase() ==
                                                      'new' ||
                                                  _complaintType
                                                          .toLowerCase() ==
                                                      'reopen' ||
                                                  _complaintType
                                                          .toLowerCase() ==
                                                      'in progress' ||
                                              _complaintType
                                                  .toLowerCase() ==
                                                  'on hold'
                                              ? _complaintType = "Close"
                                              : _complaintType =
                                                  complaints.STATUS;
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: _complaintType
                                                              .toLowerCase() ==
                                                          'new' ||
                                                      _complaintType
                                                              .toLowerCase() ==
                                                          'reopen' ||
                                                      _complaintType
                                                              .toLowerCase() ==
                                                          'in progress' ||
                                                  _complaintType
                                                      .toLowerCase() ==
                                                      'on hold'
                                                  ? GlobalVariables.white
                                                  : GlobalVariables.green,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      5),
                                              border: Border.all(
                                                color: _complaintType
                                                                .toLowerCase() ==
                                                            'new' ||
                                                        _complaintType
                                                                .toLowerCase() ==
                                                            'reopen' ||
                                                        _complaintType
                                                                .toLowerCase() ==
                                                            'in progress'||
                                                    _complaintType
                                                        .toLowerCase() ==
                                                        'on hold'
                                                    ? GlobalVariables
                                                        .mediumGreen
                                                    : GlobalVariables
                                                        .transparent,
                                                width: 2.0,
                                              )),
                                          child: Icon(Icons.check,
                                              color:
                                                  GlobalVariables.white),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(
                                            10, 0, 0, 0),
                                        child: text(
                                          AppLocalizations.of(context)
                                              .translate('close'),
                                         textColor:
                                                  GlobalVariables.green,
                                              fontSize: GlobalVariables.textSizeMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Flexible(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _complaintType.toLowerCase() ==
                                                  "close"
                                              ? _complaintType = "Reopen"
                                              : _complaintType = "Close";
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: _complaintType
                                                          .toLowerCase() ==
                                                      "close"
                                                  ? GlobalVariables.white
                                                  : GlobalVariables.green,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      5),
                                              border: Border.all(
                                                color: _complaintType
                                                            .toLowerCase() ==
                                                        "close"
                                                    ? GlobalVariables
                                                        .mediumGreen
                                                    : GlobalVariables
                                                        .transparent,
                                                width: 2.0,
                                              )),
                                          child: AppIcon(Icons.check,
                                              iconColor:
                                                  GlobalVariables.white),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(
                                            10, 0, 0, 0),
                                        child: text(
                                          AppLocalizations.of(context)
                                              .translate('reopen'),
                                          textColor:
                                                  GlobalVariables.green,
                                              fontSize: GlobalVariables.textSizeMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      Flexible(
                        flex: 1,
                        child: AppButton(
                          textContent: AppLocalizations.of(context).translate('submit'),
                          onPressed: (){
                            print('_complaintType : '+_complaintType.toString());
                            print('_selectedItem : '+_selectedItem.toString());
                            if(isAssignComplaint){
                              isComment = false;
                              updateComplaintStatus(context);
                            }else{
                              if(_complaintType.toLowerCase()!='close' || _complaintType.toLowerCase()!='reopen'){
                                /*if(_complaintType.toLowerCase()=='close' || _complaintType.toLowerCase()=='completed'){
                                      GlobalFunctions.showToast('Please Select the Complaint Status');
                                    }else {*/
                                isComment = false;
                                updateComplaintStatus(context);
                                // }
                              }else{
                                GlobalFunctions.showToast('Please Select the Complaint Status');
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _commentsList.length > 0
                  ? AppContainer(
                isListItem: true,
                      child: Column(
                        children: [
                          Container(
                            //margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                            alignment: Alignment.topLeft,
                            child: primaryText(
                              AppLocalizations.of(context)
                                  .translate('comments'),
                            ),
                          ),
                          Divider(),
                          getCommentsListData()
                        ],
                      ),
                    )
                  : SizedBox(),
            ],
          )
          : Container(),
    );
  }

  addCommentLayout() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.fromLTRB(4, 10, 4, 10),
        //  margin: EdgeInsets.fromLTRB(20, 40, 20,40),
       // height: 50,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: GlobalVariables.lightGray,
              width: 1,
            )),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: photo.isEmpty ? Image.asset(
                GlobalVariables.componentUserProfilePath,
                width: 20,
                height: 20,
              ): CircleAvatar(
                radius: 10,
                backgroundColor: GlobalVariables.mediumGreen,
                backgroundImage: NetworkImage(photo),
              ),
            ),
            Expanded(
              child: Container(
                // color: GlobalVariables.grey,
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: TextField(
                  controller: commentController,
                  keyboardType: TextInputType.multiline,
                   minLines: 1,
                  maxLines: 999999,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)
                          .translate('add_ur_comments'),
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: GlobalVariables.textSizeMedium),
                      border: InputBorder.none),
                ),
              ),
            ),
            Visibility(
              visible: false,
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 0, 10, 0),
                child: Transform.rotate(
                    angle: 108 * 3.14 / 600,
                    child: AppIcon(
                      Icons.attach_file,
                      iconColor: GlobalVariables.mediumGreen,
                    )),
              ),
            ),
            InkWell(
              onTap: () {
                isComment = true;

                updateComplaintStatus(context);
              },
              child: Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.fromLTRB(5, 0, 10, 0),
                decoration: BoxDecoration(
                  color: GlobalVariables.green,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: AppIcon(
                  Icons.arrow_forward_ios,
                  iconColor: GlobalVariables.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

/*
  getCommentsList() {
    _commentsList = [
      Comments(cmtUserID: "1",cmtName: "Pallavi Unde",cmtDate: "16/05/2019 12:13pm",
          cmtDesc: "I agree with Mr. ABC Drinking water timing shoud be increased by atleast 2 hours.",cmtLikeCount: "2"),
      Comments(cmtUserID: "12",cmtName: "Umesh Dere",cmtDate: "17/05/2019 7:27am",
          cmtDesc: "in my opinion we should leave the decision to society management.",cmtLikeCount: "0"),
      Comments(cmtUserID: "13",cmtName: "Ashish Waykar",cmtDate: "17/05/2019 12:30pm",
          cmtDesc: "On Sunday 19th May 2019 we are going to discuss with Society member and update the status to you",cmtLikeCount: "1"),
      Comments(cmtUserID: "1",cmtName: "Pallavi Unde",cmtDate: "16/05/2019 12:13pm",
          cmtDesc: "I agree with Mr. ABC Drinking water timing shoud be increased by atleast 2 hours.",cmtLikeCount: "2"),
      Comments(cmtUserID: "12",cmtName: "Umesh Dere",cmtDate: "17/05/2019 7:27am",
          cmtDesc: "in my opinion we should leave the decision to society management.",cmtLikeCount: "0"),
      Comments(cmtUserID: "13",cmtName: "Ashish Waykar",cmtDate: "17/05/2019 12:30pm",
          cmtDesc: "On Sunday 19th May 2019 we are going to discuss with Society member and update the status to you",cmtLikeCount: "1"),
    ];
  }
*/

  getCommentsListData() {
    return Container(
      padding: EdgeInsets.only(bottom: 40),
      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // controller: _scrollController,
                // scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _commentsList.length,
                itemBuilder: (context, position) {
                  return getCommentsListDataListItemLayout(position);
                },
                //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  static getTicketCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case "new":
        return GlobalVariables.skyBlue;
        break;
      case "in progress":
        return GlobalVariables.orangeYellow;
        break;
      case "reopen":
        return GlobalVariables.red;
        break;
      case "on hold":
        return GlobalVariables.orangeYellow;
        break;
      default:
        return GlobalVariables.skyBlue;
        break;
    }
  }

  getCommentsListDataListItemLayout(int position) {
   // print('_commentsList[position].PROFILE_PHOTO : '+_commentsList[position].PROFILE_PHOTO.toString());
    return Container(
      //alignment: userId!=_commentsList[position].cmtUserID ? Alignment.topRight:Alignment.topLeft,
      //margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: GlobalVariables.lightGreen,
                backgroundImage: userId != _commentsList[position].USER_ID
                    ? _commentsList[position].PROFILE_PHOTO.isNotEmpty ? NetworkImage(_commentsList[position].PROFILE_PHOTO) : AssetImage(GlobalVariables.componentUserProfilePath)
                    : NetworkImage(photo),
              ),
              SizedBox(width: 8,),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          primaryText(
                            _commentsList[position].NAME,
                          ),
                          text(
                            _commentsList[position].C_WHEN != '0000-00-00 00:00:00'
                                ? GlobalFunctions.convertDateFormat(
                                _commentsList[position].C_WHEN,
                                "hh:mm aa")
                                : '',
                            textColor: GlobalVariables.grey, fontSize: GlobalVariables.textSizeVerySmall,
                          ),
                        ],
                      ),
                      text(
                        _commentsList[position].C_WHEN != '0000-00-00 00:00:00'
                            ? GlobalFunctions.convertDateFormat(
                            _commentsList[position].C_WHEN,
                            "dd-MM-yyyy")
                            : '',
                        textColor: GlobalVariables.grey, fontSize: GlobalVariables.textSizeVerySmall,
                      ),
                    ],
              )),
            ],
          ),
          SizedBox(height: 8,),
          text(
              _commentsList[position].COMMENT,
              textColor: GlobalVariables.black,
              fontSize: GlobalVariables.textSizeSMedium,
          ),
          Divider(),
        ],
      ),
      /*child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
             *//* margin: userId == _commentsList[position].USER_ID
                  ? EdgeInsets.fromLTRB(40, 0, 0, 0)
                  : EdgeInsets.fromLTRB(
                      0, 0, 0, 0),*//* // color: GlobalVariables.black,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: GlobalVariables.lightGreen,
                backgroundImage: userId != _commentsList[position].USER_ID
                    ? NetworkImage(_commentsList[position].PROFILE_PHOTO)
                    : NetworkImage(photo),
              )),
          Flexible(
            child: Container(
              //   color: GlobalVariables.grey,
              child: Column(
                children: <Widget>[
                  Container(
                    // color : GlobalVariables.lightGray,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          child: text(
                            _commentsList[position].NAME,
                            textColor: GlobalVariables.green, fontSize: GlobalVariables.textSizeMedium,
                          ),
                        ), *//*Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(_commentsList[position].cmtLikeCount + " Likes",style: TextStyle(
                              color: GlobalVariables.green,fontSize: 16
                          ),),
                        ),*//*
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: text(
                      _commentsList[position].C_WHEN != '0000-00-00 00:00:00'
                          ? GlobalFunctions.convertDateFormat(
                              _commentsList[position].C_WHEN,
                              "dd-MM-yyyy hh:mm aa")
                          : '',
                     textColor: GlobalVariables.lightGray, fontSize: GlobalVariables.textSizeSmall,
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                            child: text(
                              _commentsList[position].COMMENT,
                              textColor: GlobalVariables.black, fontSize: GlobalVariables.textSizeSMedium,
                            ),
                          ),
                        ), *//*Container(
                          child: Icon(Icons.chat_bubble_outline,color: GlobalVariables.mediumGreen,)
                        ),*//*
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),*/
    );
  }

  void changeDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedItem = value;
      print('_selctedItem:' + _selectedItem.toString());
    });
  }

  getComplaintStatus() {
    _complaintStatusList = [
      //ComplaintStatus(complaintStatus: "New"),
      //ComplaintStatus(complaintStatus: "Close"),
      //ComplaintStatus(complaintStatus: "Reopen"),
      ComplaintStatus(complaintStatus: "Completed"),
      ComplaintStatus(complaintStatus: "In Progress"),
      ComplaintStatus(complaintStatus: "On Hold"),
    ];
    print('dropdown length : ' + _complaintStatusList.length.toString());

    for (int i = 0; i < _complaintStatusList.length; i++) {
      _complaintStatusListItems.add(DropdownMenuItem(
        value: _complaintStatusList[i].complaintStatus,
        child: text(
          _complaintStatusList[i].complaintStatus,
          textColor: GlobalVariables.green,
          fontSize: GlobalVariables.textSizeSmall
        ),
      ));
    }
    for(int i=0;i<_complaintStatusListItems.length;i++){
      if(_selectedItem==null){
        if(complaints.STATUS!=null) {
          if (complaints.STATUS.toLowerCase() ==
              _complaintStatusListItems[i].value.toLowerCase()) {
            _selectedItem = _complaintStatusListItems[i].value;
            break;
          }
        }

      }
    }
    if(_selectedItem==null) {
      _selectedItem = _complaintStatusListItems[0].value;
    }
    print('_selectedItem length : ' + _selectedItem..toString());
  }

  getUserId() {
    GlobalFunctions.getUserId().then((value) {
      userId = value;
      getUserPhoto();
    });
  }

  void getLocalPath() {
    GlobalFunctions.localPath().then((value) {
      print("External Directory Path" + value.toString());
      _localPath = value;
    });
  }

  getUserPhoto() {
    GlobalFunctions.getPhoto().then((value) {
      photo = value;
      setState(() {});
    });
  }

  Future<void> getUserCommentData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    var societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getCommentData(societyId, complaints.TICKET_NO).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;
        _commentsList =
            List<Comments>.from(_list.map((i) => Comments.fromJson(i)));
        print('complaints.SUBJECT : '+ complaints.SUBJECT.toString());
        if (complaints.SUBJECT != null) {
         // _progressDialog.hide();
          Navigator.of(context).pop();
          setState(() {});
        } else {
          getComplaintDataAgainstTicketNo();
        }
      }
    });
  }

  Future<void> getComplaintDataAgainstTicketNo() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    var societyId = await GlobalFunctions.getSocietyId();
    if(!_progressDialog.isShowing()) {
      _progressDialog.show();
    }
    restClient
        .getComplaintDataAgainstTicketNo(societyId, complaints.TICKET_NO)
        .then((value) {
      //_progressDialog.hide();
      Navigator.of(context).pop();
      if (value.status) {
        List<dynamic> _list = value.data;
        _complaintsList =
            List<Complaints>.from(_list.map((e) => Complaints.fromJson(e)));
        complaints = _complaintsList[0];
        _complaintType = complaints.STATUS;
        setState(() {});
      }
    });
  }

  Future<void> updateComplaintStatus(BuildContext context) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();
    String ticketNo = complaints.TICKET_NO;
    String societyName = await GlobalFunctions.getSocietyName();
    String societyEmail = await GlobalFunctions.getSocietyEmail();
    String userEmail = await GlobalFunctions.getUserName();
    String userName = await GlobalFunctions.getDisplayName();
    String comment = commentController.text;
    String attachment;
    String type = complaints.TYPE;
    String escalationLevel = complaints.ESCALATION_LEVEL;
    String complaintStatus = isAssignComplaint ? _selectedItem : _complaintType;

    if (isComment) {
      var currentTime = DateTime.now();
      String str = currentTime.year.toString() +
          "-" +
          currentTime.month.toString().padLeft(2, '0') +
          "-" +
          currentTime.day.toString().padLeft(2, '0') +
          " " +
          currentTime.hour.toString().padLeft(2, '0') +
          ':' +
          currentTime.minute.toString().padLeft(2, '0') +
          ':' +
          currentTime.second.toString().padLeft(2, '0');
      Comments comments = Comments(
          PARENT_TICKET: complaints.TICKET_NO,
          USER_ID: userId,
          COMMENT: commentController.text,
          C_WHEN: str,
          NAME: userName);
      print("list lenght before : " + _commentsList.length.toString());
      _commentsList.add(comments);
      print("list lenght after : " + _commentsList.length.toString());
      setState(() {});
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      commentController.clear();
      complaintStatus = "";
    } else {
      _progressDialog.show();
      //  Navigator.of(context).pop();
    }

    print('Status : ' + complaintStatus);
    print('Comment : ' + comment);
    print('isComment : ' + isComment.toString());

    restClient
        .getUpdateComplaintStatus(
            societyId,
            block,
            flat,
            userId,
            ticketNo,
            complaintStatus,
            comment,
            attachment,
            type,
            escalationLevel,
            societyName,
            userEmail,
            societyEmail,
            userName)
        .then((value) {
      print("update status response : " + value.toString());
      if (_progressDialog.isShowing()) {
        _progressDialog.hide();
      }
      if (value.status) {
        commentController.clear();
        if (isComment) {
          GlobalFunctions.showToast(
              "Your comment has been updated to the complaint log.");
          Provider.of<HelpDeskResponse>(context,listen: false).getUnitComplaintData(isAssignComplaint).then((value) {});
        } else {
          GlobalFunctions.showToast(value.message);
          Navigator.pop(context,'back');
       //   Navigator.push(context, MaterialPageRoute(builder: (context) => BaseHelpDesk(false)));
        }
      }
    });
  }
}

class ComplaintStatus {
  String complaintStatus;

  ComplaintStatus({this.complaintStatus});
}
