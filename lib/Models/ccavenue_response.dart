class AvenueResponse {
  String? orderId;
  String? accessCode;
  String? redirectUrl;
  String? cancelUrl;
  String? encVal;
  String? errorMessage;

  AvenueResponse(
      {this.orderId,
      this.accessCode,
      this.redirectUrl,
      this.cancelUrl,
      this.errorMessage,
      this.encVal});

  AvenueResponse.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    accessCode = json['access_code'];
    redirectUrl = json['redirect_url'];
    cancelUrl = json['cancel_url'];
    encVal = json['enc_val'];
  }
}
