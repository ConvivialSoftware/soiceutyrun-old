class PaymentChargesResponse{

  List<dynamic> Preferred_Method;
  List<dynamic> Other_Method;
  String message;
  bool status;

  PaymentChargesResponse({this.Preferred_Method, this.Other_Method, this.message, this.status});

  factory PaymentChargesResponse.fromJson(Map<String,dynamic> map){

    return PaymentChargesResponse(
      Preferred_Method: map["Preferred_Method"],
      Other_Method: map["Other_Method"],
      status: map["status"],
      message: map["message"]
    );

  }

}

class PaymentMethod{

  String variable,value;

  PaymentMethod({this.variable, this.value});

  factory PaymentMethod.fromJson(Map<String,dynamic> map){

    return PaymentMethod(
      variable: map["variable"],
      value: map["value"],
    );

  }
}