import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

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


  List<String> _ledgerAccountList = new List<String>();
  List<DropdownMenuItem<String>> _ledgerAccountListItems = new List<DropdownMenuItem<String>>();
  String _selectedLedgerAccount;


  List<String> _paidByList = new List<String>();
  List<DropdownMenuItem<String>> _paidByListItems = new List<DropdownMenuItem<String>>();
  String _selectedPaidBy;

  List<String> _fromAccountList = new List<String>();
  List<DropdownMenuItem<String>> _fromAccountListItems = new List<DropdownMenuItem<String>>();
  String _selectedFromAccount;


  ProgressDialog _progressDialog;
  bool isStoragePermission=false;


  @override
  void initState() {
    super.initState();
    getPaidByData();
    _paymentDateController.text = DateTime.now().toLocal().day.toString().padLeft(2, '0')+"/"+DateTime.now().toLocal().month.toString().padLeft(2, '0')+"/"+DateTime.now().toLocal().year.toString();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission=value;
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
            child: Icon(
              Icons.arrow_back,
              color: GlobalVariables.white,
            ),
          ),
          title: Text(
            AppLocalizations.of(context).translate('add_expense'),
            style: TextStyle(color: GlobalVariables.white),
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
        margin: EdgeInsets.fromLTRB(20, 40, 20, 40),
        padding: EdgeInsets.all(20),
       // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
               padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 5, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _paymentDateController,
                  readOnly: true,
                  style: TextStyle(
                      color: GlobalVariables.green
                  ),
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('payment_date'),
                      hintStyle: TextStyle(color: GlobalVariables.veryLightGray ,fontSize: 16),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                          onPressed: (){

                            GlobalFunctions.getSelectedDate(context).then((value){
                              _paymentDateController.text = value.day.toString().padLeft(2, '0')+"/"+value.month.toString().padLeft(2, '0')+"/"+value.year.toString();
                            });

                          },
                          icon: Icon(Icons.date_range,color: GlobalVariables.mediumGreen,))
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: _ledgerAccountListItems,
                    value: _selectedLedgerAccount,
                    onChanged: changeLedgerAccountDropDownItem,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('ledger_account')+'*',
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 16),
                    ),
                  ),
                ),
              ),
              Container(
                //  height: 150,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  //readOnly: true,
                  //maxLines: 99,
                  decoration: InputDecoration(
                      hintText:
                      AppLocalizations.of(context).translate('amount')+'*',
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                      border: InputBorder.none),
                ),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(5, 20, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 3.0,
                          )),
                      child: ButtonTheme(
                        child: DropdownButton(
                          items: _paidByListItems,
                          value: _selectedPaidBy,
                          onChanged: changePaidByDropDownItem,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: GlobalVariables.mediumGreen,
                          ),
                          underline: SizedBox(),
                          hint: Text(
                            AppLocalizations.of(context).translate('paid_by')+'*',
                            style: TextStyle(
                                color: GlobalVariables.lightGray, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Container(
                      //  height: 150,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(5, 20, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 3.0,
                          )),
                      child: TextField(
                        controller: _referenceController,
                        //maxLines: 99,
                        decoration: InputDecoration(
                            hintText:
                            AppLocalizations.of(context).translate('reference_no')+'*',
                            hintStyle: TextStyle(
                                color: GlobalVariables.lightGray, fontSize: 14),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(5, 20, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: _fromAccountListItems,
                    value: _selectedFromAccount,
                    onChanged: changeFromAccountDropDownItem,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('from_account')+'*',
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 16),
                    ),
                  ),
                ),
              ),
              Container(
                height: 100,
               padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _noteController,
                  keyboardType: TextInputType.text,
                  maxLines: 99,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('enter_note'),
                    hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
                    border: InputBorder.none
                  ),
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
                            width:50,
                            height: 50,
                            margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
                            decoration: attachmentFilePath==null ? BoxDecoration(
                              color: GlobalVariables.mediumGreen,
                              borderRadius: BorderRadius.circular(25),
                           //   border: Border.all(color: GlobalVariables.green,width: 2.0)

                            ) : BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: FileImage(File(attachmentFilePath)),
                                    fit: BoxFit.cover
                                ),
                                border: Border.all(color: GlobalVariables.green,width: 2.0)

                            ),
                            //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                child: FlatButton.icon(
                                  onPressed: () {

                                    if(isStoragePermission) {
                                      openFile(context);
                                    }else{
                                      GlobalFunctions.askPermission(Permission.storage).then((value) {
                                        if(value){
                                          openFile(context);
                                        }else{
                                          GlobalFunctions.showToast(AppLocalizations.of(context).translate('download_permission'));
                                        }
                                      });
                                    }

                                  },
                                  icon: Icon(
                                    Icons.attach_file,
                                    color: GlobalVariables.mediumGreen,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context).translate('attach_photo'),
                                    style: TextStyle(color: GlobalVariables.green),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Text(
                                  'OR',
                                  style: TextStyle(color: GlobalVariables.lightGray),
                                ),
                              ),
                              Container(
                                child: FlatButton.icon(
                                    onPressed: () {

                                      if(isStoragePermission) {
                                        openCamera(context);
                                      }else{
                                        GlobalFunctions.askPermission(Permission.storage).then((value) {
                                          if(value){
                                            openCamera(context);
                                          }else{
                                            GlobalFunctions.showToast(AppLocalizations.of(context).translate('download_permission'));
                                          }
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: GlobalVariables.mediumGreen,
                                    ),
                                    label: Text(
                                      AppLocalizations.of(context).translate('take_picture'),
                                      style: TextStyle(color: GlobalVariables.green),
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
                child: ButtonTheme(
                 // minWidth: MediaQuery.of(context).size.width/2,
                  child: RaisedButton(
                    color: GlobalVariables.green,
                    onPressed: () {

                      verifyInfo();

                    },
                    textColor: GlobalVariables.white,
                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),side: BorderSide(color: GlobalVariables.green)
                    ),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('submit'),
                      style: TextStyle(
                          fontSize: GlobalVariables.largeText),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void verifyInfo() {

  /*  if(_nameController.text.length>0){

     // if(_dobController.text.length>0){

        if(_mobileController.text.length>0){

        //  if(_emailController.text.length>0){

          //  if(_selectedBloodGroup!=null || _selectedBloodGroup.length>0){

             // if(_occupationController.text.length>0){

                  if(_selectedMembershipType!=null) {

                    if(_selectedLivesHere!=null) {

                      //addMember();

                    }else{
                      GlobalFunctions.showToast('Please Select Lives Here');
                    }
                  }else{
                    GlobalFunctions.showToast('Please Select MemberShip Type');
                  }

             *//* }else{
                GlobalFunctions.showToast('Please Enter Occupation');
              }*//*
            *//*}else{
              GlobalFunctions.showToast('Please Select BloodGroup');
            }*//*
          *//*}else{
            GlobalFunctions.showToast('Please Enter EmailId');
          }*//*
        }else{
          GlobalFunctions.showToast('Please Enter Mobile Number');
        }
      *//*}else{
        GlobalFunctions.showToast('Please Select Date of Birth');
      }*//*
    }else{
      GlobalFunctions.showToast('Please Enter Name');
    }*/

  }

/*  Future<void> addMember() async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();

    String attachmentName;
    String attachment;

    if(attachmentFileName!=null && attachmentFilePath!=null){
      attachmentName = attachmentFileName;
      attachment = GlobalFunctions.convertFileToString(attachmentCompressFilePath);
      GlobalFunctions.removeFileFromDirectory(attachmentCompressFilePath);
    }

    print('attachment lengtth : '+attachment.length.toString());

    _progressDialog.show();
    restClient.addMember(societyId, block, flat, _nameController.text, _selectedGender, _dobController.text, _emailController.text,
        _mobileController.text, _selectedBloodGroup, _occupationController.text, '',_selectedMembershipType,_infoController.text,attachment).then((value) {
          print('add member Status value : '+value.toString());
          _progressDialog.hide();
          if(value.status){
            Navigator.of(context).pop();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BaseMyUnit(
                        AppLocalizations.of(context).translate('my_household'))));
          }
          GlobalFunctions.showToast(value.message);


    })*//*.catchError((Object obj) {
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
    })*//*;

  }*/

  void openFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentFilePath=value;
      getCompressFilePath();
    });

  }

  void openCamera(BuildContext context) {
    GlobalFunctions.openCamera().then((value) {
      attachmentFilePath=value.path;
      getCompressFilePath();
    });
  }

  void getCompressFilePath(){
    attachmentFileName = attachmentFilePath.substring(attachmentFilePath.lastIndexOf('/')+1,attachmentFilePath.length);
    print('file Name : '+attachmentFileName.toString());
    GlobalFunctions.getTemporaryDirectoryPath().then((value) {
      print('cache file Path : '+value.toString());
      GlobalFunctions.getFilePathOfCompressImage(attachmentFilePath, value.toString()+'/'+attachmentFileName).then((value) {
        attachmentCompressFilePath = value.toString();
        print('Cache file path : '+attachmentCompressFilePath);
        setState(() {
        });
      });
    });
  }


  void getPaidByData() {
    _paidByList = ["Cash","Cheque","NEFT/IMPS/UPI"];
    for(int i=0;i<_paidByList.length;i++){
      _paidByListItems.add(DropdownMenuItem(
        value: _paidByList[i],
        child: Text(
          _paidByList[i],
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));
    }
  }


  void changeLedgerAccountDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedLedgerAccount = value;
      print('_selctedItem:' + _selectedLedgerAccount.toString());
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
      _selectedFromAccount = value;
      print('_selctedItem:' + _selectedFromAccount.toString());
    });
  }



}
