class DBNotificationPayload {
  String nid;
  String title;
  String body;
  String ID;
  String TYPE;
  String VID;
  String FROM_VISITOR;
  String IMAGE;
  String VISITOR_NAME;
  String CONTACT;
  String DATE_TIME;
  String Visitor_type;
  int read;

  DBNotificationPayload(
      {this.nid,
        this.title,
        this.ID,
        this.TYPE,
        this.body,
        this.VID,
        this.FROM_VISITOR,
        this.IMAGE,
        this.VISITOR_NAME,
        this.CONTACT,
        this.DATE_TIME,
        this.Visitor_type,
        this.read});

  DBNotificationPayload.fromJson(Map<String, dynamic> json) {
    nid = json['nid'];
    title = json['title'];
    ID = json['ID'];
    TYPE = json['TYPE'];
    body = json['body'];
    VID = json['VID'];
    FROM_VISITOR = json['FROM_VISITOR'];
    IMAGE = json['IMAGE'];
    VISITOR_NAME = json['VISITOR_NAME'];
    CONTACT = json['CONTACT'];
    DATE_TIME = json['DATE_TIME'];
    Visitor_type = json['Visitor_type'];
    read = json['read']??0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nid'] = this.nid;
    data['title'] = this.title;
    data['ID'] = this.ID;
    data['TYPE'] = this.TYPE;
    data['body'] = this.body;
    data['VID'] = this.VID;
    data['FROM_VISITOR'] = this.FROM_VISITOR;
    data['IMAGE'] = this.IMAGE;
    data['VISITOR_NAME'] = this.VISITOR_NAME;
    data['CONTACT'] = this.CONTACT;
    data['DATE_TIME'] = this.DATE_TIME;
    data['Visitor_type'] = this.Visitor_type;
    data['read'] = this.read;
    return data;
  }
}