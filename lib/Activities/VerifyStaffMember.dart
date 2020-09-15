
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/AddStaffMember.dart';
import 'package:societyrun/Activities/EditStaffMember.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'base_stateful.dart';

class BaseVerifyStaffMember extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return VerifyStaffMemberState();
  }
}

class VerifyStaffMemberState extends BaseStatefulState<BaseVerifyStaffMember> {
  ProgressDialog _progressDialog;

  TextEditingController _mobileController = TextEditingController();

  String _mobileNumber = "";

  List<Staff> _staffList = new List<Staff>();

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
          title: Text(
            AppLocalizations.of(context).translate('staff_mobile_no'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: Container(),
        bottomNavigationBar: verifyStaffMemberFabLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Container(
      //  width: MediaQuery.of(context).size.width,
      //  height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        children: <Widget>[
          Flexible(
            child: verifyStaffMemberFabLayout(),
          ),
        ],
      ),
    );
  }

  verifyStaffMemberFabLayout() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
          // color: GlobalVariables.grey,
          //margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                flex: 1,
                child:Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  margin: EdgeInsets.fromLTRB(25, 25, 0, 10),
                  child: TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 10,
                    style: TextStyle(color: GlobalVariables.black),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)
                          .translate('enter_mobile_no'),
                      hintStyle: TextStyle(
                        color: GlobalVariables.lightGray,
                      ),
                      suffixIcon: Icon(
                        Icons.phone_android,
                        color: GlobalVariables.lightGreen,
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: GlobalVariables.green,
                            width: 2.0,
                          ),
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: GlobalVariables.green, width: 2.0),
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0))),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        appendNumber('1');
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: GlobalVariables.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            )),
                        child: Text(
                          AppLocalizations.of(context).translate('one_num'),
                          style: TextStyle(
                              color: GlobalVariables.green,
                                fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        appendNumber('2');
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: GlobalVariables.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            )),
                        child: Text(
                          AppLocalizations.of(context).translate('two_num'),
                          style: TextStyle(
                              color: GlobalVariables.green,
                                fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        appendNumber('3');
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: GlobalVariables.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            )),
                        child: Text(
                          AppLocalizations.of(context).translate('three_num'),
                          style: TextStyle(
                              color: GlobalVariables.green,
                                fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        appendNumber('4');
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: GlobalVariables.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            )),
                        child: Text(
                            AppLocalizations.of(context).translate('four_num'),
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        appendNumber('5');
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: GlobalVariables.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            )),
                        child: Text(
                          AppLocalizations.of(context).translate('five_num'),
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        appendNumber('6');
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: GlobalVariables.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            )),
                        child: Text(
                          AppLocalizations.of(context).translate('six_num'),
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        appendNumber('7');
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: GlobalVariables.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            )),
                        child: Text(
                          AppLocalizations.of(context).translate('seven_num'),
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        appendNumber('8');
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: GlobalVariables.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            )),
                        child: Text(
                          AppLocalizations.of(context).translate('eight_num'),
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        appendNumber('9');
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: GlobalVariables.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            )),
                        child: Text(
                          AppLocalizations.of(context).translate('nine_num'),
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        verifyNumber();
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: GlobalVariables.green,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            )),
                        child:Icon(Icons.check,color: GlobalVariables.white,),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        appendNumber('0');
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: GlobalVariables.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            )),
                        child: Text(
                          AppLocalizations.of(context).translate('zero_num'),
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        if(_mobileController.text.length>0){
                          clearNumber();
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: GlobalVariables.transparent,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: GlobalVariables.green,
                              width: 2.0,
                            )),
                        child:Icon(Icons.backspace,color: GlobalVariables.green,),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  void appendNumber(String number) {
    _mobileNumber+=number;
    setState(() {
      _mobileController.text=_mobileNumber.toString();
    });
  }

  void verifyNumber() {

    if(_mobileNumber.length==10){

      verifyStaffMember();

    }else{
        GlobalFunctions.showToast('Invalid Mobile Number');
    }

  }

  void clearNumber() {
    setState(() {
      _mobileNumber = _mobileNumber.substring(0,_mobileNumber.length-1);
      _mobileController.text=_mobileNumber.toString();
    });
  }


  Future<void> verifyStaffMember() async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
_progressDialog.show();
    restClient.getStaffMobileVerifyData(societyId,_mobileNumber).then((value) {
        _progressDialog.hide();
      if (value.status) {
        List<dynamic> _list = value.data;

        _staffList = List<Staff>.from(_list.map((i) => Staff.fromJson(i)));
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                   BaseEditStaffMember(_staffList[0])));
        /*Dialog infoDialog = Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          child: getDialogLayout(),
        );
        showDialog(
            context: context, builder: (BuildContext context) => infoDialog);
*/

      }else{
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BaseAddStaffMember(_mobileNumber)));
      }
      GlobalFunctions.showToast(value.message);
    });

  }

  getDialogLayout() {
    
    return Container(
      padding: EdgeInsets.all(25),
      width: MediaQuery.of(context).size.width/1.2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          
          Container(
            child: Text(AppLocalizations.of(context).translate('add_staff_for_other_flat') , style: TextStyle(
              color: GlobalVariables.black,fontSize: 18
            ),),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
             // alignment: Alignment.topRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    //   alignment: Alignment.topRight,
                    child: FlatButton(onPressed: (){
                      Navigator.of(context).pop();
                    }, child: Text(AppLocalizations.of(context).translate('no'))),
                  ),
                  Container(
                  //  alignment: Alignment.topRight,
                    child: FlatButton(onPressed: (){
                      Navigator.of(context).pop();
                      addMember();
                    }, child: Text(AppLocalizations.of(context).translate('yes'))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addMember() async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();

    _progressDialog.show();
    restClient.addStaffMember(societyId, block, flat, _staffList[0].STAFF_NAME,  _staffList[0].GENDER,  _staffList[0].DOB, _mobileController.text
        ,  _staffList[0].QUALIFICATION ,  _staffList[0].ADDRESS,  _staffList[0].NOTES, userId,  _staffList[0].ROLE,  _staffList[0].IMAGE,  _staffList[0].Attachment,  _staffList[0].VEHICLE_NO).then((value) {

      _progressDialog.hide();
      if(value.status){
        Navigator.of(context).pop();
      }
      GlobalFunctions.showToast(value.message);
    });

  }

}
