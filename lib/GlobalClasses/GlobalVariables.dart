import 'dart:convert';

import 'package:flutter/material.dart';
class GlobalVariables{

  /*Variables for the Web URL*/
  static const termsConditionURL="https://societyrun.com/Terms%20&%20conditions.html";
  static const privacyPolicyURL="https://societyrun.com/Privacy_Policy.html";

  /*Variables for the SharedPreferences*/
  static var keyIsLogin="isLogin";
  static var keyUsername="username";
  static var keyPassword="password";
  static var keyLanguageCode="language_code";
  static var keyId="id";
  static var keySocietyId="society_id";
  static var keyUserId="user_id";
  static var keyBlock="block";
  static var keyFlat="flat";
  static var keyMobile="mobile";
  static var keyUserType="user_type";
  static var keySocietyName="society_name";
  static var keySocietyAddress="society_address";
  static var keyEmail="email";
  static var keySocietyPermission="society_permission";
  static var keyName="name";
  static var keyStaffQRImage="staff_qr_image";
  static var keyPhoto="photo";
  static var keyUserPermission="user_permission";
  static var keyConsumerId="consumer_id";
  static var keyDuesRs="dues_rs";
  static var keyDuesDate="dues_date";

  static var appLogoPath="assets/images/society_run_green.png";
  static var userProfilePath="assets/images/user_profile.jpeg";
  static var drawerImagePath="assets/other_assets/societyrun-logo_colored.svg";
  static var appIconPath="assets/other_assets/societyrun-logo.svg";
  static var myFlatIconPath="assets/menu_assets/myhome_icon.svg";
  static var myBuildingIconPath="assets/menu_assets/building_icon_menu.svg";
  static var myServiceIconPath="assets/menu_assets/service_icon_menu.svg";
  static var myClubIconPath="assets/menu_assets/club_icon_menu.svg";
  static var myGateIconPath="assets/menu_assets/gatepass_icon_menu.svg";
  static var mySupportIconPath="assets/menu_assets/Support_icon_menu.svg";
  static var myAdminIconPath="assets/menu_assets/admin_icon_menu.svg";
  static var headerIconPath="assets/other_assets/Header_bg.svg";
  static var loginIconPath="assets/other_assets/login_icon.svg";
  static var mailIconPath="assets/other_assets/mail_icon.svg";
  static var lockIconPath="assets/other_assets/lock_icon.svg";
  static var classifiedBigIconPath="assets/other_assets/Classified_big_icon.svg";
  static var classifiedPath="assets/other_assets/Classified_icon.svg";
  static var topBreadCrumPath="assets/other_assets/Top_breadcrum.svg";
  static var overviewTxtPath="assets/other_assets/overview_txt.svg";
  static var notificationBellIconPath="assets/other_assets/notification_icon.svg";
  static var whileBGPath="assets/other_assets/while_bg.svg";
  static var buildingIconPath="assets/other_assets/building_icon.svg";
  static var gatePassIconPath="assets/other_assets/gatePass_icon.svg";
  static var moreIconPath="assets/other_assets/More_icon.svg";
  static var serviceIconPath="assets/other_assets/Services_icon.svg";
  static var shoppingIconPath="assets/other_assets/shopping_icon.svg";
  static var shopIconPath="assets/other_assets/Shop_icon.svg";
  static var supportIconPath="assets/other_assets/Support_icon.svg";
  static var storeIconPath="assets/other_assets/store_icon.svg";
  static var componentUserProfilePath="assets/other_assets/component_user_profile.png";
  static var userProfileIconPath="assets/other_assets/profile_icon.svg";
  static var waterIconPath="assets/other_assets/water_icon.svg";
  static var pdfIconPath="assets/other_assets/Icon awesome-file-pdf.svg";
  static var downloadIconPath="assets/other_assets/Icon awesome-download.svg";
  static var pdfBackIconPath="assets/other_assets/icon-pdf.svg";

  static var bottomBGPath = "assets/bottom_menu/bottom_bg.svg";
  static var bottomBuildingIconPath = "assets/bottom_menu/bottom_building_icon.svg";
  static var bottomClubIconPath = "assets/bottom_menu/bottom_club_icon.svg";
  static var bottomHomeIconPath = "assets/bottom_menu/bottom_home_icon.svg";
  static var bottomMenuIconPath = "assets/bottom_menu/bottom_menu_icon.svg";
  static var bottomMyHomeIconPath = "assets/bottom_menu/bottom_myhome_icon.svg";
  static var bottomServiceIconPath = "assets/bottom_menu/bottom_service_icon.svg";


  /*Variable of Text Size */
  static var smallText = 12.0;
  static var mediumText = 14.0;
  static var largeText = 16.0;
  static var varyLargeText = 25.0;


  /*Variables For Call Rest API*/
  static const Get = 'GET';
  static const Post = 'POST';
  static const Put = 'PUT';
  static const Delete = 'DELETE';


