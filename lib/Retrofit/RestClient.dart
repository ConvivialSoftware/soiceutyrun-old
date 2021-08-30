
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/AllMemberResponse.dart';
import 'package:societyrun/Models/DataResponse.dart';
import 'package:societyrun/Models/GatePassResponse.dart';
import 'package:societyrun/Models/LoginResponse.dart';
import 'package:societyrun/Models/MemberResponse.dart';
import 'package:societyrun/Models/PaymentCharges.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'package:societyrun/Models/VehicleResponse.dart';
import 'RestAPI.dart';

@RestApi(baseUrl: GlobalVariables.BaseURL)
abstract class RestClient {

  factory RestClient(Dio dio, {String baseUrl}) = RestAPI;

  @FormUrlEncoded()
  @POST(GlobalVariables.LoginAPI)
  Future<LoginResponse> getLogin(@Field("username") String username, @Field("password") String password,@Field("GCM_ID") String token);

  @FormUrlEncoded()
  @POST(GlobalVariables.otpLoginAPI)
  Future<LoginResponse> getOTPLogin(@Field("expire_time") String expire_time, @Field("otp") String otp,
      @Field("send_otp") String send_otp, @Field("mobile_no") String mobile_no,@Field("Email_id") String Email_id,@Field("GCM_ID") String token);

  @FormUrlEncoded()
  @POST(GlobalVariables.otpSendAPI)
  Future<StatusMsgResponse> getOTP(@Field("mobile_no") String mobile, @Field("Email_id") String emailId);

@FormUrlEncoded()
  @POST(GlobalVariables.otpReSendAPI)
  Future<StatusMsgResponse> getResendOTP(@Field("otp") String otp,@Field("mobile_no") String mobile, @Field("Email_id") String emailId);

  @FormUrlEncoded()
  @POST(GlobalVariables.newPasswordAPI)
  Future<StatusMsgResponse> changeNewPassword(@Field(GlobalVariables.societyId) String societyId, @Field(GlobalVariables.userID) String userId,
      @Field("confirm_pwd") String confirmPassword);


  @FormUrlEncoded()
  @POST(GlobalVariables.AllSocietyAPI)
  Future<DataResponse> getAllSocietyData(@Field("username") String username/*, @Field("password") String password*/);

  @FormUrlEncoded()
  @POST(GlobalVariables.profileAPI)
  Future<DataResponse> getProfileData(@Field(GlobalVariables.societyId) String societyId, @Field(GlobalVariables.userID) String password);

  @FormUrlEncoded()
  @POST(GlobalVariables.editProfileAPI)
  Future<DataResponse> editProfileInfo(@Field("SOCIETY_ID") String socId, @Field("USER_ID") String userId,
      @Field("NAME") String name, @Field("MOBILE") String phone,
      @Field("ALTERNATE_CONTACT1") String altCon1, @Field("PROFILE_PHOTO") String profilePhoto,
      @Field("ADDRESS") String address, @Field("GENDER") String gender,
      @Field("DOB") String dob,/* @Field("ANNIVERSARY_DATE") String anniverDate,*/
      @Field("BLOOD_GROUP") String bloodGroup, @Field("OCCUPATION") String occupation,
      /*@Field("HOBBIES") String hobbies, @Field("LANGUAGES") String language,
      @Field("FB_PROFILE") String fbProfile, @Field("LINKDIN_PROFILE") String linkDinProfile,
      @Field("INSTAGRAM") String instagram,*/ @Field("USER_NAME") String userName,@Field("TYPE") String type,@Field("LIVES_HERE") String livesHere);


  @FormUrlEncoded()
  @POST(GlobalVariables.unitMemberAPI)
  Future<MemberResponse> getMembersData(@Field(GlobalVariables.societyId) String socId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat );

  @FormUrlEncoded()
  @POST(GlobalVariables.unitStaffAPI)
  Future<DataResponse> getStaffData(@Field(GlobalVariables.societyId) String socId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat );

  @FormUrlEncoded()
  @POST(GlobalVariables.unitStaffAPI)
  Future<DataResponse> getAllSocietyStaffData(@Field(GlobalVariables.societyId) String socId);

  @FormUrlEncoded()
  @POST(GlobalVariables.unitVehicleAPI)
  Future<VehicleResponse> getVehicleData(@Field(GlobalVariables.societyId) String socId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat );

