
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ProfileInfo.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

class BaseDisplayProfileInfo extends StatefulWidget {
  String userId,userType;

  BaseDisplayProfileInfo(this.userId, this.userType);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DisplayProfileInfoState(userId,userType);
  }
}

class DisplayProfileInfoState extends BaseStatefulState<BaseDisplayProfileInfo> {


  ProgressDialog _progressDialog;

  List<ProfileInfo> _profileList = List<ProfileInfo>();

  String userId,societyId,userType,loggedUserType='';
  bool isEdit=false;

  DisplayProfileInfoState(this.userId,this.userType);

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
              if(!isEdit) {
                Navigator.of(context).pop();
              }else{
                Navigator.of(context).pop('profile');
              }
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
        body: WillPopScope(child: getBaseLayout(), onWillPop: (){
          if(!isEdit) {
            Navigator.of(context).pop();
          }else{
            Navigator.of(context).pop('profile');
          }
          return;
        }),
      ),
    );
  }



  void geProfileData() async{
    societyId = await GlobalFunctions.getSocietyId();
    loggedUserType = await GlobalFunctions.getUserType();
    print('loggedUserType : '+ loggedUserType.toString());
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    _progressDialog.show();
    restClient.getProfileData(societyId,userId).then((value) {
        _progressDialog.hide();
      if (value.status) {
        List<dynamic> _list = value.data;
        _profileList = List<ProfileInfo>.from(_list.map((i) => ProfileInfo.fromJson(i)));
        print('Display User Type : '+ _profileList[0].TYPE.toString());
        print('Display User Type : '+ userType.toString());
        setState(() {
        });
      }
    });

  }

  getBaseLayout() {

    bool isEditOptionDisplay=false;

    if(loggedUserType.toLowerCase()=='tenant' && userType.toLowerCase()=='tenant'){
        isEditOptionDisplay=true;
    }else if(loggedUserType.toLowerCase()!='tenant' && userType.toLowerCase()=='tenant'){
      isEditOptionDisplay=true;
    }else if(loggedUserType.toLowerCase()!='tenant' && userType.toLowerCase()!='tenant'){
      isEditOptionDisplay=true;
    }else if(loggedUserType.toLowerCase()=='tenant' && userType.toLowerCase()!='tenant'){
      isEditOptionDisplay=false;
    }
    print('loggedUserType : '+loggedUserType.toLowerCase());
    print('userType : '+userType.toLowerCase());

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
                isEditOptionDisplay ? editProfileFabLayout(): Container(),
               // deleteProfileFabLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getProfileInfoLayout() {

    bool isDeleteOptionDisplay=false;

    if(loggedUserType.toLowerCase()=='owner'){
      isDeleteOptionDisplay=true;
    }else if(loggedUserType.toLowerCase()=='owner family' && userType=='owner'){
      isDeleteOptionDisplay=false;
    }else if(loggedUserType.toLowerCase()=='owner' && userType=='owner'){
      isDeleteOptionDisplay=false;
    }else if(loggedUserType.toLowerCase()=='tenant' && userType=='tenant'){
      isDeleteOptionDisplay=true;
    }

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
                child: Column(
                  children: [
                    isDeleteOptionDisplay ?  InkWell(
                      onTap:(){
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25.0)),
                                    child: deleteFamilyMemberLayout(),
                                  );
                                }));
                      },
                      child: Container(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.delete,
                          color: GlobalVariables.green,
                        ),
                      ),
                    ) : Container(),
                    Row(
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0,0),
                         //   width: 400,
                            //color: GlobalVariables.red,
                            //TODO: userImage
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30.0),
                              child: _profileList[0].PROFILE_PHOTO == ""
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
                        Flexible(
                          child: Column(
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
                              Visibility(
                                visible: true,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                                  child:  AutoSizeText(
                                    _profileList[0].BLOCK+_profileList[0].FLAT,
                                    style: TextStyle(
                                      color: GlobalVariables.grey,
                                      fontSize:16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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
                      child: AutoSizeText(_profileList[0].Phone==null ? '': _profileList[0].Phone,style: TextStyle(
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
                      child: AutoSizeText(AppLocalizations.of(context).translate('email')+ " : ",style: TextStyle(
                          color: GlobalVariables.green,fontSize: 18
                      ),),
                    ),
                    Container(
                    //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_profileList[0].Email==null ? '': _profileList[0].Email,style: TextStyle(
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
                    _profileList[0].DOB!=null && _profileList[0].DOB.length!=0 ? Container(
                    //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: AutoSizeText(_profileList[0].DOB=='0000-00-00' ? '':GlobalFunctions.convertDateFormat(_profileList[0].DOB, "dd-MM-yyyy"),style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16
                      ),),
                    ):Container()
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
              onPressed: () async {
                //GlobalFunctions.showToast('Fab CLick');

               // Navigator.of(context).pop('profile');
              var result = await  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BaseEditProfileInfo(userId,societyId)));

              print('Back Result : '+result.toString());
              if(result=='profile'){
                isEdit=true;
                geProfileData();
              }
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

  deleteFamilyMemberLayout() {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Text(AppLocalizations.of(context).translate('sure_delete'),
              style: TextStyle(
                  fontSize: 18,
                  color: GlobalVariables.black,
                  fontWeight: FontWeight.bold),
            ),
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
                        deleteFamilyMember();
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('yes'),
                        style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('no'),
                        style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> deleteFamilyMember() async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.deleteFamilyMember(userId, societyId).then((value) {
      _progressDialog.hide();
      if(value.status){
        Navigator.of(context).pop('back');
      }
      GlobalFunctions.showToast(value.message);
    });

  }



}
