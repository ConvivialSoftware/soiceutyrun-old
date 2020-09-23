

class PollOption {
  String ANS_ID;
  String ANS;
  String VOTES;
  bool isSelected;

  PollOption({this.ANS_ID, this.ANS,this.VOTES,this.isSelected=false});

  factory PollOption.fromJson(Map<String, dynamic> map){

    return PollOption(
        ANS_ID: map["ANS_ID"],
        ANS: map["ANS"],
        VOTES: map["VOTES"],
        isSelected: map["isSelected"]
    );

  }

}
