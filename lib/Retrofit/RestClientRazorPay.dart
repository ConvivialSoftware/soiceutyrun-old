import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/razor_pay_order_request.dart';
import 'RestAPI.dart';

@RestApi(baseUrl: GlobalVariables.BaseRazorPayURL)
abstract class RestClientRazorPay {

  factory RestClientRazorPay(Dio dio, {String baseUrl}) = RestAPI;

  @POST(GlobalVariables.razorPayOrderAPI)
  Future<Map<String, dynamic>> getRazorPayOrderID(RazorPayOrderRequest request,String razorKey, String secretKey);


}


