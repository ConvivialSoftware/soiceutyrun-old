import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/AddExpense.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/ExpenseVoucher.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Models/Expense.dart';
import 'package:societyrun/Models/VoucherAmount.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';

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

  List<Expense> _expenseList = List<Expense>();

  @override
  void initState() {
    super.initState();
    GlobalFunctions.checkInternetConnection().then((value) {
      if(value){
        getExpenseData();
      }else{
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
    return _expenseList.length>0 ? Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 20, 10, 0),
      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
            itemCount: _expenseList.length,
            itemBuilder: (context, position) {
              return getExpenseDescListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    ):Container();
  }

  getExpenseDescListItemLayout(int position) {

    List<VoucherAmount> _voucherAmountList = List<VoucherAmount>();
    _voucherAmountList = List<VoucherAmount>.from(_expenseList[position].head_details.map((i) => VoucherAmount.fromJson(i)));
    double _voucherAmount;
    for(int i=0;i<_voucherAmountList.length;i++){
      _voucherAmount +=double.parse(_voucherAmountList[i].amount);
    }

    return InkWell(
      onTap: () async {

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BaseExpenseVoucher(_expenseList[position])));

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
                  Flexible(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.date_range,color: GlobalVariables.mediumGreen,),
                            Container(
                              margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: Text(GlobalFunctions.convertDateFormat(_expenseList[position].PAYMENT_DATE, "dd-MM-yyyy"),style: TextStyle(
                                  color: GlobalVariables.black,fontSize: 16
                              ),),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            //Icon(Icons.attach_money,color: GlobalVariables.lightGreen,),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Text('Rs. '+_voucherAmount.toString(),style: TextStyle(
                                color: GlobalVariables.green,fontSize: 18,fontWeight: FontWeight.bold
                              ),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      child: Text(/*AppLocalizations.of(context).translate('ledger_account')+' : '+*/_expenseList[position].name,style: TextStyle(
                          color: GlobalVariables.black,fontSize: 16
                      ),),
                    ),
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
                    margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: Text(/*AppLocalizations.of(context).translate('bank')+' : '+*/_expenseList[position].BANK_NAME,style: TextStyle(
                        color: GlobalVariables.skyBlue,fontSize: 14
                    ),),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(AppLocalizations.of(context).translate('reference_number')+' : '+_expenseList[position].REFERENCE_NO,style: TextStyle(
                              color: GlobalVariables.orangeYellow,fontSize: 14
                          ),),
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          decoration: BoxDecoration(
                            color: GlobalVariables.green,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Icon(
                            Icons.remove_red_eye,
                            color: GlobalVariables.white,
                            size: 18,
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

  getExpenseData() async {

    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClientERP.getExpenseData(societyId).then((value) {
      _progressDialog.hide();
      print('Response : ' + value.toString());
      List<dynamic> _list = value.data;
     _expenseList = List<Expense>.from(_list.map((i) => Expense.fromJson(i)));

      setState(() {});
    })/*.catchError((Object obj) {
      //   if(_progressDialog.isShowing()){
      //    _progressDialog.hide();
      //  }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            //getAllBillData();
          }
          break;
        default:
      }
    })*/;
  }

}
