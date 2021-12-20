import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ndialog/ndialog.dart';
import 'package:societyrun/Activities/AboutSocietyRun.dart';
import 'package:societyrun/Activities/AppNotificationSettings.dart';
import 'package:societyrun/Activities/ChangePassword.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/Feedback.dart';
import 'package:societyrun/Activities/LoginPage.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseAppSettings extends StatefulWidget {
  @override
  _BaseAppSettingsState createState() => _BaseAppSettingsState();
}

class _BaseAppSettingsState extends State<BaseAppSettings> {
  var userId = "", name = "", photo = "", societyId = "", flat = "", block = "";
  var email = '', phone = '', consumerId = '', societyName = '';

  @override
  void initState() {
    super.initState();
    getSharedPreferenceData();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.primaryColor,
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
            AppLocalizations.of(context).translate('settings'),
            textColor: GlobalVariables.white, fontSize: GlobalVariables.textSizeMedium
          ),
        ),
        body: getBaseLayout(),
        bottomNavigationBar: appDetailsLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Container(
      width: MediaQuery.of(context).size.width,
      //height: double.maxFinite,
      //height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 150.0),
                getAppSettingsLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getAppSettingsLayout() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            profileLayout(),
            appNotificationSettingsLayout(),
            //loggedSocietyDetails(),
            changePasswordLayout(),
            aboutUsLayout(),
            feedbackLayout(),
            logoutLayout(),
          ],
        ),
      ),
    );
  }

  appNotificationSettingsLayout() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BaseAppNotificationSettings()));
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(18, 20, 18, 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: SvgPicture.asset(
                GlobalVariables.appSettingsIconPath,
                width: 25,
                height: 25,
                color: GlobalVariables.grey,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: text(
                  AppLocalizations.of(context)
                      .translate('app_notification_settings'),
                  fontSize: GlobalVariables.textSizeMedium, fontWeight: FontWeight.w500
                ),
              ),
            ),
            Container(
              child: AppIcon(
                Icons.arrow_forward_ios,
                iconSize: GlobalVariables.textSizeLargeMedium,
                iconColor: GlobalVariables.grey,
              ),
            )
          ],
        ),
      ),
    );
  }

  profileLayout() {
    return InkWell(
      onTap: () {},
      child: Align(
        alignment: Alignment.center,
        child: Container(
          // height: double.infinity,
          // color: GlobalVariables.black,
          //width: MediaQuery.of(context).size.width / 1.2,
          margin: EdgeInsets.fromLTRB(
              18,
              MediaQuery.of(context).size.height / 30,
              18,
              0), //margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Card(
            shape: (RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0))),
            elevation: 2.0,
            //  shadowColor: GlobalVariables.green.withOpacity(0.3),
            //margin: EdgeInsets.all(20),
            color: GlobalVariables.white,
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AppAssetsImage(
                      GlobalVariables.whileBGPath,
                      imageHeight: 50,
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(20),
                          // alignment: Alignment.center,
                          /* decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25)),*/
                          child: photo.isEmpty
                              ? AppAssetsImage(
                                  GlobalVariables.componentUserProfilePath,
                                  imageWidth: 60.0,
                                  imageHeight: 60.0,
                                  borderColor: GlobalVariables.grey,
                                  borderWidth: 1.0,
                                  fit: BoxFit.cover,
                                  radius: 30.0,
                                )
                              : AppNetworkImage(
                                  photo,
                            imageWidth: 60.0,
                            imageHeight: 60.0,
                                  borderColor: GlobalVariables.grey,
                                  borderWidth: 1.0,
                                  fit: BoxFit.cover,
                                  radius: 30.0,
                                )),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: text(
                                  name,

                                      textColor: GlobalVariables.black,
                                      fontSize: GlobalVariables.textSizeLargeMedium,
                                      fontWeight: FontWeight.bold
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: text(
                                  block +
                                      ' ' +
                                      flat +
                                      ', '
                                          '' +
                                      societyName,
                                    fontSize: GlobalVariables.textSizeSMedium,
                                    textColor: GlobalVariables.grey,
                                ),
                              ),
                              Container(
                                child: text(
                                  email,
                                    fontSize: GlobalVariables.textSizeSMedium,
                                    textColor: GlobalVariables.grey,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: text(
                                  phone,
                                    fontSize: GlobalVariables.textSizeSMedium,
                                    textColor: GlobalVariables.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: IconButton(
                            icon: AppIcon(
                              Icons.edit,
                              iconColor: GlobalVariables.primaryColor,
                              iconSize: GlobalVariables.textSizeLarge,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BaseEditProfileInfo(
                                          userId, societyId)));
                            }),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getSharedPreferenceData() async {
    userId = await GlobalFunctions.getUserId();
    name = await GlobalFunctions.getDisplayName();
    photo = await GlobalFunctions.getPhoto();
    phone = await GlobalFunctions.getMobile();
    email = await GlobalFunctions.getUserName();
    consumerId = await GlobalFunctions.getConsumerID();
    societyName = await GlobalFunctions.getSocietyName();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();
    societyId = await GlobalFunctions.getSocietyId();

    print('UserId : ' + userId);
    print('Name : ' + name);
    print('Photo : ' + photo);
    print('Phone : ' + phone);
    print('EmailId : ' + email);
    print('ConsumerId : ' + consumerId);
    setState(() {});
  }

  loggedSocietyDetails() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: GlobalVariables.white,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: SvgPicture.asset(
              GlobalVariables.bottomBuildingIconPath,
              width: 30,
              height: 30,
              color: GlobalVariables.grey,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: text(
                block +
                    ' ' +
                    flat +
                    ','
                        '' +
                    societyName,
               fontSize: GlobalVariables.textSizeMedium, fontWeight: FontWeight.w500
              ),
            ),
          ),
          Container(
            child: AppIcon(
              Icons.arrow_forward_ios,
              iconSize: GlobalVariables.textSizeLargeMedium,
              iconColor: GlobalVariables.grey,
            ),
          )
        ],
      ),
    );
  }

  changePasswordLayout() {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BaseChangePassword()));
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(18, 10, 18, 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: SvgPicture.asset(
                GlobalVariables.changePasswordPath,
                width: 25,
                height: 25,
                color: GlobalVariables.grey,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: text(
                  AppLocalizations.of(context).translate('change_password'),
                  fontSize: GlobalVariables.textSizeMedium, fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              child: AppIcon(
                Icons.arrow_forward_ios,
                iconSize: GlobalVariables.textSizeLargeMedium,
                iconColor: GlobalVariables.grey,
              ),
            )
          ],
        ),
      ),
    );
  }

  aboutUsLayout() {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BaseAboutSocietyRunInfo()));
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(18, 10, 18, 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: SvgPicture.asset(
                GlobalVariables.aboutUsPath,
                width: 25,
                height: 25,
                color: GlobalVariables.grey,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: text(
                  AppLocalizations.of(context).translate('about_us'),
                  fontSize: GlobalVariables.textSizeMedium, fontWeight: FontWeight.w500
                ),
              ),
            ),
            Container(
              child: AppIcon(
                Icons.arrow_forward_ios,
                iconSize: GlobalVariables.textSizeLargeMedium,
                iconColor: GlobalVariables.grey,
              ),
            )
          ],
        ),
      ),
    );
  }

  feedbackLayout() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BaseFeedback()));
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(18, 10, 18, 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: SvgPicture.asset(
                GlobalVariables.feedbackIconPath,
                width: 25,
                height: 25,
                color: GlobalVariables.grey,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: text(
                  AppLocalizations.of(context).translate('feedback'),
                  fontSize: GlobalVariables.textSizeMedium, fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              child: AppIcon(
                Icons.arrow_forward_ios,
                iconSize: GlobalVariables.textSizeLargeMedium,
                iconColor: GlobalVariables.grey,
              ),
            )
          ],
        ),
      ),
    );
  }

  logoutLayout() {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: displayLogoutLayout(),
                  );
                }));
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(18, 10, 18, 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: SvgPicture.asset(
                GlobalVariables.logoutIconPath,
                width: 25,
                height: 25,
                color: GlobalVariables.grey,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: text(
                  AppLocalizations.of(context).translate('logout'),
                  fontSize: GlobalVariables.textSizeMedium, fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              child: AppIcon(
                Icons.arrow_forward_ios,
                iconSize: GlobalVariables.textSizeLargeMedium,
                iconColor: GlobalVariables.grey,
              ),
            )
          ],
        ),
      ),
    );
  }

  appDetailsLayout() {
    return Container(
      color: GlobalVariables.veryLightGray,
      height: 120,
      child: Column(
        children: [
          Container(
            child: SvgPicture.asset(
              GlobalVariables.drawerImagePath,
              height: 40,
            ),
          ),
          Container(
            margin: EdgeInsets.all(5), //  color: GlobalVariables.green,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(
                  visible: true,
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 5), //TODO: logout
                        child: GestureDetector(
                          onTap: () {
                            launch(GlobalVariables.termsConditionURL);
                          },
                          child: text(
                            AppLocalizations.of(context)
                                .translate('terms_conn'),
                            //textAlign: TextAlign.left,
                              fontSize: GlobalVariables.textSizeSMedium,
                              textColor: GlobalVariables.primaryColor,
                          ),
                        )),
                  ),
                ),
                Visibility(
                  visible: true,
                  child: Container(
                      margin: EdgeInsets.all(5),
                      //TODO: Divider
                      height: 15,
                      width: 8,
                      child: VerticalDivider(
                        color: GlobalVariables.primaryColor,
                      )),
                ),
                Visibility(
                  visible: true,
                  child: Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 5, 5), //Todo: setting
                      child: GestureDetector(
                        onTap: () {
                          launch(GlobalVariables.privacyPolicyURL);
                        },
                        child: text(
                          AppLocalizations.of(context)
                              .translate('privacy_statement'),
                          //textAlign: TextAlign.left,
                            fontSize: GlobalVariables.textSizeSMedium,
                            textColor: GlobalVariables.primaryColor,
                        ),
                      )),
                )
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.fromLTRB(0, 0, 5, 5), //Todo: setting
              child: GestureDetector(
                onTap: () {},
                child: text(
                  'Version ' + AppPackageInfo.version,
                //  textAlign: TextAlign.left,
                    fontSize: GlobalVariables.textSizeMedium,
                    textColor: GlobalVariables.black,
                ),
              )),
        ],
      ),
    );
  }

  displayLogoutLayout() {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: text(
              AppLocalizations.of(context).translate('sure_logout'),
                  fontSize: GlobalVariables.textSizeLargeMedium,
                  textColor: GlobalVariables.black,
                  fontWeight: FontWeight.bold),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        logout(context);
                      },
                      child: text(
                        AppLocalizations.of(context).translate('yes'),
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                ),
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: text(
                        AppLocalizations.of(context).translate('no'),
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  static Future<void> logout(BuildContext context) async {
    ProgressDialog _progressDialog;
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    String gcmId = await GlobalFunctions.getFCMToken();

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    _progressDialog.show();
    restClient.userLogout(societyId, userId, gcmId).then((value) {
      print('Response : ' + value.toString());
      _progressDialog.hide();
      if (value.status) {
        GlobalFunctions.clearSharedPreferenceData();
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new BaseLoginPage()),
            (Route<dynamic> route) => false);
      }
      GlobalFunctions.showToast(value.message);
    }).catchError((Object obj) {
      if (_progressDialog.isShowing()) {
        _progressDialog.hide();
      }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
  }
}
