import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:societyrun/Activities/AddExpense.dart';
import 'package:societyrun/Activities/Expense.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/LedgerAccount.dart';
import 'package:societyrun/Models/LedgerResponse.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseExpenseSearchAdd extends StatefulWidget {
  @override
  _BaseExpenseSearchAddState createState() => _BaseExpenseSearchAddState();
}

class _BaseExpenseSearchAddState extends State<BaseExpenseSearchAdd> {


  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();


  List<LedgerAccount> _ledgerAccountList = new List<LedgerAccount>();
  List<String> _ledgerAccountStringList = new List<String>();
  LedgerAccount _selectedLedgerAccount;

  List<DropdownMenuItem<String>> _yearListItems =
  new List<DropdownMenuItem<String>>();
  List<LedgerYear> _listYear = List<LedgerYear>();
  String _yearSelectedItem;


  var startDate,endDate;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    DateTime selectedDate = DateTime.now();
    //endDate = GlobalFunctions.convertDateFormat(selectedDate.toIso8601String(), 'dd-MM-yyyy');
    //startDate = GlobalFunctions.convertDateFormat(DateTime(selectedDate.year,selectedDate.month-2,selectedDate.day).toIso8601String(), 'dd-MM-yyyy');

   // _startDateController.text=startDate;
    //_endDateController.text=endDate;
    //print('startDate : '+startDate);
    //print('endDate : '+endDate);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        body: getBaseLayout(context),
      ),
    );
  }

  getBaseLayout(BuildContext context) {
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
                searchFilterLayout(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  searchFilterLayout(BuildContext context) {
    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BaseAddExpense()))
                  .then((value) {
                GlobalFunctions.setBaseContext(context);
              });
            },
            child:   AppPermission.isAddExpensePermission ? Container(
              margin: EdgeInsets.fromLTRB(20, 60, 20, 40),
              padding: EdgeInsets.all(20),
              // height: MediaQuery.of(context).size.height / 0.5,
              decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          child: AppAssetsImage(
                            GlobalVariables.expenseIconPath,
                            imageWidth: 80.0,
                            imageHeight: 80.0,
                          ),
                        ),
                        SizedBox(
                          width: 32,
                        ),
                        Container(
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('add_expense'),
                              fontSize: GlobalVariables.textSizeMedium,
                              textColor: GlobalVariables.green,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ):SizedBox(),
          ),
          InkWell(
            onTap: () {
              getExpenseAccountLedger();
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(20, AppPermission.isAddExpensePermission ? 20:80, 20, 40),
              padding: EdgeInsets.all(20),
              // height: MediaQuery.of(context).size.height / 0.5,
              decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          child: AppAssetsImage(
                            GlobalVariables.expenseIconPath,
                            imageWidth: 80.0,
                            imageHeight: 80.0,
                          ),
                        ),
                        SizedBox(
                          width: 32,
                        ),
                        Container(
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('search_expense'),
                              fontSize: GlobalVariables.textSizeMedium,
                              textColor: GlobalVariables.green,
                              fontWeight: FontWeight.bold),
                        )
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

 // List<String> _selectOptionList = List<String>();
 // var _selectedText = "All";

  showSearchWiseBottomSheet() {


   /* _selectOptionList = List<String>();

    _selectOptionList.add('Date Wise');
    _selectOptionList.add('Ledger Wise');
    _selectOptionList.add('All');
*/
    return showDialog(
       // backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, _setState){
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: GlobalVariables.white),
                    // height: MediaQuery.of(context).size.width * 1.0,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: text('Search By',
                                      maxLine: 3,
                                      fontSize: GlobalVariables.textSizeMedium,
                                      textColor: GlobalVariables.green,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                 // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      alignment: Alignment.topLeft,
                                      child: text('Financial Year : ',
                                          maxLine: 3,
                                          fontSize: GlobalVariables.textSizeSMedium,
                                          textColor: GlobalVariables.green,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.topLeft,
                                        width: 150,
                                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        decoration: BoxDecoration(
                                            color: GlobalVariables.white,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: GlobalVariables.mediumGreen,
                                              width: 2.0,
                                            )),
                                        child: ButtonTheme(
                                          //alignedDropdown: true,
                                          child: DropdownButton(
                                            items: _yearListItems,
                                            onChanged: (value) {
                                              _yearSelectedItem = value;
                                              print('_selctedItem:' +
                                                  _yearSelectedItem.toString());
                                              _setState(() {

                                              });
                                            },
                                            value: _yearSelectedItem,
                                            underline: SizedBox(),
                                            isExpanded: true,
                                            icon: AppIcon(
                                              Icons.keyboard_arrow_down,
                                              iconColor: GlobalVariables.mediumGreen,
                                            ),
                                            iconSize: 20,
                                            selectedItemBuilder: (BuildContext context) {
                                              // String txt =  _societyListItems.elementAt(position).value;
                                              return _yearListItems.map((e) {
                                                return Container(
                                                    alignment: Alignment.center,
                                                    //margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
                                                    child: text(
                                                      _yearSelectedItem,
                                                      textColor: GlobalVariables.green,
                                                    ));
                                              }).toList();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                             Container(

                               //   margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                 // padding: EdgeInsets.all(20),
                                  // height: MediaQuery.of(context).size.height / 0.5,
                                  decoration: BoxDecoration(
                                     // color: GlobalVariables.grey,
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
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                        decoration: BoxDecoration(
                                            color: GlobalVariables.white,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: GlobalVariables.mediumGreen,
                                              width: 2.0,
                                            )),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              flex:6,
                                              child: SearchableDropdown(
                                                items: _ledgerAccountList.map((item) {
                                                  return new DropdownMenuItem<LedgerAccount>(
                                                      child: text(item.name), value: item);
                                                }).toList(),
                                                value: _selectedLedgerAccount,
                                                onChanged: changeLedgerAccountDropDownItem,
                                                isExpanded: true,
                                                isCaseSensitiveSearch: true,
                                                icon: AppIcon(null
                                                  /*Icons.keyboard_arrow_down, color: GlobalVariables.grey,*/
                                                ),
                                                underline: SizedBox(),
                                              clearIcon: Icon(Icons.clear),
                                              onClear: (){
                                                _selectedLedgerAccount=null;
                                                print('_selectedLedgerAccount : '+_selectedLedgerAccount.toString());
                                                setState(() {
                                                }); _setState(() {
                                                });
                                              },
                                              //  closeButton: SizedBox.shrink(),
                                                hint: text(
                                                  AppLocalizations.of(context).translate('ledger_account'),
                                                  textColor: GlobalVariables.lightGray, fontSize: GlobalVariables.textSizeSMedium),
                                              ),
                                            ),
                                            SizedBox(width: 8,),
                                           /* Flexible(
                                              flex:1,
                                              child: AppIconButton(
                                                Icons.close,
                                                iconColor: GlobalVariables.mediumGreen,
                                                onPressed: () {
                                                  _selectedLedgerAccount=null;
                                                  print('_selectedLedgerAccount : '+_selectedLedgerAccount.toString());
                                                  setState(() {
                                                  }); _setState(() {
                                                  });
                                                },
                                              ),
                                            ),*/
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 32,),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  child: AppButton(textContent : 'Submit',
                                      onPressed: (){
                                        /*if(_startDateController.text.isEmpty && _endDateController.text.isEmpty && _selectedLedgerAccount==null) {
                                          GlobalFunctions.showToast('Please Enter Start-End Date or Ledger Account');
                                        }else{*/
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BaseExpense(
                                                        startDate: _startDateController
                                                            .text,
                                                        endDate: _endDateController
                                                            .text.isEmpty ? GlobalFunctions.convertDateFormat(DateTime.now().toIso8601String(), 'dd-MM-yyyy') : _endDateController.text,
                                                        ledgerHeads: _selectedLedgerAccount ==
                                                            null
                                                            ? null
                                                            : _selectedLedgerAccount
                                                            .name,ledgerYear: _yearSelectedItem,)))
                                              .then((value) {
                                            GlobalFunctions.setBaseContext(
                                                context);
                                          });
                                        //}
                                      },
                                      //fontSize: 16.0,
                                      textColor: GlobalVariables.white,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          });
        });
  }


  void changeLedgerAccountDropDownItem(LedgerAccount value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedLedgerAccount = value;
      print('_selctedItem: ' + _selectedLedgerAccount.toString());
      print('_selctedItem name: ' + _selectedLedgerAccount.name.toString());
      print('_selctedItem value: ' + _selectedLedgerAccount.id.toString());
    });
  }


  getExpenseAccountLedger() async {
    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
      _progressDialog.show();
    restClientERP.getExpenseAccountLedger(societyId).then((value) {
      print('Response : ' + value.toString());
      List<dynamic> _list = value.data;
      List<dynamic> _listLedgerYear = value.Year;

      _ledgerAccountList = List<LedgerAccount>.from(_list.map((i) => LedgerAccount.fromJson(i)));
      for (int i = 0; i < _ledgerAccountList.length; i++) {
        LedgerAccount _ledgerAccount = _ledgerAccountList[i];
        _ledgerAccountStringList.add(_ledgerAccount.name);
      }

      _yearListItems = new List<DropdownMenuItem<String>>();
      _listYear = List<LedgerYear>();

      _listYear  = List<LedgerYear>.from(_listLedgerYear.map((i) => LedgerYear.fromJson(i)));
      for (int i = 0; i < _listYear.length; i++) {
        print('_listYear : ' + _listYear[i].Active_account.toString());
        print('_listYear : ' + _listYear[i].years.toString());
        if (_listYear[i].Active_account.toString().toLowerCase() == 'yes') {
          if (_yearListItems.length == 0) {
            _yearListItems.add(DropdownMenuItem(
              value: _listYear[i].years,
              child: text(
                _listYear[i].years,
                textColor: GlobalVariables.green
              ),
            ));
          } else {
            print('insert at 0 ');
            _yearListItems.insert(
                0,
                DropdownMenuItem(
                  value: _listYear[i].years,
                  child: text(
                    _listYear[i].years,
                   textColor: GlobalVariables.green,
                  ),
                ));
            if (_yearSelectedItem == null) {
              _yearSelectedItem = _listYear[i].years;
              print('_yearSelectedItem : ' + _yearSelectedItem);
            }
          }
        } else {
          _yearListItems.add(DropdownMenuItem(
            value: _listYear[i].years,
            child: text(
              _listYear[i].years,
              textColor: GlobalVariables.green,
            ),
          ));
        }
      }

      print('_yearSelectedItem : '+_yearSelectedItem.toString());
      if(_yearSelectedItem==null){
        _yearSelectedItem = _listYear[0].years;
      }

      _progressDialog.hide();
      setState(() {
        showSearchWiseBottomSheet();
      });
    }) /*.catchError((Object obj) {
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
    })*/
    ;
  }
}
