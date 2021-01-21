import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/AllMemberResponse.dart';
import 'package:societyrun/Models/BankResponse.dart';
import 'package:societyrun/Models/BillViewResponse.dart';
import 'package:societyrun/Models/DataResponse.dart';
import 'package:societyrun/Models/DuesResponse.dart';
import 'package:societyrun/Models/GatePassResponse.dart';
import 'package:societyrun/Models/LedgerResponse.dart';
import 'package:societyrun/Models/LoginResponse.dart';
import 'package:societyrun/Models/MemberResponse.dart';
import 'package:societyrun/Models/ReceiptViewResponse.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'package:societyrun/Models/VehicleResponse.dart';
import 'package:societyrun/Models/razor_pay_order_request.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Retrofit/RestClientRazorPay.dart';

import 'RestClient.dart';
const bool kDebugMode = true;


class RestAPI implements RestClient, RestClientERP , RestClientRazorPay{
  RestAPI(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
    this.baseUrl ??= GlobalVariables.BaseURL;

    /*if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: false,
          request: true,
          requestBody: true));
    }*/
  }

  final Dio _dio;
  String baseUrl;

  RequestOptions newRequestOptions(Options options) {
    if (options is RequestOptions) {
      return options;
    }
    if (options == null) {
      return RequestOptions();
    }
    return RequestOptions(
      method: options.method,
      sendTimeout: options.sendTimeout,
      receiveTimeout: options.receiveTimeout,
      extra: options.extra,
      headers: options.headers,
      responseType: options.responseType,
      contentType: options.contentType,
      validateStatus: options.validateStatus,
      receiveDataWhenStatusError: options.receiveDataWhenStatusError,
      followRedirects: options.followRedirects,
      maxRedirects: options.maxRedirects,
      requestEncoder: options.requestEncoder,
      responseDecoder: options.responseDecoder,
    );

  }

  @override
  Future<LoginResponse> getLogin(String username, String password,String token) async {
// TODO: implement getLogin
    ArgumentError.checkNotNull(username, GlobalVariables.keyUsername);
    ArgumentError.checkNotNull(password, GlobalVariables.keyPassword);
    ArgumentError.checkNotNull(token, Platform.isIOS ? GlobalVariables.TOKEN_ID : GlobalVariables.keyToken);

    if(Platform.isIOS){
      GlobalVariables.keyToken =  GlobalVariables.keyTokenIOS;
    }
    FormData formData = FormData.fromMap({
      GlobalVariables.keyUsername: username,
      GlobalVariables.keyPassword: password,
      Platform.isIOS ? GlobalVariables.TOKEN_ID : GlobalVariables.keyToken:token
    });
    print('baseurl : ' + baseUrl + GlobalVariables.LoginAPI);
    print('LOGIN TOKEN >>>> $token');
    final Response _result = await _dio.post(GlobalVariables.LoginAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of login response : ' + value.toString());
    return LoginResponse.fromJson(value);
  }

  @override
  Future<LoginResponse> getOTPLogin(String expire_time, String otp,
      String send_otp, String mobile_no, String Email_id,String token) async {
    // TODO: implement getOTPLogin

    ArgumentError.checkNotNull(expire_time, "expire_time");
    ArgumentError.checkNotNull(otp, "otp");
    ArgumentError.checkNotNull(send_otp, "send_otp");
    ArgumentError.checkNotNull(mobile_no, "mobile_no");
    ArgumentError.checkNotNull(Email_id, "Email_id");
    ArgumentError.checkNotNull(token, Platform.isIOS ? GlobalVariables.TOKEN_ID : GlobalVariables.keyToken);

    FormData formData = FormData.fromMap({
      "expire_time": expire_time,
      "otp": otp,
      "send_otp": send_otp,
      "mobile_no": mobile_no,
      "Email_id": Email_id,
      Platform.isIOS ? GlobalVariables.TOKEN_ID : GlobalVariables.keyToken:token
    });
    print('baseurl : ' + baseUrl + GlobalVariables.otpLoginAPI);
    final Response _result = await _dio.post(GlobalVariables.otpLoginAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of login response : ' + value.toString());
    return LoginResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> getOTP(String mobile, String emailId) async {
// TODO: implement getOTP
    //ArgumentError.checkNotNull(mobile, "mobile_no");
    //ArgumentError.checkNotNull(emailId, "Email_id");

    FormData formData =
        FormData.fromMap({"mobile_no": mobile, "Email_id": emailId});
    print('baseurl : ' + baseUrl + GlobalVariables.otpSendAPI);
    final Response _result = await _dio.post(GlobalVariables.otpSendAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getOTP response : ' + value.toString());

    /*{status: false, message: Mobile no. not registered with Societyrun}*/
    /*{status: false, message: Your account is deactivated..!! Please try again..!!}*/
    /*{expire_time: 2020-05-27 03:01:25, otp: 053287, status: true, message: Otp Send}*/

    return StatusMsgResponse.fromJsonWithOTP(value);
  }

  @override
  Future<StatusMsgResponse> changeNewPassword(String societyId, String userId, String confirmPassword) async {
// TODO: implement changeNewPassword
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(userId, GlobalVariables.userID);
    ArgumentError.checkNotNull(confirmPassword, "confirm_pwd");

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.userID: userId,
      "confirm_pwd":confirmPassword
    });
    print('baseurl : ' + baseUrl + GlobalVariables.newPasswordAPI);
    final Response _result = await _dio.post(GlobalVariables.newPasswordAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of changeNewPassword response : ' + value.toString());

    return StatusMsgResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getAllSocietyData(
      String username/*, String password*/) async {
// TODO: implement getAllSocietyData
    ArgumentError.checkNotNull(username, GlobalVariables.keyUsername);
    //ArgumentError.checkNotNull(password, GlobalVariables.keyPassword);

    FormData formData = FormData.fromMap({
      GlobalVariables.keyUsername: username,
      //GlobalVariables.keyPassword: password
    });
    print('username : ' + username);
   // print('password : ' + password);
    print('baseurl : ' + baseUrl + GlobalVariables.AllSocietyAPI);
    final Response _result = await _dio.post(GlobalVariables.AllSocietyAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;


    print('value of getAllSocietyData : ' + value.toString());
    return DataResponse.fromJsonWithVersion(value);
  }

  @override
  Future<DuesResponse> getDuesData(
      String socId, String blockflat, String block) async {
    // TODO: implement getDuesData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(blockflat, GlobalVariables.flat);
    ArgumentError.checkNotNull(block, GlobalVariables.block);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.flat: blockflat,
      GlobalVariables.block: block
    });
    print(GlobalVariables.societyId + " " + socId);
    print(GlobalVariables.flat + " " + blockflat);
    print(GlobalVariables.block + " " + block);

    print('baseurlERP : ' + baseUrl + GlobalVariables.duesAPI);
    final Response _result = await _dio.post(GlobalVariables.duesAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTHERP,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getDuesData : ' + value.toString());
    return DuesResponse.fromJson(value);
  }

  @override
  Future<MemberResponse> getMembersData(
      String socId, String block, String flat) async {
    // TODO: implement getMembersData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat
    });
    print(GlobalVariables.societyId + ": " + socId);
    print(GlobalVariables.block + ": " + block);
    print(GlobalVariables.flat + ": " + flat);

    print('baseurl : ' + baseUrl + GlobalVariables.unitMemberAPI);
    final Response _result = await _dio.post(GlobalVariables.unitMemberAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getMembersData : ' + value.toString());
    return MemberResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getStaffData(String socId, String block, String flat) async {
    // TODO: implement getStaffData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);


    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat
    });
    print(GlobalVariables.societyId + ": " + socId);
    print(GlobalVariables.block + ": " + block);
    print(GlobalVariables.flat + ": " + flat);

    print('baseurl : ' + baseUrl + GlobalVariables.unitStaffAPI);
    final Response _result = await _dio.post(GlobalVariables.unitStaffAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getStaffData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getAllSocietyStaffData(String socId) async {
    // TODO: implement getStaffData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId
    });
    print(GlobalVariables.societyId + ": " + socId);

    print('baseurl : ' + baseUrl + GlobalVariables.unitStaffAPI);
    final Response _result = await _dio.post(GlobalVariables.unitStaffAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getStaffData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<VehicleResponse> getVehicleData(
      String socId, String block, String flat) async {
    // TODO: implement getVehicleData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat
    });
    print(GlobalVariables.societyId + ": " + socId);
    print(GlobalVariables.block + ": " + block);
    print(GlobalVariables.flat + ": " + flat);

    print('baseurl : ' + baseUrl + GlobalVariables.unitVehicleAPI);
    final Response _result = await _dio.post(GlobalVariables.unitVehicleAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('runtimeType of getVehicleData : ' + value.runtimeType.toString());
    print('value of getVehicleData : ' + value.toString());
    return VehicleResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getComplaintsData(String socId, String block, String flat,String userId,bool isAssignComplaint) async {
    // TODO: implement getComplaintsData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);

    //AppPermission.isUserAdminHelpDeskPermission=false;
    FormData formData = !AppPermission.isUserAdminHelpDeskPermission ? FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat
    }):FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
      GlobalVariables.userID: userId
    });
    print(GlobalVariables.societyId + ": " + socId);
    print(GlobalVariables.block + ": " + block);
    print(GlobalVariables.flat + ": " + flat);
    print(GlobalVariables.flat + ": " + flat);
    print(" isAssignComplaint " + isAssignComplaint.toString());

    var url = isAssignComplaint  ? GlobalVariables.assignComplaintsAPI: GlobalVariables.ComplaintsAPI;
    print('baseurl : ' + baseUrl + url);
    final Response _result = await _dio.post(url,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getComplaintData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getCommentData(String socId, String ticketNo) async {
    // TODO: implement getCommentData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(ticketNo, GlobalVariables.ticketNo);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.ticketNo: ticketNo,
    });
    print(GlobalVariables.societyId + ": " + socId);
    print(GlobalVariables.ticketNo + ": " + ticketNo);

    print('baseurl : ' + baseUrl + GlobalVariables.CommentAPI);
    final Response _result = await _dio.post(GlobalVariables.CommentAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getCommentData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getDocumentData(String societyId,String userId) async {
    // TODO: implement getDocumentData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(userId, GlobalVariables.userID);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.userID: userId,
    });
    print(GlobalVariables.societyId + ": " + societyId);
    print(GlobalVariables.userID + ": " + userId);

    print('baseurl : ' + baseUrl + GlobalVariables.DocumentAPI);
    final Response _result = await _dio.post(GlobalVariables.DocumentAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getDocumentData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> getUpdateComplaintStatus(
      String socId,
      String block,
      String flat,
      String userId,
      String ticketNo,
      String updateStatus,
      String comment,
      String attachment,
      String type,
      String escalationLevel,
      String socName,
      String eMail,
      String socEmail,
      String name) async {
    // TODO: implement getUpdateComplaintStatus
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);
    ArgumentError.checkNotNull(userId, GlobalVariables.userID);
    ArgumentError.checkNotNull(ticketNo, GlobalVariables.parentTicket);
    ArgumentError.checkNotNull(updateStatus, GlobalVariables.status);

    //  ArgumentError.checkNotNull(comment,GlobalVariables.COMMENT);
    ArgumentError.checkNotNull(type, GlobalVariables.TYPE);
    //   ArgumentError.checkNotNull(attachment,GlobalVariables.ATTACHMENT);
    ArgumentError.checkNotNull(
        escalationLevel, GlobalVariables.ESCALATION_LEVEL);

    ArgumentError.checkNotNull(socName, GlobalVariables.societyName);
    ArgumentError.checkNotNull(socEmail, GlobalVariables.societyEmail);
    ArgumentError.checkNotNull(eMail, GlobalVariables.userEmail);
    ArgumentError.checkNotNull(name, GlobalVariables.NAME);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
      GlobalVariables.userID: userId,
      GlobalVariables.parentTicket: ticketNo,
      GlobalVariables.status: updateStatus,
      GlobalVariables.COMMENT: comment,
      GlobalVariables.TYPE: type,
      GlobalVariables.ATTACHMENT: attachment,
      GlobalVariables.ESCALATION_LEVEL: escalationLevel,
      GlobalVariables.societyName: socName,
      GlobalVariables.societyEmail: socEmail,
      GlobalVariables.userEmail: eMail,
      GlobalVariables.NAME: name,
    });
    print(GlobalVariables.societyId + ": " + socId);
    print(GlobalVariables.ticketNo + ": " + ticketNo);

