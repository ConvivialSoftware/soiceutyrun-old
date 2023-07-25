class PayOption {
  String? PAYTM_MERCHANT_MID;
  String? PAYTM_MERCHANT_KEY;
  String? UPI_URL;
  String? PAYTM_URL;
  String? ADD_NOTE;
  String? KEY_ID;
  String? SECRET_KEY;
  bool? Status;
  String? Message;
  String? CCAVENUE_ACCOUNT_ID;

  PayOption(
      {this.PAYTM_MERCHANT_MID,
        this.PAYTM_MERCHANT_KEY,
        this.PAYTM_URL,
        this.ADD_NOTE,
        this.KEY_ID,
        this.SECRET_KEY,
        this.Status,
        this.Message,
        this.CCAVENUE_ACCOUNT_ID,
        this.UPI_URL});

  factory PayOption.fromJson(Map<String, dynamic> map) {
    return PayOption(
        PAYTM_MERCHANT_MID: map["PAYTM_MERCHANT_MID"],
        PAYTM_MERCHANT_KEY: map["PAYTM_MERCHANT_KEY"],
        UPI_URL: map["UPI_URL"],
        PAYTM_URL: map["PAYTM_URL"],
        ADD_NOTE: map["ADD_NOTE"],
        KEY_ID: map["KEY_ID"],
        SECRET_KEY: map["SECRET_KEY"],
        Status: map["STATUS"],
        Message: map["Message"],
        CCAVENUE_ACCOUNT_ID: map["CCAVENUE_ACCOUNT_ID"]);
  }
}
