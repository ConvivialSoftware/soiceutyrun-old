import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ComplaintArea.dart';
import 'package:societyrun/Models/ComplaintCategory.dart';
import 'package:societyrun/Models/ProfileInfo.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

import 'HelpDesk.dart';

class BaseDisplayProfileInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DisplayProfileInfoState();
  }
}

class DisplayProfileInfoState extends State<BaseDisplayProfileInfo> {


  ProgressDialog _progressDialog;

  List<ProfileInfo> _profileList = List<ProfileInfo>();

  var societyId,userId;

  @override
  void initState() {
    super.initState();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        geProfileData();
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
          title: AutoSizeText(
            AppLocalizations.of(context).translate('my_profile'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }



  void geProfileData() async{

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    userId = await GlobalFunctions.getUserId();
    _progressDialog.show();
    restClient.getProfileData(societyId,userId).then((value) {
      //  _progressDialog.hide();
      if (value.status) {
        List<dynamic> _list = value.data;

        _profileList = List<ProfileInfo>.from(_list.map((i) => ProfileInfo.fromJson(i)));
        setState(() {
        });

      }
      _progressDialog.hide();
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
                getProfileInfoLayout(),
                editProfileFabLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getProfileInfoLayout() {
    return _profileList.length> 0 ? SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 10),
        padding: EdgeInsets.all(
            10), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0,0),
                        //color: GlobalVariables.red,
                        //TODO: userImage
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: _profileList[0].PROFILE_PHOTO == null
                              ? Image.asset(
                              GlobalVariables.componentUserProfilePath,
                              width: 60,
                              height: 60)
                              : Container(
                            // alignment: Alignment.center,
                            /* decoration: BoxDecoration(
                                    borderRadius: BorderRad

                                    ius.circular(25)),*/
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: GlobalVariables.mediumGreen,
                              backgroundImage: NetworkImage(_profileList[0].PROFILE_PHOTO),
                            ),
                          ),
                        )),
                    Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child:  AutoSizeText(
                            _profileList[0].NAME,
                            style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize:20,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child:  AutoSizeText(
                            _profileList[0].BLOCK+_profileList[0].FLAT,
                            style: TextStyle(
                              color: GlobalVariables.grey,
                              fontSize:16,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('contact1')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                   //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_profileList[0].ALTERNATE_CONTACT1,style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('contact2')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                     // margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_profileList[0].ALTERNATE_CONTACT2,style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('email')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                    //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_profileList[0].Email,style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('gender')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                    //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_profileList[0].GENDER,style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('blood_group')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                      //margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_profileList[0].BLOOD_GROUP,style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('date_of_birth')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                    //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(GlobalFunctions.convertDateFormat(_profileList[0].DOB, "dd-MM-yyyy"),style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: false,
                child: Container(
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: AutoSizeText(AppLocalizations.of(context).translate('anniversary_date')+ " : ",style: TextStyle(
                            color: GlobalVariables.green,fontSize: 18
                        ),),
                      ),
                      Container(
                     //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: AutoSizeText(/*GlobalFunctions.convertDateFormat(_profileList[0].ANNIVERSARY_DATE, "dd-MM-yyyy")*/'',style: TextStyle(
                            color: GlobalVariables.grey,fontSize: 16
                        ),),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: AutoSizeText(AppLocalizations.of(context).translate('occupation')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                    //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_profileList[0].OCCUPATION,style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: false,
                child: Container(
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: AutoSizeText(AppLocalizations.of(context).translate('hobbies')+ " : ",style: TextStyle(
                            color: GlobalVariables.green,fontSize: 18
                        ),),
                      ),
                      Container(
                     //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: AutoSizeText(''/*_profileList                     [0].HOBBIES*/,style: TextStyle(
                            color: GlobalVariables.grey,fontSize: 16
                        ),),
                      )
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: false,
                child: Container(
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: AutoSizeText(AppLocalizations.of(context).translate('language_known')+ " : ",style: TextStyle(
                            color: GlobalVariables.green,fontSize: 18
                        ),),
                      ),
                      Container(
                      //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: AutoSizeText('',/*_profileList[0].LANGUAGES,*/style: TextStyle(
                            color: GlobalVariables.grey,fontSize: 16
                        ),),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5,20,5,5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        child: AutoSizeText(AppLocalizations.of(context).translate('address')+ " : ",style: TextStyle(
                            color: GlobalVariables.green,fontSize: 18
                        ),),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        //color : GlobalVariables.green,
                        //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: AutoSizeText(_profileList[0].ADDRESS,style: TextStyle(
                            color: GlobalVariables.grey,fontSize: 16
                        ),maxLines: 2,)
                        ,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ) : Container();
  }

  editProfileFabLayout() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: FloatingActionButton(
              onPressed: () {
                //GlobalFunctions.showToast('Fab CLick');

                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BaseEditProfileInfo(userId,societyId)));
              },
              child: Icon(
                Icons.edit,
                color: GlobalVariables.white,
              ),
              backgroundColor: GlobalVariables.green,
            ),
          )
        ],
      ),
    );
  }


}
