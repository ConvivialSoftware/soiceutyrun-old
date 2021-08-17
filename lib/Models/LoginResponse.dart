import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Banners.dart';
import 'package:societyrun/Models/ProfileInfo.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';

class LoginDashBoardResponse extends ChangeNotifier {
  List<Banners> bannerList = List<Banners>();
  static List<LoginResponse> societyList = new List<LoginResponse>();
  String duesRs;
  String duesDate;
  bool isLoading = true;
  String errMsg;

  Future<dynamic> getDuesData() async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String flat = await GlobalFunctions.getFlat();
    String block = await GlobalFunctions.getBlock();

    await restClientERP.getDuesData(societyId, flat, block).then((value) {
      print('Response : ' + value.toString());

      if (value.status) {
        GlobalVariables.isERPAccount = true;
      } else {
        GlobalVariables.isERPAccount = false;
      }

      duesRs = value.DUES.toString();
      duesDate = value.DUE_DATE.toString();
      if (duesRs == null) {
        duesRs = '0.0';
      }
      if (duesRs.length == 0) {
        duesRs = "0.0";
      }
      if (duesDate == 'null') duesDate = '-';
      GlobalFunctions.saveDuesDataToSharedPreferences(duesRs, duesDate);
    });

    isLoading = false;
    notifyListeners();
  }

  getBannerData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    await restClient.getBannerData().then((value) {
      print('Response : ' + value.toString());
      if (value.status) {
        List<dynamic> _list = value.data;
        bannerList = List<Banners>.from(_list.map((i) => Banners.fromJson(i)));
      }
    });

    isLoading = false;
    notifyListeners();
  }

  Future<dynamic> getAllSocietyData(
      String loggedUsername, BuildContext context) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);

    await restClient.getAllSocietyData(loggedUsername).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;
        societyList = List<LoginResponse>.from(
            _list.map((i) => LoginResponse.fromJson(i)));
      } else {
        if (value.message ==
            AppLocalizations.of(context)
                .translate('invalid_username_password')) {
          GlobalFunctions.notAllowForRunAppDialog(context);
        }
      }

      if (Platform.isAndroid) {
        if (value.android_version != AppPackageInfo.version) {
          //show app update Dialog
          GlobalFunctions.appUpdateDialog(context, value.android_type);
        }
      } else if (Platform.isIOS) {
        if (value.ios_version != AppPackageInfo.version) {
          //show app update Dialog
          GlobalFunctions.appUpdateDialog(context, value.ios_type);
        }
      }
    });

    isLoading = false;
    notifyListeners();
    return societyList;
  }

  Future<dynamic> geProfileData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    restClient.getProfileData(societyId, userId).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;
        List<ProfileInfo> _profileList =
            List<ProfileInfo>.from(_list.map((i) => ProfileInfo.fromJson(i)));
        GlobalVariables.userNameValueNotifer.value = _profileList[0].NAME;
        GlobalVariables.userImageURLValueNotifer.value =
            _profileList[0].PROFILE_PHOTO;
        GlobalVariables.userImageURLValueNotifer.notifyListeners();
        GlobalVariables.userNameValueNotifer.notifyListeners();
        GlobalFunctions.saveUserProfileToSharedPreferences(
            _profileList[0].PROFILE_PHOTO);
        GlobalFunctions.saveDisplayUserNameToSharedPreferences(
            _profileList[0].NAME);

        isLoading = false;
        notifyListeners();
      }
    });
  }
}

@JsonSerializable()
class LoginResponse {
  String ID;
  String USER_ID;
  String SOCIETY_ID;
  String BLOCK;
  String FLAT;
  String USER_NAME;
  String MOBILE;
  String PASSWORD;
  String USER_TYPE;
  String gcm_id;
  String token_id;
  String C_DATE;
  String message;
  String Society_Name;
  String Address;
  String Reg_no;
  String Contact;
  String Email;
  String society_Permissions;
  String Name;
  String Role;
  String TYPE;
  String Photo;
  String Permissions;
  String Consumer_no;
  bool status;
  String Staff_QR_Image;
  String google_parameter;
  String User_Status;
  String LoggedUsername;
  String SMS_CREDIT;
  bool isSelected;

  LoginResponse({
    this.ID,
    this.USER_ID,
    this.SOCIETY_ID,
    this.BLOCK,
    this.FLAT,
    this.USER_NAME,
    this.MOBILE,
    this.PASSWORD,
    this.USER_TYPE,
    this.gcm_id,
    this.token_id,
    this.C_DATE,
    this.message,
    this.Society_Name,
    this.Address,
    this.Reg_no,
    this.Contact,
    this.Email,
    this.society_Permissions,
    this.Name,
    this.Role,
    this.TYPE,
    this.Photo,
    this.Permissions,
    this.Consumer_no,
    this.status,
    this.Staff_QR_Image,
    this.google_parameter,
    this.User_Status,
    this.LoggedUsername,
    this.SMS_CREDIT,
    this.isSelected=false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
        ID: json["ID"],
        USER_ID: json["USER_ID"],
        SOCIETY_ID: json["SOCIETY_ID"],
        BLOCK: json["BLOCK"],
        FLAT: json["FLAT"],
        USER_NAME: json["USER_NAME"],
        MOBILE: json["MOBILE"],
        PASSWORD: json["PASSWORD"],
        USER_TYPE: json["USER_TYPE"],
        gcm_id: json["gcm_id"],
        token_id: json["token_id"],
        C_DATE: json["C_DATE"],
        message: json["message"],
        Society_Name: json["Society_Name"],
        Address: json["Address"],
        Reg_no: json["Reg_no"],
        Contact: json["Contact"],
        Email: json["Email"],
        society_Permissions: json["society_Permissions"],
        Name: json["Name"],
        Role: json["Role"],
        TYPE: json["TYPE"],
        Photo: json["Photo"],
        Permissions: json["Permissions"],
        Consumer_no: json["Consumer_no"],
        status: json["status"],
        Staff_QR_Image: json["Staff_QR_Image"],
        google_parameter: json["google_parameter"],
        User_Status: json["User_Status"],
        LoggedUsername: json["LoggedUsername"] ?? "",
        SMS_CREDIT: json["SMS_CREDIT"] ?? "0");
  }
}
