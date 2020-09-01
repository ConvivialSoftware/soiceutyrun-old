import 'package:dio/dio.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/AllMemberResponse.dart';
import 'package:societyrun/Models/BankResponse.dart';
import 'package:societyrun/Models/BillViewResponse.dart';
import 'package:societyrun/Models/DataResponse.dart';
import 'package:societyrun/Models/DuesResponse.dart';
import 'package:societyrun/Models/LedgerResponse.dart';
import 'package:societyrun/Models/LoginResponse.dart';
import 'package:societyrun/Models/MemberResponse.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'package:societyrun/Models/VehicleResponse.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';

import 'RestClient.dart';

class RestAPI implements RestClient, RestClientERP {
  RestAPI(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
    this.baseUrl ??= GlobalVariables.BaseURL;
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
    ArgumentError.checkNotNull(token, GlobalVariables.keyToken);

    FormData formData = FormData.fromMap({
      GlobalVariables.keyUsername: username,
      GlobalVariables.keyPassword: password,
      GlobalVariables.keyToken:token
    });
    print('baseurl : ' + baseUrl + GlobalVariables.LoginAPI);
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
    ArgumentError.checkNotNull(token, GlobalVariables.keyToken);

    FormData formData = FormData.fromMap({
      "expire_time": expire_time,
      "otp": otp,
      "send_otp": send_otp,
      "mobile_no": mobile_no,
      "Email_id": Email_id,
      GlobalVariables.keyToken:token
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
    ArgumentError.checkNotNull(mobile, "mobile_no");
    ArgumentError.checkNotNull(emailId, "Email_id");

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
    return DataResponse.fromJson(value);
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

    Map<String, dynamic> map = {};

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

    Map<String, dynamic> map = {};

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

    Map<String, dynamic> map = {};

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
  Future<DataResponse> getComplaintsData(String socId, String block, String flat) async {
    // TODO: implement getComplaintsData
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);

    Map<String, dynamic> map = {};

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.block: block,
      GlobalVariables.flat: flat
    });
    print(GlobalVariables.societyId + ": " + socId);
    print(GlobalVariables.block + ": " + block);
    print(GlobalVariables.flat + ": " + flat);

    print('baseurl : ' + baseUrl + GlobalVariables.ComplaintsAPI);
    final Response _result = await _dio.post(GlobalVariables.ComplaintsAPI,
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
  Future<DataResponse> getDocumentData(String societyId) async {
    // TODO: implement getDocumentData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
    });
    print(GlobalVariables.societyId + ": " + societyId);

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
      String societyId, String type) async {
    // TODO: implement getAnnouncementData
    ArgumentError.checkNotNull(societyId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(societyId, GlobalVariables.Type);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: societyId,
      GlobalVariables.Type: type,
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
      String bloodGroup,
      String occupation,
      String hobbies,
      String membershipType,
      String additionalInfo,
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
      GlobalVariables.BLOOD_GROUP: bloodGroup,
      GlobalVariables.OCCUPATION: occupation,
      GlobalVariables.HOBBIES: hobbies,
      GlobalVariables.TYPE: membershipType,
      GlobalVariables.NOTE: additionalInfo,
      GlobalVariables.IDENTITY_PROOF: profilePic,
    });
    //print(GlobalVariables.societyId+": "+socId);

    print('baseurl : ' + baseUrl + GlobalVariables.unitAddMemberAPI);

