import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/LoginResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseReferAndEarn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ReferAndEarnState();
  }
}

class ReferAndEarnState extends BaseStatefulState<BaseReferAndEarn> {
  TextEditingController _societyNameController = TextEditingController();
  TextEditingController _noOfFlatsController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  ProgressDialog _progressDialog;
  final ContactPicker _contactPicker = ContactPicker();
  Contact _contact;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //GlobalFunctions.showToast(memberType.toString());
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return ChangeNotifierProvider<LoginDashBoardResponse>.value(
        value: Provider.of<LoginDashBoardResponse>(context),
      child: Consumer<LoginDashBoardResponse>(builder: (context,value,child){
        return Builder(
          builder: (context) => Scaffold(
            backgroundColor: GlobalVariables.veryLightGray,
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
              title: text(AppLocalizations.of(context).translate('refer_earn'),
                  textColor: GlobalVariables.white,
                  fontSize: GlobalVariables.textSizeMedium),
            ),
            body: getBaseLayout(value),
          ),
        );
      }),
    );
  }

  getBaseLayout(LoginDashBoardResponse value) {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 200.0),
        getReferAndEarnLayout(value),
      ],
    );
  }

  getReferAndEarnLayout(LoginDashBoardResponse loginDashBoardResponse) {
    return SingleChildScrollView(
      child: AppContainer(
        child: Column(
          children: <Widget>[
            Container(
              //color: GlobalVariables.grey,
              decoration: boxDecoration(
                radius: GlobalVariables.textSizeVerySmall,
              ),
             // margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: false,
                  autoPlayInterval: Duration(seconds: 3),
                  viewportFraction: 1.0,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                ),
                itemCount: loginDashBoardResponse.referBannerList.length,
                itemBuilder: (BuildContext context, int itemIndex,
                    int item) =>
                loginDashBoardResponse.referBannerList.length > 0
                    ? InkWell(
                  onTap: () {

                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    //color: GlobalVariables.black,
                    //alignment: Alignment.center,
                    child: AppNetworkImage(
                      loginDashBoardResponse
                          .referBannerList[itemIndex].IMAGE,
                      fit: BoxFit.fitWidth,
                      shape: BoxShape.rectangle,
                      borderColor: GlobalVariables.transparent,
                      radius: GlobalVariables.textSizeVerySmall,
                    ),
                  ),
                )
                    : Container(),
              ),
            ),
            AppTextField(
              textHintContent: 'Society Name' + '*',
              controllerCallback: _societyNameController,
            ),
            AppTextField(
              textHintContent: 'No of. Flats',
              controllerCallback: _noOfFlatsController,
              keyboardType: TextInputType.number,
            ),
            Container(
              height: 100,
              child: AppTextField(
                textHintContent:'Society Address'+'*',
                controllerCallback: _addressController,
                maxLines: 99,
                contentPadding: EdgeInsets.only(top: 14),
              ),
            ),
            AppTextField(
              textHintContent:
                  AppLocalizations.of(context).translate('name') + '*',
              controllerCallback: _nameController,
            ),
            AppTextField(
              textHintContent:
                  AppLocalizations.of(context).translate('contact1') + '*',
              controllerCallback: _mobileController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              contentPadding: EdgeInsets.only(top: 14),
              suffixIcon: AppIconButton(
                Icons.phone_android,
                iconColor: GlobalVariables.mediumGreen,
                onPressed: () async {
                  Contact contact = await _contactPicker.selectContact();
                  print('contact Name : ' + contact.fullName);
                  print('contact Number : ' +
                      contact.phoneNumber.toString());
                  _contact = contact;
                  setState(() {
                    if (_contact != null) {
                      //  _nameController.text = _contact.fullName;
                      String phoneNumber = _contact.phoneNumber
                          .toString()
                          .substring(
                          0,
                          _contact.phoneNumber
                              .toString()
                              .indexOf('(') -
                              1);
                      _mobileController.text = GlobalFunctions.getMobileFormatNumber(phoneNumber.toString());
                      // _nameController.selection = TextSelection.fromPosition(TextPosition(offset: _nameController.text.length));
                    }
                  });
                },
              ),
            ),
            AppTextField(
              textHintContent:
                  AppLocalizations.of(context).translate('email_id'),
              controllerCallback: _emailController,
              keyboardType: TextInputType.emailAddress,
              contentPadding: EdgeInsets.only(top: 14),
              suffixIcon: AppIconButton(
                Icons.email,
                iconColor: GlobalVariables.mediumGreen,
              ),
            ),
            Container(
              height: 100,
              child: AppTextField(
                textHintContent: 'Message',
                controllerCallback: _messageController,
                maxLines: 99,
                contentPadding: EdgeInsets.only(top: 14),
              ),
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
    );
  }

  void verifyInfo() {
    if (_societyNameController.text.length > 0) {
      if (_nameController.text.length > 0) {
        if (_mobileController.text.length > 0) {
          //  if(_emailController.text.length>0){

          //  if(_selectedBloodGroup!=null || _selectedBloodGroup.length>0){

          // if(_occupationController.text.length>0){

          addMember();

          /* }else{
                GlobalFunctions.showToast('Please Enter Occupation');
              }*/
          /*}else{
              GlobalFunctions.showToast('Please Select BloodGroup');
            }*/
          /*}else{
            GlobalFunctions.showToast('Please Enter EmailId');
          }*/
        } else {
          GlobalFunctions.showToast('Please Enter Mobile Number');
        }
      } else {
        GlobalFunctions.showToast('Please Enter you name');
      }
    } else {
      GlobalFunctions.showToast('Please Enter Society Name');
    }
  }

  Future<void> addMember() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String loggedSocietyName = await GlobalFunctions.getSocietyName();
    String loggedFlat = await GlobalFunctions.getFlat();
    String loggedUser = await GlobalFunctions.getDisplayName();
    String loggedPhone = await GlobalFunctions.getMobile();
    _progressDialog.show();
    restClient.referAndEarn(societyId, _societyNameController.text, _noOfFlatsController.text,
        _addressController.text, _nameController.text, _mobileController.text,
        _emailController.text, _messageController.text,
    loggedSocietyName,loggedFlat,loggedUser,loggedPhone).then((value) {
      GlobalFunctions.showToast(value.message);
      _progressDialog.hide();
      //GlobalFunctions.showToast(value.status.runtimeType.toString());
      if(value.status){
        print('value true');
        Navigator.of(context).pop();
        print('value navigate');
      }
    });

  }

}
