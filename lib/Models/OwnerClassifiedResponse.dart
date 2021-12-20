import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'package:societyrun/Retrofit/RestClientDiscover.dart';

class OwnerClassifiedResponse extends ChangeNotifier {
  List<Classified> ownerClassifiedList = <Classified>[];
  List<ClassifiedCategory> ownerClassifiedCategoryList = <ClassifiedCategory>[];
  List<City> cityList = <City>[];
  bool isLoading = true;
  String? errMsg;

  Future<String> getOwnerClassifiedData({String? Id}) async {
    try {
      print('getClassifiedData');
      if(!isLoading){
        isLoading = false;
      }
      String userId = await GlobalFunctions.getUserId();
      String societyId = await GlobalFunctions.getSocietyId();
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
      await restClient.getOwnerClassifiedData(userId,societyId,Id).then((value) {
        ownerClassifiedList = List<Classified>.from(
            value.data!.map((i) => Classified.fromJson(i)));
        ownerClassifiedCategoryList = List<ClassifiedCategory>.from(
            value.category!.map((i) => ClassifiedCategory.fromJson(i)));
        print('classifiedList : ' + ownerClassifiedList.toString());
        print('classifiedCategoryList : ' + ownerClassifiedCategoryList.toString());
        getCityData();
        isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      errMsg = e.toString();
      isLoading = false;
      notifyListeners();
    }
    return ownerClassifiedCategoryList.length.toString();
  }

  Future<String> getCityData() async {
    try {
      print('getCityData');
      final dio = Dio();
      final RestClientDiscover restClient =
      RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
      await restClient.getCityData().then((value) {
        cityList = List<City>.from(
            value.data!.map((i) => City.fromJson(i)));
        isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      errMsg = e.toString();
      isLoading = false;
      notifyListeners();
    }
    return ownerClassifiedCategoryList.length.toString();
  }

  Future<StatusMsgResponse> insertClassifiedData(
      String name,
      String email,
      String phone,
      String category,
      String type,
      String title,
      String description,/*
      String propertyDetails,*/
      String price,
      String locality,
      String city,
      images,String address,String pinCode,String addVisibility) async {

    String userId = await GlobalFunctions.getUserId();
    String societyId = await GlobalFunctions.getSocietyId();
    String societyName = await GlobalFunctions.getSocietyName();
    String gcmId = await GlobalFunctions.getFCMToken();
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
     var result =  await restClient
          .insertClassifiedData(userId,name, email, phone, category, type, title,
              description,/* propertyDetails,*/ price, locality, city, images,address,pinCode,societyName,societyId,addVisibility,gcmId);
      isLoading = false;
      notifyListeners();
      print('insertClassifiedData : '+result.toString());
      getOwnerClassifiedData();
     return result;
  }

  Future<StatusMsgResponse> updateClassifiedData(
      String classifiedId,
      String name,
      String email,
      String phone,
      String category,
      String type,
      String title,
      String description,/*
      String propertyDetails,*/
      String price,
      String locality,
      String city,
      images,String address,String pinCode,String add_visibility) async {

    String userId = await GlobalFunctions.getUserId();
    String societyName = await GlobalFunctions.getSocietyName();
    final dio = Dio();
    final RestClientDiscover restClient =
    RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
    var result =  await restClient
        .editClassifiedData(classifiedId,userId,name, email, phone, category, type, title,
        description,/* propertyDetails,*/ price, locality, city, images,address,pinCode,societyName,add_visibility);
    isLoading = false;
    notifyListeners();
    print('insertClassifiedData : '+result.toString());
    getOwnerClassifiedData();
    return result;
  }


  Future<StatusMsgResponse> updateClassifiedStatus(String classifiedId,String reason) async {

      isLoading=true;
      notifyListeners();
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
     var result =  await restClient
          .updateClassifiedStatus(classifiedId,reason);
      isLoading = false;
      notifyListeners();
      print('updateClassifiedStatus : '+result.toString());
      getOwnerClassifiedData();
     return result;
  }

  Future<StatusMsgResponse> activeClassifiedStatus(String classifiedId) async {

    isLoading=true;
    notifyListeners();
    final dio = Dio();
    final RestClientDiscover restClient =
    RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
    var result =  await restClient
        .activeClassifiedStatus(classifiedId);
    isLoading = false;
    notifyListeners();
    print('activeClassifiedStatus : '+result.toString());
    getOwnerClassifiedData();
    return result;
  }

  Future<StatusMsgResponse> deleteClassifiedImage(String classifiedId,String imageId) async {

    isLoading=true;
    notifyListeners();
    final dio = Dio();
    final RestClientDiscover restClient =
    RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
    var result =  await restClient
        .deleteClassifiedImage(classifiedId,imageId);
    isLoading = false;
    notifyListeners();
    print('activeClassifiedStatus : '+result.toString());
    getOwnerClassifiedData();
    return result;
  }
}

class Classified {
  String? id,
      Name,
      Email,
      Phone,
      Locality,
      Pincode,
      City,
      Category,
      Type,
      Title,
      Description,
      Price,
      Address,
      Society_Name,
      Status,
      Reason,
      C_Date;
  var Images;
  var Interested;

  Classified(
      {this.id,
      this.Name,
      this.Email,
      this.Phone,
      this.Locality,
        this.Pincode,
      this.City,
      this.Category,
      this.Type,
      this.Title,
      this.Description,
        this.Status,
        this.Reason,
      this.Price,
      this.C_Date,
      this.Images,this.Interested,this.Society_Name,this.Address});

  factory Classified.fromJson(Map<String, dynamic> map) {
    return Classified(
      id: map["Id"],
      Name: map["Name"],
      Email: map["Email"],
      Phone: map["Phone"],
      Locality: map["Locality"],
      Pincode: map["Pincode"],
      Address: map["Address"],
      City: map["City"],
      Category: map["Category"],
      Type: map["Type"],
      Title: map["Title"],
      Description: map["Description"],
      Status: map["Status"],
      Reason: map["Reason"],
      Price: map["Price"],
      C_Date: map["C_Date"],
      Images: map["Images"],
      Interested: map["Interested"],
      Society_Name: map["Society_Name"],
    );
  }
}

class ClassifiedCategory {
  String? Id, Category_Name;

  ClassifiedCategory({
    this.Id,
    this.Category_Name,
  });

  factory ClassifiedCategory.fromJson(Map<String, dynamic> map) {
    return ClassifiedCategory(
      Id: map["Id"],
      Category_Name: map["Category_Name"],
    );
  }
}

class ClassifiedImage {
  String? Id,Img_Name;

  ClassifiedImage({this.Img_Name,this.Id});

  factory ClassifiedImage.fromJson(Map<String, dynamic> map) {
    return ClassifiedImage(
        Id: map["Id"],
        Img_Name: map["Img_Name"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Id": Id,
      "Img_Name": Img_Name
    };
  }
}

class Interested{

  String? Id,C_Id,User_Id,Society_Name,Unit,Mobile,Address,C_Date,User_Name,Profile_Image,User_Email;

  Interested({this.Id, this.C_Id, this.User_Id, this.Society_Name, this.Unit,
      this.Mobile, this.Address, this.C_Date,this.User_Name,this.Profile_Image,this.User_Email});


  factory Interested.fromJson(Map<String,dynamic> map){
    return Interested(
      Id:map["Id"],
      C_Id:map["C_Id"],
      User_Id:map["User_Id"],
      Society_Name:map["Society_Name"],
      Unit:map["Unit"],
      Mobile:map["Mobile"],
      Address:map["Address"],
      C_Date:map["C_Date"],
      User_Name:map["User_Name"],
      User_Email:map["User_Email"],
      Profile_Image:map["Profile_Image"]??'',
    );
  }

}


class City {
  String? city;

  City({this.city});

  factory City.fromJson(Map<String, dynamic> map) {
    return City(city: map["City"]);
  }

  Map<String, dynamic> toJson() {
    return {"City": city};
  }
}
