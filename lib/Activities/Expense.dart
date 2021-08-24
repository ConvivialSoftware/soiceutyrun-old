import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:societyrun/Activities/AddExpense.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/ExpenseVoucher.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Models/Expense.dart';
import 'package:societyrun/Models/LedgerAccount.dart';
import 'package:societyrun/Models/VoucherAmount.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseExpense extends StatefulWidget {

  var startDate,endDate,ledgerHeads,ledgerYear;


  BaseExpense({this.startDate, this.endDate, this.ledgerHeads,this.ledgerYear});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ExpenseState();
  }
}

class ExpenseState extends BaseStatefulState<BaseExpense> {


  var societyId, flat, block;
  var _totalSumUp=0.0;

  ProgressDialog _progressDialog;

  List<Expense> _expenseList = List<Expense>();
  @override
  void initState() {
    super.initState();

    GlobalFunctions.checkInternetConnection().then((value) {
      if(value){

        getExpenseData(widget.startDate,widget.endDate,widget.ledgerHeads,widget.ledgerYear);
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
        backgroundColor: GlobalVariables.veryLightGray,
        //resizeToAvoidBottomPadding: false,
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
          title: text(
            AppLocalizations.of(context).translate('expense'),
            textColor: GlobalVariables.white,fontSize: GlobalVariables.textSizeMedium
          ),
        ),
        body:  getExpenseLayout(),
      ),
    );
  }

