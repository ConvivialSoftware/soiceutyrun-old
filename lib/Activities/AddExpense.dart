import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ndialog/ndialog.dart';
//import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Bank.dart';
import 'package:societyrun/Models/LedgerAccount.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseAddExpense extends StatefulWidget {
  bool isAdmin;
  String? mBlock, mFlat;

  BaseAddExpense({this.isAdmin = false, this.mBlock, this.mFlat});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddExpenseState();
  }
}

class AddExpenseState extends State<BaseAddExpense> {
  String? attachmentFilePath;
  String? attachmentFileName;
  String? attachmentCompressFilePath;

  TextEditingController _ledgerAccController = TextEditingController();
  TextEditingController _paymentDateController = TextEditingController();
  TextEditingController _dueDateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  List<LedgerAccount> _ledgerAccountList = <LedgerAccount>[];
  List<String> _ledgerAccountStringList = <String>[];
  LedgerAccount? _selectedLedgerAccount;

  List<String> _paidByList = <String>[];
  List<DropdownMenuItem<String>> _paidByListItems =
      <DropdownMenuItem<String>>[];
  String? _selectedPaidBy;

  List<Bank> _bankList = <Bank>[];
  List<DropdownMenuItem<String>> _bankAccountListItems =
      <DropdownMenuItem<String>>[];
  String? _selectedBankAccount;

  ProgressDialog? _progressDialog;
  bool isStoragePermission = false;

  String currentLedgerAccountText = '';
  String currentLedgerAccountTextID = '';

