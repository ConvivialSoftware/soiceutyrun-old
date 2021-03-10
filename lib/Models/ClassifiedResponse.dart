import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClientDiscover.dart';

class ClassifiedResponse extends ChangeNotifier {
  List<Classified> classifiedList = List<Classified>();
  List<ClassifiedCategory> classifiedCategoryList = List<ClassifiedCategory>();
  bool isLoading = true;
  String errMsg;

  Future<String> getClassifiedData() async {
    try {
      print('getClassifiedData');
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
      await restClient.getClassifiedData().then((value) {
        classifiedList = List<Classified>.from(
            value.data.map((i) => Classified.fromJson(i)));
        classifiedCategoryList = List<ClassifiedCategory>.from(
            value.category.map((i) => ClassifiedCategory.fromJson(i)));
        print('classifiedList : ' + classifiedList.toString());
        print('classifiedCategoryList : ' + classifiedCategoryList.toString());
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

  Future<void> insertClassifiedData(
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
      images) async {
    try {
      final dio = Dio();
      final RestClientDiscover restClient =
          RestClientDiscover(dio, baseUrl: GlobalVariables.BaseURLDiscover);
      await restClient
          .insertClassifiedData(name, email, phone, category, type, title,
              description, propertyDetails, price, locality, city, images)
          .then((value) {
        isLoading = false;
        notifyListeners();
        print(value.toString());
      });
    } catch (e) {
      errMsg = e.toString();
      isLoading = false;
      notifyListeners();
    }
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
      this.C_Date,
      this.Images});

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
