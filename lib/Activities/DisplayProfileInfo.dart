
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ProfileInfo.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

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

  String userId,societyId,userType,loggedUserType='',loggedUserId;
  bool isEdit=false;
  TextEditingController _reasonController = TextEditingController();

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
            child: AppIcon(
              Icons.arrow_back,
              iconColor: GlobalVariables.white,
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
    loggedUserId = await GlobalFunctions.getUserId();
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
    }else if(loggedUserType.toLowerCase()=='owner' && userType=='owner family'){
      isDeleteOptionDisplay=true;
    }else if(loggedUserType.toLowerCase()=='owner' && userType=='tenant'){
      isDeleteOptionDisplay=true;
    }else if(loggedUserType.toLowerCase()=='owner' && userType=='owner'){
      isDeleteOptionDisplay=false;
    }else if(loggedUserType.toLowerCase()=='tenant' && userType=='tenant'){
      isDeleteOptionDisplay=true;
    }

    if(_profileList.length>0){
      if(loggedUserId==userId){
        isDeleteOptionDisplay=false;
      }
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
                        child: AppIcon(
                          Icons.delete,
                          iconColor: GlobalVariables.green,
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
                              child: /*_profileList[0].PROFILE_PHOTO == ""
                                  ? Image.asset(
                                  GlobalVariables.componentUserProfilePath,
                                  width: 60,
                                  height: 60)
                                  : Container(
                                // alignment: Alignment.center,
                                *//* decoration: BoxDecoration(
                                        borderRadius: BorderRad

                                        ius.circular(25)),*//*
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: GlobalVariables.mediumGreen,
                                  backgroundImage: NetworkImage(_profileList[0].PROFILE_PHOTO),
                                ),
                              ),*/_profileList[0].PROFILE_PHOTO
                                  .isEmpty
                                  ? AppAssetsImage(
                                GlobalVariables
                                    .componentUserProfilePath,
                                imageWidth:60.0,
                                imageHeight:60.0,
                                borderColor: GlobalVariables.grey,
                                borderWidth: 1.0,
                                fit: BoxFit.cover,
                                radius: 30.0,
                              )
                                  : AppNetworkImage(
                                _profileList[0].PROFILE_PHOTO,
                                imageWidth:60.0,
                                imageHeight:60.0,
                                borderColor: GlobalVariables.grey,
                                borderWidth: 1.0,
                                fit: BoxFit.cover,
                                radius: 30.0,
                              )
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
                      child: text(AppLocalizations.of(context).translate('contact1')+ " : ",
                          textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeLargeMedium),
                    ),
                    Container(
                   //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: text(_profileList[0].Phone==null ? '': _profileList[0].Phone,
                          textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(
                        child: text(AppLocalizations.of(context).translate('contact2')+ " : ",
                  textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeLargeMedium),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                       // margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: text(_profileList[0].ALTERNATE_CONTACT1,
                            textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium
                        ),
                      ),
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
                      child: text(AppLocalizations.of(context).translate('email')+ " : ",
                          textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeLargeMedium
                      ),
                    ),
                    Flexible(
                      child: Container(
                      //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: text(_profileList[0].Email==null ? '': _profileList[0].Email,
                            textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium
                        ),
                      ),
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
                      child: text(AppLocalizations.of(context).translate('gender')+ " : ",
                          textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeLargeMedium
                      ),
                    ),
                    Container(
                    //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: text(_profileList[0].GENDER,
                          textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium
                      ),
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
                      child: text(AppLocalizations.of(context).translate('blood_group')+ " : ",
                          textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeLargeMedium
                      ),
                    ),
                    Container(
                      //margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: text(_profileList[0].BLOOD_GROUP,
                          textColor: GlobalVariables.grey,fontSize:GlobalVariables.textSizeMedium
                      ),
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
                      child: text(AppLocalizations.of(context).translate('date_of_birth')+ " : ",
                          textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeLargeMedium
                      ),
                    ),
                    _profileList[0].DOB!=null && _profileList[0].DOB.length!=0 ? Container(
                    //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: text(_profileList[0].DOB=='0000-00-00' ? '':GlobalFunctions.convertDateFormat(_profileList[0].DOB, "dd-MM-yyyy"),
                          textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium
                      ),
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
                        child: text(AppLocalizations.of(context).translate('anniversary_date')+ " : ",
                            textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeLargeMedium
                        ),
                      ),
                      Container(
                     //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: text(/*GlobalFunctions.convertDateFormat(_profileList[0].ANNIVERSARY_DATE, "dd-MM-yyyy")*/'',
                            textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium
                        ),
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
                      child: text(AppLocalizations.of(context).translate('occupation')+ " : ",
                          textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeLargeMedium
                      ),
                    ),
                    Container(
                    //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: text(_profileList[0].OCCUPATION,
                          textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium
                      ),
                    )
                  ],
                ),
              ),
             /* Visibility(
                visible: false,
                child: Container(
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: text(AppLocalizations.of(context).translate('hobbies')+ " : ",
                            textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeLargeMedium
                        ),
                      ),
                      Container(
                     //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: text(''*//*_profileList                     [0].HOBBIES*//*,
                            textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium
                        ),
                      ),
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
                        child: text(AppLocalizations.of(context).translate('language_known')+ " : ",
                            textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeLargeMedium
                        ),
                      ),
                      Container(
                      //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: text('',*//*_profileList[0].LANGUAGES,*//*
                            textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium
                        ),
                      )
                    ],
                  ),
                ),
              ),*/
              Container(
                margin: EdgeInsets.fromLTRB(5,5,5,5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: text(AppLocalizations.of(context).translate('address')+ " : ",
                          textColor: GlobalVariables.green,fontSize: 18
                      ),
                    ),
                    Flexible(
                      child: Container(
                        //color : GlobalVariables.green,
                        //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: text(_profileList[0].ADDRESS,
                            textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium,
                        maxLine: 3,)
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
              child: AppIcon(
                Icons.edit,
                iconColor: GlobalVariables.white,
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
            child: text(AppLocalizations.of(context).translate('sure_delete'),
                  fontSize: GlobalVariables.textSizeLargeMedium,
                  textColor: GlobalVariables.black,
                  fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 100,
            child: AppTextField(
              textHintContent:
              AppLocalizations.of(context).translate('reason') +
                  '*',
              controllerCallback: _reasonController,
              maxLines: 99,
              contentPadding: EdgeInsets.only(top: 14),
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
                        if(_reasonController.text.length>0){
                          Navigator.of(context).pop();
                          moveOutMember();
                        }else{
                          GlobalFunctions.showToast('Please Enter Reason');
                        }
                      },
                      child: text(
                        AppLocalizations.of(context).translate('yes'),
                        textColor: GlobalVariables.green,
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
                        textColor: GlobalVariables.green,
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> moveOutMember() async {


    _progressDialog.show();
    Provider.of<UserManagementResponse>(context,listen: false).deactivateUser(userId, _reasonController.text,_profileList[0].BLOCK,_profileList[0].FLAT).then((value) {
      _progressDialog.hide();
      if(value.status){
        Navigator.of(context).pop('back');
      }
      GlobalFunctions.showToast(value.message);
    });

  }



}
