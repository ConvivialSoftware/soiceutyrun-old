import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/Feedback.dart';
import 'package:societyrun/Activities/WebViewScreen.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Banners.dart';
import 'package:societyrun/Models/LoginResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseAboutSocietyRunInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AboutSocietyRunInfoState();
  }
}

class AboutSocietyRunInfoState
    extends State<BaseAboutSocietyRunInfo> {
  var societyId, name, phone, block, flat;

  // List<Banners> value.bannerList = List<Banners>();
  var response = "";

  @override
  void initState() {
    super.initState();
    getSharedPreferencesData();
    /*  GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getBannerData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return ChangeNotifierProvider<LoginDashBoardResponse>.value(
      value: Provider.of<LoginDashBoardResponse>(context),
      child: Consumer<LoginDashBoardResponse>(builder: (context, value, child) {
        return Builder(
          builder: (context) => Scaffold(
            appBar: CustomAppBar(
              title:AppLocalizations.of(context).translate('about_societyrun'),
            ),
            body: getBaseLayout(value),
          ),
        );
      }),
    );
  }

  /*getBannerData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    restClient.getBannerData().then((value) {
      print('Response : ' + value.toString());
      if (value.status) {
        List<dynamic> _list = value.data;
        print('complaint list length : ' + _list.length.toString());

        // print('first complaint : ' + _list[0].toString());
        // print('first complaint Status : ' + _list[0]['STATUS'].toString());

        value.bannerList = List<Banners>.from(_list.map((i) => Banners.fromJson(i)));
        if (this.mounted) {
          setState(() {
            //Your state change code goes here
          });
        }
      }
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
  }*/

  getBaseLayout(LoginDashBoardResponse value) {
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
                getAboutSocietyRunLayout(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getAboutSocietyRunLayout(LoginDashBoardResponse value) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(18, 40, 18, 10),
        padding: EdgeInsets.all(
            10), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: GlobalVariables.AccentColor,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              margin: EdgeInsets.all(20),
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  height: 150.0,
                  autoPlay: false,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 1.0,
                ),
                itemCount: value.bannerList.length,
                itemBuilder: (BuildContext context, int itemIndex,int item) =>
                    value.bannerList.length > 0
                        ? InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BaseWebViewScreen(
                                          value.bannerList[itemIndex].Url! +
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
                                              flat.toString())));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              decoration: boxDecoration(
                                radius: 10.0,
                              ),
                              child: AppNetworkImage(
                                value.bannerList[itemIndex].IMAGE,
                                fit: BoxFit.fitWidth,
                                shape: BoxShape.rectangle,
                                radius: 10.0,
                              ),
                            ),
                          )
                        : Container(),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        alignment: Alignment.topLeft,
                        child: text(
                            AppLocalizations.of(context)
                                .translate('develop_by'),
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeLargeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: text(
                          SocietyRun.companyName,
                          textColor: GlobalVariables.grey,
                          fontSize: GlobalVariables.textSizeMedium,
                        ),
                      ),
                      divider(),
                      /*Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 20),
                        child: Divider(
                          color: GlobalVariables.grey,
                          height: 1,
                        ),
                      )*/
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: text(
                            AppLocalizations.of(context).translate('contact'),
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeLargeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: text(
                                AppLocalizations.of(context)
                                        .translate('sales_contact') +
                                    " : ",
                                textColor: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeMedium,
                                fontWeight: FontWeight.w500),
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  launch("tel://" + SocietyRun.salesContact);
                                },
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: text(SocietyRun.salesContact,
                                      textColor: GlobalVariables.skyBlue,
                                      fontSize: GlobalVariables.textSizeMedium),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  launch("tel://" + SocietyRun.salesContact1);
                                },
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: text(SocietyRun.salesContact1,
                                      textColor: GlobalVariables.skyBlue,
                                      fontSize: GlobalVariables.textSizeMedium),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: text(
                                AppLocalizations.of(context)
                                        .translate('support_contact') +
                                    " : ",
                                textColor: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeMedium,
                                fontWeight: FontWeight.w500),
                          ),
                          InkWell(
                            onTap: () {
                              launch("tel://" + SocietyRun.supportContact);
                            },
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: text(SocietyRun.supportContact,
                                  textColor: GlobalVariables.skyBlue,
                                  fontSize: GlobalVariables.textSizeMedium),
                            ),
                          ),
                        ],
                      ),
                      divider(),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: text(
                            AppLocalizations.of(context).translate('_email'),
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeLargeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: text(
                                AppLocalizations.of(context)
                                        .translate('sales_email') +
                                    " : ",
                                textColor: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeMedium,
                                fontWeight: FontWeight.w500),
                          ),
                          InkWell(
                            onTap: () {
                              Uri _emailUri = Uri(
                                  scheme: 'mailto',
                                  path: SocietyRun.salesEmail,
                                  queryParameters: {'subject': ''});
                              launch(_emailUri.toString());
                            },
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: text(SocietyRun.salesEmail,
                                  textColor: GlobalVariables.skyBlue,
                                  fontSize: GlobalVariables.textSizeMedium),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: text(
                                AppLocalizations.of(context)
                                        .translate('support_email') +
                                    " : ",
                                textColor: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeMedium,
                                fontWeight: FontWeight.w500),
                          ),
                          InkWell(
                            onTap: () {
                              Uri _emailUri = Uri(
                                  scheme: 'mailto',
                                  path: SocietyRun.supportEmail,
                                  queryParameters: {'subject': ''});
                              launch(_emailUri.toString());
                            },
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: text(SocietyRun.supportEmail,
                                  textColor: GlobalVariables.skyBlue,
                                  fontSize: GlobalVariables.textSizeMedium),
                            ),
                          ),
                        ],
                      ),
                      divider()
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: text(
                            AppLocalizations.of(context)
                                .translate('office_address'),
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeLargeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: text(
                                  AppLocalizations.of(context)
                                          .translate('pune') +
                                      " : ",
                                  textColor: GlobalVariables.grey,
                                  fontSize: GlobalVariables.textSizeMedium,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                              child: text(SocietyRun.puneAddress,
                                  maxLine: 5,
                                  textColor: GlobalVariables.grey,
                                  fontSize: GlobalVariables.textSizeMedium),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: text(
                                    AppLocalizations.of(context)
                                            .translate('mumbai') +
                                        " : ",
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeMedium,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Flexible(
                              flex: 4,
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                                child: text(
                                  SocietyRun.mumbaiAddress,
                                  maxLine: 5,
                                  textColor: GlobalVariables.grey,
                                  fontSize: GlobalVariables.textSizeMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      divider(),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: text(
                            AppLocalizations.of(context)
                                .translate('version_code'),
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeLargeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: text(
                          AppPackageInfo.version,
                          textColor: GlobalVariables.grey,
                          fontSize: GlobalVariables.textSizeMedium,
                        ),
                      ),
                      divider(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getSharedPreferencesData() async {
    societyId = await GlobalFunctions.getSocietyId();
    name = await GlobalFunctions.getDisplayName();
    phone = await GlobalFunctions.getMobile();
    block = await GlobalFunctions.getBlock();
    flat = await GlobalFunctions.getFlat();

    setState(() {});
  }
}
