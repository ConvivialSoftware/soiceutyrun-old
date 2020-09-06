import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/BankResponse.dart';
import 'package:societyrun/Models/BillViewResponse.dart';
import 'package:societyrun/Models/DataResponse.dart';
import 'package:societyrun/Models/DuesResponse.dart';
import 'package:societyrun/Models/LedgerResponse.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'RestAPI.dart';

@RestApi(baseUrl: GlobalVariables.BaseRazorPayURL)
abstract class RestClientRazorPay {

  factory RestClientRazorPay(Dio dio, {String baseUrl}) = RestAPI;

  @FormUrlEncoded()
  @POST(GlobalVariables.razorPayOrderAPI)
  Future<Map<String, dynamic>> getRazorPayOrderID(@Field("amount") String amount, @Field("currency") String currency,
      @Field("receipt") String receipt,@Field("payment_capture") String paymentCapture, String razorKey, String secret_key);


}