  getExpenseLayout() {
    print('getExpenseLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 180.0),
    //    getSearchLayout(),
        getExpenseListDataLayout(),
      ],
    );
  }

  addExpenseFabLayout() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: FloatingActionButton(
              onPressed: () async {
                //GlobalFunctions.showToast('Fab CLick');
               // Navigator.of(context).pop();
               var result =  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BaseAddExpense()));
               if(result=='back'){
                 getExpenseData(widget.startDate,widget.endDate,widget.ledgerHeads,widget.ledgerYear);
               }
              },
              child: AppIcon(
                Icons.add,
                iconColor: GlobalVariables.white,
              ),
              backgroundColor: GlobalVariables.green,
            ),
          )
        ],
      ),
    );
  }

  getExpenseListDataLayout() {
    return _expenseList.length>0 ?
    SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.fromLTRB(
                16, 16, 16, 16),
            child: text(GlobalFunctions.getCurrencyFormat(_totalSumUp.toString()),fontSize: GlobalVariables.textSizeNormal,
                textColor: GlobalVariables.white,fontWeight: FontWeight.bold),
          ),
          Container(
            child: Builder(
                builder: (context) => ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  // scrollDirection: Axis.vertical,
                  itemCount: _expenseList.length,
                  itemBuilder: (context, position) {
                    return getExpenseDescListItemLayout(position);
                  }, //  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                )),
          ),
        ],
      ),
    ):Container();
  }

  getExpenseDescListItemLayout(int position) {

    List<VoucherAmount> _voucherAmountList = List<VoucherAmount>();
    _voucherAmountList = List<VoucherAmount>.from(_expenseList[position].head_details.map((i) => VoucherAmount.fromJson(i)));
    double _voucherAmount=0.0;
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
      child: AppContainer(
        isListItem: true,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: text(_voucherAmountList[0].head_name,textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeSMedium,fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: text(GlobalFunctions.getCurrencyFormat(_voucherAmount.toString()),textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeMedium,fontWeight: FontWeight.bold
                              ),
                            ),

                          ],
                        ),
                        /*SizedBox(
                          height: 4,
                        ),*/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: text(_expenseList[position].BANK_NAME,textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeSmall
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: text(GlobalFunctions.convertDateFormat(_expenseList[position].PAYMENT_DATE, "dd-MM-yyyy"),textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeSmall
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  /*Flexible(
                    flex: 1,
                    child: Container(
                      child: Text(*//*AppLocalizations.of(context).translate('ledger_account')+' : '+*//*_expenseList[position].name,style: TextStyle(
                          color: GlobalVariables.black,fontSize: 16
                      ),),
                    ),
                  )*/
                ],
              )
            ),
          /*  Container(
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
                    child: Text(*//*AppLocalizations.of(context).translate('bank')+' : '+*//*_expenseList[position].BANK_NAME,style: TextStyle(
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
                        *//*Container(
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
                        ),*//*
                      ],
                    ),
                  ),
                ],
              ),
            ),*/
          ],
        )
      ),
    );
  }

  getExpenseData(startDate,endDate,heads, ledgerYear) async {

    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClientERP.getExpenseData(societyId,startDate,endDate,heads,ledgerYear).then((value) {
      _progressDialog.hide();
      print('Response : ' + value.toString());
      List<dynamic> _list = value.data;
     _expenseList = List<Expense>.from(_list.map((i) => Expense.fromJson(i)));
      //getExpenseAccountLedger();
      for(int j=0;j<_expenseList.length;j++){
        _totalSumUp += double.parse(_expenseList[j].AMOUNT==null ? '0' : _expenseList[j].AMOUNT);
      }
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
/*
  getSearchLayout() {

    return Container(

      margin: EdgeInsets.fromLTRB(20, 40, 20, 40),
      padding: EdgeInsets.all(20),
      // height: MediaQuery.of(context).size.height / 0.5,
      decoration: BoxDecoration(
          color: GlobalVariables.white,
          borderRadius: BorderRadius.circular(20)),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            textHintContent:
            AppLocalizations.of(context).translate('start_date'),
            controllerCallback: _startDateController,
            borderWidth: 2.0,
            contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
            readOnly: true,
            suffixIcon: AppIconButton(
              Icons.date_range,
              iconColor: GlobalVariables.mediumGreen,
              onPressed: () {
                GlobalFunctions.getSelectedDate(context).then((value) {
                  _startDateController.text =
                      value.day.toString().padLeft(2, '0') +
                          "-" +
                          value.month.toString().padLeft(2, '0') +
                          "-" +
                          value.year.toString();
                  startDate=_startDateController.text;
                });
              },
            ),
          ),
          AppTextField(
            textHintContent:
            AppLocalizations.of(context).translate('end_date'),
            controllerCallback: _endDateController,
            borderWidth: 2.0,
            contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
            readOnly: true,
            suffixIcon: AppIconButton(
              Icons.date_range,
              iconColor: GlobalVariables.mediumGreen,
              onPressed: () {
                GlobalFunctions.getSelectedDate(context).then((value) {
                  _endDateController.text =
                      value.day.toString().padLeft(2, '0') +
                          "-" +
                          value.month.toString().padLeft(2, '0') +
                          "-" +
                          value.year.toString();
                  endDate=_endDateController.text;
                  getExpenseData(startDate, endDate,null);
                });
              },
            ),
          ),
          SizedBox(height: 8,),
          Divider(thickness: 1,color: GlobalVariables.veryLightGray,),
         // SizedBox(height: 8,),
          Row(
            children: [
              Flexible(
                flex: 5,
                child:Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.mediumGreen,
                        width: 2.0,
                      )),
                  child: SearchableDropdown(
                    items: _ledgerAccountList.map((item) {
                      return new DropdownMenuItem<LedgerAccount>(
                          child: Text(item.name), value: item);
                    }).toList(),
                    value: _selectedLedgerAccount,
                    onChanged: changeLedgerAccountDropDownItem,
                    isExpanded: true,
                    isCaseSensitiveSearch: true,
                    icon: Icon(null
                      *//*Icons.keyboard_arrow_down,
                    color: GlobalVariables.mediumRed,*//*
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('ledger_account'),
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: GlobalVariables.textSizeSMedium),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 32,),
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: (){
                    getExpenseData(null, null, _selectedLedgerAccount.name);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: boxDecoration(
                      radius: 30.0,
                      bgColor: GlobalVariables.green,

                    ),
                    child: AppIconButton(
                      Icons.search,
                      iconColor: GlobalVariables.white,
                      iconSize: 30.0,
                    ),
                  ),
                ),
              )
            ],
          ),
       *//*   Row(
            children: [
              AppTextField(
                textHintContent:
                AppLocalizations.of(context).translate('search_by_heads'),
                controllerCallback: _startDateController,
                borderWidth: 2.0,
                contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              ),
              SizedBox(
                width: 8,
              ),

            ],
          ),*//*
        ],
      ),
    );

  }

 */


}
