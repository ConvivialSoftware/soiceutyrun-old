import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseHelpDesk extends StatefulWidget {
  bool isAssignComplaint = false;

  BaseHelpDesk(this.isAssignComplaint);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HelpDeskState();
  }
}

class HelpDeskState extends State<BaseHelpDesk> {
  /* List<Complaints> _complaintList = new List<Complaints>();
  List<Complaints> value.openComplaintList = new List<Complaints>();
  List<Complaints> value.closeComplaintList = new List<Complaints>();*/

  var firstTicketContainerColor = GlobalVariables.secondaryColor;
  var secondTicketContainerColor = GlobalVariables.white;
  var firstTicketTextColor = GlobalVariables.white;
  var secondTicketTextColor = GlobalVariables.primaryColor;
  bool isOpenTicket = true;
  bool isClosedTicket = false;

  var societyId, flat, block;

  @override
  void initState() {
    super.initState();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        Provider.of<HelpDeskResponse>(context, listen: false)
            .getUnitComplaintData(widget.isAssignComplaint)
            .then((value) {
          setState(() {});
        });
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //_progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return ChangeNotifierProvider<HelpDeskResponse>.value(
      value: Provider.of(context),
      child: Consumer<HelpDeskResponse>(builder: (context, value, child) {
        return Builder(
          builder: (context) => Scaffold(
            backgroundColor: GlobalVariables.veryLightGray,
            //resizeToAvoidBottomPadding: false,
            appBar: CustomAppBar(
              title: AppLocalizations.of(context).translate('help_desk'),
            ),
            body: getMyTicketLayout(value),
          ),
        );
      }),
    );
  }

  getMyTicketLayout(HelpDeskResponse value) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(true);
      },
      child: Stack(
        children: <Widget>[
          //   GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 180.0),
          ticketOpenClosedLayout(), //ticketFilterLayout(),
          !value.isLoading
              ? getTicketListDataLayout(value)
              : GlobalFunctions.loadingWidget(context),
          !widget.isAssignComplaint ? addTicketFabLayout() : Container(),
        ],
      ),
    );
  }

  ticketOpenClosedLayout() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        //width: MediaQuery.of(context).size.width / 1.1,
        height: 50,
        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          color: GlobalVariables.transparent,
          borderRadius: BorderRadius.circular(10),
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
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0))),
                  child: ButtonTheme(
                    minWidth: 190,
                    height: 50,
                    child: TextButton(
                      //color: GlobalVariables.grey,
                      child: text(
                        AppLocalizations.of(context).translate('open'),
                        fontSize: 15.0,
                        textColor: firstTicketTextColor,
                      ),
                      onPressed: () {
                        //  GlobalFunctions.showToast("OPEN Click");
                        if (!isOpenTicket) {
                          isOpenTicket = true;
                          isClosedTicket = false;
                          firstTicketTextColor = GlobalVariables.white;
                          firstTicketContainerColor =
                              GlobalVariables.secondaryColor;
                          secondTicketTextColor = GlobalVariables.primaryColor;
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
                          topRight: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0))),
                  child: ButtonTheme(
                    minWidth: 190,
                    height: 50,
                    child: TextButton(
                      child: text(
                        AppLocalizations.of(context).translate('closed'),
                        fontSize: 15.0,
                        textColor: secondTicketTextColor,
                      ),
                      onPressed: () {
                        //  GlobalFunctions.showToast("CLOSED Click");
                        if (!isClosedTicket) {
                          isOpenTicket = false;
                          isClosedTicket = true;
                          firstTicketContainerColor = GlobalVariables.white;
                          firstTicketTextColor = GlobalVariables.primaryColor;
                          secondTicketTextColor = GlobalVariables.white;
                          secondTicketContainerColor =
                              GlobalVariables.secondaryColor;
                        }
                        setState(() {});
                      },
                     
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
                        color: GlobalVariables.secondaryColor,
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
                          suffixIcon: AppIcon(
                            Icons.search,
                            iconColor: GlobalVariables.secondaryColor,
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
              onPressed: () async {
                //GlobalFunctions.showToast('Fab CLick');
                //Navigator.of(context).pop();
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BaseRaiseNewTicket()));
                if (result == 'back') {
                  GlobalFunctions.setBaseContext(context);
                  Provider.of<HelpDeskResponse>(context, listen: false)
                      .getUnitComplaintData(widget.isAssignComplaint);
                } else {
                  GlobalFunctions.setBaseContext(context);
                }
              },
              child: AppIcon(
                Icons.add,
                iconColor: GlobalVariables.white,
              ),
              backgroundColor: GlobalVariables.primaryColor,
            ),
          )
        ],
      ),
    );
  }

  getTicketListDataLayout(HelpDeskResponse value) {
    print(' value.openComplaintList.length :' +
        value.openComplaintList.length.toString());
    print(' value.closeComplaintList.length :' +
        value.closeComplaintList.length.toString());
    return value.complaintList.length > 0
        ? Container(
            //padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(0, 80, 0, 0),
            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      itemCount: isOpenTicket
                          ? value.openComplaintList.length
                          : value.closeComplaintList.length,
                      itemBuilder: (context, position) {
                        return getTicketDescListItemLayout(position, value);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          )
        : GlobalFunctions.noDataFoundLayout(context, "No Data Found");
  }

  getTicketDescListItemLayout(int position, HelpDeskResponse value) {
    return InkWell(
        onTap: () async {
          // GlobalFunctions.showToast(isOpenTicket ? value.openComplaintList[position].TICKET_NO : value.closeComplaintList[position].TICKET_NO);
          //print('value.openComplaintList[position].toString()  : '+ value.openComplaintList[position].toString() );
          // Navigator.of(context).pop();
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseComplaintInfoAndComments(
                      isOpenTicket
                          ? value.openComplaintList[position]
                          : value.closeComplaintList[position],
                      widget.isAssignComplaint)));
          if (result == 'back') {
            GlobalFunctions.setBaseContext(context);
            Provider.of<HelpDeskResponse>(context, listen: false)
                .getUnitComplaintData(widget.isAssignComplaint);
          } else {
            GlobalFunctions.setBaseContext(context);
          }
        },
        child: AppContainer(
          isListItem: true,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: text(
                        isOpenTicket
                            ? value.openComplaintList[position].STATUS
                            : value.closeComplaintList[position].STATUS,
                        textColor: GlobalVariables.white,
                        fontSize: GlobalVariables.textSizeSmall,
                        textStyleHeight: 1.0),
                    decoration: BoxDecoration(
                        color: getTicketCategoryColor(isOpenTicket
                            ? value.openComplaintList[position].STATUS!
                            : value.closeComplaintList[position].STATUS!),
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        alignment: Alignment.topRight,
                        child: text(
                            'Ticket No: ' +
                                (isOpenTicket
                                    ? value
                                        .openComplaintList[position].TICKET_NO!
                                    : value.closeComplaintList[position]
                                        .TICKET_NO!),
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeSmall),
                      ),
                      widget.isAssignComplaint
                          ? Container(
                              alignment: Alignment.topRight,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: text(
                                  'Unit No: ' +
                                      (isOpenTicket
                                          ? value.openComplaintList[position]
                                                  .BLOCK! +
                                              ' ' +
                                              value.openComplaintList[position]
                                                  .FLAT!
                                          : value.closeComplaintList[position]
                                                  .BLOCK! +
                                              ' ' +
                                              value.closeComplaintList[position]
                                                  .FLAT!),
                                  textColor: GlobalVariables.primaryColor,
                                  fontSize: GlobalVariables.textSizeSmall),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Visibility(
                        visible: false,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: GlobalVariables.secondaryColor,
                              shape: BoxShape.rectangle),
                          /* child:*/ /* SvgPicture.asset(
                          GlobalVariables.waterIconPath,
                        ),*/ /*CircleAvatar(
                          radius: 5,
                          backgroundColor: GlobalVariables.mediumGreen,
                         // backgroundImage: NetworkImage(value.openComplaintList[position]. ),
                        ),*/
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        //margin: EdgeInsets.fromLTRB(5, 0, 0, 0), //alignment: Alignment.topLeft,
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
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: primaryText(
                                isOpenTicket
                                    ? value.openComplaintList[position].SUBJECT
                                    : value
                                        .closeComplaintList[position].SUBJECT,
                                maxLine: 1,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: secondaryText(
                                isOpenTicket
                                    ? value
                                        .openComplaintList[position].DESCRIPTION
                                    : value.closeComplaintList[position]
                                        .DESCRIPTION,
                                maxLine: 1,
                              ),
                            ),
                            /*Row(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                    'Category : ' ,
                                    style: TextStyle(color: GlobalVariables.grey)),
                              ),
                              Container(
                                margin:EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(isOpenTicket ? value.openComplaintList[position].CATEGORY : value.closeComplaintList[position].CATEGORY,
                                    style: TextStyle(
                                        color: GlobalVariables.lightGray, fontSize: 14)),
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
              /*isAssignComplaint ? Container(
              height: 1,
              color: GlobalVariables.mediumGreen,
              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Divider(
                height: 3,
              ),
            ):Container(),
            isAssignComplaint ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                      child: Text(
                        'Name: ',
                        style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 14),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                      child: Text(isOpenTicket ? value.openComplaintList[position].NAME : value.closeComplaintList[position].NAME,
                          style: TextStyle(
                              color: GlobalVariables.grey, fontSize: 14)),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Text(
                        'Block-Flat: ',
                        style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 14),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Text(
                        isOpenTicket ?  value.openComplaintList[position].BLOCK+' '+value.openComplaintList[position].FLAT : value.closeComplaintList[position].BLOCK+' '+value.closeComplaintList[position].FLAT,
                        style: TextStyle(
                          color: GlobalVariables.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ) : Container(),*/
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: text(
                        'Issued on: ' +
                            (isOpenTicket
                                ? GlobalFunctions.convertDateFormat(
                                    value.openComplaintList[position].DATE!,
                                    "dd-MM-yyyy")
                                : GlobalFunctions.convertDateFormat(
                                    value.closeComplaintList[position].DATE!,
                                    "dd-MM-yyyy")),
                        textColor: GlobalVariables.grey,
                        fontSize: GlobalVariables.textSizeSmall),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AppIcon(
                        Icons.insert_comment_outlined,
                        iconColor: GlobalVariables.lightGray,
                        iconSize: 20.0,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      text(
                          (isOpenTicket
                                  ? value
                                      .openComplaintList[position].COMMENT_COUNT
                                  : value.closeComplaintList[position]
                                      .COMMENT_COUNT)! +
                              ' Comments',
                          textColor: GlobalVariables.grey,
                          fontSize: GlobalVariables.textSizeSmall),
                    ],
                  ),
                ],
              )
            ],
          ),
        ));
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
}
