import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Bank.dart';
import 'package:societyrun/Models/LedgerAccount.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseAddExpense extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddExpenseState();
  }
}

class AddExpenseState extends BaseStatefulState<BaseAddExpense> {
  String attachmentFilePath;
  String attachmentFileName;
  String attachmentCompressFilePath;

  TextEditingController _paymentDateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  List<LedgerAccount> _ledgerAccountList = new List<LedgerAccount>();
  List<String> _ledgerAccountStringList = new List<String>();
  LedgerAccount _selectedLedgerAccount;

  List<String> _paidByList = new List<String>();
  List<DropdownMenuItem<String>> _paidByListItems =
      new List<DropdownMenuItem<String>>();
  String _selectedPaidBy;

  List<Bank> _bankList = new List<Bank>();
  List<DropdownMenuItem<String>> _bankAccountListItems =
      new List<DropdownMenuItem<String>>();
  String _selectedBankAccount;

  ProgressDialog _progressDialog;
  bool isStoragePermission = false;

  String currentLedgerAccountText = '';
  String currentLedgerAccountTextID = '';

  @override
  void initState() {
    super.initState();
    getPaidByData();
    _paymentDateController.text =
        DateTime.now().toLocal().day.toString().padLeft(2, '0') +
            "-" +
            DateTime.now().toLocal().month.toString().padLeft(2, '0') +
            "-" +
            DateTime.now().toLocal().year.toString();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission = value;
    });
    GlobalFunctions.checkInternetConnection().then((value) {
      if (value) {
        getExpenseAccountLedger();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //GlobalFunctions.showToast(memberType.toString());
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
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
            AppLocalizations.of(context).translate('add_expense'),
            textColor: GlobalVariables.white, fontSize: GlobalVariables.textSizeMedium
          ),
        ),
        body: getBaseLayout(),
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
                getAddExpenseLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getAddExpenseLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(18, 40, 18, 40),
        padding: EdgeInsets.all(20),
        // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(10)),
        child: Container(
          child: Column(
            children: <Widget>[
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('payment_date'),
                controllerCallback: _paymentDateController,
                borderWidth: 2.0,
                contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                readOnly: true,
                suffixIcon: AppIconButton(
                  Icons.date_range,
                  iconColor: GlobalVariables.mediumGreen,
                  onPressed: () {
                    GlobalFunctions.getSelectedDate(context).then((value) {
                      _paymentDateController.text =
                          value.day.toString().padLeft(2, '0') +
                              "-" +
                              value.month.toString().padLeft(2, '0') +
                              "-" +
                              value.year.toString();
                    });
                  },
                ),
              ),
              Container(
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
                        child: text(item.name), value: item);
                  }).toList(),
                  value: _selectedLedgerAccount,
                  onChanged: changeLedgerAccountDropDownItem,
                  isExpanded: true,
                  isCaseSensitiveSearch: true,
                  icon: AppIcon(null
                      /*Icons.keyboard_arrow_down,
                    color: GlobalVariables.mediumRed,*/
                      ),
                  underline: SizedBox(),
                  hint: text(
                    AppLocalizations.of(context).translate('ledger_account') +
                        '*',
                    textColor: GlobalVariables.lightGray,
                    fontSize: GlobalVariables.textSizeSMedium,
                  ),
                ),
              ),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('amount') + '*',
                controllerCallback: _amountController,
                keyboardType: TextInputType.number,
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 2.0,
                          )),
                      child: ButtonTheme(
                        child: DropdownButtonFormField(
                          items: _paidByListItems,
                          value: _selectedPaidBy,
                          onChanged: changePaidByDropDownItem,
                          isExpanded: true,
                          icon: AppIcon(
                            Icons.keyboard_arrow_down,
                            iconColor: GlobalVariables.mediumGreen,
                          ),
                          /*underline: SizedBox(),
                          hint: text(
                            AppLocalizations.of(context).translate('paid_by') +
                                '*',
                            textColor: GlobalVariables.lightGray,
                            fontSize: GlobalVariables.textSizeSMedium,
                          ),*/
                          decoration: InputDecoration(
                            //filled: true,
                            //fillColor: Hexcolor('#ecedec'),
                              labelText: AppLocalizations.of(context)
                                  .translate('paid_by') +
                                  '*',
                              labelStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeSMedium),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent))
                            // border: new CustomBorderTextFieldSkin().getSkin(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Flexible(
                    flex: 3,
                    child: AppTextField(
                      textHintContent: AppLocalizations.of(context)
                              .translate('reference_no') +
                          '*',
                      controllerCallback: _referenceController,
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 2.0,
                    )),
                child: ButtonTheme(
                  child: DropdownButtonFormField(
                    items: _bankAccountListItems,
                    value: _selectedBankAccount,
                    onChanged: changeFromAccountDropDownItem,
                    isExpanded: true,
                    icon: AppIcon(
                      Icons.keyboard_arrow_down,
                      iconColor: GlobalVariables.mediumGreen,
                    ),
                    /*underline: SizedBox(),
                    hint: text(
                      AppLocalizations.of(context).translate('from_account') +
                          '*',
                      textColor: GlobalVariables.lightGray,
                      fontSize: GlobalVariables.textSizeSMedium,
                    ),*/
                    decoration: InputDecoration(
                      //filled: true,
                      //fillColor: Hexcolor('#ecedec'),
                        labelText: AppLocalizations.of(context)
                            .translate('from_account') +
                            '*',
                        labelStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeSMedium),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent))
                      // border: new CustomBorderTextFieldSkin().getSkin(),
                    ),
                  ),
                ),
              ),
              Container(
                height: 100,
                child: AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('enter_note') +
                          '*',
                  controllerCallback: _noteController,
                ),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
                            decoration: attachmentFilePath == null
                                ? BoxDecoration(
                                    color: GlobalVariables.mediumGreen,
                                    borderRadius: BorderRadius.circular(25),
                                    //   border: Border.all(color: GlobalVariables.green,width: 2.0)
                                  )
                                : BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image:
                                            FileImage(File(attachmentFilePath)),
                                        fit: BoxFit.cover),
                                    border: Border.all(
                                        color: GlobalVariables.green,
                                        width: 2.0)),
                            //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                child: FlatButton.icon(
                                  onPressed: () {
                                    if (isStoragePermission) {
                                      openFile(context);
                                    } else {
                                      GlobalFunctions.askPermission(
                                              Permission.storage)
                                          .then((value) {
                                        if (value) {
                                          openFile(context);
                                        } else {
                                          GlobalFunctions.showToast(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      'download_permission'));
                                        }
                                      });
                                    }
                                  },
                                  icon: AppIcon(
                                    Icons.attach_file,
                                    iconColor: GlobalVariables.mediumGreen,
                                  ),
                                  label: text(
                                    AppLocalizations.of(context)
                                        .translate('attach_photo'),
                                    textColor: GlobalVariables.green,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: text(
                                  'OR',
                                  textColor: GlobalVariables.lightGray,
                                ),
                              ),
                              Container(
                                child: FlatButton.icon(
                                    onPressed: () {
                                      if (isStoragePermission) {
                                        openCamera(context);
                                      } else {
                                        GlobalFunctions.askPermission(
                                                Permission.storage)
                                            .then((value) {
                                          if (value) {
                                            openCamera(context);
                                          } else {
                                            GlobalFunctions.showToast(
                                                AppLocalizations.of(context)
                                                    .translate(
                                                        'download_permission'));
                                          }
                                        });
                                      }
                                    },
                                    icon: AppIcon(
                                      Icons.camera_alt,
                                      iconColor: GlobalVariables.mediumGreen,
                                    ),
                                    label: text(
                                      AppLocalizations.of(context)
                                          .translate('take_picture'),
                                      textColor: GlobalVariables.green,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.topLeft,
                height: 45,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: AppButton(
                  textContent: AppLocalizations.of(context).translate('submit'),
                  onPressed: () {
                    verifyInfo();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void verifyInfo() {
    if (_selectedLedgerAccount != null) {
      if (_amountController.text.length > 0) {
        if (_selectedPaidBy != null) {
          if (_referenceController.text.length > 0) {
            if (_selectedBankAccount != null) {
              addExpense();
            } else {
              GlobalFunctions.showToast('Please Select From Account');
            }
          } else {
            GlobalFunctions.showToast('Please Enter Reference Number');
          }
        } else {
          GlobalFunctions.showToast('Please Select PaidBy');
        }
      } else {
        GlobalFunctions.showToast('Please Enter Amount');
      }
    } else {
      GlobalFunctions.showToast('Please Select Ledger Account');
    }
  }

  Future<void> addExpense() async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String attachmentName;
    String attachment;

    if (attachmentFileName != null && attachmentFilePath != null) {
      attachmentName = attachmentFileName;
      attachment =
          GlobalFunctions.convertFileToString(attachmentCompressFilePath);
    }

    // print('attachment lengtth : '+attachment.length.toString());

    _progressDialog.show();
    restClientERP
        .addExpense(
            societyId,
            _amountController.text,
            _referenceController.text,
            _selectedPaidBy,
            _selectedBankAccount,
            _selectedLedgerAccount.id,
            _paymentDateController.text,
            _noteController.text,
            attachment)
        .then((value) {
      print('add member Status value : ' + value.toString());
      _progressDialog.hide();
      if (value.status) {
        if (attachmentFileName != null && attachmentFilePath != null) {
          GlobalFunctions.removeFileFromDirectory(attachmentCompressFilePath);
        }
        Navigator.of(context).pop('back');
      }
      GlobalFunctions.showToast(value.message);
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            _progressDialog.hide();
          }
          break;
        default:
      }
    });
  }

  void openFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentFilePath = value;
      getCompressFilePath();
    });
  }

  void openCamera(BuildContext context) {
    GlobalFunctions.openCamera().then((value) {
      attachmentFilePath = value.path;
      getCompressFilePath();
    });
  }

  void getCompressFilePath() {
    attachmentFileName = attachmentFilePath.substring(
        attachmentFilePath.lastIndexOf('/') + 1, attachmentFilePath.length);
    print('file Name : ' + attachmentFileName.toString());
    GlobalFunctions.getTemporaryDirectoryPath().then((value) {
      print('cache file Path : ' + value.toString());
      GlobalFunctions.getFilePathOfCompressImage(
              attachmentFilePath, value.toString() + '/' + attachmentFileName)
          .then((value) {
        attachmentCompressFilePath = value.toString();
        print('Cache file path : ' + attachmentCompressFilePath);
        setState(() {});
      });
    });
  }

  void getPaidByData() {
    _paidByList = ["Cash", "Cheque", "NEFT/IMPS/UPI"];
    for (int i = 0; i < _paidByList.length; i++) {
      _paidByListItems.add(DropdownMenuItem(
        value: _paidByList[i],
        child: text(
          _paidByList[i],
          textColor: GlobalVariables.green,
        ),
      ));
    }
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

  void changePaidByDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedPaidBy = value;
      print('_selctedItem:' + _selectedPaidBy.toString());
    });
  }

  void changeFromAccountDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedBankAccount = value;
      print('_selctedItem:' + _selectedBankAccount.toString());
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
      List<dynamic> _listBank = value.bank;

      _ledgerAccountList =
          List<LedgerAccount>.from(_list.map((i) => LedgerAccount.fromJson(i)));
      for (int i = 0; i < _ledgerAccountList.length; i++) {
        LedgerAccount _ledgerAccount = _ledgerAccountList[i];
        _ledgerAccountStringList.add(_ledgerAccount.name);
      }

      _bankList = List<Bank>.from(_listBank.map((i) => Bank.fromJson(i)));
      for (int i = 0; i < _bankList.length; i++) {
        _bankAccountListItems.add(DropdownMenuItem(
          value: _bankList[i].ID,
          child: text(
            _bankList[i].BANK_NAME,
            textColor: GlobalVariables.green,
          ),
        ));
      }
      print('bsnk list lenght : ' + _bankList.length.toString());
      //_categorySelectedItem = __categoryListItems[0].value;
      _progressDialog.hide();
      setState(() {});
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