    print('baseurl : ' + baseUrl + GlobalVariables.UpdateStatusAPI);
    final Response _result = await _dio.post(GlobalVariables.UpdateStatusAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getUpdateComplaintStatus : ' + value.toString());
    return StatusMsgResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getComplaintsAreaData(String societyId) async {
    // TODO: implement getComplaintsAreaData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
    });
    print(GlobalVariables.societyId + ": " + societyId);

    print('baseurl : ' + baseUrl + GlobalVariables.ComplaintsAreaAPI);
    final Response _result = await _dio.post(GlobalVariables.ComplaintsAreaAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getComplaintsAreaData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getComplaintsCategoryData(String societyId) async {
    // TODO: implement getComplaintsCategoryData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
    });
    print(GlobalVariables.societyId + ": " + societyId);

    print('baseurl : ' + baseUrl + GlobalVariables.ComplaintsCategoryAPI);
    final Response _result =
        await _dio.post(GlobalVariables.ComplaintsCategoryAPI,
            options: RequestOptions(
                //method: GlobalVariables.Post,
                headers: <String, dynamic>{
                  "Authorization": GlobalVariables.AUTH,
                }, baseUrl: baseUrl),
            data: formData);
    final value = _result.data;
    print('value of getComplaintsCategoryData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> addComplaint(
      String socId,
      String block,
      String flat,
      String userId,
      String subject,
      String type,
     /* String area,*/
      String category,
      String description,
      String priority,
      String name,
      String attachment,
      String attachmentName,
      String socName,
      String eMail,
      String socEmail) async {
    // TODO: implement addComplaint
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);
    ArgumentError.checkNotNull(userId, GlobalVariables.userID);
    ArgumentError.checkNotNull(subject, GlobalVariables.SUBJECT);
    ArgumentError.checkNotNull(type, GlobalVariables.TYPE);
  //  ArgumentError.checkNotNull(area, GlobalVariables.COMPLAINT_AREA);
    ArgumentError.checkNotNull(category, GlobalVariables.CATEGORY);
    ArgumentError.checkNotNull(description, GlobalVariables.DESCRIPTION);
    ArgumentError.checkNotNull(priority, GlobalVariables.PRIORITY);
    ArgumentError.checkNotNull(name, GlobalVariables.NAME);
//    ArgumentError.checkNotNull(attachment,GlobalVariables.ATTACHMENT);
    ArgumentError.checkNotNull(socName, GlobalVariables.societyName);
    ArgumentError.checkNotNull(socEmail, GlobalVariables.societyEmail);
    ArgumentError.checkNotNull(eMail, GlobalVariables.userEmail);

//SUBJECT,TYPE,COMPLAINT_AREA,CATEGORY,DESCRIPTION,PRIORITY,NAME,ATTACHMENT
    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
      GlobalVariables.userID: userId,
      GlobalVariables.SUBJECT: subject,
      GlobalVariables.TYPE: type,
     // GlobalVariables.COMPLAINT_AREA: area,
      GlobalVariables.CATEGORY: category,
      GlobalVariables.PRIORITY: priority,
      GlobalVariables.DESCRIPTION: description,
      GlobalVariables.NAME: name,
      GlobalVariables.ATTACHMENT: attachment,
      GlobalVariables.ATTACHMENT_NAME: attachmentName,
      GlobalVariables.societyName: socName,
      GlobalVariables.societyEmail: socEmail,
      GlobalVariables.userEmail: eMail,
    });
    //print(GlobalVariables.societyId+": "+socId);
    //print(GlobalVariables.ticketNo+": "+ticketNo);

    print('baseurl : ' + baseUrl + GlobalVariables.AddComplaintsAPI);
    final Response _result = await _dio.post(GlobalVariables.AddComplaintsAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of addComplaint : ' + value.toString());
    return StatusMsgResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getAnnouncementData(
      String societyId, String type,String userId) async {
    // TODO: implement getAnnouncementData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(societyId, GlobalVariables.Type);
    ArgumentError.checkNotNull(userId, GlobalVariables.userID);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.Type: type,
      GlobalVariables.userID: userId,
    });
    print(GlobalVariables.societyId + ": " + societyId);
    print(GlobalVariables.Type + ": " + type);

    print('baseurl : ' + baseUrl + GlobalVariables.AnnouncementAPI);
    final Response _result = await _dio.post(GlobalVariables.AnnouncementAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getAnnouncementData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getCommitteeDirectoryData(String societyId) async {
    // TODO: implement getCommitteeDirectoryData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
    });
    print(GlobalVariables.societyId + ": " + societyId);

    print('baseurl : ' + baseUrl + GlobalVariables.CommitteeDirectoryAPI);
    final Response _result =
        await _dio.post(GlobalVariables.CommitteeDirectoryAPI,
            options: RequestOptions(
                //method: GlobalVariables.Post,
                headers: <String, dynamic>{
                  "Authorization": GlobalVariables.AUTH,
                }, baseUrl: baseUrl),
            data: formData);
    final value = _result.data;
    print('value of getCommitteeDirectoryData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getEmergencyDirectoryData(String societyId) async {
    // TODO: implement getEmergencyDirectoryData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
    });
    print(GlobalVariables.societyId + ": " + societyId);

    print('baseurl : ' + baseUrl + GlobalVariables.EmergencyDirectoryAPI);
    final Response _result =
        await _dio.post(GlobalVariables.EmergencyDirectoryAPI,
            options: RequestOptions(
                //method: GlobalVariables.Post,
                headers: <String, dynamic>{
                  "Authorization": GlobalVariables.AUTH,
                }, baseUrl: baseUrl),
            data: formData);
    final value = _result.data;
    print('value of getEmergencyDirectoryData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getNeighboursDirectoryData(String societyId) async {
    // TODO: implement getNeighboursDirectoryData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
    });

    print('baseurl : ' + baseUrl + GlobalVariables.NeighboursDirectoryAPI);
    final Response _result =
        await _dio.post(GlobalVariables.NeighboursDirectoryAPI,
            options: RequestOptions(
                //method: GlobalVariables.Post,
                headers: <String, dynamic>{
                  "Authorization": GlobalVariables.AUTH,
                }, baseUrl: baseUrl),
            data: formData);
    final value = _result.data;
    print('value of getNeighboursDirectoryData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getAnnouncementPollData(String societyId, String type,
      String block, String flat, String userId) async {
    // TODO: implement getAnnouncementPollData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);
    ArgumentError.checkNotNull(userId, GlobalVariables.userID);
    ArgumentError.checkNotNull(societyId, GlobalVariables.Type);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
      GlobalVariables.userID: userId,
      GlobalVariables.Type: type,
    });
    //print(GlobalVariables.societyId+": "+socId);
    //print(GlobalVariables.ticketNo+": "+ticketNo);

    print('baseurl : ' + baseUrl + GlobalVariables.AnnouncementPollAPI);
    final Response _result =
        await _dio.post(GlobalVariables.AnnouncementPollAPI,
            options: RequestOptions(
                //method: GlobalVariables.Post,
                headers: <String, dynamic>{
                  "Authorization": GlobalVariables.AUTH,
                }, baseUrl: baseUrl),
            data: formData);
    final value = _result.data;
    print('value of getAnnouncementPollData'
            ' : ' +
        value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> addMember(
      String socId,
      String block,
      String flat,
      String name,
      String gender,
      String dob,
      String userName,
      String mobile,
      String alternateMobile,
      String bloodGroup,
      String occupation,
      String livesHere,
      String membershipType,
      String address,
      String profilePic) async {
    // TODO: implement addMember
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);
    //ArgumentError.checkNotNull(name, GlobalVariables.NAME);
   //ArgumentError.checkNotNull(gender, GlobalVariables.GENDER);
    //ArgumentError.checkNotNull(dob, GlobalVariables.DOB);
    //ArgumentError.checkNotNull(userName, GlobalVariables.USER_NAME);
    //ArgumentError.checkNotNull(mobile, GlobalVariables.MOBILE);
    //ArgumentError.checkNotNull(bloodGroup, GlobalVariables.BLOOD_GROUP);
    //ArgumentError.checkNotNull(occupation, GlobalVariables.OCCUPATION);
    //ArgumentError.checkNotNull(hobbies, GlobalVariables.HOBBIES);
    ArgumentError.checkNotNull(membershipType, GlobalVariables.TYPE);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
      GlobalVariables.NAME: name,
      GlobalVariables.GENDER: gender,
      GlobalVariables.DOB: dob,
      GlobalVariables.USER_NAME: userName,
      GlobalVariables.MOBILE: mobile,
      GlobalVariables.ALTERNATE_CONTACT1: alternateMobile,
      GlobalVariables.BLOOD_GROUP: bloodGroup,
      GlobalVariables.OCCUPATION: occupation,
      GlobalVariables.LIVES_HERE: livesHere,
      GlobalVariables.TYPE: membershipType,
      GlobalVariables.ADDRESS: address,
      GlobalVariables.PROFILE_PHOTO: profilePic,
    });
    print(GlobalVariables.ALTERNATE_CONTACT1+": "+alternateMobile);

    print('baseurl : ' + baseUrl + GlobalVariables.unitAddMemberAPI);

   // print("Pic String: " + profilePic);
   // print('attachment lengtth : ' + profilePic.length.toString());
    final Response _result = await _dio.post(GlobalVariables.unitAddMemberAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of addMember : ' + value.toString());
    return StatusMsgResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> addVehicle(
      String socId,
      String block,
      String flat,
      String vehicleNo,
      String model,
      String wheel,
      String stickerNo,
      String userId) async {
    // TODO: implement addVehicle
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);
    ArgumentError.checkNotNull(vehicleNo, GlobalVariables.VEHICLE_NO);
    ArgumentError.checkNotNull(model, GlobalVariables.MODEL);
    ArgumentError.checkNotNull(wheel, GlobalVariables.WHEEL);
    ArgumentError.checkNotNull(stickerNo, GlobalVariables.STICKER_NO);
    ArgumentError.checkNotNull(userId, GlobalVariables.userID);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
      GlobalVariables.VEHICLE_NO: vehicleNo,
      GlobalVariables.MODEL: model,
      GlobalVariables.WHEEL: wheel,
      GlobalVariables.STICKER_NO: stickerNo,
      GlobalVariables.userID: userId,
    });
    //print(GlobalVariables.societyId+": "+socId);
    //print(GlobalVariables.ticketNo+": "+ticketNo);

    print('baseurl : ' + baseUrl + GlobalVariables.unitAddVehicleAPI);
    final Response _result = await _dio.post(GlobalVariables.unitAddVehicleAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of addVehicle : ' + value.toString());
    return StatusMsgResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> addScheduleVisitorGatePass(
      String socId,
      String block,
      String flat,
      String name,
      String mobile,
      String date,
      String userId) async {
    // TODO: implement addScheduleVisitorGatePass
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);
    ArgumentError.checkNotNull(name, GlobalVariables.NAME);
    ArgumentError.checkNotNull(mobile, GlobalVariables.MOBILE_NO);
    ArgumentError.checkNotNull(date, GlobalVariables.DATE);
    ArgumentError.checkNotNull(userId, GlobalVariables.userID);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
      GlobalVariables.NAME: name,
      GlobalVariables.MOBILE_NO: mobile,
      GlobalVariables.DATE: date,
      GlobalVariables.userID: userId,
    });
    print(GlobalVariables.NAME+": "+name);
    print(GlobalVariables.MOBILE_NO+": "+mobile);

    print('baseurl : ' + baseUrl + GlobalVariables.AddGatePassScheduleAPI);
    final Response _result =
        await _dio.post(GlobalVariables.AddGatePassScheduleAPI,
            options: RequestOptions(
                //method: GlobalVariables.Post,
                headers: <String, dynamic>{
                  "Authorization": GlobalVariables.AUTH,
                }, baseUrl: baseUrl),
            data: formData);
    final value = _result.data;
    print('value of addScheduleVisitorGatePass : ' + value.toString());
    return StatusMsgResponse.fromJsonWithPassCode(value);
  }

  @override
  Future<GatePassResponse> getGatePassData(
      String societyId, String block, String flat) async {
    // TODO: implement getGatePassData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
    });
    //print(GlobalVariables.societyId+": "+socId);
    //print(GlobalVariables.ticketNo+": "+ticketNo);

    print('baseurl : ' + baseUrl + GlobalVariables.GatePassAPI);
    final Response _result = await _dio.post(GlobalVariables.GatePassAPI,
        options: RequestOptions(
            //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getGatePassData'
            ' : ' +
        value.toString());

    /*{visitor: [{ID: 489, SID: 59, VISITOR_NAME: Ashish Tiwari, CONTACT: 9867579867,
     IMAGE: https://societyrun.com//Uploads/637362_2019-06-08_15:03:51.jpg, VEHICLE_NO: MH 12 GH 3456,
     IN_DATE: 29th Apr, NO_OF_VISITOR: null, VISITOR_USER_STATUS: , COMMENT_USER: , IN_TIME: 09:25 PM, OUT_DATE: ,
      OUT_TIME: , FROM_VISITOR: null, FLAT_NO: Block A 301, STATUS: In, VISITOR_STATUS: , REASON: Driver, TYPE: Staff,
       visitor_info: {VISITOR_NAME: Ashish Tiwari, CONTACT: 9867579867}}, */

    return GatePassResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getGatePassScheduleVisitorData(
      String societyId, String block, String flat) async {
    // TODO: implement getGatePassData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
    });
    //print(GlobalVariables.societyId+": "+socId);
    //print(GlobalVariables.ticketNo+": "+ticketNo);

    print('baseurl : ' + baseUrl + GlobalVariables.GetGatePassScheduleAPI);
    final Response _result =
        await _dio.post(GlobalVariables.GetGatePassScheduleAPI,
            options: RequestOptions(
                //method: GlobalVariables.Post,
                headers: <String, dynamic>{
                  "Authorization": GlobalVariables.AUTH,
                }, baseUrl: baseUrl),
            data: formData);
    final value = _result.data;
    print('value of getGatePassScheduleVisitorData'
            ' : ' +
        value.toString());

