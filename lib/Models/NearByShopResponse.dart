import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'package:societyrun/Retrofit/RestClientDiscover.dart';

class NearByShopResponse extends ChangeNotifier {
  List<NearByShop> nearByShopList = List<NearByShop>();
  List<NearByShopCategory> nearByShopCategoryList = List<NearByShopCategory>();
  bool isLoading = true;
  String errMsg;

  Future<String> getExclusiveOfferData(String appName,String Id) async {
    try {
      print('getClassifiedData');
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
      await restClient.getExclusiveOfferData(appName,Id).then((value) {
        nearByShopList = List<NearByShop>.from(
            value.data.map((i) => NearByShop.fromJson(i)));
        nearByShopCategoryList = List<NearByShopCategory>.from(
            value.category.map((i) => NearByShopCategory.fromJson(i)));
        print('nearByShopList : ' + nearByShopList.toString());
        print('nearByShopCategoryList : ' + nearByShopCategoryList.toString());
        isLoading = false;
        notifyListeners();

      });
    } catch (e) {
      errMsg = e.toString();
      print('errMsg : '+errMsg);
      isLoading = false;
      notifyListeners();
    }
    return nearByShopCategoryList.length.toString();
  }

  Future<StatusMsgResponse> insertUserInfoOnExclusiveGetCode(
      String societyName, String unit, String mobile, String address,String userName,String societyId,exclusiveId) async {

    String userId = await GlobalFunctions.getUserId();
    String userEmail = await GlobalFunctions.getUserName();
    final dio = Dio();
    final RestClientDiscover restClient =
    RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
    var result =  await restClient
        .insertUserInfoOnExclusiveGetCode(userId, societyName,  unit,  mobile,  address,userName,societyId,exclusiveId,userEmail);
    isLoading = false;
    notifyListeners();
    print('insertUserInfoOnExclusiveGetCode : '+result.toString());
    return result;
  }
}

class NearByShop {
  String Id,
      Category,
      Title,
      short_description,
      Offer_Code,
      Location,
      Img_Name,
      exp_date,
      vendor_shop,
      vendor_mobile,
      vendor_logo,
      vendor_logo_bg,
      title_bg,
      card_bg,
      redeem,
      C_Date;
  var offer_details,terms_condition;

  NearByShop(
      {this.Id,
      this.Category,
      this.Title,
      this.short_description,
      this.Img_Name,
      this.offer_details,
      this.exp_date,
      this.C_Date,
      this.Location,
      this.Offer_Code,
      this.card_bg,
      this.title_bg,
      this.vendor_logo_bg,
      this.vendor_mobile,
      this.vendor_shop,this.vendor_logo,this.terms_condition,this.redeem});

  factory NearByShop.fromJson(Map<String, dynamic> map) {
    return NearByShop(
      Id: map["Id"],
      Category: map["Category"],
      Title: map["Title"],
      short_description: map["short_description"],
      Offer_Code: map["Offer_Code"],
      Location: map["Location"],
      offer_details: map["offer_details"],
      terms_condition: map["terms_condition"],
      Img_Name: map["Img_Name"],
      C_Date: map["C_Date"],
      exp_date: map["exp_date"],
      card_bg: map["card_bg"],
      title_bg: map["title_bg"],
      vendor_logo: map["vendor_logo"],
      vendor_logo_bg: map["vendor_logo_bg"],
      vendor_mobile: map["vendor_mobile"],
      vendor_shop: map["vendor_shop"],
      redeem: map["redeem"],

    );
  }
}

class NearByShopCategory {
  String Id, Category_Name;

  NearByShopCategory({
    this.Id,
    this.Category_Name,
  });

  factory NearByShopCategory.fromJson(Map<String, dynamic> map) {
    return NearByShopCategory(
      Id: map["Id"],
      Category_Name: map["Category_Name"],
    );
  }
}

class NearByShopOfferDetails {
  String Id, Exclusive_Id,Description;

  NearByShopOfferDetails({
    this.Id,
    this.Exclusive_Id,
    this.Description,
  });

  factory NearByShopOfferDetails.fromJson(Map<String, dynamic> map) {
    return NearByShopOfferDetails(
      Id: map["Id"],
      Exclusive_Id: map["Exclusive_Id"],
      Description: map["Description"],
    );
  }
}

class NearByShopTermsCondition {
  String Id, Exclusive_Id,Description;

  NearByShopTermsCondition({
    this.Id,
    this.Exclusive_Id,
    this.Description,
  });

  factory NearByShopTermsCondition.fromJson(Map<String, dynamic> map) {
    return NearByShopTermsCondition(
      Id: map["Id"],
      Exclusive_Id: map["Exclusive_Id"],
      Description: map["Description"],
    );
  }
}
