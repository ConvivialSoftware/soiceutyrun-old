import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Comments.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

import 'HelpDesk.dart';

class BaseComplaintInfoAndComments extends StatefulWidget {

  Complaints _complaint;
  //final String ticketId;
  BaseComplaintInfoAndComments(this._complaint);

  BaseComplaintInfoAndComments.ticketNo(String ticketId){
    print('Ticket No :'+ticketId);
    _complaint = Complaints();
    _complaint.TICKET_NO=ticketId;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ComplaintInfoAndCommentsState(_complaint);
  }
}

class ComplaintInfoAndCommentsState
    extends State<BaseComplaintInfoAndComments> {
  var userId,photo="";
  List<Complaints> _complaintsList = new List<Complaints>();
  List<Comments> _commentsList = new List<Comments>();
  List<ComplaintStatus> _complaintStatusList = new List<ComplaintStatus>();
  Complaints complaints;

  ProgressDialog _progressDialog;
  ComplaintInfoAndCommentsState(this.complaints);

  TextEditingController commentController = TextEditingController();

  String _selectedItem;
  List<DropdownMenuItem<String>> _complaintStatusListItems =
      new List<DropdownMenuItem<String>>();

  bool isComment = false;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getUserId();
    getComplaintStatus();
    //getCommentsList();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getUserCommentData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);

    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back,
              color: GlobalVariables.white,
            ),
          ),
          title: Text(
            AppLocalizations.of(context).translate('complaint') +
                " " +
                complaints.TICKET_NO,
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Container(
      width: MediaQuery.of(context).size.width,
      //height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 200.0),
                getComplaintInfoCommentLayout(),
                addCommentLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getComplaintInfoCommentLayout() {
    return SingleChildScrollView(
      child: complaints.SUBJECT!=null ? Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 80),
        padding: EdgeInsets.all(0),
      //  height: MediaQuery.of(context).size.height - 210,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
        //  width: MediaQuery.of(context).size.width / 1.1,
          padding: EdgeInsets.all(10),
          margin:
              EdgeInsets.fromLTRB(0, 10, 0, 0), // color: GlobalVariables.grey,
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(
                            15, 0, 0, 0), //alignment: Alignment.topLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                                // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  child: Text(
                                    complaints.STATUS,
                                    style: TextStyle(
                                        color: GlobalVariables.white,
                                        fontSize: 12),
                                  ),
                                  decoration: BoxDecoration(
                                      color: MyUnitState.getTicketCategoryColor(
                                          complaints.STATUS),
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                Container(
                                  child: Text(
                                    'Ticket No: ' + complaints.TICKET_NO,
                                    style: TextStyle(
                                        color: GlobalVariables.green,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            )),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                              child: AutoSizeText(complaints.SUBJECT,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Text(
                                complaints.DESCRIPTION,
                                style:
                                    TextStyle(color: GlobalVariables.mediumGreen),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(
                                    'Category: ',
                                    style: TextStyle(
                                        color: GlobalVariables.green,
                                        fontSize: 14),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(
                                    complaints.CATEGORY,
                                    style: TextStyle(
                                      color: GlobalVariables.mediumGreen,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            /*Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(
                                    'Area: ',
                                    style: TextStyle(
                                        color: GlobalVariables.green,
                                        fontSize: 14),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(
                                     complaints.COMPLAINT_AREA,
                                    style: TextStyle(
                                        color: GlobalVariables.mediumGreen,
                                        fontSize: 14),
                                  ),
                                ),
                              ],
                            ),*/
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 1,
                color: GlobalVariables.mediumGreen,
                margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Divider(
                  height: 3,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Text('Issued on: ' + GlobalFunctions.convertDateFormat(complaints.DATE,"dd-MM-yyyy"),
                          style: TextStyle(
                              color: GlobalVariables.mediumGreen, fontSize: 14)),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 2,
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 3.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _complaintStatusListItems,
                            onChanged: changeDropDownItem,
                            isExpanded: true,
                            value: _selectedItem,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
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
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        height: 45,
                        margin: EdgeInsets.fromLTRB(10, 20, 0, 0),
                        child: ButtonTheme(
                          // minWidth: MediaQuery.of(context).size.width/2,
                          child: RaisedButton(
                            color: GlobalVariables.green,
                            onPressed: () {
                              isComment = false;
                              updateComplaintStatus(context);
                            },
                            textColor: GlobalVariables.white,
                            //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: GlobalVariables.green)),
                            child: AutoSizeText(
                              AppLocalizations.of(context).translate('submit'),
                              style:
                                  TextStyle(fontSize: GlobalVariables.largeText),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                alignment: Alignment.topLeft,
                child: Text(
                  AppLocalizations.of(context).translate('comments'),
                  style: TextStyle(
                      color: GlobalVariables.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: 1,
                color: GlobalVariables.mediumGreen,
                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Divider(
                  height: 3,
                ),
              ),
              getCommentsListData()
            ],
          ),
        ),
      ) : Container(),
    );
  }

  addCommentLayout() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        //  margin: EdgeInsets.fromLTRB(20, 40, 20,40),
        height: 50,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: GlobalVariables.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Image.asset(
                GlobalVariables.componentUserProfilePath,
                width: 20,
                height: 20,
              ),
            ),
            Expanded(
              child: Container(
                // color: GlobalVariables.grey,
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)
                          .translate('add_ur_comments'),
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 16),
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
                    child: Icon(
                      Icons.attach_file,
                      color: GlobalVariables.mediumGreen,
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
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: GlobalVariables.white,
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
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                controller: _scrollController,
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

  getCommentsListDataListItemLayout(int position) {
    return Container(
      //alignment: userId!=_commentsList[position].cmtUserID ? Alignment.topRight:Alignment.topLeft,
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Row(
        children: <Widget>[
          Container(
            margin: userId == _commentsList[position].USER_ID
                ? EdgeInsets.fromLTRB(40, 0, 0, 0)
                : EdgeInsets.fromLTRB(
                    0, 0, 0, 0), // color: GlobalVariables.black,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: GlobalVariables.lightGreen,
              backgroundImage: userId != _commentsList[position].USER_ID ? NetworkImage(_commentsList[position].PROFILE_PHOTO) : NetworkImage(photo),
            )
          ),
          Flexible(
            child: Container(
              //   color: GlobalVariables.grey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    // color : GlobalVariables.lightGray,
                    margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          child: Text(
                            _commentsList[position].NAME,
                            style: TextStyle(
                                color: GlobalVariables.green, fontSize: 16),
                          ),
                        ), /*Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(_commentsList[position].cmtLikeCount + " Likes",style: TextStyle(
                              color: GlobalVariables.green,fontSize: 16
                          ),),
                        ),*/
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: Text(
                     GlobalFunctions.convertDateFormat(_commentsList[position].C_WHEN,"dd-MM-yyyy hh:mm"),
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 12),
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
                            child: Text(
                              _commentsList[position].COMMENT,
                              style: TextStyle(
                                  color: GlobalVariables.black, fontSize: 14),
                            ),
                          ),
                        ), /*Container(
                          child: Icon(Icons.chat_bubble_outline,color: GlobalVariables.mediumGreen,)
                        ),*/
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
      ComplaintStatus(complaintStatus: "New"),
      ComplaintStatus(complaintStatus: "Close"),
      ComplaintStatus(complaintStatus: "Reopen"),
      ComplaintStatus(complaintStatus: "Completed"),
      ComplaintStatus(complaintStatus: "In Progress"),
    ];

    for (int i = 0; i < _complaintStatusList.length; i++) {
      _complaintStatusListItems.add(DropdownMenuItem(
        value: _complaintStatusList[i].complaintStatus,
        child: Text(
          _complaintStatusList[i].complaintStatus,
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));
    }
    _selectedItem = _complaintStatusListItems[0].value;
  }

  getUserId() {
    GlobalFunctions.getUserId().then((value) {
      userId = value;
      getUserPhoto();
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
        _commentsList = List<Comments>.from(_list.map((i) => Comments.fromJson(i)));
        if(complaints.SUBJECT!=null) {
          setState(() {});
        }else{
          getComplaintDataAgainstTicketNo();
        }
      }
      _progressDialog.hide();
    });
  }


  Future<void> getComplaintDataAgainstTicketNo() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    var societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getComplaintDataAgainstTicketNo(societyId, complaints.TICKET_NO).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;
        _complaintsList = List<Complaints>.from(_list.map((e) => Complaints.fromJson(e)));
        complaints = _complaintsList[0];
        setState(() {});
      }
      _progressDialog.hide();
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
    String complaintStatus= _selectedItem;

    if (isComment) {
      var currentTime = DateTime.now();
      String str = currentTime.year.toString() +
          "-" +
          currentTime.month.toString().padLeft(2,'0') +
          "-" +
          currentTime.day.toString().padLeft(2,'0') +
          " " +
          currentTime.hour.toString() +
          ':' +
          currentTime.minute.toString()+
          ':' +
          currentTime.second.toString();
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
      complaintStatus="";
    } else {
      _progressDialog.show();
      //  Navigator.of(context).pop();
    }

    print('Status : '+ complaintStatus);
    print('Comment : '+ comment);
    print('isComment : '+ isComment.toString());


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
      if(_progressDialog.isShowing()){
        _progressDialog.hide();
      }
      if (value.status) {
        commentController.clear();
        if (isComment) {
          GlobalFunctions.showToast(
              "Your comment has been updated to the complaint log.");
        }else{
          GlobalFunctions.showToast(value.message);
          Navigator.of(context).pop();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => BaseHelpDesk()));
        }
      }
    });
  }
}

class ComplaintStatus {
  String complaintStatus;

  ComplaintStatus({this.complaintStatus});
}
