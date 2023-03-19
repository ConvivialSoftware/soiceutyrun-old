
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AppStatefulState.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Comments.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';


class BaseComplaintInfoAndComments extends StatefulWidget {
  Complaints? complaints;
  bool? isAssignComplaint;

  //final String ticketId;
  BaseComplaintInfoAndComments(this.complaints, this.isAssignComplaint);

  BaseComplaintInfoAndComments.ticketNo(
      String ticketId, this.isAssignComplaint) {
    print('Ticket No :' + ticketId);
    complaints = Complaints();
    complaints!.TICKET_NO = ticketId;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ComplaintInfoAndCommentsState();
  }
}

class ComplaintInfoAndCommentsState
    extends AppStatefulState<BaseComplaintInfoAndComments> {
  String? userId, photo = "";
  List<Complaints> _complaintsList = <Complaints>[];
  List<Comments> _commentsList = <Comments>[];
  List<ComplaintStatus> _complaintStatusList = <ComplaintStatus>[];

  //Complaints complaints;

  ProgressDialog? _progressDialog;

  // final bool isAssignComplaint;

  // bool isStoragePermission = false;

  // ComplaintInfoAndCommentsState(this.complaints, this.isAssignComplaint);

  TextEditingController commentController = TextEditingController();

  String? _complaintType;
  String? _selectedItem;
  List<DropdownMenuItem<String>> _complaintStatusListItems =
      <DropdownMenuItem<String>>[];

  bool isComment = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    getUserId();
    if (widget.isAssignComplaint!) getComplaintStatus();
    //getCommentsList();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getUserCommentData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
    _complaintType = widget.complaints!.STATUS;
    print('_complaintType : '+_complaintType.toString());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('complaint') +
                " #" +
              widget.complaints!.TICKET_NO!,
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
    print('attchment ' + widget.complaints!.ATTACHMENT.toString());
    return SingleChildScrollView(
      controller: _scrollController,
      child: widget.complaints!.SUBJECT != null
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
                              widget.complaints!.STATUS,
                           textColor: GlobalVariables.white,
                            fontSize: GlobalVariables.textSizeSmall,
                          ),
                          decoration: BoxDecoration(
                              color: getTicketCategoryColor(
                                    widget.complaints!.STATUS!),
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
                                        widget.complaints!.DATE!, "dd-MM-yyyy"),
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
                        child: primaryText(
                          widget.complaints!.SUBJECT,
                        ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: secondaryText(
                          widget.complaints!.DESCRIPTION,
                      ),
                    ),
                      widget.isAssignComplaint! ? Divider() : SizedBox(),
                      widget.isAssignComplaint!
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
                                              .primaryColor,
                                          fontSize: GlobalVariables.textSizeSmall,
                                    ),
                                  ),
                                  Container(
                                      child: text(widget.complaints!.NAME,
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
                                              .primaryColor,
                                          fontSize: GlobalVariables.textSizeSmall,
                                    ),
                                  ),
                                  Container(
                                    child: text(
                                        widget.complaints!.BLOCK! +
                                          ' ' +
                                            widget.complaints!.FLAT!,
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
                                textColor: GlobalVariables.primaryColor,
                                    fontSize: GlobalVariables.textSizeSmall,
                              ),
                            ),
                            Container(
                              child: text(
                                  widget.complaints!.CATEGORY,
                                textColor: GlobalVariables.grey,
                                  fontSize: GlobalVariables.textSizeSmall,
                              ),
                            ),
                          ],
                        ),
                          widget.complaints!.ATTACHMENT != null &&
                                  widget.complaints!.ATTACHMENT!.length > 0
                              ? InkWell(
                          onTap: () {
                                    if (widget.complaints!.ATTACHMENT != null) {
                                    downloadAttachment(
                                          widget.complaints!.ATTACHMENT);
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
                                    iconColor: GlobalVariables.secondaryColor,
                                    iconSize: 20.0,
                                  )),
                              Container(
                                //margin: EdgeInsets.fromLTRB(5, 15, 5, 0),
                                child: text(
                                  "Attachment",
                                  textColor: GlobalVariables.primaryColor,
                                  fontSize: GlobalVariables.textSizeVerySmall,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      if (downloading)
                                        Stack(
                                          alignment:
                                              AlignmentDirectional.center,
                                          children: [
                                            Container(
                                              //height: 20,
                                              //width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                //value: 71.0,
                                              ),
                                ),
                                            //SizedBox(width: 4,),
                                            Container(
                                                child: text(
                                                    downloadRate.toString(),
                                                    fontSize: GlobalVariables
                                                        .textSizeSmall,
                                                    textColor: GlobalVariables
                                                        .skyBlue))
                                          ],
                              )
                            ],
                          ),
                        ) : SizedBox(),
                      ],
                    ),
                  ],
                ),
              ),
                widget.isAssignComplaint! &&
                        widget.complaints!.STATUS!.toLowerCase() == 'close'
                    ? SizedBox()
               : Visibility(
                        visible:
                            widget.complaints!.STATUS!.toLowerCase() == 'new' ||
                                    widget.complaints!.STATUS!.toLowerCase() ==
                                        'reopen' ||
                                    widget.complaints!.STATUS!.toLowerCase() ==
                                        'in progress' ||
                                    widget.complaints!.STATUS!.toLowerCase() ==
                                        'close' ||
                                    widget.complaints!.STATUS!.toLowerCase() ==
                                        'on hold'
                    ? true
                    : false,
                child: AppContainer(
                  isListItem: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                              widget.isAssignComplaint!
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
                                      color: GlobalVariables.secondaryColor,
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
                                      iconColor: GlobalVariables.secondaryColor,
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
                                  : widget.complaints!.STATUS!.toLowerCase() ==
                                              'new' ||
                                          widget.complaints!.STATUS!
                                                  .toLowerCase() ==
                                      'reopen' ||
                                          widget.complaints!.STATUS!
                                                  .toLowerCase() ==
                                              'in progress' ||
                                          widget.complaints!.STATUS!
                                                  .toLowerCase() ==
                                              'on hold'
                              ? Flexible(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                                  _complaintType!.toLowerCase() ==
                                                      'new' ||
                                                          _complaintType!
                                                          .toLowerCase() ==
                                                      'reopen' ||
                                                          _complaintType!
                                                          .toLowerCase() ==
                                                      'in progress' ||
                                                          _complaintType!
                                                  .toLowerCase() ==
                                                  'on hold'
                                              ? _complaintType = "Close"
                                                      : _complaintType = widget
                                                          .complaints!.STATUS;
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                                      color: _complaintType!
                                                              .toLowerCase() ==
                                                          'new' ||
                                                              _complaintType!
                                                              .toLowerCase() ==
                                                          'reopen' ||
                                                              _complaintType!
                                                              .toLowerCase() ==
                                                          'in progress' ||
                                                              _complaintType!
                                                      .toLowerCase() ==
                                                      'on hold'
                                                  ? GlobalVariables.white
                                                  : GlobalVariables.primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      5),
                                              border: Border.all(
                                                        color: _complaintType!
                                                                .toLowerCase() ==
                                                            'new' ||
                                                                _complaintType!
                                                                .toLowerCase() ==
                                                            'reopen' ||
                                                                _complaintType!
                                                                .toLowerCase() ==
                                                            'in progress'||
                                                                _complaintType!
                                                        .toLowerCase() ==
                                                        'on hold'
                                                    ? GlobalVariables
                                                        .secondaryColor
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
                                                  GlobalVariables.primaryColor,
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
                                                  _complaintType!
                                                              .toLowerCase() ==
                                                  "close"
                                              ? _complaintType = "Reopen"
                                              : _complaintType = "Close";
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                                      color: _complaintType!
                                                          .toLowerCase() ==
                                                      "close"
                                                  ? GlobalVariables.white
                                                  : GlobalVariables.primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      5),
                                              border: Border.all(
                                                        color: _complaintType!
                                                            .toLowerCase() ==
                                                        "close"
                                                    ? GlobalVariables
                                                        .secondaryColor
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
                                                  GlobalVariables.primaryColor,
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
                                      if (widget.isAssignComplaint!) {
                              isComment = false;
                              updateComplaintStatus(context);
                            }else{
                                        if (_complaintType!.toLowerCase() !=
                                                'close' ||
                                            _complaintType!.toLowerCase() !=
                                                'reopen') {
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
              child: photo!.isEmpty ? Image.asset(
                GlobalVariables.componentUserProfilePath,
                width: 20,
                height: 20,
              ): CircleAvatar(
                radius: 10,
                backgroundColor: GlobalVariables.secondaryColor,
                      backgroundImage: NetworkImage(photo!),
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
                      iconColor: GlobalVariables.secondaryColor,
                    )),
              ),
            ),
            InkWell(
              onTap: () {
                isComment = true;
                if(commentController.text.isNotEmpty) {
                  updateComplaintStatus(context);
                }else{
                  GlobalFunctions.showToast("Please Enter Comment");
                }
              },
              child: Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.fromLTRB(5, 0, 10, 0),
                decoration: BoxDecoration(
                  color: GlobalVariables.primaryColor,
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
                backgroundColor: GlobalVariables.AccentColor,
                backgroundImage: userId != _commentsList[position].USER_ID
                    ? _commentsList[position].PROFILE_PHOTO!.isNotEmpty
                        ? NetworkImage(_commentsList[position].PROFILE_PHOTO!)
                        : AssetImage(GlobalVariables.componentUserProfilePath)
                            as ImageProvider
                    : NetworkImage(photo!),
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
                                _commentsList[position].C_WHEN!, "hh:mm aa")
                                : '',
                            textColor: GlobalVariables.grey, fontSize: GlobalVariables.textSizeVerySmall,
                          ),
                        ],
                      ),
                      text(
                        _commentsList[position].C_WHEN != '0000-00-00 00:00:00'
                            ? GlobalFunctions.convertDateFormat(
                            _commentsList[position].C_WHEN!, "dd-MM-yyyy")
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

  void changeDropDownItem(String? value) {
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
          textColor: GlobalVariables.primaryColor,
          fontSize: GlobalVariables.textSizeSmall
        ),
      ));
    }
    for(int i=0;i<_complaintStatusListItems.length;i++){
      if(_selectedItem==null){
        if (widget.complaints!.STATUS != null) {
          if (widget.complaints!.STATUS!.toLowerCase() ==
              _complaintStatusListItems[i].value!.toLowerCase()) {
            _selectedItem = _complaintStatusListItems[i].value;
            break;
          }
        }

      }
    }
    if(_selectedItem==null) {
      _selectedItem = _complaintStatusListItems[0].value;
    }
    print('_selectedItem length : ' + _selectedItem!
      ..toString());
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
    _progressDialog!.show();
    restClient.getCommentData(societyId, widget.complaints!.TICKET_NO!).then((value) {
      _progressDialog!.dismiss();
      if (value.status!) {
        List<dynamic> _list = value.data!;
        _commentsList =
            List<Comments>.from(_list.map((i) => Comments.fromJson(i)));
        print('complaints.SUBJECT : ' + widget.complaints!.SUBJECT.toString());
        if (widget.complaints!.SUBJECT != null) {
          // Navigator.of(context).pop();
          setState(() {});
        } else {
          getComplaintDataAgainstTicketNo();
        }
      }
    }).catchError((Object obj) {
      GlobalFunctions.showToast('Exception : ' + obj.toString());
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            GlobalFunctions.showToast('DioError Result : ' + res.toString());
          }
          break;
        default:
      }
    });
  }

  Future<void> getComplaintDataAgainstTicketNo() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    var societyId = await GlobalFunctions.getSocietyId();
    //if(!_progressDialog.isShowing()) {
    _progressDialog!.show();
    //}
    restClient
        .getComplaintDataAgainstTicketNo(
            societyId, widget.complaints!.TICKET_NO!)
        .then((value) {
      _progressDialog!.dismiss();
      //Navigator.of(context).pop();
      if (value.status!) {
        List<dynamic> _list = value.data!;
        _complaintsList =
            List<Complaints>.from(_list.map((e) => Complaints.fromJson(e)));
        widget.complaints = _complaintsList[0];
        _complaintType = widget.complaints!.STATUS;
        setState(() {});
      }
    }).catchError((Object obj) {
      GlobalFunctions.showToast('Exception : ' + obj.toString());
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            GlobalFunctions.showToast('DioError Result : ' + res.toString());
          }
          break;
        default:
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
    String ticketNo = widget.complaints!.TICKET_NO!;
    String societyName = await GlobalFunctions.getSocietyName();
    String societyEmail = await GlobalFunctions.getSocietyEmail();
    String userEmail = await GlobalFunctions.getUserName();
    String userName = await GlobalFunctions.getDisplayName();
    String comment = commentController.text;
    String? attachment;
    String type = widget.complaints!.TYPE!;
    String escalationLevel = widget.complaints!.ESCALATION_LEVEL!;
    String complaintStatus =
        widget.isAssignComplaint! ? _selectedItem! : _complaintType!;

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
          PARENT_TICKET: widget.complaints!.TICKET_NO,
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
    }
    /*else {
     // _progressDialog.show();
      //  Navigator.of(context).pop();
    }*/

    print('Status : ' + complaintStatus);
    print('Comment : ' + comment);
    print('isComment : ' + isComment.toString());
    if (!isComment) {
      _progressDialog!.show();
    }
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
      //if (_progressDialog.isShowing()) {
      if (!isComment) {
        _progressDialog!.dismiss();
      }
      //}
      if (value.status!) {
        commentController.clear();
        if (isComment) {
          GlobalFunctions.showToast(
              "Your comment has been updated to the complaint log.");
          Provider.of<HelpDeskResponse>(context, listen: false)
              .getUnitComplaintData(widget.isAssignComplaint!)
              .then((value) {});
        } else {
          GlobalFunctions.showToast(value.message!);
          Navigator.pop(context,'back');
       //   Navigator.push(context, MaterialPageRoute(builder: (context) => BaseHelpDesk(false)));
        }
      }
    });
  }
}

class ComplaintStatus {
  String? complaintStatus;

  ComplaintStatus({this.complaintStatus});
}