  @FormUrlEncoded()
  @POST(GlobalVariables.ComplaintsAPI)
  Future<DataResponse> getComplaintsData(@Field(GlobalVariables.societyId) String socId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat,@Field(GlobalVariables.userID) String userID, bool isAssignComplaint );

  @FormUrlEncoded()
  @POST(GlobalVariables.TicketNoComplaintAPI)
  Future<DataResponse> getComplaintDataAgainstTicketNo(@Field(GlobalVariables.societyId) String socId,@Field(GlobalVariables.parentTicket) String ticketNo);

  @FormUrlEncoded()
  @POST(GlobalVariables.CommentAPI)
  Future<DataResponse> getCommentData(@Field(GlobalVariables.societyId) String socId, @Field(GlobalVariables.ticketNo) String ticketNo);


  @FormUrlEncoded()
  @POST(GlobalVariables.DocumentAPI)
  Future<DataResponse> getDocumentData(@Field("SOCIETY_ID") String societyId,@Field(GlobalVariables.userID) String userId);

  @FormUrlEncoded()
  @POST(GlobalVariables.ComplaintsAreaAPI)
  Future<DataResponse> getComplaintsAreaData(@Field("SOCIETY_ID") String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.ComplaintsCategoryAPI)
  Future<DataResponse> getComplaintsCategoryData(@Field("SOCIETY_ID") String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.UpdateStatusAPI)
  Future<StatusMsgResponse> getUpdateComplaintStatus(@Field(GlobalVariables.societyId) String socId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat ,@Field(GlobalVariables.userID) String userId,
      @Field(GlobalVariables.parentTicket) String ticketNo,@Field(GlobalVariables.status) String updateStatus,
      @Field(GlobalVariables.COMMENT) String comment,@Field(GlobalVariables.ATTACHMENT) String attachment,
      @Field(GlobalVariables.TYPE) String type,@Field(GlobalVariables.ESCALATION_LEVEL) String escalationLevel,
      @Field(GlobalVariables.societyName) String socName,@Field(GlobalVariables.userEmail) String eMail,
      @Field(GlobalVariables.societyEmail) String socEmail,@Field(GlobalVariables.NAME) String userName);


  @FormUrlEncoded()
  @POST(GlobalVariables.AddComplaintsAPI)
  Future<StatusMsgResponse> addComplaint(@Field(GlobalVariables.societyId) String socId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat ,@Field(GlobalVariables.userID) String userId,
      @Field(GlobalVariables.SUBJECT) String subject,@Field(GlobalVariables.TYPE) String type,
      /*@Field(GlobalVariables.COMPLAINT_AREA) String area,*/@Field(GlobalVariables.CATEGORY) String category,
      @Field(GlobalVariables.DESCRIPTION) String description,@Field(GlobalVariables.PRIORITY) String priority,
      @Field(GlobalVariables.NAME) String name,@Field(GlobalVariables.ATTACHMENT) String attachment,@Field(GlobalVariables.ATTACHMENT_NAME) String ATTACHMENT_NAME,
      @Field(GlobalVariables.societyName) String socName,@Field(GlobalVariables.userEmail) String eMail,
      @Field(GlobalVariables.societyEmail) String socEmail);

  @FormUrlEncoded()
  @POST(GlobalVariables.allMemberAPI)
  Future<AllMemberResponse> getAllMemberDirectoryData(@Field(GlobalVariables.societyId) String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.CommitteeDirectoryAPI)
  Future<DataResponse> getCommitteeDirectoryData(@Field(GlobalVariables.societyId) String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.EmergencyDirectoryAPI)
  Future<DataResponse> getEmergencyDirectoryData(@Field(GlobalVariables.societyId) String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.NeighboursDirectoryAPI)
  Future<DataResponse> getNeighboursDirectoryData(@Field(GlobalVariables.societyId) String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.AnnouncementAPI)
  Future<DataResponse> getAnnouncementData(@Field(GlobalVariables.societyId) String societyId,@Field(GlobalVariables.Type) String type,@Field(GlobalVariables.userID) String userId);

  @FormUrlEncoded()
  @POST(GlobalVariables.AnnouncementPollAPI)
  Future<DataResponse> getAnnouncementPollData(@Field(GlobalVariables.societyId) String societyId,@Field(GlobalVariables.Type) String type,
    @Field(GlobalVariables.block) String block, @Field(GlobalVariables.flat) String flat,
    @Field(GlobalVariables.userID) String userId);


