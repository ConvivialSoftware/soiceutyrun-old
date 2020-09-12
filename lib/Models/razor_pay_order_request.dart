class RazorPayOrderRequest {
  int amount;
  String currency;
  String receipt;
  int paymentCapture;

  RazorPayOrderRequest(
      {this.amount, this.currency, this.receipt, this.paymentCapture});

  RazorPayOrderRequest.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    currency = json['currency'];
    receipt = json['receipt'];
    paymentCapture = json['payment_capture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['receipt'] = this.receipt;
    data['payment_capture'] = this.paymentCapture;
    return data;
  }
}