import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:societyrun/Activities/Feedback.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/Activities/ReferAndEarn.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseSupport extends StatefulWidget {

  @override
  _BaseSupportState createState() => _BaseSupportState();
}

class _BaseSupportState extends BaseStatefulState<BaseSupport> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
          backgroundColor: GlobalVariables.black.withOpacity(0.7),
          appBar: AppBar(
            backgroundColor: GlobalVariables.transparent,
            leading: AppIconButton(Icons.close,iconColor: GlobalVariables.white,onPressed: (){
              Navigator.of(context).pop();
            },),
            title: text(AppLocalizations.of(context).translate('support'),textColor: GlobalVariables.white,isCentered: true),
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    //color: GlobalVariables.black,
                    //alignment: Alignment.center,
                    child: Column(
                      children: [
                        AppContainer(
                          isListItem:true,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppAssetsImage(GlobalVariables.supportIconPath),
                                  SizedBox(width: 8,),
                                  text(AppLocalizations.of(context).translate('society_issue'),fontSize: GlobalVariables.textSizeMedium,fontWeight: FontWeight.bold,textColor: GlobalVariables.grey)
                                ],
                              ),
                              SizedBox(height: 4,),
                              text(AppLocalizations.of(context).translate('society_issue_txt'),fontSize: GlobalVariables.textSizeSMedium,textColor: GlobalVariables.black),
                              SizedBox(height: 16,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //AppIcon(Icons.article_outlined,iconColor: GlobalVariables.grey,),
                                  //SizedBox(width: 16,),
                                  InkWell(
                                      onTap: (){
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => BaseRaiseNewTicket()));
                                      },
                                      child: text('Raise Complaint',textColor: GlobalVariables.primaryColor,fontSize: GlobalVariables.textSizeSMedium)),
                                  InkWell(
                                      onTap: () async {

                                        String emailId = await GlobalFunctions.getSocietyEmail();

                                        Uri _emailUri = Uri(
                                            scheme: 'mailto',
                                            path: emailId,
                                            queryParameters: {'subject': ''});
                                        launch(_emailUri.toString());
                                      },
                                      child: text('Email Society',textColor: GlobalVariables.primaryColor,fontSize: GlobalVariables.textSizeSMedium))
                                ],
                              ),
                              SizedBox(height: 8,),
                              InkWell(
                                  onTap: () async {

                                    String callNumber = await GlobalFunctions.getSocietyContact();
                                    launch("tel://" + callNumber);
                                  },
                                  child: Container(
                                      alignment: Alignment.topLeft,
                                      child: text('Call Society Office',fontSize: GlobalVariables.textSizeSMedium,textColor: GlobalVariables.primaryColor))),
                            ],
                          ),
                        ),
                        AppContainer(
                          isListItem: true,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppAssetsImage(GlobalVariables.appLogoGreenIcon),
                                  SizedBox(width: 8,),
                                  Flexible(
                                    child: text(
                                        AppLocalizations.of(context).translate('app_issue'),
                                        fontSize: GlobalVariables.textSizeMedium,
                                        fontWeight: FontWeight.bold,
                                        textColor: GlobalVariables.grey
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 4,),
                              text(AppLocalizations.of(context).translate('app_issue_txt'),fontSize: GlobalVariables.textSizeSMedium,textColor: GlobalVariables.black),
                              SizedBox(height: 16,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                      onTap: (){
                                        launch(GlobalVariables.FAQURL);
                                      },
                                      child: text('FAQ',textColor: GlobalVariables.primaryColor,fontSize: GlobalVariables.textSizeSMedium)
                                  ),
                                  InkWell(
                                      onTap: (){
                                        Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => BaseFeedback()));
                                      },
                                      child: text(AppLocalizations.of(context).translate('feedback'),textColor: GlobalVariables.primaryColor,fontSize: GlobalVariables.textSizeSMedium)
                                  ),
                                ],
                              ),
                            ],
                          ),

                        ),
                        InkWell(
                          onTap: (){
                            if(Platform.isAndroid)
                              launch(GlobalVariables.androidAppRedirectUrl+AppPackageInfo.packageName);
                            else
                              launch(GlobalVariables.iosAppRedirectUrl);

                          },
                          child: AppContainer(
                            isListItem: true,
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppAssetsImage(GlobalVariables.rateImagePath),
                                    SizedBox(width: 8,),
                                    Flexible(
                                      child: text(
                                          AppLocalizations.of(context).translate('app_rate'),
                                          fontSize: GlobalVariables.textSizeMedium,
                                          fontWeight: FontWeight.bold,
                                        textColor: GlobalVariables.grey
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 4,),
                                text(AppLocalizations.of(context).translate('app_rate_txt'),fontSize: GlobalVariables.textSizeSMedium,textColor: GlobalVariables.black),
                                SizedBox(height: 16,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.star_rate,color: GlobalVariables.orangeYellow,),
                                    Icon(Icons.star_rate,color: GlobalVariables.orangeYellow,),
                                    Icon(Icons.star_rate,color: GlobalVariables.orangeYellow,),
                                    Icon(Icons.star_rate,color: GlobalVariables.orangeYellow,),
                                    Icon(Icons.star_rate,color: GlobalVariables.orangeYellow,)
                                  ],
                                ),
                              ],
                            ),

                          ),
                        ),
                        AppContainer(
                          isListItem: true,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppAssetsImage(GlobalVariables.referAndEarnImagePath),
                                  SizedBox(width: 8,),
                                  Flexible(
                                    child: text(
                                        AppLocalizations.of(context).translate('refer_earn'),
                                        fontSize: GlobalVariables.textSizeMedium,
                                        fontWeight: FontWeight.bold,
                                        textColor: GlobalVariables.grey
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 4,),
                              text(AppLocalizations.of(context).translate('refer_earn_txt'),fontSize: GlobalVariables.textSizeSMedium,textColor: GlobalVariables.black),
                              SizedBox(height: 16,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                      onTap: (){
                                        Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => BaseReferAndEarn()));
                                      },
                                      child: text('Refer',textColor: GlobalVariables.primaryColor,fontSize: GlobalVariables.textSizeSMedium)
                                  ),
                                  /*InkWell(
                                      onTap: (){
                                        Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => BaseFeedback()));
                                      },
                                      child: text(AppLocalizations.of(context).translate('feedback'),textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeSMedium)
                                  ),*/
                                ],
                              ),
                            ],
                          ),

                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
      ),
    );
  }
}