  @FormUrlEncoded()
  @POST(GlobalVariables.unitAddMemberAPI)
  Future<StatusMsgResponse> addMember(@Field(GlobalVariables.societyId) String socId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat ,@Field(GlobalVariables.NAME) String name,
      @Field(GlobalVariables.GENDER) String gender,@Field(GlobalVariables.DOB) String dob,
      @Field(GlobalVariables.USER_NAME) String userName,@Field(GlobalVariables.MOBILE) String mobile,@Field(GlobalVariables.ALTERNATE_CONTACT1) String alternateNumber,
      @Field(GlobalVariables.BLOOD_GROUP) String bloodGroup,@Field(GlobalVariables.OCCUPATION) String occupation,
      @Field(GlobalVariables.LIVES_HERE) String hobbies,@Field(GlobalVariables.TYPE) String membershipType,
      @Field(GlobalVariables.ADDRESS) String additionalInfo,@Field(GlobalVariables.PROFILE_PHOTO) String profilePic);


  @FormUrlEncoded()
  @POST(GlobalVariables.unitAddVehicleAPI)
  Future<StatusMsgResponse> addVehicle(@Field(GlobalVariables.societyId) String socId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat ,@Field(GlobalVariables.VEHICLE_NO) String vehicleNo,
      @Field(GlobalVariables.MODEL) String model,@Field(GlobalVariables.WHEEL) String wheel,
      @Field(GlobalVariables.STICKER_NO) String stickerNo,@Field(GlobalVariables.userID) String userId);


  @FormUrlEncoded()
  @POST(GlobalVariables.AddGatePassScheduleAPI)
  Future<StatusMsgResponse> addScheduleVisitorGatePass(@Field(GlobalVariables.societyId) String socId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat ,@Field(GlobalVariables.NAME) String name,
      @Field(GlobalVariables.MOBILE_NO) String mobile,@Field(GlobalVariables.DATE) String date,
      @Field(GlobalVariables.userID) String userId);


  @FormUrlEncoded()
  @POST(GlobalVariables.GatePassAPI)
  Future<GatePassResponse> getGatePassData(@Field(GlobalVariables.societyId) String societyId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat);

  @FormUrlEncoded()
  @POST(GlobalVariables.GetGatePassScheduleAPI)
  Future<DataResponse> getGatePassScheduleVisitorData(@Field(GlobalVariables.societyId) String societyId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat);

  @FormUrlEncoded()
  @POST(GlobalVariables.payOptionAPI)
  Future<DataResponse> getPayOptionData(@Field(GlobalVariables.societyId) String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.staffMobileVerifyAPI)
  Future<DataResponse> getStaffMobileVerifyData(@Field(GlobalVariables.societyId) societyId, @Field(GlobalVariables.Contact) String contact);

  @FormUrlEncoded()
  @POST(GlobalVariables.bannerAPI)
  Future<DataResponse> getBannerData();

  @FormUrlEncoded()
  @POST(GlobalVariables.addStaffMemberAPI)
  Future<StatusMsgResponse> addStaffMember(@Field(GlobalVariables.societyId) String socId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat ,@Field(GlobalVariables.STAFF_NAME) String name,
      @Field(GlobalVariables.GENDER) String gender,@Field(GlobalVariables.DOB) String dob,
      @Field(GlobalVariables.Contact) String mobile, @Field(GlobalVariables.QUALIFICATION) String qualification,
      @Field(GlobalVariables.ADDRESS) String address, @Field(GlobalVariables.NOTES) String notes,
      @Field(GlobalVariables.userID) String userId,@Field(GlobalVariables.ROLE) String role,
      @Field(GlobalVariables.PHOTO) String picture,@Field(GlobalVariables.IDENTITY_PROOF) String identityProof,
      @Field(GlobalVariables.VEHICLE_NO) String vehicleNo);

