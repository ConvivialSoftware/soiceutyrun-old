import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/AddNewMember.dart';
import 'package:societyrun/Activities/AddVehicle.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/Ledger.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/Activities/ViewBill.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/ChangeLanguageNotifier.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Models/Documents.dart';
import 'package:societyrun/Models/Member.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Models/Vehicle.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

import 'base_stateful.dart';

class BaseHelpDesk extends StatefulWidget {
 // String pageName;
 // BaseHelpDesk(this.pageName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HelpDeskState();
  }
}

class HelpDeskState extends BaseStatefulState<BaseHelpDesk> {

  List<Complaints> _complaintList = new List<Complaints>();
  List<Complaints> _openComplaintList = new List<Complaints>();
  List<Complaints> _closedComplaintList = new List<Complaints>();

  var firstTicketContainerColor = GlobalVariables.mediumBlue;
  var secondTicketContainerColor = GlobalVariables.white;
  var firstTicketTextColor = GlobalVariables.white;
  var secondTicketTextColor = GlobalVariables.darkBlue;
  bool isOpenTicket = true;
  bool isClosedTicket = false;

  var societyId, flat, block;

  ProgressDialog _progressDialog;


  @override
  void initState() {
    super.initState();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getUnitComplaintData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
      _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: GlobalVariables.darkBlue,
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
            AppLocalizations.of(context).translate('help_desk'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body:  getMyTicketLayout(),
      ),
    );
  }

  getMyTicketLayout() {
    print('MyTicketLayout Tab Call');
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 180.0),
                ticketOpenClosedLayout(), //ticketFilterLayout(),
                getTicketListDataLayout(), addTicketFabLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ticketOpenClosedLayout() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        height: 50,
        margin: EdgeInsets.fromLTRB(
            0, MediaQuery.of(context).size.height / 60, 0, 0),
        decoration: BoxDecoration(
          color: GlobalVariables.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      color: firstTicketContainerColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0))),
                  child: ButtonTheme(
                    minWidth: 190,
                    height: 50,
                    child: FlatButton(
                      //color: GlobalVariables.grey,
                      child: Text(
                        AppLocalizations.of(context).translate('open'),
                        style: TextStyle(
                            fontSize: 15, color: firstTicketTextColor),
                      ),
                      onPressed: () {
                      //  GlobalFunctions.showToast("OPEN Click");
                        if (!isOpenTicket) {
                          isOpenTicket = true;
                          isClosedTicket = false;
                          firstTicketTextColor = GlobalVariables.white;
                          firstTicketContainerColor =
                              GlobalVariables.mediumBlue;
                          secondTicketTextColor = GlobalVariables.darkBlue;
                          secondTicketContainerColor = GlobalVariables.white;
                        }
                        setState(() {});
                      },
                    ),
                  )),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      color: secondTicketContainerColor,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0))),
                  child: ButtonTheme(
                    minWidth: 190,
                    height: 50,
                    child: FlatButton(
                      child: Text(
                        AppLocalizations.of(context).translate('closed'),
                        style: TextStyle(
                            fontSize: 15, color: secondTicketTextColor),
                      ),
                      onPressed: () {
                      //  GlobalFunctions.showToast("CLOSED Click");
                        if (!isClosedTicket) {
                          isOpenTicket = false;
                          isClosedTicket = true;
                          firstTicketContainerColor = GlobalVariables.white;
                          firstTicketTextColor = GlobalVariables.darkBlue;
                          secondTicketTextColor = GlobalVariables.white;
                          secondTicketContainerColor =
                              GlobalVariables.mediumBlue;
                        }
                        setState(() {});
                      },
                      color: GlobalVariables.transparent,
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  ticketFilterLayout() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        //width: MediaQuery.of(context).size.width / 1.1,
        height: 50,
        margin: EdgeInsets.fromLTRB(
            0, MediaQuery.of(context).size.height / 12, 0, 0),
        decoration: BoxDecoration(
          color: GlobalVariables.transparent,
          //  borderRadius: BorderRadius.circular(30),
        ),
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
                color: GlobalVariables.transparent,
              ),
            ),
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
                        color: GlobalVariables.mediumBlue,
                        width: 3.0,
                      )),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: TextField(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          hintText: "Filter",
                          hintStyle:
                              TextStyle(color: GlobalVariables.veryLightGray),
                          border: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.search,
                            color: GlobalVariables.mediumBlue,
                          )),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  addTicketFabLayout() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: FloatingActionButton(
              onPressed: () {
                //GlobalFunctions.showToast('Fab CLick');
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BaseRaiseNewTicket()));
              },
              child: Icon(
                Icons.add,
                color: GlobalVariables.white,
              ),
              backgroundColor: GlobalVariables.darkBlue,
            ),
          )
        ],
      ),
    );
  }


  getTicketListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 10, 10, 0),
      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
            itemCount: isOpenTicket ? _openComplaintList.length : _closedComplaintList.length,
            itemBuilder: (context, position) {
              return getTicketDescListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getTicketDescListItemLayout(int position) {
    return InkWell(
      onTap: () {
       // GlobalFunctions.showToast(isOpenTicket ? _openComplaintList[position].TICKET_NO : _closedComplaintList[position].TICKET_NO);
        print('_openComplaintList[position].toString()  : '+ _openComplaintList[position].toString() );
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BaseComplaintInfoAndComments(isOpenTicket ? _openComplaintList[position] : _closedComplaintList[position])));
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  //margin:EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: Text(isOpenTicket ? _openComplaintList[position].CATEGORY : _closedComplaintList[position].CATEGORY,
                      style: TextStyle(
                          color: GlobalVariables.darkBlue, fontSize: 14)),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Text(
                    isOpenTicket ? _openComplaintList[position].STATUS : _closedComplaintList[position].STATUS,
                    style: TextStyle(
                        color: GlobalVariables.white,
                        fontSize: 12),
                  ),
                  decoration: BoxDecoration(
                      color: getTicketCategoryColor(
                          isOpenTicket ? _openComplaintList[position].STATUS : _closedComplaintList[position].STATUS),
                      borderRadius: BorderRadius.circular(8)),
                ),
                Container(
                  child: Text(
                    'Ticket No: ' +
                        ( isOpenTicket ? _openComplaintList[position].TICKET_NO : _closedComplaintList[position].TICKET_NO),
                    style: TextStyle(
                        color: GlobalVariables.darkBlue,
                        fontSize: 12),
                  ),
                ),
              ],
            ),

            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                     width:50,
                     height: 50,
                     decoration: BoxDecoration(
                       color: GlobalVariables.mediumBlue,
                       shape: BoxShape.rectangle
                     ),
                     /* child:*//* SvgPicture.asset(
                        GlobalVariables.waterIconPath,
                      ),*//*CircleAvatar(
                        radius: 5,
                        backgroundColor: GlobalVariables.mediumGreen,
                       // backgroundImage: NetworkImage(_openComplaintList[position]. ),
                      ),*/
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(
                          15, 0, 0, 0), //alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                         /* Container(
                              // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[


                            ],
                          )),*/
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: Text(
                                isOpenTicket ? _openComplaintList[position].SUBJECT : _closedComplaintList[position].SUBJECT,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: GlobalVariables.darkBlue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text(
                              isOpenTicket ? _openComplaintList[position].DESCRIPTION : _closedComplaintList[position].DESCRIPTION,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: GlobalVariables.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 1,
              color: GlobalVariables.mediumBlue,
              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Divider(
                height: 1,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Text(
                        'Issued on: ' +
                            ( isOpenTicket ? GlobalFunctions.convertDateFormat(_openComplaintList[position].DATE,"dd-MM-yyyy") : GlobalFunctions.convertDateFormat(_closedComplaintList[position].DATE,"dd-MM-yyyy")),
                        style: TextStyle(color: GlobalVariables.grey)),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                          child: Icon(
                        Icons.chat_bubble,
                        color: GlobalVariables.lightGray,
                      )),
                      Container(
                        margin: EdgeInsets.fromLTRB(3, 0, 0, 0),
                        child: Text(
                           ( isOpenTicket ? _openComplaintList[position].COMMENT_COUNT : _closedComplaintList[position].COMMENT_COUNT ) +
                                ' Comments',
                            style:
                                TextStyle(color: GlobalVariables.grey)),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
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
      default:
        return GlobalVariables.skyBlue;
        break;
    }
  }

  Future<void> getUnitComplaintData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    block = await GlobalFunctions.getBlock();
    flat = await GlobalFunctions.getFlat();
    _progressDialog.show();
    restClient.getComplaintsData(societyId, block, flat).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;
        print('complaint list length : ' + _list.length.toString());

        // print('first complaint : ' + _list[0].toString());
        // print('first complaint Status : ' + _list[0]['STATUS'].toString());

        _complaintList = List<Complaints>.from(_list.map((i)=>Complaints.fromJson(i)));

        // print("Complaint List : " + _complaintList.toString());
        for (int i = 0; i < _complaintList.length; i++) {
          print('status : '+_complaintList[i].toString());
          if (_complaintList[i].STATUS.toLowerCase() == 'completed' ||
              _complaintList[i].STATUS.toLowerCase() == 'close') {
            _closedComplaintList.add(_complaintList[i]);
          }else{
            _openComplaintList.add(_complaintList[i]);
          }
        }

        print('complaint openlist length : ' + _openComplaintList.length.toString());
        print('complaint closelist length : ' + _closedComplaintList.length.toString());
        setState(() {});

      }
      _progressDialog.hide();
    });
  }

}
