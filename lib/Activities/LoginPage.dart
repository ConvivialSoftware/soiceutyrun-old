import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:societyrun/Activities/ChangePassword.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/Activities/OtpWithMobile.dart';
import 'package:societyrun/Activities/Register.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLanguage.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Banners.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:dio/dio.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginPageState();
  }
}

class LoginPageState extends BaseStatefulState<LoginPage> {
  bool isLogin = false;
  AppLanguage appLanguage = AppLanguage();
  String? fcmToken;

  ProgressDialog? _progressDialog;

  bool _obscurePassword = true;
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  List<Banners> _bannerList = <Banners>[];

  @override
  void initState() {
    super.initState();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getBannerData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: GlobalVariables.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  GlobalFunctions.getAppHeaderWidget(context),
                  Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: RichText(
                            text: TextSpan(children: [
                          WidgetSpan(
                              child: AppAssetsImage(
                                  GlobalVariables.loginIconPath)),
                          TextSpan(
                              text: " " +
                                  AppLocalizations.of(context)
                                      .translate('login'),
                              style: TextStyle(
                                  fontSize: GlobalVariables.textSizeLargeMedium,
                                  color: GlobalVariables.primaryColor)),
                          TextSpan(
                              text: AppLocalizations.of(context)
                                  .translate('to_your_account'),
                              style: TextStyle(
                                  fontSize: GlobalVariables.textSizeLargeMedium,
                                  color: GlobalVariables.lightGray))
                        ])),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.1,
                        margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: TextField(
                          controller: username,
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: GlobalVariables.black),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)
                                .translate('email_or_mobile'),
                            hintStyle: TextStyle(
                              color: GlobalVariables.lightGray,
                            ),
                            suffixIcon: AppIcon(
                              Icons.mail,
                              iconColor: GlobalVariables.AccentColor,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalVariables.primaryColor,
                                  width: 2.0,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: GlobalVariables.primaryColor,
                                    width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.1,
                        margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: TextField(
                          controller: password,
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            color: GlobalVariables.black,
                          ),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)
                                .translate('password'),
                            hintStyle: TextStyle(
                              color: GlobalVariables.lightGray,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                if (_obscurePassword) {
                                  _obscurePassword = false;
                                } else {
                                  _obscurePassword = true;
                                }
                                setState(() {});
                              },
                              icon: AppIcon(
                                Icons.remove_red_eye,
                                iconColor: GlobalVariables.AccentColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: GlobalVariables.primaryColor,
                                    width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: GlobalVariables.primaryColor,
                                    width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            16, 16, 16, 16), // color: GlobalVariables.grey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: Container(
                                height: 45,
                                margin: EdgeInsets.fromLTRB(0, 0, 50, 0),
                                child: ButtonTheme(
                                  minWidth:
                                      MediaQuery.of(context).size.width / 2,
                                  child: MaterialButton(
                                    color: GlobalVariables.primaryColor,
                                    onPressed: () {
                                      //  username.text = 'pallaviunde@gmail.com';
                                      //   password.text = 'admin123';
                                      if (GlobalFunctions.verifyLoginData(
                                          username.text, password.text)) {
                                        GlobalFunctions
                                                .checkInternetConnection()
                                            .then((internet) {
                                          if (internet) {
                                            userLogin(username.text,
                                                password.text, context);
                                          } else {
                                            GlobalFunctions.showToast(
                                                AppLocalizations.of(context)
                                                    .translate(
                                                        'pls_check_internet_connectivity'));
                                          }
                                        });
                                      } else {
                                        GlobalFunctions.showToast(AppLocalizations
                                                .of(context)
                                            .translate(
                                                'pls_enter_valid_username_password'));
                                      }
                                    },
                                    textColor: GlobalVariables.white,
                                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                            color:
                                                GlobalVariables.primaryColor)),
                                    child: text(
                                      AppLocalizations.of(context)
                                          .translate('login'),
                                      fontSize: GlobalVariables.textSizeMedium,
                                      textColor: GlobalVariables.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BaseOtpWithMobile()));
                                  },
                                  child: text(
                                    AppLocalizations.of(context)
                                        .translate('login_with_otp'),
                                    textColor: GlobalVariables.primaryColor,
                                    fontSize: GlobalVariables.textSizeMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Visibility(
                              visible: false,
                              child: Flexible(
                                flex: 1,
                                child: Container(
                                  //color: GlobalVariables.black,
                                  child: text(
                                    AppLocalizations.of(context)
                                        .translate('forget_password'),
                                    textColor: GlobalVariables.primaryColor,
                                    fontSize:
                                        GlobalVariables.textSizeLargeMedium,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: false,
                              child: Flexible(
                                flex: 1,
                                child: Container(
                                  //  height: 45,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.topRight,
                                        child: text(
                                            AppLocalizations.of(context)
                                                .translate("don't_hv_acc"),
                                            textColor: GlobalVariables.black,
                                            fontSize:
                                                GlobalVariables.textSizeMedium,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      Container(
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BaseRegister()));
                                          },
                                          child: text(
                                              AppLocalizations.of(context)
                                                  .translate('register'),
                                              textColor:
                                                  GlobalVariables.primaryColor,
                                              fontSize: GlobalVariables
                                                  .textSizeLargeMedium,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),

                                  /*RichText(text: TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: AppLocalizations.of(context).translate("don't_hv_acc")+"\n",style: TextStyle(
                                                  color: GlobalVariables.black,fontSize: 16,fontWeight: FontWeight.w300
                                              )
                                              ),
                                              TextSpan(
                                                  text: AppLocalizations.of(context).translate('register'),style: TextStyle(
                                                color: GlobalVariables.green,fontSize: 18,fontWeight: FontWeight.bold,
                                              ),recognizer: TapGestureRecognizer()..onTap=(){
                                                Navigator.push(context, MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChangeLanguageNotifier.title(
                                                            GlobalVariables.RegisterPage)));
                                              }
                                              ),
                                            ]
                                        )),*/
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    //color: GlobalVariables.grey,
                    decoration: boxDecoration(
                      radius: GlobalVariables.textSizeVerySmall,
                    ),
                    margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: CarouselSlider.builder(
                      options: CarouselOptions(
                        height: 200.0,
                        autoPlay: false,
                        autoPlayInterval: Duration(seconds: 3),
                        viewportFraction: 1.0,
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                      ),
                      itemCount: _bannerList.length,
                      itemBuilder: (BuildContext context, int itemIndex,
                              int item) =>
                          _bannerList.length > 0
                              ? InkWell(
                                  onTap: () {
                                    /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BaseWebViewScreen(
                                      _bannerList[itemIndex].Url +
                                          '?' +
                                          'SID=' +
                                          societyId.toString() +
                                          '&MOBILE=' +
                                          phone.toString() +
                                          '&NAME=' +
                                          name.toString() +
                                          '&UNIT=' +
                                          block.toString() +
                                          ' ' +
                                          flat.toString()))).then(
                                  (value) {
                                GlobalFunctions.setBaseContext(
                                    _dashboardSacfoldKey.currentContext);
                              });*/
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    //color: GlobalVariables.black,
                                    //alignment: Alignment.center,
                                    child: AppNetworkImage(
                                      _bannerList[itemIndex].IMAGE,
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
                  /*Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.fromLTRB(
                        20, MediaQuery.of(context).size.height / 8, 20, 10),
                    //color: GlobalVariables.orangeAccent,
                    //margin: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              color: GlobalVariables.mediumGreen,
                              borderRadius:
                              BorderRadius.all(Radius.circular(10))),
                          margin: EdgeInsets.fromLTRB(0, 30, 0, 15),
                          child: CarouselSlider.builder(
                            options: CarouselOptions(height: 200.0, autoPlay: false,
                              autoPlayInterval: Duration(seconds: 3),
                              viewportFraction: 1.0,
                              autoPlayAnimationDuration: Duration(
                                  milliseconds: 800),
                            ),
                            itemCount: _bannerList.length,
                            itemBuilder: (BuildContext context, int itemIndex,int item) =>
                            _bannerList.length> 0 ? InkWell(
                              onTap: (){
                                //launch(_bannerList[itemIndex].Url);
                                Navigator.push(context, MaterialPageRoute(builder:  (context) => BaseWebViewScreen(_bannerList[itemIndex].Url)));
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                //color: GlobalVariables.black,
                                //alignment: Alignment.center,
                                child: AppNetworkImage(_bannerList[itemIndex].IMAGE,fit: BoxFit.fitWidth,shape: BoxShape.rectangle,),
                              ),
                            ): Container(),
                          ),
                        ),
                        */ /*Container(

                          //   color: GlobalVariables.lightGreen,
                          decoration: BoxDecoration(
                              color: GlobalVariables.lightGreen,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: SvgPicture.asset(
                                    GlobalVariables.classifiedBigIconPath),
                              ),
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: RichText(
                                          text: TextSpan(
                                              text: AppLocalizations.of(context)
                                                  .translate('classified_ads'),
                                              style: TextStyle(
                                                  color: GlobalVariables.green,
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                      child: RichText(
                                          text: TextSpan(
                                              text: AppLocalizations.of(context)
                                                  .translate('classified_str'),
                                              style: TextStyle(
                                                  color: GlobalVariables.black,
                                                  fontSize: 15))),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),*/ /*
                        Container(
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: AppLocalizations.of(context)
                                    .translate('pre_terms_conn'),
                                style: TextStyle(color: GlobalVariables.black),
                            ),
                            TextSpan(
                                text: AppLocalizations.of(context)
                                    .translate('terms_conn'),
                                style: TextStyle(color: GlobalVariables.green),
                                recognizer: TapGestureRecognizer()..onTap=(){

                                  launch(GlobalVariables.termsConditionURL);
                            }),
                          ])),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: AppLocalizations.of(context)
                                    .translate('pre_privacy_statement'),
                                style: TextStyle(color: GlobalVariables.black)),
                            TextSpan(
                                text: AppLocalizations.of(context)
                                    .translate('privacy_statement'),
                                style: TextStyle(color: GlobalVariables.green),
                                recognizer: TapGestureRecognizer()..onTap=(){

                                  launch(GlobalVariables.privacyPolicyURL);

                                }),
                          ])),
                        )
                      ],
                    ),
                  )*/
                ],
              ),
            )),
      ),
    );
  }

  void userLogin(String username, String password, BuildContext context) async {
    fcmToken = await GlobalFunctions.getGCMToken();
    final dio = Dio();
    final restClient = RestClient(dio);
    //  var date = GlobalFunctions.getAppLanguage();

    _progressDialog!.show();
    restClient.getLogin(username, password, fcmToken!).then((value) {
      print('status : ' + value.status.toString());
      GlobalFunctions.showToast(value.message!);
      _progressDialog!.dismiss();
      if (value.status!) {
        value.PASSWORD = password;
        value.LoggedUsername = username;
        GlobalFunctions.saveDataToSharedPreferences(value);

        if (value.LAST_LOGIN == GlobalVariables.ZeroTimeLine) {
          Navigator.pushAndRemoveUntil(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => BaseChangePassword()),
              (Route<dynamic> route) => false);
        } else {
          //TODO: Navigate To DashBoardPage
          Navigator.pushAndRemoveUntil(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => BaseDashBoard()),
              (Route<dynamic> route) => false);
        }
      }
    }).catchError((Object obj) {
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

  getBannerData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    restClient.getBannerData().then((value) {
      print('Response : ' + value.toString());
      if (value.status!) {
        List<dynamic> _list = value.front!;
        print('complaint list length : ' + _list.length.toString());

        // print('first complaint : ' + _list[0].toString());
        // print('first complaint Status : ' + _list[0]['STATUS'].toString());

        _bannerList = List<Banners>.from(_list.map((i) => Banners.fromJson(i)));
        if (this.mounted) {
          setState(() {
            //Your state change code goes here
          });
        }
      }
    }).catchError((Object obj) {
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

  getThemeData() {
    return ThemeData(
        primaryColor: GlobalVariables.primaryColor,
        primaryColorDark: GlobalVariables.primaryColor,
        textSelectionTheme:
            TextSelectionThemeData(cursorColor: GlobalVariables.secondaryColor),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: GlobalVariables.white));
  }
}
