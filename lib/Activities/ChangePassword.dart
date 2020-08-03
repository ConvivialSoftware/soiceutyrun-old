import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

import 'DashBoard.dart';

class BaseChangePassword extends StatefulWidget {

  //String memberType;
  //BaseChangePassword(this.memberType);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ChangePasswordState();
  }
}

class ChangePasswordState extends State<BaseChangePassword> {

  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

ProgressDialog _progressDialog;
  @override
  Widget build(BuildContext context) {

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
            AppLocalizations.of(context).translate('create_new_password'),
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
                getChangePasswordLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getChangePasswordLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 40),
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
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('new_password'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                      onPressed: () {
                        if (_obscureNewPassword) {
                          _obscureNewPassword = false;
                        } else {
                          _obscureNewPassword = true;
                        }
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: GlobalVariables.lightGreen,
                      ),
                    ),
                  ),

                ),
              ),
              Container(
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
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('confirm_password'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
                      border: InputBorder.none,
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (_obscureConfirmPassword) {
                          _obscureConfirmPassword = false;
                        } else {
                          _obscureConfirmPassword = true;
                        }
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: GlobalVariables.lightGreen,
                      ),
                    ),
                  ),
                ),
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
                      verifyPassword();
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

  Future<void> changePassword() async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();

    _progressDialog.show();
    restClient.changeNewPassword(societyId,userId,_confirmPasswordController.text).then((value) {

      print('changeNewPassword value : '+value.toString());
      GlobalFunctions.showToast(value.message);
      _progressDialog.hide();
      if(value.status)
      {

        GlobalFunctions.savePasswordToSharedPreferences(_confirmPasswordController.text);
        //TODO: send FirebaseToken To Server

      //TODO: Navigate To DashBoardPage

        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new BaseDashBoard()),
                (Route<dynamic> route) => false);
      }



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

  void verifyPassword() {

    if(_newPasswordController.text.length>0){
      if(_confirmPasswordController.text.length>0){
        if(_newPasswordController.text==_confirmPasswordController.text){
          changePassword();
        }else{
          GlobalFunctions.showToast("Confirm Password doesn't match with New Password..!!");
        }
      }else{
        GlobalFunctions.showToast("Invalid Confirm Password");
      }
    }else{
      GlobalFunctions.showToast("Please Enter New Password");
    }


  }
}
