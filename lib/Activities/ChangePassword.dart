import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'DashBoard.dart';
import 'base_stateful.dart';

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
  String? lastLogin;

  ProgressDialog? _progressDialog;

  @override
  void initState() {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    getLastLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
      builder: (context) =>
          Scaffold(
        appBar: CustomAppBar(
              leading: InkWell(
                onTap: () {
                  getNavigatePage();
                },
                child: AppIcon(
                  Icons.arrow_back,
                  iconColor: GlobalVariables.white,
                ),
              ),
          title: AppLocalizations.of(context).translate('create_new_password'),
              ),
        body: WillPopScope(
            child: getBaseLayout(),
            onWillPop: () async {
              getNavigatePage();
              return false;
            }),
          ),
    );
  }

  getBaseLayout() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery
          .of(context)
          .size
          .height,
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
                AppLocalizations.of(context).translate('new_password'),
                controllerCallback: _newPasswordController,
                obscureText: _obscureNewPassword,
                suffixIcon: AppIconButton(
                  Icons.remove_red_eye,
                  iconColor: GlobalVariables.secondaryColor,
                  onPressed: () {
                    if (_obscureNewPassword) {
                      _obscureNewPassword = false;
                    } else {
                      _obscureNewPassword = true;
                    }
                    setState(() {});
                  },
                ),
              ),
              /* Container(
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

                      },
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: GlobalVariables.lightGreen,
                      ),
                    ),
                  ),

                ),
              ),*/
              AppTextField(
                textHintContent:
                AppLocalizations.of(context).translate('confirm_password'),
                controllerCallback: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                suffixIcon: AppIconButton(
                  Icons.remove_red_eye,
                  iconColor: GlobalVariables.secondaryColor,
                  onPressed: () {
                    if (_obscureConfirmPassword) {
                      _obscureConfirmPassword = false;
                    } else {
                      _obscureConfirmPassword = true;
                    }
                    setState(() {});
                  },
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                height: 45,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: AppButton(
                  textContent: AppLocalizations.of(context).translate('submit'),
                  onPressed: () {
                    verifyPassword();
                  },
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

    _progressDialog!.show();
    restClient.changeNewPassword(
        societyId, userId, _confirmPasswordController.text).then((value) {
      print('changeNewPassword value : ' + value.toString());
      GlobalFunctions.showToast(value.message!);
      _progressDialog!.dismiss();
      if (value.status!) {
        GlobalFunctions.savePasswordToSharedPreferences(
            _confirmPasswordController.text);
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
            _progressDialog!.dismiss();
          }
          break;
        default:
      }
    });
  }

  void verifyPassword() {
    if (_newPasswordController.text.length > 0) {
      if (_confirmPasswordController.text.length > 0) {
        if (_newPasswordController.text == _confirmPasswordController.text) {
          changePassword();
        } else {
          GlobalFunctions.showToast(
              "Confirm Password doesn't match with New Password..!!");
        }
      } else {
        GlobalFunctions.showToast("Invalid Confirm Password");
      }
    } else {
      GlobalFunctions.showToast("Please Enter New Password");
    }
  }

  Future<void> getLastLogin() async {
    lastLogin = await GlobalFunctions.getLastLogin();
  }

  void getNavigatePage() {
    if (lastLogin == GlobalVariables.ZeroTimeLine) {
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => BaseDashBoard()),
              (Route<dynamic> route) => false);
    }else {
      Navigator.of(context).pop();
    }
  }
}
