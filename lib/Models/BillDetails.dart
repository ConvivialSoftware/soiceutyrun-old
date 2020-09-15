
class BillDetails {
  String INVOICE_NO;
  String FLAT_NO;
  String NAME;
  String START_DATE;
  String END_DATE;
  String DUE_DATE;
  String TYPE;
  String REMARK;
  String C_DATE;

  BillDetails(
      {this.INVOICE_NO,
      this.FLAT_NO,
      this.NAME,
      this.START_DATE,
      this.END_DATE,
      this.DUE_DATE,
      this.TYPE,
      this.REMARK,
      this.C_DATE});

  factory BillDetails.fromJson(Map<String, dynamic> map) {
    return BillDetails(
        INVOICE_NO: map["INVOICE_NO"],
        FLAT_NO: map["FLAT_NO"],
        NAME: map["NAME"],
        START_DATE: map["START_DATE"],
        END_DATE: map["END_DATE"],
        DUE_DATE: map["DUE_DATE"],
        TYPE: map["TYPE"],
        REMARK: map["REMARK"],
        C_DATE: map["C_DATE"]);
  }
}
