class PaymentChargesResponse{

  List<dynamic>? Razorpay;
  List<dynamic>? Paytm;
  String? message;
  bool? status;

  PaymentChargesResponse({this.Razorpay, this.Paytm, this.message, this.status});

  factory PaymentChargesResponse.fromJson(Map<String,dynamic> map){

    return PaymentChargesResponse(
        Razorpay: map["Razorpay"],
        Paytm: map["Paytm"],
      status: map["status"],
      message: map["message"]
    );

  }

}

class PaymentPerGateway{

  List<dynamic>? Preferred_Method;
  List<dynamic>? Other_Method;
  PaymentPerGateway({this.Preferred_Method, this.Other_Method});

  factory PaymentPerGateway.fromJson(Map<String,dynamic> map){

    return PaymentPerGateway(
      Preferred_Method: map["Preferred_Method"],
      Other_Method: map["Other_Method"],
    );

  }
}

class PaymentMethod{

  String? variable,value;

  PaymentMethod({this.variable, this.value});

  factory PaymentMethod.fromJson(Map<String,dynamic> map){

    return PaymentMethod(
      variable: map["variable"],
      value: map["value"],
    );

  }
}