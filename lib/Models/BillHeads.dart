
class BillHeads {
  String AMOUNT;
  String HEAD_NAME;
  String DESCRIPTION;

  BillHeads({this.AMOUNT, this.HEAD_NAME,this.DESCRIPTION});

  factory BillHeads.fromJson(Map<String, dynamic> map){

    return BillHeads(
        AMOUNT: map["AMOUNT"],
        HEAD_NAME: map["HEAD_NAME"],
        DESCRIPTION: map["DESCRIPTION"]
    );

  }

}