  static const authorizedToken = "admin:1234";
  static var AUTH="Basic "+base64Url.encode(utf8.encode(authorizedToken));
  static const BaseURL = "https://societyrun.com/Flutter/";
  static const BaseURLAndroid = "https://societyrun.com/Android/";
  /*Api Name for BaseURL*/
  static const LoginAPI = "Api";
  static const AllSocietyAPI = "Api/login";
  static const SocietyAPI = "Api/mysociety";
  static const otpSendAPI = "Api/otpsend";
  static const otpReSendAPI = "Api/otp_resend";
  static const otpLoginAPI = "Api/otpLogin";
  static const newPasswordAPI = "Api/newpwd";
  static const unitMemberAPI = "Members";
  static const unitAddMemberAPI = "Members/insert";
  static const unitStaffAPI = "Staff";
  static const unitVehicleAPI = "Vehicle";
  static const unitAddVehicleAPI = "Vehicle/insert";
  static const ComplaintsAPI = "Helpdesk";
  static const AddComplaintsAPI = "Helpdesk/add";
  static const CommentAPI = "Helpdesk/comment";
  static const ComplaintsAreaAPI = "Helpdesk/area";
  static const ComplaintsCategoryAPI = "Helpdesk/category";
  static const UpdateStatusAPI = "Helpdesk/updatecmtstatus";
  static const DocumentAPI = "Document";
  static const UploadFileAPI = "UploadFile";
  static const CommitteeDirectoryAPI = "View_directory/commitee";
  static const NeighboursDirectoryAPI = "View_directory/society_member";
  static const EmergencyDirectoryAPI = "Api/emergency";
  static const AnnouncementAPI = "Announcement";
  static const AnnouncementPollAPI = "Announcement/Poll";
  static const GatePassAPI = "Gatepass";
  static const AddGatePassScheduleAPI = "Gatepass/scheduled_visitor";
  static const GetGatePassScheduleAPI = "Gatepass/schedule_visitor";
  static const profileAPI = "profile";
  static const editProfileAPI = "profile/insert";
  static const payOptionAPI = "Api/payoption";
  static const staffMobileVerifyAPI = "Staff/mobileverifystaff";
  static const addStaffMemberAPI = "Staff/insertstaff";

  /*GATEPASEE DIALOG API*/
  static const approveGatePassAPI = "Gatepassapp/visitorcalling_response";
  static const rejectGatepassAPI = "Gatepassapp/visitorstatusupdate";

  static const authorizedTokenERP = "erpadmin:SocERP21run";
  static var AUTHERP="Basic "+base64Url.encode(utf8.encode(authorizedTokenERP));
  static const BaseURLERP = "https://housingsocietyerp.com/AndroidApi/";
  /*Api Name for BaseURLERP*/
  static const duesAPI = "dues";
  static const ledgerAPI = "ledger";
  static const viewBillsAPI = "view";
  static const billAPI = "Billview1";
  static const receiptAPI = "receiptview";
  static const bankAPI = "bank";
  static const insertPaymentAPI = "insertpayment";
  static const paymentRequestAPI = "paymentrequest";
  static const mailAPI = "mail";


  /*Routs Variables*/
  static const LoginPage = "Login";
  static const OTPPage = "OTP";
  static const OtpWithMobilePage = "OtpWithMobile";
  static const DashBoardPage = "DashBoard";
  static const RegisterPage = "Register";
  static const AddSocietyPage = "AddSociety";
  static const MyUnitPage = "MyUnit";
  static const MyComplexPage = "MyComplex";
  static const MyDiscoverPage = "MyDiscover";
  static const MyFacilitiesPage = "MyFacilities";
  static const MyGatePage = "MyGate";
  static const HelpDeskPage = "HelpDesk";
  static const RaiseNewTicketPage = "RaiseNewTicket";
  static const ComplaintInfoAndCommentsPage = "ComplaintInfoAndComments";
  static const AdminPage = "Admin";
  static const MorePage = "More";
  static const ExpectedVisitorPage = "ExpectedVisitor";
  static const CabPage = "Cab";
  static const DeliveryPage = "Delivery";
  static const HomeServicePage = "HomeService";
  static const ListOfHomeServicePage = "ListOfHomeService";
  static const DescriptionOfHomeServicePage = "DescriptionOfHomeService";
  static const GuestOthersPage = "GuestOthers";
  static const CreateClassifiedListingPage = "CreateClassifiedListing";
  static const AddNearByShopPage = "AddNearByShop";
  static const BanquetBookingPage = "BanquetBooking";
  static const AddNewMemberPage = "AddNewMember";
  static const LedgerPage = "BaseLedger";
  static const ViewBillPage = "ViewBill";
  static const ChangeLanguageNotifier = "ChangeLanguageNotifier";