  @FormUrlEncoded()
  @POST(GlobalVariables.approveGatePassAPI)
  Future<DataResponse> postApproveGatePass(
    @Field(GatePassFields.ID) String vid,
    @Field(GatePassFields.VISITOR_STATUS) String visitorStatus,
    @Field(GatePassFields.GCM_ID) String gcmId,
    @Field(GatePassFields.SOCIETY_ID) String societyId,
  );
/*
  @FormUrlEncoded()
  @POST(GlobalVariables.rejectGatepassAPI)
  Future<DataResponse> postRejectGatePass(
      @Field(GatePassFields.ID) String id,
      @Field(GatePassFields.SOCIETY_ID) String societyId,
      @Field(GatePassFields.COMMENT) String comment,
      @Field(GatePassFields.STATUS) String status
      );
*/

  @FormUrlEncoded()
  @POST(GlobalVariables.feedbackAPI)
  Future<StatusMsgResponse> addFeedback(@Field(GlobalVariables.societyId) String socId, @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat ,@Field(GlobalVariables.societyName) String name,
      @Field('Subject') String subject, @Field('Description') String description,
      @Field('Attachment') String attachment);

  @FormUrlEncoded()
  @POST(GlobalVariables.logoutAPI)
  Future<StatusMsgResponse> userLogout(@Field(GlobalVariables.societyId) String societyId, @Field(GlobalVariables.userID) String userId,
      @Field(GlobalVariables.GCM_ID) String gcmId);

  @FormUrlEncoded()
  @POST(GlobalVariables.pollVoteAPI)
  Future<StatusMsgResponse> addPollVote(@Field(GlobalVariables.societyId) String societyId, @Field(GlobalVariables.userID) String userId,
      @Field(GlobalVariables.block) String block,@Field(GlobalVariables.flat) String flat,
      @Field(GlobalVariables.ID) String optionId,@Field(GlobalVariables.OPTION) String optionText);

  @FormUrlEncoded()
  @POST(GlobalVariables.gatePassWrongEntryAPI)
  Future<StatusMsgResponse> addGatePassWrongEntry(@Field(GlobalVariables.societyId) String societyId, @Field(GlobalVariables.ID) String id,
      @Field(GlobalVariables.status) String status);

  @FormUrlEncoded()
  @POST(GlobalVariables.deleteExpectedVisitorAPI)
  Future<StatusMsgResponse> deleteExpectedVisitor(@Field(GlobalVariables.societyId) String societyId, @Field(GlobalVariables.SR_NO) String srNo);

  @FormUrlEncoded()
  @POST(GlobalVariables.staffCountAPI)
  Future<DataResponse> staffCount(@Field(GlobalVariables.societyId) String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.staffRoleDetailsAPI)
  Future<DataResponse> staffRoleDetails(@Field(GlobalVariables.societyId) String societyId,@Field(GlobalVariables.ROLE) String role);