  @override
  void initState() {
    super.initState();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
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
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        appBar: CustomAppBar(
          title: widget.isAdmin
              ? AppLocalizations.of(context).translate('add_invoice') +
                  ' ' +
                  widget.mBlock! +
                  ' ' +
                  widget.mFlat!
              : AppLocalizations.of(context).translate('add_expense'),
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
                textHintContent: widget.isAdmin
                    ? AppLocalizations.of(context).translate('invoice_date')
                    : AppLocalizations.of(context).translate('payment_date'),
                controllerCallback: _paymentDateController,
                borderWidth: 2.0,
                contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                readOnly: true,
                suffixIcon: AppIconButton(
                  Icons.date_range,
                  iconColor: GlobalVariables.secondaryColor,
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
              widget.isAdmin
                  ? AppTextField(
                      textHintContent:
                          AppLocalizations.of(context).translate('due_date'),
                      controllerCallback: _dueDateController,
                      borderWidth: 2.0,
                      contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      readOnly: true,
                      suffixIcon: AppIconButton(
                        Icons.date_range,
                        iconColor: GlobalVariables.secondaryColor,
                        onPressed: () {
                          GlobalFunctions.getSelectedDate(context)
                              .then((value) {
                            _dueDateController.text =
                                value.day.toString().padLeft(2, '0') +
                                    "-" +
                                    value.month.toString().padLeft(2, '0') +
                                    "-" +
                                    value.year.toString();
                          });
                        },
                      ),
                    )
                  : SizedBox(),
              Container(
                width: double.infinity,
                height: 70,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.lightGray,
                      width: 2.0,
                    )),
                //.map((item) {
                //                     return new DropdownMenuItem<LedgerAccount>(
                //                         child: text(item.name), value: item);
                //                   }).toList()
                child:  DropdownSearch<LedgerAccount>(
                    items: _ledgerAccountList,

                    popupProps: PopupProps.menu(showSearchBox: true),
                    validator: (item) {
                      if (item == null)
                        return "Required field";
                      else
                        return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedLedgerAccount = value;
                      });
                    },
                    clearButtonProps: ClearButtonProps(
                      icon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.clear,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    dropdownButtonProps: DropdownButtonProps(
                      icon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.arrow_drop_down,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                                  .translate('ledger_account') +
                              '*',
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          border: InputBorder.none,
                          helperStyle: TextStyle(
                            color: GlobalVariables.lightGray,
                            fontSize: GlobalVariables.textSizeSMedium,
                          )),
                    ),
                  ),
                ),
              SizedBox(
                height: 0,
              ),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('amount') + '*',
                controllerCallback: _amountController,
                keyboardType: TextInputType.number,
              ),
              widget.isAdmin
                  ? SizedBox()
                  : Row(
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
                                  color: GlobalVariables.lightGray,
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
                                  iconColor: GlobalVariables.secondaryColor,
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
                                    labelStyle: TextStyle(
                                        color: GlobalVariables.lightGray,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent))
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
              widget.isAdmin
                  ? SizedBox()
                  : Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.lightGray,
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
                            iconColor: GlobalVariables.secondaryColor,
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
                              labelStyle: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: GlobalVariables.textSizeSMedium),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent))
                              // border: new CustomBorderTextFieldSkin().getSkin(),
                              ),
                        ),
                      ),
                    ),
              Container(
                height: 150,
                child: AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('enter_note'),
                  controllerCallback: _noteController,
                  maxLines: 99,
                  contentPadding: EdgeInsets.only(top: 14),
                ),
              ),
              /*Container(
                height: 100,
                child: AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('enter_note') +
                          '*',
                  controllerCallback: _noteController,
                ),
              ),*/
              widget.isAdmin
                  ? SizedBox()
                  : Row(
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
                                          color: GlobalVariables.secondaryColor,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          //   border: Border.all(color: GlobalVariables.green,width: 2.0)
                                        )
                                      : BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: FileImage(
                                                  File(attachmentFilePath!)),
                                              fit: BoxFit.cover),
                                          border: Border.all(
                                              color:
                                                  GlobalVariables.primaryColor,
                                              width: 2.0)),
                                  //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                                ),
                                Column(
                                  children: <Widget>[
                                    Container(
                                      child: TextButton.icon(
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
                                          iconColor:
                                              GlobalVariables.secondaryColor,
                                        ),
                                        label: text(
                                          AppLocalizations.of(context)
                                              .translate('attach_photo'),
                                          textColor:
                                              GlobalVariables.primaryColor,
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
                                      child: TextButton.icon(
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
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              'download_permission'));
                                                }
                                              });
                                            }
                                          },
                                          icon: AppIcon(
                                            Icons.camera_alt,
                                            iconColor:
                                                GlobalVariables.secondaryColor,
                                          ),
                                          label: text(
                                            AppLocalizations.of(context)
                                                .translate('take_picture'),
                                            textColor:
                                                GlobalVariables.primaryColor,
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
                    if (widget.isAdmin) {
                      verifyInvoiceInfo();
                    } else {
                      verifyInfo();
                    }
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
              if (widget.isAdmin) {
                addInvoice();
              } else {
                addExpense();
              }
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

  void verifyInvoiceInfo() {
    if (_selectedLedgerAccount != null) {
      if (_amountController.text.length > 0) {
        addInvoice();
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
    String? attachment;

    if (attachmentFileName != null && attachmentFilePath != null) {
      attachmentName = attachmentFileName!;
      attachment =
          GlobalFunctions.convertFileToString(attachmentCompressFilePath!);
    }

    // print('attachment lengtth : '+attachment.length.toString());

    _progressDialog!.show();
    restClientERP
        .addExpense(
            societyId,
            _amountController.text,
            _referenceController.text,
            _selectedPaidBy!,
            _selectedBankAccount!,
            _selectedLedgerAccount!.id!,
            _paymentDateController.text,
            _noteController.text,
            attachment)
        .then((value) async {
      print('add member Status value : ' + value.toString());
      _progressDialog!.dismiss();
      if (value.status!) {
        if (attachmentFileName != null && attachmentFilePath != null) {
          await GlobalFunctions.removeFileFromDirectory(attachmentFilePath!);
          await GlobalFunctions.removeFileFromDirectory(
              attachmentCompressFilePath!);
        }
        Navigator.of(context).pop('back');
      }
      GlobalFunctions.showToast(value.message!);
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            _progressDialog!.dismiss();
          }
          break;
        default:
      }
    });
  }

  Future<void> addInvoice() async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();

    _progressDialog!.show();
    restClientERP
        .addInvoice(
            societyId,
            _amountController.text,
            _dueDateController.text,
            widget.mBlock! + ' ' + widget.mFlat!,
            _selectedLedgerAccount!.id!,
            _paymentDateController.text,
            _noteController.text)
        .then((value) {
      print('add member Status value : ' + value.toString());
      _progressDialog!.dismiss();
      if (value.status!) {
        Navigator.of(context).pop('back');
      }
      GlobalFunctions.showToast(value.message!);
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            _progressDialog!.dismiss();
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
    attachmentFileName = attachmentFilePath!.substring(
        attachmentFilePath!.lastIndexOf('/') + 1, attachmentFilePath!.length);
    print('file Name : ' + attachmentFileName.toString());
    GlobalFunctions.getAppDocumentDirectory().then((value) {
      print('cache file Path : ' + value.toString());
      GlobalFunctions.getFilePathOfCompressImage(
              attachmentFilePath!, value.toString() + '/' + attachmentFileName!)
          .then((value) {
        attachmentCompressFilePath = value.toString();
        print('Cache file path : ' + attachmentCompressFilePath!);
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
          textColor: GlobalVariables.primaryColor,
        ),
      ));
    }
  }

  /* void changeLedgerAccountDropDownItem(LedgerAccount value) {
    print('clickable value : ' + value.toString());

  }*/

  void changePaidByDropDownItem(String? value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedPaidBy = value;
      print('_selctedItem:' + _selectedPaidBy.toString());
    });
  }

  void changeFromAccountDropDownItem(String? value) {
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
    _progressDialog!.show();
    if (widget.isAdmin) {
      restClientERP.getExpenseIncomeLedger(societyId).then((value) {
        print('Response : ' + value.toString());
        List<dynamic> _list = value.data!;
        //List<dynamic> _listBank = value.bank!;

        _ledgerAccountList = List<LedgerAccount>.from(
            _list.map((i) => LedgerAccount.fromJson(i)));
        for (int i = 0; i < _ledgerAccountList.length; i++) {
          LedgerAccount _ledgerAccount = _ledgerAccountList[i];
          _ledgerAccountStringList.add(_ledgerAccount.name!);
        }

        /*_bankList = List<Bank>.from(_listBank.map((i) => Bank.fromJson(i)));
        for (int i = 0; i < _bankList.length; i++) {
          _bankAccountListItems.add(DropdownMenuItem(
            value: _bankList[i].ID,
            child: text(
              _bankList[i].BANK_NAME,
              textColor: GlobalVariables.green,
            ),
          ));
        }
        print('bsnk list lenght : ' + _bankList.length.toString());*/
        //_categorySelectedItem = __categoryListItems[0].value;
        _progressDialog!.dismiss();
        setState(() {});
      }) /*.catchError((Object obj) {
      //   if(_progressDialog.isShowing()){
      //    _progressDialog.dismiss(;
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
    } else {
      restClientERP.getExpenseAccountLedger(societyId).then((value) {
        print('Response : ' + value.toString());
        List<dynamic> _list = value.data!;
        List<dynamic> _listBank = value.bank!;

        _ledgerAccountList = List<LedgerAccount>.from(
            _list.map((i) => LedgerAccount.fromJson(i)));
        for (int i = 0; i < _ledgerAccountList.length; i++) {
          LedgerAccount _ledgerAccount = _ledgerAccountList[i];
          _ledgerAccountStringList.add(_ledgerAccount.name!);
        }

        _bankList = List<Bank>.from(_listBank.map((i) => Bank.fromJson(i)));
        for (int i = 0; i < _bankList.length; i++) {
          _bankAccountListItems.add(DropdownMenuItem(
            value: _bankList[i].ID,
            child: text(
              _bankList[i].BANK_NAME,
              textColor: GlobalVariables.primaryColor,
            ),
          ));
        }
        print('bsnk list lenght : ' + _bankList.length.toString());
        //_categorySelectedItem = __categoryListItems[0].value;
        _progressDialog!.dismiss();
        setState(() {});
      }) /*.catchError((Object obj) {
      //   if(_progressDialog.isShowing()){
      //    _progressDialog.dismiss(;
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
}
