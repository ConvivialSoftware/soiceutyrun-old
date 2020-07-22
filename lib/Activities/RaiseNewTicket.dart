import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ComplaintArea.dart';
import 'package:societyrun/Models/ComplaintCategory.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

import 'HelpDesk.dart';

class BaseRaiseNewTicket extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RaiseNewTicketState();
  }
}

class RaiseNewTicketState extends State<BaseRaiseNewTicket> {

  List<ComplaintArea> _areaList = new List<ComplaintArea>();
  List<ComplaintCategory> _categoryList = new List<ComplaintCategory>();
  String complaintType="Personal";
  String complaintPriority="No";

  TextEditingController complaintSubject =  TextEditingController();

  TextEditingController complaintDesc = TextEditingController();



  List<DropdownMenuItem<String>> __areaListItems = new List<DropdownMenuItem<String>>();
  String _areaSelectedItem;


  List<DropdownMenuItem<String>> __categoryListItems =
  new List<DropdownMenuItem<String>>();

  String _categorySelectedItem;

  String attachmentFilePath;
  String attachmentFileName;

  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getComplaintAreaData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });

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
          title: Text(
            AppLocalizations.of(context).translate('help_desk'),
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
                getRaiseTicketLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getRaiseTicketLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 40, 20, 40),
        padding: EdgeInsets.all(
            20), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  AppLocalizations.of(context).translate('raise_new_ticket'),
                  style: TextStyle(
                      color: GlobalVariables.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
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
                  controller: complaintSubject,
                  //maxLines: 99,
                  decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context).translate('subject'),
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                      border: InputBorder.none),
                ),
              ),
              /*Container(
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
                    items: null,
                    onChanged: null,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('flat_no'),
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 12),
                    ),
                  ),
                ),
              ),*/
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {
/*
                          AppLocalizations.of(context)
                              .translate('personal')*/
                          complaintType = "Personal";
                          setState(() {

                          });

                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: complaintType== "Personal" ? GlobalVariables.green : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: complaintType== "Personal" ? GlobalVariables.green : GlobalVariables.mediumGreen,
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('personal'),
                                  style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {

                          complaintType = "Community";
                          setState(() {

                          });

                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: complaintType!= "Personal" ? GlobalVariables.green : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: complaintType!= "Personal" ? GlobalVariables.green : GlobalVariables.mediumGreen,
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('community'),
                                  style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
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
                    items: __areaListItems,
                    value: _areaSelectedItem,
                    onChanged: changeAreaDropDownItem,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('select_area'),
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                    ),
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
                    items: __categoryListItems,
                    value: _categorySelectedItem,
                    onChanged: changeCategoryDropDownItem,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('select_category'),
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                    ),
                  ),
                ),
              ),
              Container(
                height: 150,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: TextField(
                  controller: complaintDesc,
                  maxLines: 99,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)
                          .translate('complaint_desc'),
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                      border: InputBorder.none),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: FlatButton.icon(
                        onPressed: () {

                          openFile(context);

                        },
                        icon: Icon(
                          Icons.attach_file,
                          color: GlobalVariables.mediumGreen,
                        ),
                        label: Text(
                          AppLocalizations.of(context).translate('attach_file'),
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

                            openCamera(context);

                          },
                          icon: Icon(
                            Icons.camera_alt,
                            color: GlobalVariables.mediumGreen,
                          ),
                          label: Text(
                            AppLocalizations.of(context)
                                .translate('take_picture'),
                            style: TextStyle(color: GlobalVariables.green),
                          )),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  attachmentFileName==null ? "" : attachmentFileName,
                  style: TextStyle(
                      color: GlobalVariables.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    InkWell(
                       onTap:(){
                         complaintPriority=="No" ? complaintPriority="Yes" : complaintPriority="No";
                         setState(() {
                         });
                       } ,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                           color:  complaintPriority=="No" ?  GlobalVariables.white:GlobalVariables.green,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: complaintPriority=="No" ?  GlobalVariables.mediumGreen : GlobalVariables.transparent,
                              width: 2.0,
                            )),
                        child: Icon(Icons.check, color: GlobalVariables.white),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('mark_as_urgent'),
                        style: TextStyle(
                            color: GlobalVariables.green, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              /*  Container(
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
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('for_flat_number'),
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                    ),
                  ),
                ),
              ),*/
              Container(
                alignment: Alignment.topLeft,
                height: 45,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: ButtonTheme(
                  // minWidth: MediaQuery.of(context).size.width/2,
                  child: RaisedButton(
                    color: GlobalVariables.green,
                    onPressed: () {

                      verifyData();

                    },
                    textColor: GlobalVariables.white,
                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: GlobalVariables.green)),
                    child: Text(
                      AppLocalizations.of(context).translate('submit'),
                      style: TextStyle(fontSize: GlobalVariables.largeText),
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


  void changeAreaDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _areaSelectedItem = value;
      print('_selctedItem:' + _areaSelectedItem.toString());
    });
  }


  void changeCategoryDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _categorySelectedItem = value;
      print('_selctedItem:' + _categorySelectedItem.toString());
    });
  }

  void getComplaintAreaData() async{

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getComplaintsAreaData(societyId).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;

      //  print("area list : "+_list.toString());
        _areaList = List<ComplaintArea>.from(_list.map((i)=>ComplaintArea.fromJson(i)));

        for(int i=0;i<_areaList.length;i++){
          __areaListItems.add(DropdownMenuItem(
            value: _areaList[i].COMPLAINT_AREA,
            child: Text(
              _areaList[i].COMPLAINT_AREA,
              style: TextStyle(color: GlobalVariables.green),
            ),
          ));
        }
     //   _areaSelectedItem = __areaListItems[0].value;
       getComplaintCategoryData();
      }
    });

  }


  void getComplaintCategoryData() async{

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    restClient.getComplaintsCategoryData(societyId).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;
      //  print("category list : "+_list.toString());
        _categoryList = List<ComplaintCategory>.from(_list.map((i)=>ComplaintCategory.fromJson(i)));

        for(int i=0;i<_categoryList.length;i++){
          __categoryListItems.add(DropdownMenuItem(
            value: _categoryList[i].COMPLAINT_CATEGORY,
            child: Text(
              _categoryList[i].COMPLAINT_CATEGORY,
              style: TextStyle(color: GlobalVariables.green),
            ),
          ));
        }
        //_categorySelectedItem = __categoryListItems[0].value;

        setState(() {
        });
      }
      _progressDialog.hide();
    });

  }

  Future<void> addComplaint() async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();
    String name = await GlobalFunctions.getDisplayName();

    String societyName = await GlobalFunctions.getSocietyName();
    String societyEmail = await GlobalFunctions.getSocietyEmail();
    String userEmail = await GlobalFunctions.getUserName();

    String attachmentName;
    String attachment;

    if(attachmentFileName!=null && attachmentFilePath!=null){
      attachmentName = attachmentFileName;
      attachment = GlobalFunctions.convertFileToString(attachmentFilePath);
    }
    _progressDialog.show();
    restClient.addComplaint(societyId, block,flat,userId,complaintSubject.text,complaintType,_areaSelectedItem,_categorySelectedItem,
    complaintDesc.text,complaintPriority,name,attachment,attachmentName,societyName,userEmail,societyEmail).then((value) {
      print("add complaint response : "+ value.toString());
      _progressDialog.hide();
      if(value.status){
        Navigator.of(context).pop();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BaseHelpDesk()));
      }
      GlobalFunctions.showToast(value.message);

    });
  }

  void openFile(BuildContext context) {

     GlobalFunctions.getFilePath(context).then((value) {
       attachmentFilePath=value;

       print('file Path : '+attachmentFilePath.toString());
/*  /storage/emulated/0/Pictures/Screenshots/Screenshot_20200515-105610.jpg   */

     attachmentFileName = attachmentFilePath.substring(attachmentFilePath.lastIndexOf('/')+1,attachmentFilePath.length);
       print('file Name : '+attachmentFileName.toString());

       setState(() {
       });

// https://societyrun.com//Uploads/278808_2019-08-16_12:45:09.jpg

     });

  }

  void openCamera(BuildContext context) {

    GlobalFunctions.openCamera().then((value) {

      attachmentFilePath=value.path;

      print('file Path : '+attachmentFilePath.toString());
/*  /storage/emulated/0/Pictures/Screenshots/Screenshot_20200515-105610.jpg   */

      attachmentFileName = attachmentFilePath.substring(attachmentFilePath.lastIndexOf('/')+1,attachmentFilePath.length);
      print('file Name : '+attachmentFileName.toString());

    });


  }

  void verifyData() {


    if(complaintSubject.text.length>0){

      if(_areaSelectedItem!=null){

        if(_categorySelectedItem!=null){

          if(complaintDesc.text.length>0){

            addComplaint();

          }else{
            GlobalFunctions.showToast("Please Enter Complaint Description");
          }


        }else{
          GlobalFunctions.showToast("Please Select Complaint Category");
        }


      }else{
        GlobalFunctions.showToast("Please Select Complaint Area");
      }

    }else{
      GlobalFunctions.showToast("Please Enter Complaint Subject");
    }


  }




}