/*{data: [{DATE: 2021-08-04, MOBILE_NO: +9183788602, NAME: Akash Agarwal, PASS_CODE: },
{DATE: 2020-05-28, MOBILE_NO: 9726197065, NAME: Julie, PASS_CODE: 115200}], status: true, message: visitor data}
*/

    return DataResponse.fromJson(value);
  }


  @override
  Future<LedgerResponse> getLedgerData(String socId, String flat, String block) async {
    // TODO: implement getLedgerData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.flat);
    ArgumentError.checkNotNull(block, GlobalVariables.block);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.flat: flat,
      GlobalVariables.block: block
    });
    print(GlobalVariables.societyId + " " + socId);
    print(GlobalVariables.flat + " " + flat);
    print(GlobalVariables.block + " " + block);

    print('baseurlERP : ' + baseUrl + GlobalVariables.ledgerAPI);
    final Response _result = await _dio.post(GlobalVariables.ledgerAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTHERP,
            },
            baseUrl: baseUrl,
       //   contentType: ContentType.parse("application/x-www-form-urlencoded"),
          //followRedirects: true,
         // validateStatus: (status){return status<500;}

        ),
        data: formData);
    final value = _result.data;
    //print('runtimeType of getLedgerData : ' + value.runtimeType.toString());
    print('value of getLedgerData : ' + value.toString());
   // print('value of getLedgerData length : ' + value.toString().length.toString());


   // var jsons = json.decode(value);
   // Map<String, dynamic> map = json.decode(jsons);
   // print('value of getLedgerData : ' + map.toString());
    return LedgerResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getAllBillData(String socId, String flat, String block) async {
    // TODO: implement getAllBillData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.flat);
    ArgumentError.checkNotNull(block, GlobalVariables.block);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.flat: flat,
      GlobalVariables.block: block
    });
    print(GlobalVariables.societyId + ":" + socId);
    print(GlobalVariables.flat + ":" + flat);
    print(GlobalVariables.block + ":" + block);

    print('baseurlERP : ' + baseUrl + GlobalVariables.viewBillsAPI);
    final Response _result = await _dio.post(GlobalVariables.viewBillsAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTHERP,
            }, baseUrl: baseUrl,
        //  contentType: ContentType.parse("application/x-www-form-urlencoded"),
          //  followRedirects: false,
           // validateStatus: (status){return status<500;}

        ),
        data: formData);
    final value = _result.data;
    print('value of getAllBillData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<BankResponse> getBankData(String socId, String invoiceNo) async {
    // TODO: implement getBankData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
   // ArgumentError.checkNotNull(invoiceNo, GlobalVariables.INVOICE_NO);
    //ArgumentError.checkNotNull(block, GlobalVariables.block);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.INVOICE_NO: invoiceNo,
     // GlobalVariables.block: block
    });
    print(GlobalVariables.societyId + ":" + socId);
   // print(GlobalVariables.flat + ":" + flat);
    print(GlobalVariables.INVOICE_NO + ":" + invoiceNo.toString());

    print('baseurlERP : ' + baseUrl + GlobalVariables.bankAPI);
    final Response _result = await _dio.post(GlobalVariables.bankAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
          headers: <String, dynamic>{
            "Authorization": GlobalVariables.AUTHERP,
          }, baseUrl: baseUrl,
        //  contentType: ContentType.parse("application/x-www-form-urlencoded"),
          //  followRedirects: false,
          // validateStatus: (status){return status<500;}

        ),
        data: formData);
    final value = _result.data;
    print('value of getBankData : ' + value.toString());
    return BankResponse.fromJson(value);
  }

  @override
  Future<BillViewResponse> getBillData(String socId, String flat, String block, String invoiceNo) async {
    // TODO: implement getBillData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.flat);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(invoiceNo, GlobalVariables.INVOICE_NO);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.flat: flat,
      GlobalVariables.block: block,
      GlobalVariables.INVOICE_NO: invoiceNo
    });
    print(GlobalVariables.societyId + ":" + socId);
    print(GlobalVariables.flat + ":" + flat);
    print(GlobalVariables.block + ":" + block);
    print(GlobalVariables.INVOICE_NO + ":" + invoiceNo);

    print('baseurlERP : ' + baseUrl + GlobalVariables.billAPI);
    final Response _result = await _dio.post(GlobalVariables.billAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
          headers: <String, dynamic>{
            "Authorization": GlobalVariables.AUTHERP,
          }, baseUrl: baseUrl,
         // contentType: ContentType.parse("application/x-www-form-urlencoded"),
          //  followRedirects: false,
          // validateStatus: (status){return status<500;}

        ),
        data: formData);
    final value = _result.data;
    print('value of getBillData : ' + value.toString());
    return BillViewResponse.fromJson(value);
  }

  @override
  Future<ReceiptViewResponse> getReceiptData(String socId, String flat, String block, String receiptNo) async {
    // TODO: implement getReceiptData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.flat);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(receiptNo, GlobalVariables.RECEIPT_NO);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.flat: flat,
      GlobalVariables.block: block,
      GlobalVariables.RECEIPT_NO: receiptNo
    });
    print(GlobalVariables.societyId + ":" + socId);
    print(GlobalVariables.flat + ":" + flat);
    print(GlobalVariables.block + ":" + block);
    print(GlobalVariables.RECEIPT_NO + ":" + receiptNo);

    print('baseurlERP : ' + baseUrl + GlobalVariables.receiptAPI);
    final Response _result = await _dio.post(GlobalVariables.receiptAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
          headers: <String, dynamic>{
            "Authorization": GlobalVariables.AUTHERP,
          }, baseUrl: baseUrl,
          //contentType: ContentType.parse("application/x-www-form-urlencoded"),
          //  followRedirects: false,
          // validateStatus: (status){return status<500;}

        ),
        data: formData);
    final value = _result.data;
    print('value of getReceiptData : ' + value.toString());
    return ReceiptViewResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> addAlreadyPaidPaymentRequest(String socId, String flat, String block, String invoiceNo,
      String amount, String referenceNo, String transactionMode, String bankAccountNo, String paymentDate,
      String userId, String narration, String checkBankName, String attachment, String status) async {
    // TODO: implement addAlreadyPaidPaymentRequest
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);
    ArgumentError.checkNotNull(invoiceNo, GlobalVariables.INVOICE_NO);
    ArgumentError.checkNotNull(amount, GlobalVariables.AMOUNT);
    ArgumentError.checkNotNull(referenceNo, GlobalVariables.REFERENCE_NO);
    ArgumentError.checkNotNull(transactionMode, GlobalVariables.TRANSACTION_MODE);
    ArgumentError.checkNotNull(bankAccountNo, GlobalVariables.BANK_ACCOUNTNO);
    ArgumentError.checkNotNull(paymentDate, GlobalVariables.PAYMENT_DATE);
    ArgumentError.checkNotNull(userId, GlobalVariables.userID);
    ArgumentError.checkNotNull(checkBankName, GlobalVariables.CHEQUE_BANKNAME);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
      GlobalVariables.AMOUNT: amount,
      GlobalVariables.REFERENCE_NO: referenceNo,
      GlobalVariables.INVOICE_NO: invoiceNo,
      GlobalVariables.TRANSACTION_MODE: transactionMode,
      GlobalVariables.BANK_ACCOUNTNO: bankAccountNo,
      GlobalVariables.PAYMENT_DATE: paymentDate,
      GlobalVariables.userID: userId,
      GlobalVariables.NARRATION: narration,
      GlobalVariables.CHEQUE_BANKNAME: checkBankName,
      GlobalVariables.ATTACHMENT: attachment,
      GlobalVariables.status: status
    });
    print(GlobalVariables.status+": "+status);

    print('baseurl : ' + baseUrl + GlobalVariables.paymentRequestAPI);

   // print("Pic String: " + attachment.toString());
   // print('attachment lengtth : ' + attachment.length.toString());
    final Response _result = await _dio.post(GlobalVariables.paymentRequestAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of addAlreadyPaidPaymentRequest : ' + value.toString());
    return StatusMsgResponse.fromJson(value);
  }


  @override
  Future<StatusMsgResponse> addOnlinePaymentRequest(String socId, String flat, String block, String invoiceNo, String amount, String referenceNo, String transactionMode, String bankAccountNo, String paymentDate,String paymentStatus,String orderID) async {
    // TODO: implement addOnlinePaymentRequest
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);
    ArgumentError.checkNotNull(invoiceNo, GlobalVariables.INVOICE_NO);
    ArgumentError.checkNotNull(amount, GlobalVariables.AMOUNT);
    ArgumentError.checkNotNull(referenceNo, GlobalVariables.REFERENCE_NO);
    ArgumentError.checkNotNull(transactionMode, GlobalVariables.TRANSACTION_MODE);
    ArgumentError.checkNotNull(bankAccountNo, GlobalVariables.BANK_ACCOUNTNO);
    ArgumentError.checkNotNull(paymentDate, GlobalVariables.PAYMENT_DATE);
    ArgumentError.checkNotNull(orderID, GlobalVariables.orderID);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
      GlobalVariables.AMOUNT: amount,
      GlobalVariables.REFERENCE_NO: referenceNo,
      GlobalVariables.INVOICE_NO: invoiceNo,
      GlobalVariables.TRANSACTION_MODE: transactionMode,
      GlobalVariables.BANK_ACCOUNTNO: bankAccountNo,
      GlobalVariables.PAYMENT_DATE: paymentDate,
      GlobalVariables.ATTACHMENT:"",
      GlobalVariables.RESPONSE:"",
      GlobalVariables.status:paymentStatus,
      GlobalVariables.orderID:orderID
    });
    print(GlobalVariables.AMOUNT+": "+amount.toString());
    print(GlobalVariables.societyId+": "+socId.toString());
    print(GlobalVariables.INVOICE_NO+": "+invoiceNo.toString());
    print(GlobalVariables.PAYMENT_DATE+": "+paymentDate.toString());
    print(GlobalVariables.status+": "+paymentStatus.toString());
    print(GlobalVariables.orderID+": "+orderID.toString());

    print('baseurl : ' + baseUrl + GlobalVariables.insertPaymentAPI);

    // print("Pic String: " + attachment.toString());
    // print('attachment lengtth : ' + attachment.length.toString());
    final Response _result = await _dio.post(GlobalVariables.insertPaymentAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of addOnlinePaymentRequest : ' + value.toString());
    return StatusMsgResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getProfileData(String societyId, String userId) async {
    // TODO: implement getProfileData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(userId, GlobalVariables.userID);

    FormData formData = FormData.fromMap(
        {GlobalVariables.societyId: societyId, GlobalVariables.userID: userId});

    print('baseurl : ' + baseUrl + GlobalVariables.profileAPI);
    final Response _result = await _dio.post(GlobalVariables.profileAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;

    print('value of getProfileData : ' + value.toString());

    return DataResponse.fromJson(value);
  }


  @override
  Future<DataResponse> editProfileInfo(String societyId, String userId,
      String name, String phone, String altCon1, String profilePhoto,
      String address, String gender, String dob, String bloodGroup, String occupation,
      String email, String type,String livesHere) async {
    // TODO: implement editProfileInfo
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(userId, GlobalVariables.userID);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.userID: userId,
      GlobalVariables.PROFILE_PHOTO:profilePhoto,
      GlobalVariables.TYPE:type,
      GlobalVariables.LIVES_HERE:livesHere,
      GlobalVariables.NAME:name,
      GlobalVariables.MOBILE:phone,
      GlobalVariables.ALTERNATE_CONTACT1:altCon1,
      GlobalVariables.GENDER:gender,
      GlobalVariables.DOB:dob,
      GlobalVariables.BLOOD_GROUP:bloodGroup,
      GlobalVariables.OCCUPATION:occupation,
      GlobalVariables.Email:email,
      GlobalVariables.ADDRESS:address

      //GlobalVariables.
    });

    print('DOB : '+dob);
    print('phone : '+phone);
    print('Address : '+address);

    print('profilePhoto : ' + profilePhoto.toString());
    print('baseurl : ' + baseUrl + GlobalVariables.editProfileAPI);
    final Response _result = await _dio.post(GlobalVariables.editProfileAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;

    print('value of editProfileData : ' + value.toString());

    return DataResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getPayOptionData(String societyId) async {
    // TODO: implement getPayOptionData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);

    FormData formData =
        FormData.fromMap({GlobalVariables.societyId: societyId});

    print('baseurl : ' + baseUrl + GlobalVariables.payOptionAPI);
    final Response _result = await _dio.post(GlobalVariables.payOptionAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;

    print('value of getPayOptionData : ' + value.toString());

    return DataResponse.fromJson(value);
  }


  @override
  Future<DataResponse> getStaffMobileVerifyData(societyId, String contact) async {
    // TODO: implement getStaffMobileVerifyData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(contact, GlobalVariables.Contact);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.Contact: contact
    });

    print('baseurl : ' + baseUrl + GlobalVariables.staffMobileVerifyAPI);
    final Response _result = await _dio.post(GlobalVariables.staffMobileVerifyAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;

    print('value of getStaffMobileVerifyData : ' + value.toString());

    return DataResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> addStaffMember(String socId, String block, String flat, String name,
      String gender, String dob, String mobile, String qualification, String address,
      String notes, String userId, String role, String picture, String identityProof, String vehicleNo) async {
    // TODO: implement addStaffMember
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);
    ArgumentError.checkNotNull(name, GlobalVariables.STAFF_NAME);
    ArgumentError.checkNotNull(gender, GlobalVariables.GENDER);
    ArgumentError.checkNotNull(dob, GlobalVariables.DOB);
    ArgumentError.checkNotNull(userId, GlobalVariables.userID);
    ArgumentError.checkNotNull(mobile, GlobalVariables.Contact);
    ArgumentError.checkNotNull(qualification, GlobalVariables.QUALIFICATION);
    ArgumentError.checkNotNull(address, GlobalVariables.ADDRESS);
    ArgumentError.checkNotNull(notes, GlobalVariables.NOTES);
    ArgumentError.checkNotNull(role, GlobalVariables.ROLE);
   // ArgumentError.checkNotNull(vehicleNo, GlobalVariables.VEHICLE_NO);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
      GlobalVariables.STAFF_NAME: name,
      GlobalVariables.GENDER: gender,
      GlobalVariables.DOB: dob,
      GlobalVariables.userID: userId,
      GlobalVariables.Contact: mobile,
      GlobalVariables.QUALIFICATION: qualification,
      GlobalVariables.ADDRESS: address,
      GlobalVariables.NOTES: notes,
      GlobalVariables.VEHICLE_NO: vehicleNo,
      GlobalVariables.IDENTITY_PROOF: identityProof,
      GlobalVariables.PHOTO: picture,
    });
    //print(GlobalVariables.societyId+": "+socId);

    print('baseurl : ' + baseUrl + GlobalVariables.addStaffMemberAPI);
    final Response _result = await _dio.post(GlobalVariables.addStaffMemberAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of addStaffMember : ' + value.toString());
    return StatusMsgResponse.fromJson(value);
  }

  /*approve visitor*/
  @override
  Future<DataResponse> postApproveGatePass(
      String id,
      String visitorStatus,
      String gcmId,
      String societyId,
      ) async {
    FormData formData = FormData.fromMap({
      GatePassFields.ID: id,
      GatePassFields.VISITOR_STATUS: visitorStatus,
      GatePassFields.GCM_ID: gcmId,
      GatePassFields.SOCIETY_ID: societyId,
    });
    print('baseurl : ' + baseUrl + GlobalVariables.approveGatePassAPI);

    final Response _result = await _dio.post(GlobalVariables.approveGatePassAPI,
        options: RequestOptions(
            method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            },
            baseUrl: GlobalVariables.BaseURL),
        data: formData);
    final value = _result.data;
    print('value of postApproveGatePass : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  /*@override
  Future<DataResponse> postRejectGatePass (
      String id, String societyId, String comment, String status)async {

    FormData formData = FormData.fromMap({
      GatePassFields.ID: id,
      GatePassFields.SOCIETY_ID: societyId,
      GatePassFields.COMMENT: comment,
      GatePassFields.STATUS: status,
    });

    final Response _result = await _dio.post(GlobalVariables.rejectGatepassAPI,
        options: RequestOptions(
            method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            },
            baseUrl: GlobalVariables.BaseURL),
        data: formData);
    final value = _result.data;


    return DataResponse.fromJson(value);
  }
*/
  @override
  Future<StatusMsgResponse> getBillMail(String socId, String type, String number,String emailId) async {
    // TODO: implement getBillMail
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(type, GlobalVariables.TYPE);
    ArgumentError.checkNotNull(number, GlobalVariables.NUMBER);
    ArgumentError.checkNotNull(emailId, GlobalVariables.Email_id);

    FormData formData =
    FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.TYPE: type,
      GlobalVariables.NUMBER: number,
      GlobalVariables.Email_id: emailId
    });
    print('baseurl : ' + baseUrl + GlobalVariables.mailAPI);
    final Response _result = await _dio.post(GlobalVariables.mailAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getBillMail response : ' + value.toString());

    return StatusMsgResponse.fromJsonWithMessage(value);
  }

  @override
  Future<StatusMsgResponse> getResendOTP(String otp, String mobile, String emailId) async {
    // TODO: implement getResendOTP
    ArgumentError.checkNotNull(mobile, "mobile_no");
    ArgumentError.checkNotNull(emailId, "Email_id");
    ArgumentError.checkNotNull(otp, "otp");

    FormData formData =
    FormData.fromMap({
      "mobile_no": mobile,
      "Email_id": emailId,
      "otp": otp
    });
    print('otp : ' + otp);
    print('baseurl : ' + baseUrl + GlobalVariables.otpReSendAPI);
    final Response _result = await _dio.post(GlobalVariables.otpReSendAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getResendOTP response : ' + value.toString());

    /*{status: false, message: Mobile no. not registered with Societyrun}*/
    /*{status: false, message: Your account is deactivated..!! Please try again..!!}*/
    /*{expire_time: 2020-05-27 03:01:25, otp: 053287, status: true, message: Otp Send}*/

    return StatusMsgResponse.fromJsonWithOTP(value);
  }

  @override
  Future<DataResponse> getBannerData() async {
    // TODO: implement getBannerData
    print('baseurl : ' + baseUrl + GlobalVariables.bannerAPI);
    final Response _result = await _dio.post(GlobalVariables.bannerAPI,
        options: RequestOptions(
            method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            },
            baseUrl: GlobalVariables.BaseURL),
    //    data: formData
    );
    final value = _result.data;
    print('value of getBannerData : ' + value.toString());
    return DataResponse.fromJsonBanner(value);
  }

  @override
  Future<DataResponse> getComplaintDataAgainstTicketNo(String socId, String ticketNo) async {
    // TODO: implement getComplaintDataAgainstTicketNo
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(ticketNo, GlobalVariables.parentTicket);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.parentTicket: ticketNo
    });
    print(GlobalVariables.societyId + ": " + socId);
    print(GlobalVariables.parentTicket + ": " + ticketNo);

    print('baseurl : ' + baseUrl + GlobalVariables.TicketNoComplaintAPI);
    final Response _result = await _dio.post(GlobalVariables.TicketNoComplaintAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getComplaintDataAgainstTicketNo : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<AllMemberResponse> getAllMemberDirectoryData(String societyId) async {
    // TODO: implement getAllMemberDirectoryData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
    });
    print(GlobalVariables.societyId + ": " + societyId);

    print('baseurl : ' + baseUrl + GlobalVariables.allMemberAPI);
    final Response _result = await _dio.post(GlobalVariables.allMemberAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getAllMemberDirectoryData : ' + value.toString());
    return AllMemberResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> addFeedback(String socId, String block, String flat, String name, String subject, String description, String attachment) async {
    // TODO: implement addFeedback
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);
    ArgumentError.checkNotNull(name, GlobalVariables.STAFF_NAME);
    ArgumentError.checkNotNull(subject, 'Subject');
    ArgumentError.checkNotNull(description, 'Description');


    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat,
      GlobalVariables.societyName: name,
      'Subject': subject,
      'Description': description,
      'Attachment': attachment,
    });

    print('baseurl : ' + baseUrl + GlobalVariables.feedbackAPI);
    final Response _result = await _dio.post(GlobalVariables.feedbackAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of addFeedback : ' + value.toString());
    return StatusMsgResponse.fromJson(value);
  }

  @override
  Future<Map<String, dynamic>> getRazorPayOrderID(RazorPayOrderRequest request,String razorKey, String secretKey) async {

    var authorizedToken = razorKey+":"+secretKey;
    print('baseurl : ' + baseUrl + GlobalVariables.razorPayOrderAPI);
    final Response _result = await _dio.post(GlobalVariables.razorPayOrderAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": "Basic "+base64Url.encode(utf8.encode(authorizedToken)),
              "Content-type":"application/json"
            }, baseUrl: baseUrl),
        data: request);
    final value = _result.data;
    print('value of getRazorPayOrderID : ' + value.toString());
    return value;
  }

  @override
  Future<StatusMsgResponse> postRazorPayTransactionOrderID(String socId, String flat, String orderId, String amount) async {
    // TODO: implement postRazorPayTransactionOrderID
    ArgumentError.checkNotNull(socId, "SOCIETY_ID");
    ArgumentError.checkNotNull(flat, "FLAT_NO");
    ArgumentError.checkNotNull(orderId,"ORDER_ID");
    ArgumentError.checkNotNull(amount,"AMOUNT");

    FormData formData =
    FormData.fromMap({
      "SOCIETY_ID": socId,
      "FLAT_NO": flat,
      "ORDER_ID": orderId,
      "AMOUNT": amount
    });
    print('baseurl : ' + baseUrl + GlobalVariables.razorPayTransactionAPI);
    final Response _result = await _dio.post(GlobalVariables.razorPayTransactionAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getBillMail response : ' + value.toString());

    return StatusMsgResponse.fromJsonWithMessage(value);
  }

  @override
  Future<StatusMsgResponse> userLogout(String societyId, String userId, String gcmId) async {
    // TODO: implement userLogout
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(userId,GlobalVariables.userID);
    ArgumentError.checkNotNull(gcmId,GlobalVariables.GCM_ID);

    FormData formData =
    FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.userID: userId,
      GlobalVariables.GCM_ID:gcmId
    });
    print('baseurl : ' + baseUrl + GlobalVariables.logoutAPI);
    final Response _result = await _dio.post(GlobalVariables.logoutAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of userLogout response : ' + value.toString());

    return StatusMsgResponse.fromJsonWithMessage(value);
  }

  @override
  Future<StatusMsgResponse> addPollVote(String societyId, String userId, String block, String flat, String pollId, String optionId) async {
    // TODO: implement addPollVote
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(userId,GlobalVariables.userID);
    ArgumentError.checkNotNull(block,GlobalVariables.block);
    ArgumentError.checkNotNull(flat,GlobalVariables.flat);
    ArgumentError.checkNotNull(pollId,GlobalVariables.ID);
    ArgumentError.checkNotNull(optionId,GlobalVariables.OPTION);

    FormData formData =
    FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.userID: userId,
      GlobalVariables.block:block,
      GlobalVariables.flat:flat,
      GlobalVariables.ID:pollId,
      GlobalVariables.OPTION:optionId
    });
    print('ID : ' + pollId);
    print('OPTION : ' + optionId);
    print('baseurl : ' + baseUrl + GlobalVariables.pollVoteAPI);
    final Response _result = await _dio.post(GlobalVariables.pollVoteAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of addPollVote response : ' + value.toString());

    return StatusMsgResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> addGatePassWrongEntry(String societyId, String id, String status) async {
    // TODO: implement addGatePassWrongEntry
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(id,GlobalVariables.ID);
    ArgumentError.checkNotNull(status,GlobalVariables.status);

    FormData formData =
    FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.ID: id,
      GlobalVariables.status:status
    });
    print('baseurl : ' + baseUrl + GlobalVariables.gatePassWrongEntryAPI);
    final Response _result = await _dio.post(GlobalVariables.gatePassWrongEntryAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of addGatePassWrongEntry response : ' + value.toString());

    return StatusMsgResponse.fromJsonWithMessage(value);
  }

  @override
  Future<StatusMsgResponse> deleteExpectedVisitor(String societyId, String srNo) async {
    // TODO: implement deleteExpectedVisitor
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(srNo,GlobalVariables.SR_NO);

    FormData formData =
    FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.SR_NO: srNo
    });
    print('baseurl : ' + baseUrl + GlobalVariables.deleteExpectedVisitorAPI);
    final Response _result = await _dio.post(GlobalVariables.deleteExpectedVisitorAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of deleteExpectedVisitor response : ' + value.toString());

    return StatusMsgResponse.fromJsonWithMessage(value);
  }

  @override
  Future<DataResponse> getExpenseAccountLedger(String societyId) async {
    // TODO: implement getExpenseAccountLedger
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
    });
    print(GlobalVariables.societyId + ": " + societyId);

    print('baseurl : ' + baseUrl + GlobalVariables.accountLedgerAPI);
    final Response _result = await _dio.post(GlobalVariables.accountLedgerAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getExpenseAccountLedger : ' + value.toString());
    return DataResponse.fromJsonExpense(value);
  }

  @override
  Future<DataResponse> getExpenseData(String societyId) async {
    // TODO: implement getExpenseData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
    });
    print(GlobalVariables.societyId + ": " + societyId);

    print('baseurl : ' + baseUrl + GlobalVariables.expenseAPI);
    final Response _result = await _dio.post(GlobalVariables.expenseAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getExpenseData : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<DataResponse> getExpenseBankAccount(String societyId) async {
    // TODO: implement getExpenseBankAccount
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
    });
    print(GlobalVariables.societyId + ": " + societyId);

    print('baseurl : ' + baseUrl + GlobalVariables.expenseBankAPI);
    final Response _result = await _dio.post(GlobalVariables.expenseBankAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getExpenseBankAccount : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> addExpense(String societyId, String amount, String referenceNo,
      String transactionType, String bank, String ledgerId, String date, String narration, String attachment) async {
    // TODO: implement addExpense
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(amount, GlobalVariables.AMOUNT);
    ArgumentError.checkNotNull(referenceNo, GlobalVariables.REFERENCE_NO);
    ArgumentError.checkNotNull(transactionType, GlobalVariables.TRANSACTION_TYPE);
    ArgumentError.checkNotNull(bank, GlobalVariables.BANK);
    ArgumentError.checkNotNull(date, GlobalVariables.DATE);
    ArgumentError.checkNotNull(ledgerId, GlobalVariables.LEDGER_ID);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.AMOUNT: amount,
      GlobalVariables.REFERENCE_NO: referenceNo,
      GlobalVariables.TRANSACTION_TYPE: transactionType,
      GlobalVariables.BANK: bank,
      GlobalVariables.DATE: date,
      GlobalVariables.LEDGER_ID: ledgerId,
      GlobalVariables.NARRATION: narration,
      GlobalVariables.ATTACHMENT: attachment
    });
    print(GlobalVariables.societyId+": "+societyId);

    print('baseurl : ' + baseUrl + GlobalVariables.addExpenseAPI);

    // print("Pic String: " + attachment.toString());
    // print('attachment lengtth : ' + attachment.length.toString());
    final Response _result = await _dio.post(GlobalVariables.addExpenseAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of addExpense : ' + value.toString());
    return StatusMsgResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> getReceiptMail(String socId, String receiptNo, String emailId) async {
    // TODO: implement getReceiptMail
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(receiptNo, GlobalVariables.RECEIPT_NO);
    ArgumentError.checkNotNull(emailId, GlobalVariables.EMAIL_ID);

    FormData formData =
    FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.RECEIPT_NO: receiptNo,
      GlobalVariables.EMAIL_ID: emailId
    });
    print('baseurl : ' + baseUrl + GlobalVariables.receiptMailAPI);
    final Response _result = await _dio.post(GlobalVariables.receiptMailAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of getReceiptMail response : ' + value.toString());

    return StatusMsgResponse.fromJsonWithMessage(value);
  }

  @override
  Future<DataResponse> staffCount(String societyId) async {
    // TODO: implement staffCount
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
    });
    print(GlobalVariables.societyId + ": " + societyId);

    print('baseurl : ' + baseUrl + GlobalVariables.staffCountAPI);
    final Response _result = await _dio.post(GlobalVariables.staffCountAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of staffCount : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<DataResponse> staffRoleDetails(String societyId,String role) async {
    // TODO: implement staffRoleDetails
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(role, GlobalVariables.ROLE);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.ROLE: role
    });
    print(GlobalVariables.societyId + ": " + societyId);
    print(GlobalVariables.ROLE + ": " + role);

    print('baseurl : ' + baseUrl + GlobalVariables.staffRoleDetailsAPI);
    final Response _result = await _dio.post(GlobalVariables.staffRoleDetailsAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of staffRoleDetails : ' + value.toString());
    return DataResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> addStaffRatting(String societyId, String block, String flat, String staffId, String rate) async {
    // TODO: implement addStaffRatting
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block,GlobalVariables.block);
    ArgumentError.checkNotNull(flat,GlobalVariables.flat);
    ArgumentError.checkNotNull(staffId,GlobalVariables.SID);
    ArgumentError.checkNotNull(rate,GlobalVariables.Rate);

    FormData formData =
    FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.block:block,
      GlobalVariables.flat:flat,
      GlobalVariables.SID:staffId,
      GlobalVariables.Rate:rate
    });
    print(GlobalVariables.societyId + ": " + societyId);
    print(GlobalVariables.block + ": " + block);
    print(GlobalVariables.flat + ": " + flat);
    print('Rate : ' + rate);
    print('SID : ' + staffId);
    print('baseurl : ' + baseUrl + GlobalVariables.addStaffRattingAPI);
    final Response _result = await _dio.post(GlobalVariables.addStaffRattingAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of addStaffRatting response : ' + value.toString());

    return StatusMsgResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> addHouseHold(String societyId, String block, String flat, String staffId) async {
    // TODO: implement addHouseHold
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block,GlobalVariables.block);
    ArgumentError.checkNotNull(flat,GlobalVariables.flat);
    ArgumentError.checkNotNull(staffId,GlobalVariables.SID);

    FormData formData =
    FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.block:block,
      GlobalVariables.flat:flat,
      GlobalVariables.SID:staffId

    });
    print(GlobalVariables.societyId + ": " + societyId);
    print(GlobalVariables.block + ": " + block);
    print(GlobalVariables.flat + ": " + flat);
    print('SID : ' + staffId);
    print('baseurl : ' + baseUrl + GlobalVariables.addHouseholdAPI);
    final Response _result = await _dio.post(GlobalVariables.addHouseholdAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of addHouseHold response : ' + value.toString());

    return StatusMsgResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> removeHouseHold(String societyId, String block, String flat, String staffId) async {
    // TODO: implement removeHouseHold
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block,GlobalVariables.block);
    ArgumentError.checkNotNull(flat,GlobalVariables.flat);
    ArgumentError.checkNotNull(staffId,GlobalVariables.SID);

    FormData formData =
    FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.block:block,
      GlobalVariables.flat:flat,
      GlobalVariables.SID:staffId

    });
    print(GlobalVariables.societyId + ": " + societyId);
    print(GlobalVariables.block + ": " + block);
    print(GlobalVariables.flat + ": " + flat);
    print('SID : ' + staffId);
    print('baseurl : ' + baseUrl + GlobalVariables.removeHouseholdAPI);
    final Response _result = await _dio.post(GlobalVariables.removeHouseholdAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of removeHouseHold response : ' + value.toString());

    return StatusMsgResponse.fromJson(value);
  }

  @override
  Future<StatusMsgResponse> deleteVehicle(String id, String societyId) async {
    // TODO: implement deleteVehicle
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(id, GlobalVariables.id);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.id: id
    });
    print(GlobalVariables.societyId + ": " + societyId);
    print(GlobalVariables.id + ": " + id);

    print('baseurl : ' + baseUrl + GlobalVariables.deleteVehicleAPI);
    final Response _result = await _dio.post(GlobalVariables.deleteVehicleAPI,
        options: RequestOptions(
          //method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            }, baseUrl: baseUrl),
        data: formData);
    final value = _result.data;
    print('value of deleteVehicle : ' + value.toString());
    return StatusMsgResponse.fromJson(value);
  }
}