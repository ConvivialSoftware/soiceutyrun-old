
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Expense.dart';
import 'package:societyrun/Models/ProfileInfo.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

class BaseExpenseVoucher extends StatefulWidget {

  Expense _expense;
  BaseExpenseVoucher(this._expense);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ExpenseVoucherState(_expense);
  }
}

class ExpenseVoucherState extends BaseStatefulState<BaseExpenseVoucher> {


  ProgressDialog _progressDialog;

  Expense _expense;
  ExpenseVoucherState(this._expense);
  

  @override
  void initState() {
    super.initState();
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
          title: AutoSizeText(
            AppLocalizations.of(context).translate('expense_voucher'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: WillPopScope(child: getBaseLayout(), onWillPop: (){
          Navigator.of(context).pop();
          return;
        }),
      ),
    );
  }
  
  getBaseLayout() {
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
                    context, 200.0),
                getExpenseVoucherLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getExpenseVoucherLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 10),
        padding: EdgeInsets.all(
            10), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('voucher_number')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18,fontWeight: FontWeight.bold
                      ),),
                    ),
                    Container(
                   //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_expense.VOUCHER_NO,style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 18,fontWeight: FontWeight.bold
                      ),),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('Vendor_name')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                     // margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_expense.name,style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('amount')+ "(Rs.) : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                    //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_expense.AMOUNT.toString(),style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('transaction_mode')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                    //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_expense.TRANSACTION_TYPE,style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('transaction_number')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                      //margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_expense.REFERENCE_NO,style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('from_account')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                    //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_expense.BANK_NAME,style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5,20,5,5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        child: AutoSizeText(AppLocalizations.of(context).translate('narration')+ " : ",style: TextStyle(
                            color: GlobalVariables.green,fontSize: 18
                        ),),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        //color : GlobalVariables.green,
                        //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: AutoSizeText(_expense.REMARK,style: TextStyle(
                            color: GlobalVariables.grey,fontSize: 16
                        ),maxLines: 2,)
                        ,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
