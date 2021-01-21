
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/AllMemberResponse.dart';
import 'package:societyrun/Models/DataResponse.dart';
import 'package:societyrun/Models/GatePassResponse.dart';
import 'package:societyrun/Models/LoginResponse.dart';
import 'package:societyrun/Models/MemberResponse.dart';
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
}


