import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'package:societyrun/Retrofit/RestClientDiscover.dart';

class OwnerClassifiedResponse extends ChangeNotifier {
  List<Classified> ownerClassifiedList = List<Classified>();
  List<ClassifiedCategory> ownerClassifiedCategoryList = List<ClassifiedCategory>();
  List<City> cityList = List<City>();
  bool isLoading = true;
  String errMsg;

  Future<String> getOwnerClassifiedData() async {
    try {
      print('getClassifiedData');
      String userId = await GlobalFunctions.getUserId();
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
      await restClient.getOwnerClassifiedData(userId).then((value) {
        ownerClassifiedList = List<Classified>.from(
            value.data.map((i) => Classified.fromJson(i)));
        ownerClassifiedCategoryList = List<ClassifiedCategory>.from(
            value.category.map((i) => ClassifiedCategory.fromJson(i)));
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
            value.data.map((i) => City.fromJson(i)));
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
      String description,
      String propertyDetails,
      String price,
      String locality,
      String city,
      images,String address,String pinCode) async {

    String userId = await GlobalFunctions.getUserId();
    String societyName = await GlobalFunctions.getSocietyName();
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
     var result =  await restClient
          .insertClassifiedData(userId,name, email, phone, category, type, title,
              description, propertyDetails, price, locality, city, images,address,pinCode,societyName);
      isLoading = false;
      notifyListeners();
      print('insertClassifiedData : '+result.toString());
      getOwnerClassifiedData();
     return result;
  }
}

class Classified {
  String id,
      Name,
      Email,
      Phone,
      Locality,
      City,
      Category,
      Type,
      Title,
      Description,
      Property_Details,
      Price,
      Address,
      Society_Name,
      C_Date;
  var Images;
  var Interested;

  Classified(
      {this.id,
      this.Name,
      this.Email,
      this.Phone,
      this.Locality,
      this.City,
      this.Category,
      this.Type,
      this.Title,
      this.Description,
      this.Property_Details,
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
      City: map["City"],
      Category: map["Category"],
      Type: map["Type"],
      Title: map["Title"],
      Description: map["Description"],
      Property_Details: map["Property_Details"],
      Price: map["Price"],
      C_Date: map["C_Date"],
      Images: map["Images"],
      Interested: map["Interested"],
      Society_Name: map["Society_Name"],
    );
  }
}

class ClassifiedCategory {
  String Id, Category_Name;

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
  String img;

  ClassifiedImage({this.img});

  factory ClassifiedImage.fromJson(Map<String, dynamic> map) {
    return ClassifiedImage(img: map["img"]);
  }

  Map<String, dynamic> toJson() {
    return {"img": img};
  }
}

class Interested{

  String Id,C_Id,User_Id,Society_Name,Unit,Mobile,Address,C_Date,User_Name,Profile_Image,User_Email;

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
  String city;

  City({this.city});

  factory City.fromJson(Map<String, dynamic> map) {
    return City(city: map["City"]);
  }

  Map<String, dynamic> toJson() {
    return {"City": city};
  }
}
