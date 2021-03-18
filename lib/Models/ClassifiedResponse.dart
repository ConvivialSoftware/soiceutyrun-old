import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'package:societyrun/Retrofit/RestClientDiscover.dart';

class ClassifiedResponse extends ChangeNotifier {
  List<Classified> classifiedList = List<Classified>();
  List<ClassifiedCategory> classifiedCategoryList = List<ClassifiedCategory>();
  List<City> cityList = List<City>();
  bool isLoading = true;
  String errMsg;

  Future<String> getClassifiedData() async {
    try {
      print('getClassifiedData');
      String userId = await GlobalFunctions.getUserId();
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
      await restClient.getClassifiedData(userId).then((value) {
        classifiedList = List<Classified>.from(
            value.data.map((i) => Classified.fromJson(i)));
        classifiedCategoryList = List<ClassifiedCategory>.from(
            value.category.map((i) => ClassifiedCategory.fromJson(i)));
        print('classifiedList : ' + classifiedList.toString());
        print('classifiedCategoryList : ' + classifiedCategoryList.toString());
        getCityData();
        isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      errMsg = e.toString();
      isLoading = false;
      notifyListeners();
    }
    return classifiedCategoryList.length.toString();
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
    return classifiedCategoryList.length.toString();
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
    String address = await GlobalFunctions.getSocietyAddress();
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
     var result =  await restClient
          .insertClassifiedData(userId,name, email, phone, category, type, title,
              description, propertyDetails, price, locality, city, images,address,pinCode,societyName);
      isLoading = false;
      notifyListeners();
      print('insertClassifiedData : '+result.toString());
      getClassifiedData();
     return result;
  }

  Future<StatusMsgResponse> interestedClassified(String C_Id) async {

    String userId = await GlobalFunctions.getUserId();
    String societyName =  await GlobalFunctions.getSocietyName();
    String block =  await GlobalFunctions.getBlock();
    String flat =  await GlobalFunctions.getFlat();
    String mobile = await GlobalFunctions.getMobile();
    String address = await GlobalFunctions.getSocietyAddress();
    String userName = await GlobalFunctions.getDisplayName();
    String userEmail = await GlobalFunctions.getUserName();
    String userProfile = await GlobalFunctions.getPhoto();

    final dio = Dio();
    final RestClientDiscover restClient =
    RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
    var result =  await restClient.interestedClassified(C_Id, userId,societyName,block+' '+flat,mobile,address,userName,userEmail,userProfile);
    isLoading = false;
    notifyListeners();
    print('interestedClassified : '+result.toString());
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
      PinCode,
      Society_Name,
      C_Date;
  var Images;

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
      this.C_Date, this.Society_Name,
      this.Images,this.Address,this.PinCode});

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
      Address: map["Address"],
      PinCode: map["Pincode"],
      Society_Name: map["Society_Name"],
      Images: map["Images"],
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
