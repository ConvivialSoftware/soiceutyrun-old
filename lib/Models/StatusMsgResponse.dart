import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class StatusMsgResponse {
  String? message;
  bool? status;
  String? pass_code;
  String? expire_time;
  String? otp;
  String? token;
  String? passCode;
  String? link;
  StatusMsgResponse(
      {this.message,
      this.status,
      this.pass_code,
      this.expire_time,
      this.otp,
      this.token,
      this.link,
      this.passCode});

  factory StatusMsgResponse.fromJson(Map<String, dynamic> map) {
    return StatusMsgResponse(
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]);
  }

  Map<String, dynamic> toJson() {
    return {GlobalVariables.STATUS: status, GlobalVariables.MESSAGE: message};
  }

  factory StatusMsgResponse.fromJsonWithMessage(Map<String, dynamic> map) {
    return StatusMsgResponse(
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]);
  }

  factory StatusMsgResponse.fromJsonWithDownloadMessage(
      Map<String, dynamic> map) {
    return StatusMsgResponse(
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE],
        link: map['data']);
  }

  factory StatusMsgResponse.fromJsonWithPassCode(Map<String, dynamic> map) {
    return StatusMsgResponse(
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE],
        pass_code: map[GlobalVariables.PassCode],
        passCode: map['passcode']);
  }

  factory StatusMsgResponse.fromJsonWithOTP(Map<String, dynamic> map) {
    return StatusMsgResponse(
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE],
        expire_time: map[GlobalVariables.ExpiredTime],
        otp: map[GlobalVariables.OTP]);
  }

  factory StatusMsgResponse.fromJsonERPToken(Map<String, dynamic> map) {
    return StatusMsgResponse(
      token: map[GlobalVariables.token],
    );
  }
}
