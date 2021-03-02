
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppImage.dart';

import 'base_stateful.dart';

class BaseAddSociety extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // GlobalFunctions.showToast("OTP page");
    return AddSocietyState();
  }

}

class AddSocietyState extends BaseStatefulState<BaseAddSociety>{

  var name="";


  @override
  void initState() {
    super.initState();
    getDisplayName();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //   GlobalFunctions.showToast("Otpstate page");
    //  var otp_mobile_text=AppLocalizations.of(context).translate('')
    return Builder(
      builder: (context) => Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: GlobalVariables.white,
          ),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child:
                        AppAssetsImage(GlobalVariables.headerIconPath, imageWidth : MediaQuery.of(context).size.width,)
                        /*SvgPicture.asset(
                          GlobalVariables.headerIconPath,width: MediaQuery.of(context).size.width,)*/
                    ),
                  ),
                  Align(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 80, 0, 0),
                      child: AppAssetsImage(GlobalVariables.appIconPath,)/*SvgPicture.asset(GlobalVariables.appIconPath,)*/,
                    ),
                    alignment: AlignmentDirectional.topCenter,
                  ),
                  Align(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 130, 0, 0),
                        child: ClipRRect(borderRadius: BorderRadius.circular(8.0),
                          child: /*SvgPicture.asset(GlobalVariables.userProfileIconPath,
                              width: 100, height: 100)*/AppAssetsImage(GlobalVariables.userProfileIconPath, imageWidth : 100.0,imageHeight: 100.0,),
                        )
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5, 30, 0, 5),
                //color: GlobalVariables.green,
                //TODO : UserName
                child: Text(name,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: GlobalVariables.green, fontSize: 25,fontWeight: FontWeight.bold
                  ),),
              ),
              Container(
                height: 50,
                width: 320,
                color: GlobalVariables.lightGray,
                margin: EdgeInsets.fromLTRB(5, 30, 0, 5),
                //color: GlobalVariables.green,
                //TODO : UserName

              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                child: Text(AppLocalizations.of(context).translate('not_find_society'),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: GlobalVariables.black, fontSize: 14,
                  ),),
              ),
              Container(
                height: 45,
                margin: EdgeInsets.fromLTRB(30, 20, 25, 10),
                child: ButtonTheme(
                  minWidth: MediaQuery.of(context).size.width/2,
                  child: RaisedButton(
                    color: GlobalVariables.green,
                    onPressed: () {

                    },
                    textColor: GlobalVariables.white,
                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),side: BorderSide(color: GlobalVariables.green)
                    ),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('add_ur_society'),
                      style: TextStyle(
                          fontSize: GlobalVariables.textSizeMedium),
                    ),
                  ),
                ),
              ),
              Container(
                //   color: GlobalVariables.lightGreen,
                decoration: BoxDecoration(
                    color: GlobalVariables.lightGreen,
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: /*SvgPicture.asset(GlobalVariables.classifiedBigIconPath)*/AppAssetsImage(GlobalVariables.headerIconPath, imageWidth : MediaQuery.of(context).size.width,),
                    ),
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: RichText(text: TextSpan(
                                text: AppLocalizations.of(context).translate('classified_ads'),
                                style: TextStyle(
                                    color: GlobalVariables.green,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                )
                            )),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: RichText(text: TextSpan(
                                text: AppLocalizations.of(context).translate('classified_str'),
                                style: TextStyle(
                                    color: GlobalVariables.black,
                                    fontSize: 15
                                )
                            )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getDisplayName() async {
  name =  await GlobalFunctions.getDisplayName();
  setState(() {

  });
  }

}