  /*Variables for Custom Colors*/
  static const Color black =const Color(0xFF000000);
  static const Color white =const Color(0xFFFFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color lightGray =const Color(0xFFD3D3D3);
  static const Color veryLightGray =const Color(0xFFE0E0E0);
  static const Color grey =const Color(0xFF66766F);
  static const Color green =const Color(0xFF2CA01C);
  static const Color lightGreen =const Color(0xFFDAF7D5);
  static const Color mediumGreen =const Color(0xFFB3E3BD);
  static const Color transparent =const Color(0xFF00000000);
  static const Color skyBlue =const Color(0xFF64B5F6);
  static const Color orangeYellow =const Color(0xFFFFA726);
  static const Color red =const Color(0xFFC62828);

  /*Variables for URL FormData Key*/

  static const societyId='SOCIETY_ID';
  static const flat='FLAT';
  static const block='BLOCK';
  static const ticketNo='TICKET_NO';
  static const userID='USER_ID';
  static const parentTicket='PARENT_TICKET';
  static const status='STATUS';
  static const message='MESSAGE';
  static const societyName='Society_Name';
  static const userEmail='Email';
  static const societyEmail='Society_Email';
  static const SUBJECT='SUBJECT';
  static const COMPLAINT_AREA='COMPLAINT_AREA';
  static const TYPE='TYPE';
  static const Type='Type';
  static const CATEGORY='CATEGORY';
  static const PRIORITY='PRIORITY';
  static const NAME='NAME';
  static const ATTACHMENT='ATTACHMENT';
  static const ATTACHMENT_NAME='ATTACHMENT_NAME';
  static const DESCRIPTION='DESCRIPTION';
  static const COMMENT='COMMENT';
  static const ESCALATION_LEVEL='ESCALATION_LEVEL';
  static const GENDER='GENDER';
  static const DOB='DOB';
  static const USER_NAME='USER_NAME';
  static const MOBILE='MOBILE';
  static const BLOOD_GROUP='BLOOD_GROUP';
  static const OCCUPATION='OCCUPATION';
  static const HOBBIES='HOBBIES';
  static const IDENTITY_PROOF='IDENTITY_PROOF';
  static const LIVES_HERE='LIVES_HERE';
  static const NOTE='NOTE';
  static const VEHICLE_NO='VEHICLE_NO';
  static const MODEL='MODEL';
  static const WHEEL='WHEEL';
  static const STICKER_NO='STICKER_NO';
  static const MOBILE_NO="MOBILE_NO";
  static const DATE="DATE";
  static const INVOICE_NO="INVOICE_NO";
  static const RECEIPT_NO="RECEIPT_NO";
  static const AMOUNT="AMOUNT";
  static const REFERENCE_NO="REFERENCE_NO";
  static const TRANSACTION_MODE="TRANSACTION_MODE";
  static const BANK_ACCOUNTNO="BANK_ACCOUNTNO";
  static const PAYMENT_DATE="PAYMENT_DATE";
  static const NARRATION="NARRATION";
  static const CHEQUE_BANKNAME="CHEQUE_BANKNAME";
  static const PROFILE_PHOTO="PROFILE_PHOTO";
  static const ALTERNATE_CONTACT1="ALTERNATE_CONTACT1";
  static const ALTERNATE_CONTACT2="ALTERNATE_CONTACT2";
  static const Email="Email";
  static const Phone="Phone";
  static const Contact="CONTACT";
  static const STAFF_NAME="STAFF_NAME";
  static const QUALIFICATION="QUALIFICATION";
  static const ADDRESS="ADDRESS";
  static const NOTES='NOTES';
  static const USER_ID='USER_ID';
  static const PHOTO='PHOTO';
  static const ROLE='ROLE';
  static const NUMBER='NUMBER';
  static const Email_id='Email_id';




  /*Server Response Key*/

  static const STATUS = "status";
  static const MESSAGE = "message";
  static const DATA = "data";
  static const PassCode = "pass_code";
  static const ExpiredTime = "expire_time";
  static const OTP = "otp";

}
class GatePassStatus{
  static const REJECTED = "Rejected";
  static const APPROVED = "Verified";
  static const LEAVE_AT_GATE = "Leave at gate";
}
class GatePassFields{
  static const VID = "VID";
  static const USER_ID = "USER_ID";
  static const REASON = "REASON";
  static const NO_OF_VISITOR = "NO_OF_VISITOR";
  static const FROM_VISITOR = "FROM_VISITOR";
  static const VISITOR_STATUS = "VISITOR_STATUS";
  static const IN_BY = "IN_BY";
  static const SOCIETY_ID = "SOCIETY_ID";
  static const IN_DATE = "IN_DATE";
  static const IN_TIME = "IN_TIME";
  static const ID = "ID";
  static const COMMENT = "COMMENT";
  static const STATUS = "STATUS";
}