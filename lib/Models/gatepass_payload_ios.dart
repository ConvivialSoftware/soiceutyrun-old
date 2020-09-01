class GatePassPayloadIos {
  int from;
  Payload payload;
  String msgID;

  GatePassPayloadIos({this.from, this.payload, this.msgID});

  GatePassPayloadIos.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    payload =
    json['payload'] != null ? new Payload.fromJson(json['payload']) : null;
    msgID = json['msgID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    if (this.payload != null) {
      data['payload'] = this.payload.toJson();
    }
    data['msgID'] = this.msgID;
    return data;
  }
}

class Payload {
  String cONTACT;
  String iNTIME;
  String sound;
  String uSERID;
  String title;
  String body;
  String vISITORNAME;
  String vID;
  String iNDATE;
  String iMAGE;
  String iNBY;
  String fROMVISITOR;
  String nOOFVISITORS;
  String iD;
  String dATETIME;
  String rEASON;
  String tYPE;

  Payload(
      {this.cONTACT,
        this.iNTIME,
        this.sound,
        this.uSERID,
        this.title,
        this.body,
        this.vISITORNAME,
        this.vID,
        this.iNDATE,
        this.iMAGE,
        this.iNBY,
        this.fROMVISITOR,
        this.nOOFVISITORS,
        this.iD,
        this.dATETIME,
        this.rEASON,
        this.tYPE});

  Payload.fromJson(Map<String, dynamic> json) {
    cONTACT = json['CONTACT'];
    iNTIME = json['IN_TIME'];
    sound = json['sound'];
    uSERID = json['USER_ID'];
    title = json['title'];
    body = json['body'];
    vISITORNAME = json['VISITOR_NAME'];
    vID = json['VID'];
    iNDATE = json['IN_DATE'];
    iMAGE = json['IMAGE'];
    iNBY = json['IN_BY'];
    fROMVISITOR = json['FROM_VISITOR'];
    nOOFVISITORS = json['NO_OF_VISITORS'];
    iD = json['ID'];
    dATETIME = json['DATE_TIME'];
    rEASON = json['REASON'];
    tYPE = json['TYPE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CONTACT'] = this.cONTACT;
    data['IN_TIME'] = this.iNTIME;
    data['sound'] = this.sound;
    data['USER_ID'] = this.uSERID;
    data['title'] = this.title;
    data['body'] = this.body;
    data['VISITOR_NAME'] = this.vISITORNAME;
    data['VID'] = this.vID;
    data['IN_DATE'] = this.iNDATE;
    data['IMAGE'] = this.iMAGE;
    data['IN_BY'] = this.iNBY;
    data['FROM_VISITOR'] = this.fROMVISITOR;
    data['NO_OF_VISITORS'] = this.nOOFVISITORS;
    data['ID'] = this.iD;
    data['DATE_TIME'] = this.dATETIME;
    data['REASON'] = this.rEASON;
    data['TYPE'] = this.tYPE;
    return data;
  }
}