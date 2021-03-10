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
  @POST(GlobalVariables.displayClassified)
  Future<DataResponse> getClassifiedData();

  @FormUrlEncoded()
  @POST(GlobalVariables.insertClassified)
  Future<StatusMsgResponse> insertClassifiedData(
      @Field("Name") String name,@Field("Email") String email, @Field("Phone") String phone,
      @Field("Category") String category, @Field("Type") String type,
      @Field("Title") String title, @Field("Description") String description,
      @Field("Property_Details") String propertyDetails, @Field("Price") String price,
      @Field("Locality") String locality, @Field("City") String city,@Field("Images") var images,);

}


