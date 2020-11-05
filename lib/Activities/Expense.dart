import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/AddExpense.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

import 'base_stateful.dart';

class BaseExpense extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ExpenseState();
  }
}

class ExpenseState extends BaseStatefulState<BaseExpense> {


  var societyId, flat, block;

  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        //resizeToAvoidBottomPadding: false,
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
            AppLocalizations.of(context).translate('expense'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body:  getExpenseLayout(),
      ),
    );
  }

  getExpenseLayout() {
    print('getExpenseLayout Tab Call');
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
                getExpenseListDataLayout(),
                addTicketFabLayout(),
              ],
            ),
          ),
        ],
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
                        builder: (context) => BaseAddExpense()));
              },
              child: Icon(
                Icons.add,
                color: GlobalVariables.white,
              ),
              backgroundColor: GlobalVariables.green,
            ),
          )
        ],
      ),
    );
  }

  getExpenseListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 20, 10, 0),
      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
            itemCount: 4,
            itemBuilder: (context, position) {
              return getExpenseDescListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getExpenseDescListItemLayout(int position) {
    return InkWell(
      onTap: () async {

      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.date_range,color: GlobalVariables.lightGreen,),
                          Container(
                            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: Text('date',style: TextStyle(
                                color: GlobalVariables.black,fontSize: 14
                            ),),
                          )
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text('amount',style: TextStyle(
                          color: GlobalVariables.green,fontSize: 16
                        ),),
                      ),
                    ],
                  ),
                  Container(
                    child: Text('ledger Account',style: TextStyle(
                        color: GlobalVariables.black,fontSize: 16
                    ),),
                  )
                ],
              )
            ),
            Container(
              child: Divider(
                thickness: 2,
                color: GlobalVariables.lightGray,
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 5, 0),
                    child: Text('bank Account',style: TextStyle(
                        color: GlobalVariables.black,fontSize: 14
                    ),),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 5, 5, 0),
                          child: Text('reference Number',style: TextStyle(
                              color: GlobalVariables.black,fontSize: 14
                          ),),
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
                          decoration: BoxDecoration(
                            color: GlobalVariables.green,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Icon(
                            Icons.remove_red_eye,
                            color: GlobalVariables.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}
