class GatePassPayload {
  String? msgID;
  String? title;
  String? body;
  String? iD;
  String? tYPE;
  String? sound;
  String? vID;
  String? rEASON;
  String? iNBY;
  String? uSERID;
  String? iNDATE;
  String? iNTIME;
  String? fROMVISITOR;
  String? iMAGE;
  String? vISITORNAME;
  String? cONTACT;
  String? nOOFVISITORS;
  String? dATETIME;
  String? vSITORTYPE;
  String? GCM_ID;
  bool? isBackGround;

  GatePassPayload(
      {this.msgID,
        this.title,
        this.iD,
        this.tYPE,
        this.sound,
        this.body,
        this.vID,
        this.rEASON,
        this.iNBY,
        this.uSERID,
        this.iNDATE,
        this.iNTIME,
        this.fROMVISITOR,
        this.iMAGE,
        this.vISITORNAME,
        this.cONTACT,
        this.nOOFVISITORS,
        this.dATETIME,
        this.vSITORTYPE,
        this.GCM_ID,
      this.isBackGround});

  GatePassPayload.fromJson(Map<String, dynamic> json) {
    msgID = json['msgID'];
    title = json['title'];
    iD = json['ID'];
    tYPE = json['TYPE'];
    sound = json['sound'];
    body = json['body'];
    vID = json['VID'];
    rEASON = json['REASON'];
    iNBY = json['IN_BY'];
    uSERID = json['USER_ID'];
    iNDATE = json['IN_DATE'];
    iNTIME = json['IN_TIME'];
    fROMVISITOR = json['FROM_VISITOR'];
    iMAGE = json['IMAGE'];
    vISITORNAME = json['VISITOR_NAME'];
    cONTACT = json['CONTACT'];
    nOOFVISITORS = json['NO_OF_VISITORS'];
    dATETIME = json['DATE_TIME'];
    vSITORTYPE = json['Visitor_type'];
    GCM_ID = json['GCM_ID'];
    isBackGround = json['isBackGround']??false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msgID'] = this.msgID;
    data['title'] = this.title;
    data['ID'] = this.iD;
    data['TYPE'] = this.tYPE;
    data['sound'] = this.sound;
    data['body'] = this.body;
    data['VID'] = this.vID;
    data['REASON'] = this.rEASON;
    data['IN_BY'] = this.iNBY;
    data['USER_ID'] = this.uSERID;
    data['IN_DATE'] = this.iNDATE;
    data['IN_TIME'] = this.iNTIME;
    data['FROM_VISITOR'] = this.fROMVISITOR;
    data['IMAGE'] = this.iMAGE;
    data['VISITOR_NAME'] = this.vISITORNAME;
    data['CONTACT'] = this.cONTACT;
    data['NO_OF_VISITORS'] = this.nOOFVISITORS;
    data['DATE_TIME'] = this.dATETIME;
    data['Visitor_type'] = this.vSITORTYPE;
    data['GCM_ID'] = this.GCM_ID;
    data['isBackGround'] = this.isBackGround;
    return data;
  }
}