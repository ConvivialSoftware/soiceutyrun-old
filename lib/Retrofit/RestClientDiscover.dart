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
  Future<DataResponse> getClassifiedData(@Field("User_Id") String userId,@Field("SOCIETY_ID") String societyId,);

  @FormUrlEncoded()
  @POST(GlobalVariables.displayOwnerClassifiedAPI)
  Future<DataResponse> getOwnerClassifiedData(@Field("User_Id") String userId,@Field("SOCIETY_ID") String societyId,@Field("Id") String id);

  @FormUrlEncoded()
  @POST(GlobalVariables.insertClassifiedAPI)
  Future<StatusMsgResponse> insertClassifiedData(@Field("User_Id") String userId,
      @Field("Name") String name,@Field("Email") String email, @Field("Phone") String phone,
      @Field("Category") String category, @Field("Type") String type,
      @Field("Title") String title, @Field("Description") String description,
     /* @Field("Property_Details") String propertyDetails,*/ @Field("Price") String price,
      @Field("Locality") String locality, @Field("City") String city,@Field("Img_Name") var images,
      @Field("Address") String address, @Field("Pincode") String pincode,
      @Field("Society_Name") String Society_Name,
      @Field("SOCIETY_ID") String societyId,
      @Field("add_visibility") String add_visibility,
      );

  @FormUrlEncoded()
  @POST(GlobalVariables.editClassifiedData)
  Future<StatusMsgResponse> editClassifiedData(@Field("C_Id") String classifiedId,@Field("User_Id") String userId,
      @Field("Name") String name,@Field("Email") String email, @Field("Phone") String phone,
      @Field("Category") String category, @Field("Type") String type,
      @Field("Title") String title, @Field("Description") String description,
      /* @Field("Property_Details") String propertyDetails,*/ @Field("Price") String price,
      @Field("Locality") String locality, @Field("City") String city,@Field("Img_Name") var images,
      @Field("Address") String address, @Field("Pincode") String pincode,@Field("Society_Name") String Society_Name,@Field("add_visibility") String add_visibility,);

  @FormUrlEncoded()
  @POST(GlobalVariables.exclusiveOfferAPI)
  Future<DataResponse> getExclusiveOfferData(@Field("flag") String appName,@Field("Id") String id);

  @FormUrlEncoded()
  @POST(GlobalVariables.cityAPI)
  Future<DataResponse> getCityData();

  @FormUrlEncoded()
  @POST(GlobalVariables.insertUserInfoOnExclusiveGetCode)
  Future<StatusMsgResponse> insertUserInfoOnExclusiveGetCode(
      @Field("User_Id") String userID,@Field("Society_Name") String societyName,@Field("Unit") String unit, @Field("Mobile") String mobile,
      @Field("Address") String address,@Field("User_Name") String name,@Field("SOCIETY_ID") String societyID,@Field("Id") String exclusiveId,@Field("User_Email") String User_Email);

  @FormUrlEncoded()
  @POST(GlobalVariables.interestedClassified)
  Future<StatusMsgResponse> interestedClassified(
      @Field("C_Id") String C_Id,@Field("User_Id") String user_id,
      @Field("Society_Name") String societyName,@Field("Unit") String unit,
      @Field("Mobile") String mobile, @Field("Address") String address,
      @Field("User_Name") String User_Name,@Field("User_Email") String User_Email,
      @Field("Profile_Image") String Profile_Image,@Field("SOCIETY_ID") String societyId);

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
      @Field("Requiremnt") String Requiremnt,@Field("SOCIETY_ID") String societyId,@Field("booking_date") String bookingDate,);


  @FormUrlEncoded()
  @POST(GlobalVariables.ownerServices)
  Future<DataResponse> getOwnerServices(@Field("User_Id") String userId,@Field("SOCIETY_ID") String societyId,);

  @FormUrlEncoded()
  @POST(GlobalVariables.addServicesRatting)
  Future<StatusMsgResponse> updateServicesRatting(@Field("User_Id") String userId,@Field("S_Id") String S_Id,@Field("Rating") String Rating,@Field("SOCIETY_ID") String societyId,);


  @FormUrlEncoded()
  @POST(GlobalVariables.updateClassifiedReasonForRemove)
  Future<StatusMsgResponse> updateClassifiedStatus(@Field("C_Id") String classified,@Field("Reason") String reason);

  @FormUrlEncoded()
  @POST(GlobalVariables.activeClassifiedStatus)
  Future<StatusMsgResponse> activeClassifiedStatus(@Field("C_Id") String classified);

  @FormUrlEncoded()
  @POST(GlobalVariables.deleteClassifiedImage)
  Future<StatusMsgResponse> deleteClassifiedImage(@Field("C_Id") String classified,@Field("Id") String Id);


}