    print("Pic String: " + profilePic);
    print('attachment lengtth : ' + profilePic.length.toString());
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
  Future<DataResponse> getGatePassData(
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

    return DataResponse.fromJson(value);
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
    ArgumentError.checkNotNull(invoiceNo, GlobalVariables.INVOICE_NO);
    //ArgumentError.checkNotNull(block, GlobalVariables.block);

    FormData formData = FormData.fromMap({
      GlobalVariables.societyId: socId,
      GlobalVariables.INVOICE_NO: invoiceNo,
     // GlobalVariables.block: block
    });
    print(GlobalVariables.societyId + ":" + socId);
   // print(GlobalVariables.flat + ":" + flat);
    print(GlobalVariables.INVOICE_NO + ":" + invoiceNo);

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
  Future<DataResponse> getReceiptData(String socId, String flat, String block, String receiptNo) async {
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
    return DataResponse.fromJson(value);
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
  Future<StatusMsgResponse> addOnlinePaymentRequest(String socId, String flat, String block, String invoiceNo, String amount, String referenceNo, String transactionMode, String bankAccountNo, String paymentDate) async {
    // TODO: implement addOnlinePaymentRequest
    ArgumentError.checkNotNull(socId, GlobalVariables.societyId);
    ArgumentError.checkNotNull(block, GlobalVariables.block);
    ArgumentError.checkNotNull(flat, GlobalVariables.flat);
    ArgumentError.checkNotNull(invoiceNo, GlobalVariables.INVOICE_NO);
    ArgumentError.checkNotNull(amount, GlobalVariables.AMOUNT);
    ArgumentError.checkNotNull(referenceNo, GlobalVariables.REFERENCE_NO);
    ArgumentError.checkNotNull(
        transactionMode, GlobalVariables.TRANSACTION_MODE);
    ArgumentError.checkNotNull(bankAccountNo, GlobalVariables.BANK_ACCOUNTNO);
    ArgumentError.checkNotNull(paymentDate, GlobalVariables.PAYMENT_DATE);

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
      GlobalVariables.RESPONSE:""
    //  Glo
    });
    print(GlobalVariables.AMOUNT+": "+amount.toString());
    print(GlobalVariables.societyId+": "+socId.toString());
    print(GlobalVariables.INVOICE_NO+": "+invoiceNo.toString());
    print(GlobalVariables.PAYMENT_DATE+": "+paymentDate.toString());

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
      String name, String altCon1, String altCon2, String profilePhoto,
      String address, String gender, String dob, String bloodGroup, String occupation,
      String email, String mobileNo,String type,String livesHere) async {
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
      GlobalVariables.ALTERNATE_CONTACT1:altCon1,
      GlobalVariables.ALTERNATE_CONTACT2:altCon2,
      GlobalVariables.GENDER:gender,
      GlobalVariables.DOB:dob,
      GlobalVariables.BLOOD_GROUP:bloodGroup,
      GlobalVariables.OCCUPATION:occupation,
      GlobalVariables.Email:email

      //GlobalVariables.
    });

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
    ArgumentError.checkNotNull(userId, GlobalVariables.USER_ID);
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
      GlobalVariables.USER_ID: userId,
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
      String vid,
      String uid,
      String reason,
      String noOfVisitors,
      String fromVisitor,
      String visitorStatus,
      String inBy,
      String societyId,
      String inDate,
      String inTime) async {
    FormData formData = FormData.fromMap({
      GatePassFields.VID: vid,
      GatePassFields.USER_ID: uid,
      GatePassFields.REASON: reason,
      GatePassFields.NO_OF_VISITOR: noOfVisitors,
      GatePassFields.FROM_VISITOR: fromVisitor,
      GatePassFields.VISITOR_STATUS: visitorStatus,
      GatePassFields.IN_BY: inBy,
      GatePassFields.SOCIETY_ID: societyId,
      GatePassFields.IN_DATE: inDate,
      GatePassFields.IN_TIME: inTime,
    });

    final Response _result = await _dio.post(GlobalVariables.approveGatePassAPI,
        options: RequestOptions(
            method: GlobalVariables.Post,
            headers: <String, dynamic>{
              "Authorization": GlobalVariables.AUTH,
            },
            baseUrl: GlobalVariables.BaseURLAndroid),
        data: formData);
    final value = _result.data;


    return DataResponse.fromJson(value);
  }

  @override
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
            baseUrl: GlobalVariables.BaseURLAndroid),
        data: formData);
    final value = _result.data;


    return DataResponse.fromJson(value);
  }

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
    return DataResponse.fromJson(value);
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
      GlobalVariables.STAFF_NAME: name,
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
}
/*    [SOCIETY_ID] => 11133
 [BLOCK] => A
 [FLAT] => 101
 [AMOUNT] => 1100
 [REFERENCE_NO] => asdfghjklASSDFGHJKL
 [TRANSACTION_MODE] => Cheque
 [BANK_ACCOUNTNO] => 32
 [PAYMENT_DATE] => 5/6/2020
 [USER_ID] => 2
 [NARRATION] => testing payment request
 [CHEQUE_BANKNAME] => TJSB Bank*/
