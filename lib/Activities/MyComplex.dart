import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Announcement.dart';
import 'package:societyrun/Models/CommitteeDirectory.dart';
import 'package:societyrun/Models/EmergencyDirectory.dart';
import 'package:societyrun/Models/NeighboursDirectory.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

class BaseMyComplex extends StatefulWidget {
  String pageName;
  BaseMyComplex(this.pageName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyComplexState(pageName);
  }
}

class MyComplexState extends State<BaseMyComplex>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  //List<NewsBoard> _newsBoardList = List<NewsBoard>();
  List<PollSurvey> _pollSurveyList = List<PollSurvey>();
  List<Directory> _directoryList = List<Directory>();
  List<Documents> _documentList = List<Documents>();

//  List<Events> _eventsList = List<Events>();
  List<NeighboursDirectory> _neighbourList = List<NeighboursDirectory>();
  List<CommitteeDirectory> _committeeList = List<CommitteeDirectory>();
  List<EmergencyDirectory> _emergencyList = List<EmergencyDirectory>();
  List<Announcement> _announcementList = List<Announcement>();
  List<Announcement> _meetingList = List<Announcement>();
  List<Announcement> _eventList = List<Announcement>();

  var name,_localPath;
  String _selectedItem;
  List<DropdownMenuItem<String>> _societyListItems =
      new List<DropdownMenuItem<String>>();

  ProgressDialog _progressDialog;

  String pageName;

  bool isStoragePermission=false;
  MyComplexState(this.pageName);

  @override
  void initState() {
    getDisplayName();
    getLocalPath();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission=value;
    });
    //flutterDownloadInitialize();
    _tabController = TabController(length: 6, vsync: this);
   // getNewsBordListData();
    getPollSurveyListData();
    getDocumentsListData();
    //getEventsListData();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getAnnouncementData('Announcement');


      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    if (pageName != null) {
      redirectToPage(pageName);

    }
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
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
            AppLocalizations.of(context).translate('my_complex'),
            style: TextStyle(color: GlobalVariables.white),
          ),
          bottom: getTabLayout(),
          elevation: 0,
        ),
        body: TabBarView(controller: _tabController, children: <Widget>[
          getNewsBoardLayout(),
          getMeetingsLayout(),
          getPollSurveyLayout(),
          getDocumentsLayout(),
          getDirectoryLayout(),
          getEventsLayout(),
        ]),
      ),
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

  getNewsBoardLayout() {
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
                    context, 100.0),
                getNewsBoardListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getNewsBoardListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).size.height / 20, 20, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: _announcementList.length,
                itemBuilder: (context, position) {
                  return getNewsBoardListItemLayout(position);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getNewsBoardListItemLayout(var position) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: GlobalVariables.white),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    GlobalVariables.componentUserProfilePath,
                    width: 26,
                    height: 26,
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
                        Container(
                          child: Text(
                            _announcementList[position].USER_NAME,
                            style: TextStyle(
                                color: GlobalVariables.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  _announcementList[position].BLOCK.length>0 ? _announcementList[position].BLOCK.toString()+_announcementList[position].FLAT.toString() : 'Maintainnance Staff',
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                width: 1,
                                color: GlobalVariables.grey,
                                child: Divider(
                                  height: 10,
                                ),
                              ),
                              Container(
                                child: Text(
                                  _announcementList[position].C_DATE,
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: false,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    decoration: BoxDecoration(
                        color:
                            getNewsTypeColor(_announcementList[position].CATEGORY),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      _announcementList[position].CATEGORY,
                      style: TextStyle(
                        color: GlobalVariables.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              _announcementList[position].SUBJECT,
              style: TextStyle(
                  color: GlobalVariables.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            //  maxLines: 1,
            //  overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Html(
              data: _announcementList[position].DESCRIPTION,
              defaultTextStyle: TextStyle(
                color: GlobalVariables.grey,
                fontSize: 14,
              ),
            )/*Text(
              _announcementList[position].DESCRIPTION,
              style: TextStyle(
                color: GlobalVariables.mediumGreen,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),*/
          ),
          Visibility(
            visible: false,
            child: Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        /*_newsBoardList[position].likeCount +*/ " Likes",
                        style: TextStyle(
                          color: GlobalVariables.lightGray,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      width: 1,
                      color: GlobalVariables.lightGray,
                      child: Divider(
                        height: 10,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Text(
                        /*_newsBoardList[position].commentCount +*/ " Comments",
                        style: TextStyle(
                          color: GlobalVariables.lightGray,
                          fontSize: 10,
                        ),
                      ),
                    )
                  ],
                )),
          ),
          _announcementList[position].ATTACHMENT.length>0 ? Container(
            height: 2,
            color: GlobalVariables.mediumGreen,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Divider(
              height: 2,
            ),
          ) : Container(),
          Visibility(
            visible: false,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Row(
                children: <Widget>[
                  Container(
                    child: Icon(Icons.mode_comment,
                        color: GlobalVariables.mediumGreen),
                  ),
                  Container(
                    child: Text(
                      " Likes",
                      style: TextStyle(
                        color: GlobalVariables.mediumGreen,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Icon(
                      Icons.mode_comment,
                      color: GlobalVariables.mediumGreen,
                    ),
                  ),
                  Container(
                    child: Text(
                      " Comments",
                      style: TextStyle(
                        color: GlobalVariables.mediumGreen,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _announcementList[position].ATTACHMENT.length>0 ? InkWell(
            onTap: (){
              //: https://societyrun.com//Uploads/fb4c12f20c92a8e63bbaaa8e3f680fd3.jpg,
               String url =_announcementList[position].ATTACHMENT;


               print("storagePermiassion : "+isStoragePermission.toString());
               if(isStoragePermission) {
                 GlobalFunctions.downloadAttachment(
                     url, _localPath);
               }else{
                 GlobalFunctions.askPermission(Permission.storage).then((value) {
                   if(value){
                     GlobalFunctions.downloadAttachment(
                         url, _localPath);
                   }else{
                     GlobalFunctions.showToast(AppLocalizations.of(context).translate('download_permission'));
                   }
                 });
               }

            },
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Row(
                children: <Widget>[
                  Container(
                      child: Icon(
                        Icons.attach_file,
                        color: GlobalVariables.mediumGreen,
                      )),
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(
                      "Attachment",
                      style: TextStyle(
                        color: GlobalVariables.green,
                        fontSize: 10,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ) : Container()
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

  getMeetingsLayout() {
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
                    context, 100.0),
                getMeetingsListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getMeetingsListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).size.height / 20, 20, 0),
      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
            itemCount: _meetingList.length,
            itemBuilder: (context, position) {
              return getMeetingsListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getMeetingsListItemLayout(var position) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: GlobalVariables.white),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    GlobalVariables.componentUserProfilePath,
                    width: 26,
                    height: 26,
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
                        Container(
                          child: Text(
                            _meetingList[position].USER_NAME,
                            style: TextStyle(
                                color: GlobalVariables.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
    _announcementList[position].BLOCK.length>0 ? _announcementList[position].BLOCK.toString()+_announcementList[position].FLAT.toString() : 'Maintainnance Staff',
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                width: 1,
                                color: GlobalVariables.grey,
                                child: Divider(
                                  height: 10,
                                ),
                              ),
                              Container(
                                child: Text(
                                  _meetingList[position].C_DATE,
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: false,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    decoration: BoxDecoration(
                        color:
                        getNewsTypeColor(_meetingList[position].CATEGORY),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      _meetingList[position].CATEGORY,
                      style: TextStyle(
                        color: GlobalVariables.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              _meetingList[position].SUBJECT,
              style: TextStyle(
                  color: GlobalVariables.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            //  maxLines: 1,
            //  overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Html(
                data: _meetingList[position].DESCRIPTION,
                defaultTextStyle: TextStyle(
                  color: GlobalVariables.grey,
                  fontSize: 14,
                ),
              )/*Text(
              _announcementList[position].DESCRIPTION,
              style: TextStyle(
                color: GlobalVariables.mediumGreen,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),*/
          ),
          Visibility(
            visible: false,
            child: Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        /*_newsBoardList[position].likeCount +*/ " Likes",
                        style: TextStyle(
                          color: GlobalVariables.lightGray,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      width: 1,
                      color: GlobalVariables.lightGray,
                      child: Divider(
                        height: 10,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Text(
                        /*_newsBoardList[position].commentCount +*/ " Comments",
                        style: TextStyle(
                          color: GlobalVariables.lightGray,
                          fontSize: 10,
                        ),
                      ),
                    )
                  ],
                )),
          ),
          _meetingList[position].ATTACHMENT.length>0 ? Container(
            height: 2,
            color: GlobalVariables.mediumGreen,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Divider(
              height: 2,
            ),
          ) : Container(),
          Visibility(
            visible: false,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Row(
                children: <Widget>[
                  Container(
                    child: Icon(Icons.mode_comment,
                        color: GlobalVariables.mediumGreen),
                  ),
                  Container(
                    child: Text(
                      " Likes",
                      style: TextStyle(
                        color: GlobalVariables.mediumGreen,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Icon(
                      Icons.mode_comment,
                      color: GlobalVariables.mediumGreen,
                    ),
                  ),
                  Container(
                    child: Text(
                      " Comments",
                      style: TextStyle(
                        color: GlobalVariables.mediumGreen,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _meetingList[position].ATTACHMENT.length>0 ? InkWell(
            onTap: (){
              String url =_meetingList[position].ATTACHMENT;

              print("storagePermiassion : "+isStoragePermission.toString());
              if(isStoragePermission) {
                GlobalFunctions.downloadAttachment(
                    url, _localPath);
              }else{
                GlobalFunctions.askPermission(Permission.storage).then((value) {
                  if(value){
                    GlobalFunctions.downloadAttachment(
                        url, _localPath);
                  }else{
                    GlobalFunctions.showToast(AppLocalizations.of(context).translate('download_permission'));
                  }
                });
              }


            },
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Row(
                children: <Widget>[
                  Container(
                      child: Icon(
                        Icons.attach_file,
                        color: GlobalVariables.mediumGreen,
                      )),
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(
                      "Attachment",
                      style: TextStyle(
                        color: GlobalVariables.green,
                        fontSize: 10,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ) : Container()
        ],
      ),
    );
  }


  getPollSurveyLayout() {
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
                    context, 100.0),
                getPollSurveyListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getPollSurveyListDataLayout() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: Text('Coming Soon...',style: TextStyle(
          color: GlobalVariables.black,fontSize: 18,fontWeight: FontWeight.bold
        ),),
      ),
    );/*Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).size.height / 20, 20, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: *//*_pollSurveyList.length*//*0,
                itemBuilder: (context, position) {
                  return getPollSurveyListItemLayout(position);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );*/
  }

  getPollSurveyListItemLayout(var position) {
    // int _default;

    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: GlobalVariables.white),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    GlobalVariables.componentUserProfilePath,
                    width: 26,
                    height: 26,
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
                        Container(
                          child: Text(
                            _pollSurveyList[position].username,
                            style: TextStyle(
                                color: GlobalVariables.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  _pollSurveyList[position].blockFlatNo,
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                width: 1,
                                color: GlobalVariables.grey,
                                child: Divider(
                                  height: 10,
                                ),
                              ),
                              Container(
                                child: Text(
                                  _pollSurveyList[position].date,
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              _pollSurveyList[position].surveyTitle,
              style: TextStyle(
                  color: GlobalVariables.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Text(
              _pollSurveyList[position].surveyDesc,
              style: TextStyle(
                color: GlobalVariables.mediumGreen,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Container(
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount:
                          _pollSurveyList[position].surveyVoteOptions.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Container(
                          //color: GlobalVariables.veryLightGray,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    flex: 3,
                                    fit: FlexFit.loose,
                                    child: InkWell(
                                      //  splashColor: GlobalVariables.mediumGreen,
                                      onTap: () {
                                        _pollSurveyList[position]
                                            .surveyVoteOptions
                                            .forEach((element) {
                                          element.isSelected = false;
                                        });
                                        _pollSurveyList[position]
                                            .surveyVoteOptions[i]
                                            .isSelected = true;
                                        setState(() {});
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.fromLTRB(10, 10, 0, 0),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: _pollSurveyList[
                                                                  position]
                                                              .surveyVoteOptions[
                                                                  i]
                                                              .isSelected ==
                                                          true
                                                      ? GlobalVariables.green
                                                      : GlobalVariables
                                                          .transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    color: _pollSurveyList[
                                                                    position]
                                                                .surveyVoteOptions[
                                                                    i]
                                                                .isSelected ==
                                                            true
                                                        ? GlobalVariables.green
                                                        : GlobalVariables
                                                            .mediumGreen,
                                                    width: 2.0,
                                                  )),
                                              child: Icon(
                                                Icons.check,
                                                color: _pollSurveyList[position]
                                                            .surveyVoteOptions[
                                                                i]
                                                            .isSelected ==
                                                        true
                                                    ? GlobalVariables.white
                                                    : GlobalVariables
                                                        .transparent,
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  10, 0, 0, 0),
                                              child: Text(
                                                _pollSurveyList[position]
                                                    .surveyVoteOptions[i]
                                                    .radioText,
                                                style: TextStyle(
                                                    color:
                                                        GlobalVariables.green,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.loose,
                                    child: Container(
                                      child: Text(
                                        _pollSurveyList[position].surveyVote[i],
                                        style: TextStyle(
                                            color:
                                                GlobalVariables.veryLightGray,
                                            fontSize: 12),
                                      ),
                                      margin: EdgeInsets.fromLTRB(10, 0, 15, 0),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
          Container(
            height: 2,
            color: GlobalVariables.mediumGreen,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Divider(
              height: 2,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              children: <Widget>[
                Container(
                  child: Text(
                    "Active",
                    style: TextStyle(
                      color: GlobalVariables.mediumGreen,
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  width: 1,
                  color: GlobalVariables.mediumGreen,
                  child: Divider(
                    height: 10,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Text(
                    "For All members",
                    style: TextStyle(
                      color: GlobalVariables.mediumGreen,
                      fontSize: 10,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  getPollSurveyListData() {
    _pollSurveyList = [
      PollSurvey(
          username: "Ashish Waykar",
          blockFlatNo: "AA102",
          date: "10/02/2020",
          surveyTitle: "Can we celebrate Holi festival this year?",
          surveyDesc: "please lat us know your views on this.",
          surveyVoteOptions: [
            SurveyVoteOption(isSelected: true, radioText: "Yes", index: 1),
            SurveyVoteOption(isSelected: false, radioText: "No", index: 2)
          ],
          surveyVote: [
            "1 vote",
            "0 Vote"
          ]),
      PollSurvey(
          username: "Ashish Waykar",
          blockFlatNo: "AA102",
          date: "10/02/2020",
          surveyTitle: "Can we celebrate Holi festival this year?",
          surveyDesc: "please lat us know your views on this.",
          surveyVoteOptions: [
            SurveyVoteOption(isSelected: true, radioText: "Yes", index: 1),
            SurveyVoteOption(isSelected: false, radioText: "No", index: 2),
            SurveyVoteOption(
                isSelected: false, radioText: "May be or May be not", index: 3)
          ],
          surveyVote: [
            "1 vote",
            "0 Vote",
            "0 Vote"
          ]),
      PollSurvey(
          username: "Ashish Waykar",
          blockFlatNo: "AA102",
          date: "10/02/2020",
          surveyTitle: "Can we celebrate Holi festival this year?",
          surveyDesc: "please lat us know your views on this.",
          surveyVoteOptions: [
            SurveyVoteOption(isSelected: true, radioText: "Yes", index: 1),
            SurveyVoteOption(isSelected: false, radioText: "No", index: 2)
          ],
          surveyVote: [
            "1 vote",
            "0 Vote"
          ]),
      PollSurvey(
          username: "Ashish Waykar",
          blockFlatNo: "AA102",
          date: "10/02/2020",
          surveyTitle: "Can we celebrate Holi festival this year?",
          surveyDesc: "please lat us know your views on this.",
          surveyVoteOptions: [
            SurveyVoteOption(isSelected: true, radioText: "Yes", index: 1),
            SurveyVoteOption(isSelected: false, radioText: "No", index: 2),
            SurveyVoteOption(
                isSelected: false, radioText: "May be or May be not", index: 3)
          ],
          surveyVote: [
            "1 vote",
            "0 Vote",
            "0 Vote"
          ]),
    ];
  }

  getDirectoryLayout() {
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
                    context, 100.0),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width:
                        MediaQuery.of(context).size.width / 1.1, //height: 60,
                    margin: EdgeInsets.fromLTRB(
                        0, MediaQuery.of(context).size.height / 15, 0, 0),
                    decoration: BoxDecoration(
                      color: GlobalVariables.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: getSearchFilerLayout(),
                  ),
                ),
                getDirectoryListDataLayout(),
              ],
            ),
          ),
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
                          suffixIcon: Icon(
                            Icons.search,
                            color: GlobalVariables.mediumGreen,
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
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: GlobalVariables.mediumGreen,
                        ),
                        isExpanded: true,
                        hint: Text(
                          'Category',
                          style: TextStyle(color: GlobalVariables.veryLightGray),
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

  getDirectoryListDataLayout() {
    return Container(
      // color: GlobalVariables.grey,
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).size.height / 6, 20, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: _directoryList.length,
                itemBuilder: (context, position) {
                  return getDirectoryListItemLayout(position);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getDirectoryListItemLayout(int position) {
    // int _default;

    //Committee
    String type = _directoryList[position].directoryType;
   // print('Type : '+type);
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          alignment: Alignment.topLeft,
          child: Text(
            type,
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
                        itemCount: _directoryList[position]
                            .directoryTypeWiseList
                            .length,
                        itemBuilder: (context, childPosition) {
                          return getDirectoryTypeWiseItemLayout(
                              position, childPosition,type);
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
                          type == 'Near By Shops'? 'Coming Soon...' : AppLocalizations.of(context).translate('view_more'),
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      type != 'Near By Shops' ?Container(
                        child: Icon(
                          Icons.fast_forward,
                          color: GlobalVariables.green,
                        ),
                      ) : Container()
                    ],
                  )),
            ],
          ),
        )
      ],
    );
  }

  getDirectoryTypeWiseItemLayout(int position, int childPosition, String type,) {

   // print('Type : '+type);

    bool phone=false,email=false;
    String name='',field='',permission='';
    if(type=='Committee'){
      name =  _directoryList[position]
          .directoryTypeWiseList[childPosition].NAME;

      field =  _directoryList[position]
        .directoryTypeWiseList[childPosition].POST;

      _directoryList[position]
          .directoryTypeWiseList[childPosition].EMAIL!= 0 ? email=true : email=false;

      _directoryList[position]
          .directoryTypeWiseList[childPosition].PHONE.length != 0 ? phone=true : phone=false;
    }

    if(type=='Emergency'){
      name =  _directoryList[position]
          .directoryTypeWiseList[childPosition].Address;

      field =  _directoryList[position]
          .directoryTypeWiseList[childPosition].Name;

      _directoryList[position]
          .directoryTypeWiseList[childPosition].Contact_No.length != 0 ? phone=true : phone=false;
    }

    if(type=='Neighbours'){
      name =  _directoryList[position]
          .directoryTypeWiseList[childPosition].NAME;

      field =  _directoryList[position]
          .directoryTypeWiseList[childPosition].BLOCK+"-"+_directoryList[position]
          .directoryTypeWiseList[childPosition].FLAT;

      permission = _directoryList[position]
          .directoryTypeWiseList[childPosition].PERMISSIONS;
      if(permission.contains('memberPhone')){
        phone = true;
      }else{
        phone = false;
      }

    }

    if(type=='Near By Shops'){
      name =  _directoryList[position].directoryTypeWiseList[childPosition].name;

      field =  _directoryList[position].directoryTypeWiseList[childPosition].field;
    }
    if(name==null)
      name='';

    if(field==null)
      field='';

   // print("("+field+")");
    //phone = true;

    return Container(
      //width: 200,
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
         type=='Near By Shops'
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
                    flex: 3,
                    child: Container(
                      //color: GlobalVariables.lightGray,
                      margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                      alignment: Alignment.topLeft, //height: 10,
                      //color: GlobalVariables.grey,
                      child: Text(
                        name,
                        style:
                            TextStyle(color: GlobalVariables.green, fontSize: 16),
                      ),
                    )),
                Flexible(
                    flex: 2,
                    child: Container(
                    //  color: GlobalVariables.grey,
                      margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                      alignment: Alignment.topCenter, // height: 10,
                      //  color: GlobalVariables.lightGreen,
                      child: Text(
                        field,
                        style: TextStyle(
                            color: GlobalVariables.veryLightGray, fontSize: 14),
                      ),
                    )),
                Flexible(
                    flex: 1,
                    child:phone
                        ? Container(
                      //color: GlobalVariables.lightGray,
                            // color: GlobalVariables.black,
                            // height: 10,
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                            child: Icon(
                              Icons.call,
                              color: GlobalVariables.mediumGreen,
                              size: 24,
                            ),
                          )
                        : Container(
                     // width: 24,height: 24,
                    )),
                Flexible(
                    flex: 1,
                    child:email
                        ? Container(
                     // color: GlobalVariables.lightGray,
                      // color: GlobalVariables.black,
                      // height: 10,
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                      child: Icon(
                        Icons.email,
                        color: GlobalVariables.mediumGreen,
                        size: 24,
                      ),
                    )
                        : Container(
                     // width: 24,height: 24,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getDirectoryListData() {
    _directoryList = [
      Directory(directoryType: "Neighbours", directoryTypeWiseList: _neighbourList),
      Directory(
          directoryType: "Committee", directoryTypeWiseList: _committeeList),
      Directory(
          directoryType: "Emergency", directoryTypeWiseList: _emergencyList),
      Directory(directoryType: "Near By Shops", directoryTypeWiseList: [
       /* DirectoryTypeWiseData(
            name: "Arogya Medical",
            field: "Medical",
            isCall: true,
            isMail: false,
            isSearch: true,
            isFilter: true),
        DirectoryTypeWiseData(
            name: "Mahalakshmi Store",
            field: "Grocery",
            isCall: true,
            isMail: false,
            isSearch: true,
            isFilter: true),
        DirectoryTypeWiseData(
            name: "D'mary",
            field: "Grocery",
            isCall: true,
            isMail: false,
            isSearch: true,
            isFilter: true),
        DirectoryTypeWiseData(
            name: "Medicare",
            field: "Medical",
            isCall: true,
            isMail: false,
            isSearch: true,
            isFilter: true),*/
      ]),
    ];
  }

  getDocumentsLayout() {
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
                    context, 100.0),
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
                    child: getSearchFilerLayout(),
                  ),
                ),
                getDocumentListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getDocumentListDataLayout() {
    return  Align(
      alignment: Alignment.center,
      child: Container(
        child: Text('Coming Soon...',style: TextStyle(
            color: GlobalVariables.black,fontSize: 18,fontWeight: FontWeight.bold
        ),),
      ),
    );/*Container(
      // color: GlobalVariables.grey,
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).size.height / 6, 20, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: _documentList.length,
                itemBuilder: (context, position) {
                  return getDocumentListItemLayout(position);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );*/
  }

  getDocumentListItemLayout(int position) {
    // int _default;

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          alignment: Alignment.topLeft,
          child: Text(
            _documentList[position].docTypes,
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
                        itemCount: _documentList[position].documentList.length,
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

  getDocumentTypeWiseItemLayout(
    int position,
    int childPosition,
  ) {
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
                              _documentList[position]
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
                              _documentList[position]
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
    _documentList = [
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
  }

  getEventsLayout() {
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
                    context, 100.0),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width:
                        MediaQuery.of(context).size.width / 1.1, // height: 50,
                    margin: EdgeInsets.fromLTRB(
                        0, MediaQuery.of(context).size.height / 15, 0, 0),
                    decoration: BoxDecoration(
                      color: GlobalVariables.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: getSearchFilerLayout(),
                  ),
                ),
                getEventsDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getEventsDataLayout() {
    return  /*Align(
      alignment: Alignment.center,
      child: Container(
        child: Text('Coming Soon...',style: TextStyle(
            color: GlobalVariables.black,fontSize: 18,fontWeight: FontWeight.bold
        ),),
      ),
    );*/Container(
      //  color: GlobalVariables.grey,
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).size.height / 7, 20, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: _eventList.length,
                itemBuilder: (context, position) {
                  return getEventsListItemLayout(position);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getEventsListItemLayout(var position) {
    // int _default;

    return Container(
      width: MediaQuery.of(context).size.width / 0.5,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: GlobalVariables.white),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    GlobalVariables.componentUserProfilePath,
                    width: 26,
                    height: 26,
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
                        Container(
                          child: Text(
                            _eventList[position].USER_NAME,
                            style: TextStyle(
                                color: GlobalVariables.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  _eventList[position].BLOCK.length>0 ? _eventList[position].BLOCK+_eventList[position].FLAT: "Maintannance Staff",
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                width: 1,
                                color: GlobalVariables.grey,
                                child: Divider(
                                  height: 10,
                                ),
                              ),
                              Container(
                                child: Text(
                                  _eventList[position].C_DATE,
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              _eventList[position].SUBJECT,
              style: TextStyle(
                  color: GlobalVariables.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              //maxLines: 1,
              //overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child:  Html(
              data: _eventList[position].DESCRIPTION,
              defaultTextStyle: TextStyle(
                color: GlobalVariables.grey,
                fontSize: 14,
              ),
            )/*Text(
              _eventList[position].DESCRIPTION,
              style: TextStyle(
                color: GlobalVariables.mediumGreen,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )*/,
          ),
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                        child: Icon(
                          Icons.location_on,
                          color: GlobalVariables.mediumGreen,
                          size: 20,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 3, 0, 0),
                        child: Text(
                          "Venue : ",
                          style: TextStyle(
                              color: GlobalVariables.green, fontSize: 14),
                        ),
                      ),
                      Container(
                        child: Text(
                          _eventList[position].VENUE,
                          style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                        child: Icon(
                          Icons.date_range,
                          color: GlobalVariables.mediumGreen,
                          size: 20,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 3, 0, 0),
                        child: Text(
                          "Date : ",
                          style: TextStyle(
                              color: GlobalVariables.green, fontSize: 14),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 3, 0, 0),
                        child: Text(
                          _eventList[position].START_DATE,
                          style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                        child: Icon(
                          Icons.access_time,
                          color: GlobalVariables.mediumGreen,
                          size: 20,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 3, 0, 0),
                        child: Text(
                          "Time : ",
                          style: TextStyle(
                              color: GlobalVariables.green, fontSize: 14),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 3, 0, 0),
                        child: Text(
                          _eventList[position].Start_Time+' TO '+ _eventList[position].END_TIME,
                          style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _eventList[position].ATTACHMENT.length>0 ? Container(
            height: 2,
            color: GlobalVariables.mediumGreen,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Divider(
              height: 2,
            ),
          ) : Container(),
          _eventList[position].ATTACHMENT.length>0 ?   InkWell(
            onTap: (){
              String url =_eventList[position].ATTACHMENT;

              print("storagePermiassion : "+isStoragePermission.toString());
              if(isStoragePermission) {
                GlobalFunctions.downloadAttachment(
                    url, _localPath);
              }else{
                GlobalFunctions.askPermission(Permission.storage).then((value) {
                  if(value){
                    GlobalFunctions.downloadAttachment(
                        url, _localPath);
                  }else{
                    GlobalFunctions.showToast(AppLocalizations.of(context).translate('download_permission'));
                  }
                });
              }

            },
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Row(
                children: <Widget>[
                  Container(
                      child: Icon(
                    Icons.attach_file,
                    color: GlobalVariables.mediumGreen,
                  )),
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(
                      "Attachment",
                      style: TextStyle(
                        color: GlobalVariables.green,
                        fontSize: 10,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ) : Container(),
        ],
      ),
    );
  }

 /* getEventsListData() {
    _eventsList = [
      Events(
          name: "Ashish Waykar",
          blockFlat: "AA102",
          date: "10/02/2020",
          eventTitle: "Skill Compitition",
          eventDesc:
              "Hello Guys,Today we all to gather at society hall for performing compititiona and awards.",
          eventVenue: "Mumbai",
          eventDate: "25 MArch 2020",
          eventTime: "09:00 am to 12:00 pm"),
      Events(
          name: "Ashish Waykar",
          blockFlat: "AA102",
          date: "10/02/2020",
          eventTitle: "Skill Compitition",
          eventDesc:
              "Hello Guys,Today we all to gather at society hall for performing compititiona and awards.",
          eventVenue: "Mumbai",
          eventDate: "25 MArch 2020",
          eventTime: "09:00 am to 12:00 pm"),
      Events(
          name: "Ashish Waykar",
          blockFlat: "AA102",
          date: "10/02/2020",
          eventTitle: "Skill Compitition",
          eventDesc:
              "Hello Guys,Today we all to gather at society hall for performing compititiona and awards.",
          eventVenue: "Mumbai",
          eventDate: "25 MArch 2020",
          eventTime: "09:00 am to 12:00 pm"),
      Events(
          name: "Ashish Waykar",
          blockFlat: "AA102",
          date: "10/02/2020",
          eventTitle: "Skill Compitition",
          eventDesc:
              "Hello Guys,Today we all to gather at society hall for performing compititiona and awards.",
          eventVenue: "Mumbai",
          eventDate: "25 MArch 2020",
          eventTime: "09:00 am to 12:00 pm"),
    ];
  }
*/
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

  Future<void> getAnnouncementData(String type) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getAnnouncementData(societyId, type).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;

       // print("announcement data : "+ _list[4].toString());

        /*{ID: 94, USER_NAME: Pallavi Unde, USER_PHOTO: 278808_2019-08-16_12:45:09.jpg, SUBJECT: test demo, DESCRIPTION: <p>test demo</p>
I/flutter (11139): , ATTACHMENT: , CATEGORY: Announcement, EXPIRY_DATE: 0000-00-00, POLL_Q: , C_DATE: 14 Apr 2020 03:09 pm, table_name: broadcast, ANS: , votes: , START_DATETIME: 1970-01-01 00:00:00, END_DATETIME: 1970-01-01 00:00:00, Start_Time: , VENUE: , ACHIEVER_NAME: , ALLOW_COMMENT: , DISPLAY_COMMENT_ALL: , SEND_TO: All Owners, SECRET_POLL: , VOTING_RIGHTS: , POST_AS: Societyrun System Administrator, STATUS: , Cancel_By: , Cancel_Date: 0000-00-00 00:00:00, START_DATE: 01 Jan 1970, END_DATE: 01 Jan 1970, START_TIME: 12:00 am, END_TIME: 12:00 am}*/



          _announcementList = List<Announcement>.from(_list.map((i)=>Announcement.fromJson(i)));

        print("_announcementList length : "+_announcementList.length.toString());



      }

      getMeetingData('Meeting');

    });
  }

  Future<void> getMeetingData(String type) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getAnnouncementData(societyId, type).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;

       // print("announcement data : "+ _list[4].toString());

        /*{ID: 94, USER_NAME: Pallavi Unde, USER_PHOTO: 278808_2019-08-16_12:45:09.jpg, SUBJECT: test demo, DESCRIPTION: <p>test demo</p>
I/flutter (11139): , ATTACHMENT: , CATEGORY: Announcement, EXPIRY_DATE: 0000-00-00, POLL_Q: , C_DATE: 14 Apr 2020 03:09 pm, table_name: broadcast, ANS: , votes: , START_DATETIME: 1970-01-01 00:00:00, END_DATETIME: 1970-01-01 00:00:00, Start_Time: , VENUE: , ACHIEVER_NAME: , ALLOW_COMMENT: , DISPLAY_COMMENT_ALL: , SEND_TO: All Owners, SECRET_POLL: , VOTING_RIGHTS: , POST_AS: Societyrun System Administrator, STATUS: , Cancel_By: , Cancel_Date: 0000-00-00 00:00:00, START_DATE: 01 Jan 1970, END_DATE: 01 Jan 1970, START_TIME: 12:00 am, END_TIME: 12:00 am}*/

        _meetingList = List<Announcement>.from(_list.map((i) =>Announcement.fromJson(i)));
        print("_meetingList length : "+_announcementList.length.toString());

      }
      getEventData('Event');

    });
  }

  Future<void> getEventData(String type) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getAnnouncementData(societyId, type).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;

       // print("announcement data : "+ _list[4].toString());

        /*{ID: 94, USER_NAME: Pallavi Unde, USER_PHOTO: 278808_2019-08-16_12:45:09.jpg, SUBJECT: test demo, DESCRIPTION: <p>test demo</p>
I/flutter (11139): , ATTACHMENT: , CATEGORY: Announcement, EXPIRY_DATE: 0000-00-00, POLL_Q: , C_DATE: 14 Apr 2020 03:09 pm, table_name: broadcast, ANS: , votes: , START_DATETIME: 1970-01-01 00:00:00, END_DATETIME: 1970-01-01 00:00:00, Start_Time: , VENUE: , ACHIEVER_NAME: , ALLOW_COMMENT: , DISPLAY_COMMENT_ALL: , SEND_TO: All Owners, SECRET_POLL: , VOTING_RIGHTS: , POST_AS: Societyrun System Administrator, STATUS: , Cancel_By: , Cancel_Date: 0000-00-00 00:00:00, START_DATE: 01 Jan 1970, END_DATE: 01 Jan 1970, START_TIME: 12:00 am, END_TIME: 12:00 am}*/


          _eventList = List<Announcement>.from(_list.map((i) =>Announcement.fromJson(i)));


        print("_eventList length : "+_meetingList.length.toString());


      }
      getAnnouncementPollData('Poll');

    });
  }

  Future<void> getAnnouncementPollData(String type) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();
    restClient.getAnnouncementPollData(societyId, type,block,flat,userId).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;

      //  print("announcementPoll data : "+ _list.toString());

        /*{ID: 94, USER_NAME: Pallavi Unde, USER_PHOTO: 278808_2019-08-16_12:45:09.jpg, SUBJECT: test demo, DESCRIPTION: <p>test demo</p>
I/flutter (11139): , ATTACHMENT: , CATEGORY: Announcement, EXPIRY_DATE: 0000-00-00, POLL_Q: , C_DATE: 14 Apr 2020 03:09 pm, table_name: broadcast, ANS: , votes: , START_DATETIME: 1970-01-01 00:00:00, END_DATETIME: 1970-01-01 00:00:00, Start_Time: , VENUE: , ACHIEVER_NAME: , ALLOW_COMMENT: , DISPLAY_COMMENT_ALL: , SEND_TO: All Owners, SECRET_POLL: , VOTING_RIGHTS: , POST_AS: Societyrun System Administrator, STATUS: , Cancel_By: , Cancel_Date: 0000-00-00 00:00:00, START_DATE: 01 Jan 1970, END_DATE: 01 Jan 1970, START_TIME: 12:00 am, END_TIME: 12:00 am}*/

      //  _announcementList = List<Announcement>.from(_list.map((i)=>Announcement.fromJson(i)));

        print("announcementPoll : "+_list.length.toString());
        /*setState(() {
        });*/
      }

      getNeighboursDirectoryData();
    });
  }

  Future<void> getCommitteeDirectoryData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    restClient.getCommitteeDirectoryData(societyId).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;
/*{ID: 54, POST: Chairman, STATUS: A, C_DATE: 2019-12-30 17:20:39, NAME: Pallavi Unde, BLOCK: Block A, FLAT: 301, INTERCOM: 0, EMAIL: pallaviunde@gmail.com, PHONE: 7620016529, SOCIETY_ID: null}*/
        _committeeList = List<CommitteeDirectory>.from(
            _list.map((i) => CommitteeDirectory.fromJson(i)));
        /*setState(() {
        });*/

      }
      getEmergencyDirectoryData();
    });
  }

  Future<void> getEmergencyDirectoryData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    restClient.getEmergencyDirectoryData(societyId).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;
/*{ID: 9, Name: Police, Category: For Any Trouble , Contact_No: 100, Address: Pimpri Police Thane., Sequence: 1, STATUS: P}*/
        _emergencyList = List<EmergencyDirectory>.from(
            _list.map((i) => EmergencyDirectory.fromJson(i)));
        /*setState(() {
        });*/
        getDirectoryListData();
        setState(() {
        });
      }
      _progressDialog.hide();
    });
  }

  Future<void> getNeighboursDirectoryData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    restClient.getNeighboursDirectoryData(societyId).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;

        //_documentList = List<Documents>.from(_list.map((i)=>Documents.fromJson(i)));
        /*setState(() {
        });*/

        /*ID: 8, BLOCK: Block B, FLAT: 701, TYPE: Owner, NAME: Milind J, PERMISSIONS: , Email: milindj@societyrun.com, Phone: 9527105019*/

        _neighbourList = List<NeighboursDirectory>.from(
            _list.map((i) => NeighboursDirectory.fromJson(i)));


      }
      getCommitteeDirectoryData();
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
  }

  void redirectToPage(String item) {
    if(item==AppLocalizations.of(context).translate('my_complex')){
      //Redirect to my Unit
      _tabController.animateTo(0);
    }else if(item==AppLocalizations.of(context).translate('announcement')){
      //Redirect to  NewsBoard
      _tabController.animateTo(0);
    }else if(item==AppLocalizations.of(context).translate('meetings')){
      //Redirect to  PollSurvey
      _tabController.animateTo(1);
    }else if(item==AppLocalizations.of(context).translate('poll_survey')){
      //Redirect to  PollSurvey
      _tabController.animateTo(2);
    }else if(item==AppLocalizations.of(context).translate('documents')){
      //Redirect to  Directory
      _tabController.animateTo(3);
    }else if(item==AppLocalizations.of(context).translate('directory +++++')){
      //Redirect to  Document
      _tabController.animateTo(4);
    }else if(item==AppLocalizations.of(context).translate('events')){
      //Redirect to  Events
      _tabController.animateTo(5);
    }else{
      _tabController.animateTo(0);
    }



  }
}

class NewsBoard {
  String username,
      blockFlatNo,
      date,
      newsType,
      newsTitle,
      newsDesc,
      likeCount,
      commentCount;

  NewsBoard(
      {this.username,
      this.blockFlatNo,
      this.date,
      this.newsType,
      this.newsTitle,
      this.newsDesc,
      this.likeCount,
      this.commentCount});
}

class PollSurvey {
  String username, blockFlatNo, date, surveyTitle, surveyDesc;
  List<SurveyVoteOption> surveyVoteOptions;
  List<String> surveyVote;

  PollSurvey(
      {this.username,
      this.blockFlatNo,
      this.date,
      this.surveyTitle,
      this.surveyDesc,
      this.surveyVoteOptions,
      this.surveyVote});
}

class SurveyVoteOption {
  bool isSelected;
  String radioText;
  int index;

  SurveyVoteOption({this.isSelected, this.radioText, this.index});
}

class Directory {
  String directoryType;
  List<dynamic> directoryTypeWiseList;

  Directory({this.directoryType, this.directoryTypeWiseList});
}

class DirectoryTypeWiseData {
  String name, field;
  bool isCall, isMail, isSearch, isFilter;

  DirectoryTypeWiseData(
      {this.name,
      this.field,
      this.isCall,
      this.isMail,
      this.isSearch,
      this.isFilter});
}

class Documents {
  String docTypes;
  List<DocumentsTypeWiseData> documentList;

  Documents({this.docTypes, this.documentList});
}

class DocumentsTypeWiseData {
  String docTitle, docDesc;

  DocumentsTypeWiseData({this.docTitle, this.docDesc});
}

class Events {
  String name,
      blockFlat,
      date,
      eventTitle,
      eventDesc,
      eventVenue,
      eventDate,
      eventTime;

  Events(
      {this.name,
      this.blockFlat,
      this.date,
      this.eventTitle,
      this.eventDesc,
      this.eventVenue,
      this.eventDate,
      this.eventTime});
}
