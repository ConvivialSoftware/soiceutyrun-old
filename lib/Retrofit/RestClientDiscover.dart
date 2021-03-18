import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/DataResponse.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'RestAPI.dart';

@RestApi(baseUrl: GlobalVariables.BaseURLDiscover)
abstract class RestClientDiscover {

  factory RestClientDiscover(Dio dio, {String baseUrl}) = RestAPI;

  @FormUrlEncoded()
  @POST(GlobalVariables.displayClassifiedAPI)
  Future<DataResponse> getClassifiedData(@Field("User_Id") String userId,);

  @FormUrlEncoded()
  @POST(GlobalVariables.displayOwnerClassifiedAPI)
  Future<DataResponse> getOwnerClassifiedData(@Field("User_Id") String userId,);

  @FormUrlEncoded()
  @POST(GlobalVariables.insertClassifiedAPI)
  Future<StatusMsgResponse> insertClassifiedData(@Field("User_Id") String userId,
      @Field("Name") String name,@Field("Email") String email, @Field("Phone") String phone,
      @Field("Category") String category, @Field("Type") String type,
      @Field("Title") String title, @Field("Description") String description,
      @Field("Property_Details") String propertyDetails, @Field("Price") String price,
      @Field("Locality") String locality, @Field("City") String city,@Field("Img_Name") var images,
      @Field("Address") String address, @Field("Pincode") String pincode,@Field("Society_Name") String Society_Name,);

  @FormUrlEncoded()
  @POST(GlobalVariables.exclusiveOfferAPI)
  Future<DataResponse> getExclusiveOfferData(@Field("flag") String appName);

  @FormUrlEncoded()
  @POST(GlobalVariables.cityAPI)
  Future<DataResponse> getCityData();

  @FormUrlEncoded()
  @POST(GlobalVariables.insertUserInfoOnExclusiveGetCode)
  Future<StatusMsgResponse> insertUserInfoOnExclusiveGetCode(
      @Field("Society_Name") String societyName,@Field("Unit") String unit, @Field("Mobile") String mobile,
      @Field("Address") String address);

  @FormUrlEncoded()
  @POST(GlobalVariables.interestedClassified)
  Future<StatusMsgResponse> interestedClassified(
      @Field("C_Id") String C_Id,@Field("User_Id") String user_id,
      @Field("Society_Name") String societyName,@Field("Unit") String unit,
      @Field("Mobile") String mobile, @Field("Address") String address,
      @Field("User_Name") String User_Name,@Field("User_Email") String User_Email,@Field("Profile_Image") String Profile_Image);

  @FormUrlEncoded()
  @POST(GlobalVariables.servicesCategory)
  Future<DataResponse> getServicesCategory();

  @FormUrlEncoded()
  @POST(GlobalVariables.servicePerCategory)
  Future<DataResponse> getServicePerCategory(@Field("category") String category,);

  @FormUrlEncoded()
  @POST(GlobalVariables.bookServicePerCategory)
  Future<StatusMsgResponse> bookServicePerCategory(
      @Field("S_Id") String S_Id,@Field("User_Id") String user_id,
      @Field("Name") String Name,@Field("Email") String Email,
      @Field("Society_Name") String societyName,@Field("Unit") String unit,
      @Field("Mobile") String mobile, @Field("Address") String address,
      @Field("Requiremnt") String Requiremnt,);


  @FormUrlEncoded()
  @POST(GlobalVariables.ownerServices)
  Future<DataResponse> getOwnerServices(@Field("User_Id") String userId,);

  @FormUrlEncoded()
  @POST(GlobalVariables.addServicesRatting)
  Future<StatusMsgResponse> updateServicesRatting(@Field("User_Id") String userId,@Field("S_Id") String S_Id,@Field("Rating") String Rating);


}


