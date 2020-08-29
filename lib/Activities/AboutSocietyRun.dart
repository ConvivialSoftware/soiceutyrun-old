import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/Feedback.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Banners.dart';
import 'package:societyrun/Models/ComplaintArea.dart';
import 'package:societyrun/Models/ComplaintCategory.dart';
import 'package:societyrun/Models/ProfileInfo.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:url_launcher/url_launcher.dart';

import 'HelpDesk.dart';

class BaseAboutSocietyRunInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AboutSocietyRunInfoState();
  }
}

class AboutSocietyRunInfoState extends BaseStatefulState<BaseAboutSocietyRunInfo> {

  ProgressDialog _progressDialog;
  var societyId,userId;
  List<Banners> _bannerList = List<Banners>();

  @override
  void initState() {
    super.initState();
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

    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.darkBlue,
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
          title: AutoSizeText(
            AppLocalizations.of(context).translate('about_societyrun'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBannerData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    restClient.getBannerData().then((value) {
      print('Response : ' + value.toString());
      if (value.status) {
        List<dynamic> _list = value.data;
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
                getAboutSocietyRunLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getAboutSocietyRunLayout() {
    return  SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 10),
        padding: EdgeInsets.all(
            10), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: GlobalVariables.lightGreen,
                  borderRadius:
                  BorderRadius.all(Radius.circular(10))),
              margin: EdgeInsets.all(20),
              child: CarouselSlider.builder(
                options: CarouselOptions(height: 150.0,autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 1.0,
                ),
                itemCount: _bannerList.length,
                itemBuilder: (BuildContext context, int itemIndex) =>
                _bannerList.length> 0 ? InkWell(
                  onTap: (){
                    launch(_bannerList[itemIndex].Url);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    //color: GlobalVariables.black,
                    //alignment: Alignment.center,
                    child: Image.network(_bannerList[itemIndex].IMAGE,fit: BoxFit.fitWidth,),
                  ),
                ): Container(),
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
                        child: AutoSizeText(AppLocalizations.of(context).translate('develop_by'),style: TextStyle(
                            color: GlobalVariables.darkBlue,fontSize: 18,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: AutoSizeText(SocietyRun.companyName,style: TextStyle(
                            color: GlobalVariables.grey,fontSize: 16
                        ),),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 20),
                        child: Divider(
                          color: GlobalVariables.grey,
                          height: 1,
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: AutoSizeText(AppLocalizations.of(context).translate('contact'),style: TextStyle(
                            color: GlobalVariables.darkBlue,fontSize: 18,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: AutoSizeText(AppLocalizations.of(context).translate('sales_contact')+" : ",style: TextStyle(
                                color: GlobalVariables.grey,fontSize: 16,fontWeight: FontWeight.w500
                            ),),
                          ),
                          InkWell(
                            onTap: (){
                              launch("tel://" + SocietyRun.salesContact);
                            },
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: AutoSizeText(SocietyRun.salesContact,style: TextStyle(
                                  color: GlobalVariables.skyBlue,fontSize: 16
                              ),),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: AutoSizeText(' / ',style: TextStyle(
                                color: GlobalVariables.grey,fontSize: 16
                            ),),
                          ),
                          InkWell(
                            onTap: (){
                              launch("tel://" + SocietyRun.salesContact1);
                            },
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: AutoSizeText(SocietyRun.salesContact1,style: TextStyle(
                                  color: GlobalVariables.skyBlue,fontSize: 16
                              ),),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: AutoSizeText(AppLocalizations.of(context).translate('support_contact')+" : ",style: TextStyle(
                                color: GlobalVariables.grey,fontSize: 16,fontWeight: FontWeight.w500
                            ),),
                          ),
                          InkWell(
                            onTap: (){
                              launch("tel://" + SocietyRun.supportContact);
                            },
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: AutoSizeText(SocietyRun.supportContact,style: TextStyle(
                                  color: GlobalVariables.skyBlue,fontSize: 16
                              ),),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 20),
                        child: Divider(
                          color: GlobalVariables.grey,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: AutoSizeText(AppLocalizations.of(context).translate('_email'),style: TextStyle(
                            color: GlobalVariables.darkBlue,fontSize: 18,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: AutoSizeText(AppLocalizations.of(context).translate('sales_email')+" : ",style: TextStyle(
                                color: GlobalVariables.grey,fontSize: 16,fontWeight: FontWeight.w500
                            ),),
                          ),
                          InkWell(
                            onTap: (){
                              Uri _emailUri = Uri(
                                  scheme: 'mailto',
                                  path: SocietyRun.salesEmail,
                                  queryParameters: {
                                    'subject':''
                                  }

                              );
                              launch(_emailUri.toString());
                            },
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: AutoSizeText(SocietyRun.salesEmail,style: TextStyle(
                                  color: GlobalVariables.skyBlue,fontSize: 16
                              ),),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: AutoSizeText(AppLocalizations.of(context).translate('support_email')+" : ",style: TextStyle(
                                color: GlobalVariables.grey,fontSize: 16,fontWeight: FontWeight.w500
                            ),),
                          ),
                          InkWell(
                            onTap: (){
                              Uri _emailUri = Uri(
                                  scheme: 'mailto',
                                  path: SocietyRun.supportEmail,
                                  queryParameters: {
                                    'subject':''
                                  }

                              );
                              launch(_emailUri.toString());
                            },
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: AutoSizeText(SocietyRun.supportEmail,style: TextStyle(
                                  color: GlobalVariables.skyBlue,fontSize: 16
                              ),),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 20),
                        child: Divider(
                          color: GlobalVariables.grey,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: AutoSizeText(AppLocalizations.of(context).translate('office_address'),style: TextStyle(
                            color: GlobalVariables.darkBlue,fontSize: 18,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: AutoSizeText(AppLocalizations.of(context).translate('pune')+" : ",style: TextStyle(
                                  color: GlobalVariables.grey,fontSize: 16,fontWeight: FontWeight.w500
                              ),),
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: AutoSizeText(SocietyRun.puneAddress,
                                maxLines: 5,
                                style: TextStyle(
                                  color: GlobalVariables.grey,fontSize: 16
                              ),),
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
                                child: AutoSizeText(AppLocalizations.of(context).translate('mumbai')+" : ",style: TextStyle(
                                    color: GlobalVariables.grey,fontSize: 16,fontWeight: FontWeight.w500
                                ),),
                              ),
                            ),
                            Flexible(
                              flex: 4,
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: AutoSizeText(SocietyRun.mumbaiAddress,
                                  maxLines: 5,
                                  style: TextStyle(
                                    color: GlobalVariables.grey,fontSize: 16
                                ),),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 20),
                        child: Divider(
                          color: GlobalVariables.grey,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: AutoSizeText(AppLocalizations.of(context).translate('version_code'),style: TextStyle(
                            color: GlobalVariables.darkBlue,fontSize: 18,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: AutoSizeText(SocietyRun.versionCode,style: TextStyle(
                            color: GlobalVariables.grey,fontSize: 16
                        ),),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 20),
                        child: Divider(
                          color: GlobalVariables.grey,
                          height: 1,
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: AutoSizeText(AppLocalizations.of(context).translate('feedback'),style: TextStyle(
                            color: GlobalVariables.darkBlue,fontSize: 18,fontWeight: FontWeight.bold
                        ),),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BaseFeedback()));
                        },
                        child: Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: AutoSizeText(AppLocalizations.of(context).translate('bug_suggestion'),style: TextStyle(
                              color: GlobalVariables.skyBlue,fontSize: 16
                          ),),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 20),
                        child: Divider(
                          color: GlobalVariables.grey,
                          height: 1,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ) ;
  }

}
