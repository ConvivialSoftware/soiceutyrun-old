import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'package:societyrun/Retrofit/RestClientDiscover.dart';

class ServicesResponse extends ChangeNotifier {
  List<Services> servicesList = List<Services>();
  List<Services> ownerServicesList = List<Services>();
  List<ServicesCategory> servicesCategoryList = List<ServicesCategory>();
  bool isLoading = true;
  String errMsg;

  Future<void> getServicesCategory() async {
    try {
      print('getCategoryData');
      //isLoading = true;
      //notifyListeners();
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
      var value = await restClient.getServicesCategory();
      print('servicesCategoryList value : ' + value.toString());
      servicesCategoryList = List<ServicesCategory>.from(
          value.data.map((i) => ServicesCategory.fromJson(i)));
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errMsg = e.toString();
      print('errMsg ' + errMsg);
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getServicePerCategory(String category) async {
    try {
      //isLoading = true;
      //notifyListeners();
      print('getServicePerCategory');
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
      var value = await restClient.getServicePerCategory(category);
      servicesList = List<Services>();
      servicesList =
          List<Services>.from(value.data.map((i) => Services.fromJson(i)));
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errMsg = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<StatusMsgResponse> bookServicePerCategory(
      String S_Id, String Requirement) async {
    String userId = await GlobalFunctions.getUserId();
    String societyName = await GlobalFunctions.getSocietyName();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String mobile = await GlobalFunctions.getMobile();
    String address = await GlobalFunctions.getSocietyAddress();
    String userName = await GlobalFunctions.getDisplayName();
    String userEmail = await GlobalFunctions.getUserName();

    isLoading = true;
    notifyListeners();
    final dio = Dio();
    final RestClientDiscover restClient =
        RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
    var result = await restClient.bookServicePerCategory(
        S_Id,
        userId,
        userName,
        userEmail,
        societyName,
        block + ' ' + flat,
        mobile,
        address,
        Requirement);
    isLoading = false;
    notifyListeners();
    print('bookServicePerCategory : ' + result.toString());
    return result;
  }

  Future<void> getOwnerServices() async {
    try {
      //isLoading = true;
      //notifyListeners();
      print('getOwnerServices');
      String userId = await GlobalFunctions.getUserId();
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
      var value = await restClient.getOwnerServices(userId);
      ownerServicesList =
          List<Services>.from(value.data.map((i) => Services.fromJson(i)));
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errMsg = e.toString();
      print('errMsg ' + errMsg);
      isLoading = false;
      notifyListeners();
    }
  }

  Future<StatusMsgResponse> updateServiceRatting(
      String S_Id, String _myRate) async {
    isLoading = true;
    notifyListeners();
    String userId = await GlobalFunctions.getUserId();
    final dio = Dio();
    final RestClientDiscover restClient =
        RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
    var result = await restClient.updateServicesRatting(userId, S_Id, _myRate);
    isLoading = false;
    notifyListeners();
    getOwnerServices();
    print('addServiceRatting : ' + result.toString());
    return result;
  }
}

class Services {
  String Id,
      User_Id,
      S_Id,
      Name,
      Category,
      Title,
      Description,
      Price,
      Rating,
      Discount,
      C_Date;
  var charges;

  Services(
      {this.Id,
      this.User_Id,
      this.S_Id,
      this.Name,
      this.Category,
      this.Title,
      this.Description,
      this.Price,
      this.Rating,
      this.Discount,
      this.C_Date,
      this.charges});

  factory Services.fromJson(Map<String, dynamic> map) {
    return Services(
      Id: map["Id"],
      User_Id: map["User_Id"],
      S_Id: map["S_Id"],
      Name: map["Name"],
      Category: map["Category"],
      Title: map["Title"],
      Description: map["Description"],
      Price: map["Price"],
      Rating: map["Rating"],
      Discount: map["Discount"],
      C_Date: map["C_Date"],
      charges: map["charges"],
    );
  }
}

class ServicesCategory {
  String Id, Category_Name;

  ServicesCategory({
    this.Id,
    this.Category_Name,
  });

  factory ServicesCategory.fromJson(Map<String, dynamic> map) {
    return ServicesCategory(
      Id: map["Id"],
      Category_Name: map["Category_Name"],
    );
  }
}

class ServicesCharges {
  String Id, S_Id, Service_Title, Service_Price;

  ServicesCharges({this.Id, this.S_Id, this.Service_Price, this.Service_Title});

  factory ServicesCharges.fromJson(Map<String, dynamic> map) {
    return ServicesCharges(
      Id: map["Id"],
      S_Id: map["S_Id"],
      Service_Title: map["Service_Title"],
      Service_Price: map["Service_Price"],
    );
  }
}
