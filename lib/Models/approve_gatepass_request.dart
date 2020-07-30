
class ApproveGatePassRequest {
  String vid,
      uid,
      reason,
      noOfVisitors,
      fromVisitor,
      visitorStatus,
      inBy,
      societyId;


  ApproveGatePassRequest(this.vid, this.uid, this.reason, this.noOfVisitors,
      this.fromVisitor, this.visitorStatus, this.inBy, this.societyId);

  ApproveGatePassRequest.fromJson(Map<String, dynamic> json) {
    vid = json['VID'];
    uid = json['USER_ID'];
    reason = json['REASON'];
    noOfVisitors = json['NO_OF_VISITOR'];
    fromVisitor = json['FROM_VISITOR'];
    visitorStatus = json['VISITOR_STATUS'];
    inBy = json['IN_BY'];
    societyId = json['SOCIETY_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['VID'] = this.vid;
    data['USER_ID'] = this.uid;
    data['REASON'] = this.reason;
    data['NO_OF_VISITOR'] = this.noOfVisitors;
    data['FROM_VISITOR'] = this.fromVisitor;
    data['VISITOR_STATUS'] = this.visitorStatus;
    data['IN_BY'] = this.inBy;
    data['SOCIETY_ID'] = this.societyId;
    return data;
  }
}
