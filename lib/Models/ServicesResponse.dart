import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'package:societyrun/Retrofit/RestClientDiscover.dart';

class ServicesResponse extends ChangeNotifier {
  List<Services> servicesList = List<Services>();
  List<ServicesCategory> servicesCategoryList = List<ServicesCategory>();
  bool isLoading = true;
  String errMsg;

}

class Services {
  String Id,
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
  String Id, S_Id,Service_Title,Service_Price;

  ServicesCharges({
    this.Id,
    this.S_Id,
    this.Service_Price,this.Service_Title
  });

  factory ServicesCharges.fromJson(Map<String, dynamic> map) {
    return ServicesCharges(
      Id: map["Id"],
      S_Id: map["S_Id"],
      Service_Title: map["Service_Title"],
      Service_Price: map["Service_Price"],
    );
  }
}