  @FormUrlEncoded()
  @POST(GlobalVariables.addStaffRattingAPI)
  Future<StatusMsgResponse> addStaffRatting(@Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.block) String block,@Field(GlobalVariables.flat) String flat,
      @Field(GlobalVariables.SID) String staffId,@Field(GlobalVariables.Rate) String rate);

  @FormUrlEncoded()
  @POST(GlobalVariables.addHouseholdAPI)
  Future<StatusMsgResponse> addHouseHold(@Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.block) String block,@Field(GlobalVariables.flat) String flat,
      @Field(GlobalVariables.SID) String staffId);

  @FormUrlEncoded()
  @POST(GlobalVariables.removeHouseholdAPI)
  Future<StatusMsgResponse> removeHouseHold(@Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.block) String block,@Field(GlobalVariables.flat) String flat,
      @Field(GlobalVariables.SID) String staffId);


  @FormUrlEncoded()
  @POST(GlobalVariables.deleteVehicleAPI)
  Future<StatusMsgResponse> deleteVehicle(@Field(GlobalVariables.id) String id,@Field(GlobalVariables.societyId) String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.deleteFamilyMemberAPI)
  Future<StatusMsgResponse> deleteFamilyMember(@Field(GlobalVariables.id) String id,@Field(GlobalVariables.societyId) String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.broadcastEmailAPI)
  Future<DataResponse> broadcastMail(@Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.userID) String userId,
      @Field("FLATS[]") List<String> flats,
      @Field(GlobalVariables.ATTACHMENT) String attachment,@Field(GlobalVariables.SEND_TO) String sendTo,
      @Field(GlobalVariables.SUBJECT) String subject,@Field(GlobalVariables.DESCRIPTION) String description
      ,@Field(GlobalVariables.societyName) String Society_Name,@Field(GlobalVariables.societyEmail) String Society_Email,);

  @FormUrlEncoded()
  @POST(GlobalVariables.broadcastNotificationAPI)
  Future<DataResponse> broadcastNotification(@Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.userID) String userId,
      @Field("FLATS[]") List<String> flats,/*
      @Field(GlobalVariables.ATTACHMENT) String attachment*/@Field(GlobalVariables.SEND_TO) String sendTo,
      @Field(GlobalVariables.SUBJECT) String subject,@Field(GlobalVariables.DESCRIPTION) String description
      ,@Field(GlobalVariables.societyName) String Society_Name,@Field(GlobalVariables.societyEmail) String Society_Email,);

  @FormUrlEncoded()
  @POST(GlobalVariables.flatNoAPI)
  Future<DataResponse> flatNo(@Field(GlobalVariables.societyId) String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.broadcastSMSAPI)
  Future<DataResponse> importantCommunicationSMS(
  @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.userID) String userId,
      @Field("FLATS[]") List<String> flats,
      @Field(GlobalVariables.SEND_TO) String sendTo,@Field(GlobalVariables.SMS_TYPE) String smsType,
      @Field(GlobalVariables.name) String name,
      @Field(GlobalVariables.societyName) String societyName,);

  @FormUrlEncoded()
  @POST(GlobalVariables.broadcastSMSAPI)
  Future<DataResponse> meetingSMS(
  @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.userID) String userId,
      @Field("FLATS[]") List<String> flats,
      @Field(GlobalVariables.SEND_TO) String sendTo,
      @Field(GlobalVariables.SMS_TYPE) String smsType,
      @Field(GlobalVariables.meeting_name) String meeting_name,
      @Field(GlobalVariables.meeting_date) String meeting_date,
      @Field(GlobalVariables.time) String time,
      @Field(GlobalVariables.minute) String minute,
      @Field(GlobalVariables.time_type) String time_type,
      @Field(GlobalVariables.venue) String venue,
      @Field(GlobalVariables.societyName) String societyName,);

  @FormUrlEncoded()
  @POST(GlobalVariables.broadcastSMSAPI)
  Future<DataResponse> waterSupplySMS(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.userID) String userId,
      @Field("FLATS[]") List<String> flats,
      @Field(GlobalVariables.SEND_TO) String sendTo,
      @Field(GlobalVariables.SMS_TYPE) String smsType,
      @Field("date4") String date4,
      @Field("start_time4") String start_time4,
      @Field("start_minute4") String start_minute4,
      @Field("start_time_type4") String start_time_type4,
      @Field("end_time4") String end_time4,
      @Field("end_minute4") String end_minute4,
      @Field("end_time_type4") String end_time_type4,
      @Field(GlobalVariables.societyName) String societyName,);


  @FormUrlEncoded()
  @POST(GlobalVariables.broadcastSMSAPI)
  Future<DataResponse> waterDisruptionSMS(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.userID) String userId,
      @Field("FLATS[]") List<String> flats,
      @Field(GlobalVariables.SEND_TO) String sendTo,
      @Field(GlobalVariables.SMS_TYPE) String smsType,
      @Field("date3") String date3,
      @Field("start_time3") String start_time3,
      @Field("start_minute3") String start_minute3,
      @Field("start_time_typ3") String start_time_type3,
      @Field("end_time3") String end_time3,
      @Field("end_minute3") String end_minute3,
      @Field("end_time_type3") String end_time_type3,
      @Field(GlobalVariables.societyName) String societyName,);


  @FormUrlEncoded()
  @POST(GlobalVariables.broadcastSMSAPI)
  Future<DataResponse> fireDrillSMS(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.userID) String userId,
      @Field("FLATS[]") List<String> flats,
      @Field(GlobalVariables.SEND_TO) String sendTo,
      @Field(GlobalVariables.SMS_TYPE) String smsType,
      @Field("date2") String date2,
      @Field("start_time2") String start_time2,
      @Field("start_minute2") String start_minute2,
      @Field("start_time_type2") String start_time_type2,
      @Field(GlobalVariables.societyName) String societyName,);


  @FormUrlEncoded()
  @POST(GlobalVariables.broadcastSMSAPI)
  Future<DataResponse> serviceDownSMS(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.userID) String userId,
      @Field("FLATS[]") List<String> flats,
      @Field(GlobalVariables.SEND_TO) String sendTo,
      @Field(GlobalVariables.SMS_TYPE) String smsType,
      @Field("reason") String reason,
      @Field("reason1") String reason1,
      @Field("date1") String date1,
      @Field("start_time1") String start_time1,
      @Field("start_minute1") String start_minute1,
      @Field("start_time_type1") String start_time_type1,
      @Field("end_time") String end_time,
      @Field("end_minute") String end_minute,
      @Field("end_time_type") String end_time_type,
      @Field(GlobalVariables.societyName) String societyName,);


  @FormUrlEncoded()
  @POST(GlobalVariables.broadcastSMSAPI)
  Future<DataResponse> powerOutageSMS(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.userID) String userId,
      @Field("FLATS[]") List<String> flats,
      @Field(GlobalVariables.SEND_TO) String sendTo,
      @Field(GlobalVariables.SMS_TYPE) String smsType,
      @Field("date") String date,
      @Field("start_time") String start_time,
      @Field("start_minute") String start_minute,
      @Field("start_time_type") String start_time_type,
      @Field("time") String time,
      @Field("minute") String minute,
      @Field("time_type") String time_type,
      @Field(GlobalVariables.societyName) String societyName,);


  @FormUrlEncoded()
  @POST(GlobalVariables.userManagementDashboardAPI)
  Future<DataResponse> getUserManagementDashboard(@Field(GlobalVariables.societyId) String societyId,@Field(GlobalVariables.userID) String userId);

  @FormUrlEncoded()
  @POST(GlobalVariables.userTypeListAPI)
  Future<DataResponse> getUseTypeList(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.type) String type,
      );

  @FormUrlEncoded()
  @POST(GlobalVariables.unitDetailsAPI)
  Future<DataResponse> getUnitDetails(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.block) String block,
      );


  @FormUrlEncoded()
  @POST(GlobalVariables.editUnitDetailsAPI)
  Future<StatusMsgResponse> editUnitDetails(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.id) String ID,
      @Field(GlobalVariables.CONSUMER_NO) String CONSUMER_NO,
      @Field(GlobalVariables.PARKING_SLOT) String PARKING_SLOT,
      @Field(GlobalVariables.AREA) String AREA,
      @Field(GlobalVariables.GSTIN_NO) String GSTIN_NO,
      @Field(GlobalVariables.BILLING_NAME) String BILLING_NAME,
      @Field(GlobalVariables.INTERCOM) String INTERCOM,
      );


  @FormUrlEncoded()
  @POST(GlobalVariables.addMemberByAdminAPI)
  Future<StatusMsgResponse> addMemberByAdmin(@Field(GlobalVariables.societyId) String socId,
      @Field(GlobalVariables.block) String block, @Field(GlobalVariables.flat) String flat ,
      @Field(GlobalVariables.NAME) String name,@Field(GlobalVariables.PHONE) String mobile,
      @Field(GlobalVariables.Email) String Email, @Field(GlobalVariables.LIVES_HERE) String livesHere,
      @Field(GlobalVariables.TYPE) String membershipType, @Field(GlobalVariables.ADDRESS) String additionalInfo,
      @Field(GlobalVariables.IDENTITY_PROOF) String profilePic,
      @Field(GlobalVariables.note) String notForModerator,
      @Field(GlobalVariables.societyName) String societyName
      );


  @FormUrlEncoded()
  @POST(GlobalVariables.blockAPI)
  Future<DataResponse> getBlock(@Field(GlobalVariables.societyId) String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.flatAPI)
  Future<DataResponse> getFlat(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.block) String block,
      );

  @FormUrlEncoded()
  @POST(GlobalVariables.smsDataAPI)
  Future<DataResponse> getSMSData(@Field(GlobalVariables.societyId) String societyId);


  @FormUrlEncoded()
  @POST(GlobalVariables.rentalRequestAPI)
  Future<DataResponse> getRentalRequest(@Field(GlobalVariables.societyId) String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.pendingRequestAPI)
  Future<DataResponse> getPendingMemberRequest(@Field(GlobalVariables.societyId) String societyId);


  @FormUrlEncoded()
  @POST(GlobalVariables.moveOutRequestAPI)
  Future<DataResponse> getMoveOutRequest(@Field(GlobalVariables.societyId) String societyId);

  @FormUrlEncoded()
  @POST(GlobalVariables.sendInviteAPI)
  Future<StatusMsgResponse> getSendInvite(@Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.societyName) String societyName,
      @Field("user_id[]") List<String> user_id,);

  @FormUrlEncoded()
  @POST(GlobalVariables.approvePendingRequestAPI)
  Future<StatusMsgResponse> approvePendingRequest(@Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.userID) String userId,
      @Field(GlobalVariables.societyName) String societyName,
      @Field("id") String id,);

  @FormUrlEncoded()
  @POST(GlobalVariables.deactivateUserAPI)
  Future<StatusMsgResponse> deactivateUser(@Field(GlobalVariables.societyId) String societyId,
      @Field("Reason") String Reason,
      @Field("id") String id,);


  @FormUrlEncoded()
  @POST(GlobalVariables.nocApproveAPI)
  Future<StatusMsgResponse> nocApprove(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.ID) String ID,
      @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat,
      @Field(GlobalVariables.userID) String userId,
      @Field(GlobalVariables.NOTE) String note,
      @Field(GlobalVariables.societyName) String societyName,
      );

  @FormUrlEncoded()
  @POST(GlobalVariables.addAgreementAPI)
  Future<StatusMsgResponse> addAgreement(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat,
      @Field("user_details[]") List<Map<String,String>> userID,
      @Field(GlobalVariables.AGREEMENT_FROM) String agreementFrom,
      @Field(GlobalVariables.AGREEMENT_TO) String agreementTo,
      @Field(GlobalVariables.AGREEMENT) String agreement,
      @Field(GlobalVariables.RENTED_TO) String rentedTo,
      @Field(GlobalVariables.Noc_Issue) String nocIssue,
      //@Field(GlobalVariables.ATTACHMENT) String attchment,
      @Field("FILE_TYPE") String fileType,
      @Field("isAdmin") bool isAdmin,
      );

  @FormUrlEncoded()
  @POST(GlobalVariables.adminAddAgreementAPI)
  Future<StatusMsgResponse> adminAddAgreementAPI(
      @Field(GlobalVariables.societyId) String societyId,
      @Field("user_details[]") List<String> userID,
      @Field(GlobalVariables.AGREEMENT_FROM) String agreementFrom,
      @Field(GlobalVariables.AGREEMENT_TO) String agreementTo,
      @Field(GlobalVariables.AGREEMENT) String agreement,
      @Field(GlobalVariables.RENTED_TO) String rentedTo,
      @Field(GlobalVariables.block) String block,
      @Field(GlobalVariables.flat) String flat,
      @Field(GlobalVariables.societyName) String societyName,
      @Field(GlobalVariables.Noc_Issue) String nocIssue,
      );


  @FormUrlEncoded()
  @POST(GlobalVariables.renewAgreementAPI)
  Future<StatusMsgResponse> renewAgreement(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.ID) String id,
      @Field(GlobalVariables.AGREEMENT_FROM) String agreementFrom,
      @Field(GlobalVariables.AGREEMENT_TO) String agreementTo,
      @Field(GlobalVariables.AGREEMENT) String agreement,
      @Field("FILE_TYPE") String fileType,
      @Field(GlobalVariables.Type) bool isAdmin,
      );

  @FormUrlEncoded()
  @POST(GlobalVariables.closeAgreementAPI)
  Future<StatusMsgResponse> closeAgreement(
      @Field(GlobalVariables.societyId) String societyId,
      @Field(GlobalVariables.ID) String id,
      );

  @FormUrlEncoded()
  @POST(GlobalVariables.paymentChargesAPI)
  Future<PaymentChargesResponse> getPaymentCharges();

  @FormUrlEncoded()
  @POST(GlobalVariables.referAPI)
  Future<StatusMsgResponse> referAndEarn(
      @Field(GlobalVariables.societyId) String societyId,
      @Field("society_name") String societyName,
      @Field("flat") String flat,
      @Field("address") String address,
      @Field("name") String name,
      @Field("phone") String phone,
      @Field("email") String email,
      @Field("message")String message,
      @Field("SocietyName")String loggedSocietyName,
      @Field("FlatNo")String loggedFlatNo,
      @Field("Name")String loggedUser,
      @Field("Phone")String loggedPone,
      );


}


