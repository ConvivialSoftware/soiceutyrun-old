import 'dart:convert';

import 'package:flutter/material.dart';

class GlobalVariables {
  static var isAlreadyTapped = false;
  static var isNewlyArrivedNotification = false;
  //static var isBackgroundNotification = false;
  static ValueNotifier<int> notificationCounterValueNotifer = ValueNotifier(0);
  static ValueNotifier<String> userNameValueNotifer = ValueNotifier('');
  static ValueNotifier<String> userImageURLValueNotifer = ValueNotifier('');

  /*Variables for the Web URL*/
  static const appURL = "https://societyrun.com/";
  static const termsConditionURL = "https://societyrun.com/Terms%20&%20conditions.html";
  static const privacyPolicyURL = "https://societyrun.com/Privacy_Policy.html";
  static bool isERPAccount = false;

  /*Variables for the SharedPreferences*/
  static var keyIsLogin = "isLogin";
  static var keyUsername = "username";
  static var keyToken = "GCM_ID";
  static var keyTokenIOS = "TOKEN_ID";
  static var keyPassword = "password";
  static var keyLanguageCode = "language_code";
  static var keyId = "id";
  static var keySocietyId = "society_id";
  static var keyUserId = "user_id";
  static var keyBlock = "block";
  static var keyFlat = "flat";
  static var keyMobile = "mobile";
  static var keyUserType = "user_type";
  static var keySocietyName = "society_name";
  static var keySocietyAddress = "society_address";
  static var keyEmail = "email";
  static var keySocietyPermission = "society_permission";
  static var keyName = "name";
  static var keyStaffQRImage = "staff_qr_image";
  static var keyPhoto = "photo";
  static var keyUserPermission = "user_permission";
  static var keyConsumerId = "consumer_id";
  static var keyDuesRs = "dues_rs";
  static var keyDuesDate = "dues_date";
  static var keyGoogleCoordinate = "google_parameter";
  static var keyLoggedUsername = "logged_username";
  static var keyDailyEntryNotification = "daily_entry_notification";
  static var keyGuestEntryNotification = "guest_entry_notification";
  static var keyInAppCallNotification = "in_app_call_notification";
  static var keyIsNewlyArrivedNotification = "isNewlyArrivedNotification";
  static var keySMSCredit = "SMS_CREDIT";

  static var appImagePath = "assets/images/ic_societyrun.png";
  static var appLogoPath = "assets/images/society_run_green.png";
  static var userProfilePath = "assets/images/user_profile.jpeg";
  static var drawerImagePath =
      "assets/other_assets/societyrun-logo_colored.svg";
  static var appIconPath = "assets/other_assets/societyrun-logo.svg";
  static var appLogoGreenIcon = "assets/images/societyrun_icon.png";
  static var splashIconPath = "assets/other_assets/splash_socityrun.png";
  static var myFlatIconPath = "assets/menu_assets/myhome_icon.svg";
  static var myBuildingIconPath = "assets/menu_assets/building_icon_menu.svg";
  static var myServiceIconPath = "assets/menu_assets/service_icon_menu.svg";
  static var myClubIconPath = "assets/menu_assets/club_icon_menu.svg";
  static var myGateIconPath = "assets/menu_assets/gatepass_icon_menu.svg";
  static var mySupportIconPath = "assets/menu_assets/Support_icon_menu.svg";
  static var myAdminIconPath = "assets/menu_assets/admin_icon_menu.svg";
  static var settingsIconPath = "assets/menu_assets/settings.svg";
  static var switchIconPath = "assets/menu_assets/switch.svg";
  static var headerIconPath = "assets/other_assets/Header_bg.svg";
  static var loginIconPath = "assets/other_assets/login_icon.svg";
  static var mailIconPath = "assets/other_assets/mail_icon.svg";
  static var lockIconPath = "assets/other_assets/lock_icon.svg";
  static var classifiedBigIconPath =
      "assets/other_assets/Classified_big_icon.svg";
  static var classifiedPath = "assets/other_assets/Classified_icon.svg";
  static var topBreadCrumPath = "assets/other_assets/Top_breadcrum.svg";
  static var overviewTxtPath = "assets/other_assets/overview_txt.svg";
  static var notificationBellIconPath =
      "assets/other_assets/notification_icon.svg";
  static var whileBGPath = "assets/other_assets/while_bg.svg";
  static var buildingIconPath = "assets/other_assets/building_icon.svg";
  static var gatePassIconPath = "assets/other_assets/gatePass_icon.svg";
  static var moreIconPath = "assets/other_assets/More_icon.svg";
  static var serviceIconPath = "assets/other_assets/Services_icon.svg";
  static var shoppingIconPath = "assets/other_assets/shopping_icon.svg";
  static var shopIconPath = "assets/other_assets/Shop_icon.svg";
  static var supportIconPath = "assets/other_assets/Support_icon.svg";
  static var storeIconPath = "assets/other_assets/store_icon.svg";
  static var componentUserProfilePath =
      "assets/other_assets/component_user_profile.png";
  static var userProfileIconPath = "assets/other_assets/profile_icon.svg";
  static var waterIconPath = "assets/other_assets/water_icon.svg";
  static var pdfIconPath = "assets/other_assets/Icon awesome-file-pdf.svg";
  static var downloadIconPath = "assets/other_assets/Icon awesome-download.svg";
  static var pdfBackIconPath = "assets/other_assets/icon-pdf.svg";
  static var creditCardPath = "assets/other_assets/credit_card.png";
  static var aboutUsPath = "assets/other_assets/about_us.svg";
  static var comingSoonPath = "assets/other_assets/coming_soon.png";
  static var bikeIconPath = "assets/other_assets/bike.svg";
  static var changePasswordPath = "assets/other_assets/change_password.svg";
  static var successIconPath = "assets/other_assets/success.svg";
  static var failureIconPath = "assets/other_assets/failure.svg";
  static var deactivateIconPath = "assets/other_assets/deactive.svg";
  static var deliveryManIconPath = "assets/other_assets/delivery_man.svg";
  static var taxiIconPath = "assets/other_assets/taxi.svg";
  static var visitorIconPath = "assets/other_assets/visitor.svg";
  static var inIconPath = "assets/other_assets/in.svg";
  static var outIconPath = "assets/other_assets/out.svg";
  static var anxietyIconPath = "assets/other_assets/anxiety.svg";
  static var expenseIconPath = "assets/other_assets/expense.svg";
  static var payTMIconPath = "assets/other_assets/paytm.png";
  static var razorPayIconPath = "assets/other_assets/razorpay.png";
  static var appSettingsIconPath = "assets/other_assets/app_settings.svg";
  static var inAppCallIconPath = "assets/other_assets/in_app_call.svg";
  static var dailyHelpsIconPath = "assets/other_assets/daily_helps.svg";
  static var logoutIconPath = "assets/other_assets/logout_icon.svg";
  static var guestIconPath = "assets/other_assets/guest.svg";
  static var feedbackIconPath = "assets/other_assets/feedback.svg";
  static var verifiedContactIconPath = "assets/other_assets/verified_contact.svg";
  static var whatsAppIconPath = "assets/other_assets/t3_ic_wp.svg";
  static var sofaIconPath = "assets/other_assets/db8_ic_item6.png";
  static var superDailyIconPath = "assets/other_assets/superdaily.png";
  static var noDataFoundIconPath = "assets/other_assets/no_data_found.png";
  static var paidIconPath = "assets/other_assets/paid.png";
  static var documentImageIconPath = "assets/other_assets/document_image.svg";
  static var activeUserIconPath = "assets/other_assets/active_user.png";
  static var mobileUserIconPath = "assets/other_assets/mobile_user.png";
  static var registeredUserIconPath = "assets/other_assets/registered_user.png";
  static var rentalRequestIconPath = "assets/other_assets/rental_request.png";
  static var pendingRequestIconPath = "assets/other_assets/pending_request.png";
  static var moveOutRequestIconPath = "assets/other_assets/move_out_request.png";
  static var apartmentIconPath = "assets/other_assets/apartment.png";
  static var smileIconPath = "assets/other_assets/smile.png";
  static var sadIconPath = "assets/other_assets/sad.png";

  static var bottomBGPath = "assets/bottom_menu/bottom_bg.svg";
  static var bottomBuildingIconPath =
      "assets/bottom_menu/bottom_building_icon.svg";
  static var bottomClubIconPath = "assets/bottom_menu/bottom_club_icon.svg";
  static var bottomHomeIconPath = "assets/bottom_menu/bottom_home_icon.svg";
  static var bottomMenuIconPath = "assets/bottom_menu/bottom_menu_icon.svg";
  static var bottomMyHomeIconPath = "assets/bottom_menu/bottom_myhome_icon.svg";
  static var bottomServiceIconPath = "assets/bottom_menu/bottom_service_icon.svg";

  /* font sizes*/
  static const textSizeVerySmall = 10.0;
  static const textSizeSmall = 12.0;
  static const textSizeSMedium = 14.0;
  static const textSizeMedium = 16.0;
  static const varyLargeText = 25.0;
  static const textSizeLargeMedium = 18.0;
  static const textSizeNormal = 20.0;
  static const textSizeLarge = 24.0;
  static const textSizeXLarge = 30.0;
  static const textSizeXXLarge = 35.0;

  /*static const fontRegular = 'Regular';
  static const fontMedium = 'Medium';
  static const fontSemibold = 'Semibold';
  static const fontBold = 'Bold';*/

  static const spacing_control_half = 2.0;
  static const spacing_control = 4.0;
  static const spacing_standard = 8.0;
  static const spacing_middle = 10.0;
  static const spacing_standard_new = 16.0;
  static const spacing_large = 24.0;
  static const spacing_xlarge = 32.0;
  static const spacing_xxLarge = 40.0;

  /*Variables For Call Rest API*/
  static const Get = 'GET';
  static const Post = 'POST';
  static const Put = 'PUT';
  static const Delete = 'DELETE';

  static const appFlag = "SR";
  static const authorizedToken = "socrun:Plmn#091";
  //static const authorizedToken = "admin:1234";
  static var AUTH = "Basic " + base64Url.encode(utf8.encode(authorizedToken));
  static const BaseURL = "https://societyrun.com/Flutter/";
 // static const BaseURLAndroid = "https://societyrun.com/Android/";
  static const BaseRazorPayURL = "https://api.razorpay.com/";

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
  static const unitStaffAPI = "staff/staff_list";
  static const unitVehicleAPI = "Vehicle";
  static const unitAddVehicleAPI = "Vehicle/insert";
  static const ComplaintsAPI = "Helpdesk";
  static const AddComplaintsAPI = "Helpdesk/add";
  static const CommentAPI = "Helpdesk/comment";
  static const ComplaintsAreaAPI = "Helpdesk/area";
  static const ComplaintsCategoryAPI = "Helpdesk/category";
  static const UpdateStatusAPI = "Helpdesk/updatecmtstatus";
  static const TicketNoComplaintAPI = "Helpdesk/complaints";
  static const DocumentAPI = "Document";
  static const UploadFileAPI = "UploadFile";
  static const CommitteeDirectoryAPI = "View_directory/commitee";
  static const NeighboursDirectoryAPI = "View_directory/society_member";
  static const EmergencyDirectoryAPI = "Api/emergency";
  static const AnnouncementAPI = "Announcement";
  static const AnnouncementPollAPI = "Poll";
  static const pollVoteAPI = "Dashboard/vote";
  static const GatePassAPI = "Gatepass";
  static const AddGatePassScheduleAPI = "Gatepass/scheduled_visitor";
  static const GetGatePassScheduleAPI = "Gatepass/schedule_visitor";
  static const profileAPI = "profile";
  static const editProfileAPI = "profile/insert";
  static const payOptionAPI = "Api/payoption";
  static const staffMobileVerifyAPI = "Staff/mobileverifystaff";
  static const addStaffMemberAPI = "Staff/insertstaff";
  static const bannerAPI = "Api/banner";
  static const feedbackAPI = "Feedback";
  static const allMemberAPI = "View_directory/all_member";
  static const razorPayOrderAPI = "v1/orders";
  static const logoutAPI = "Api/logout";
  static const assignComplaintsAPI = "Helpdesk/assigncomplaints";
  static const gatePassWrongEntryAPI = "Gatepass/wrong_entry";
  static const deleteExpectedVisitorAPI = "Gatepass/schedulevisitor_delete";
  static const staffCountAPI = "staff/staffcnt";
  static const staffRoleDetailsAPI = "staff/staffrole";
  static const addStaffRattingAPI = "staff/add_rating";
  static const addHouseholdAPI = "staff/add_household";
  static const removeHouseholdAPI = "staff/household_remove";
  static const deleteVehicleAPI = "Vehicle/delete";
  static const deleteFamilyMemberAPI = "Members/delete";
  static const broadcastEmailAPI = "Broadcast/send_email";
  static const broadcastNotificationAPI = "Broadcast/send_notification";
  static const flatNoAPI = "Broadcast/Flatno";
  static const broadcastSMSAPI = "Broadcast/send_sms";
  static const userManagementDashboardAPI = "Dashboard";
  static const userTypeListAPI = "Dashboard/user_list_active";
  static const unitDetailsAPI = "Dashboard/unit_data";
  static const editUnitDetailsAPI = "Dashboard/edit_unit";
  static const addMemberByAdminAPI = "Members/add_member_insert";
  static const blockAPI = "Members/Block";
  static const flatAPI = "Members/Flatno";
  static const smsDataAPI = "Dashboard/SMS_data";
  static const rentalRequestAPI = "Members/rental_request";
  static const pendingRequestAPI = "Members/pending_member";
  static const moveOutRequestAPI = "Members/moveout_member";
  static const sendInviteAPI = "Members/send_invite";
  static const approvePendingRequestAPI = "Members/approve_update";
  static const deactivateUserAPI = "Members/deactivate_user";
  static const nocApproveAPI = "Members/noc_approve";
  static const addAgreementAPI = "Members/add_agreement";
  static const adminAddAgreementAPI = "Members/admin_add_agreement";

  /*GATEPASEE DIALOG API*/
  static const approveGatePassAPI = "Gatepassapp/visitorcalling_response";
 // static const rejectGatepassAPI = "Gatepassapp/visitorstatusupdate";.;

  static const authorizedTokenERP = "erpadmin:SocERP21run";
  static var AUTHERP =
      "Basic " + base64Url.encode(utf8.encode(authorizedTokenERP));
  static const BaseURLERP = "https://housingsocietyerp.com/";
  static const BaseURLERPView = "https://housing.convivialsoftware.com/";
 // static const BaseURLDiscover = "https://mydemosites.in/";
  static const BaseURLDiscover = "https://societyrun.com//Flutter/Classified/Login/";

  /*Api Name for BaseURLDiscover*/
  static const displayClassifiedAPI = "display";
  static const displayOwnerClassifiedAPI = "my_classified";
  static const insertClassifiedAPI = "insert";
  static const exclusiveOfferAPI = "exclusive_offer";
  static const cityAPI = "city";
  static const insertUserInfoOnExclusiveGetCode = "getcode";
  static const interestedClassified = "interested";
  static const servicesCategory = "service_category";
  static const servicePerCategory = "services";
  static const bookServicePerCategory = "book_service";
  static const ownerServices = "my_service";
  static const addServicesRatting = "update_rating";
  static const editClassifiedData = "classfied_edit";
  static const updateClassifiedReasonForRemove = "update_reason";
  static const activeClassifiedStatus = "classified_active";
  static const deleteClassifiedImage = "classfied_img_delete";

  /*Api Name for BaseURLERP*/
  /*static const duesAPI = "AndroidApi/dues";
  static const ledgerAPI = "AndroidApi/ledger";
  static const viewBillsAPI = "AndroidApi/view";
  static const billAPI = "AndroidApi/Billview1";
  static const receiptAPI = "AndroidApi/receiptview1";
  static const bankAPI = "AndroidApi/bank";
  static const insertPaymentAPI = "AndroidApi/insertpayment_razorpay";
  static const paymentRequestAPI = "AndroidApi/paymentrequest";
  static const mailAPI = "AndroidApi/mail";
  static const receiptMailAPI = "AndroidApi/receipt_mail";
  static const razorPayTransactionAPI = "AndroidApi/Razorpay_transaction";
  static const accountLedgerAPI = "Androidexpense/account_ledger";
  static const expenseAPI = "Androidexpense/all_expense";
  static const expenseBankAPI = "Androidexpense/bank";
  static const addExpenseAPI = "Androidexpense/Add";*/

  static const duesAPI = "AndroidApi/dues";
  static const ledgerAPI = "AndroidApi/ledger";
  static const viewBillsAPI = "AndroidApi/view";
  static const billAPI = "AndroidApi/Billview1";
  static const billPDFAPI = "AndroidApi/Bill_view";
  static const receiptPDFAPI = "AndroidApi/Receipt_view";
  static const receiptAPI = "AndroidApi/receiptview1";
  static const bankAPI = "AndroidApi/bank";
  static const insertPaymentAPI = "AndroidApi/insertpayment_razorpay";
  static const paymentRequestAPI = "AndroidApi/paymentrequest";
  static const mailAPI = "AndroidApi/mail";
  static const receiptMailAPI = "AndroidApi/receipt_mail";
  static const razorPayTransactionAPI = "AndroidApi/Razorpay_transaction";
  static const accountLedgerAPI = "Androidexpense/account_ledger";
  static const expenseAPI = "Androidexpense/all_expense";
  static const expenseBankAPI = "Androidexpense/bank";
  static const addExpenseAPI = "Androidexpense/Add";

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
  static const Color black = const Color(0xFF000000);
  static const Color white = const Color(0xFFFFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color lightGray = const Color(0xFFD3D3D3);
  static const Color veryLightGray = const Color(0xFFE0E0E0);
  static const Color grey = const Color(0xFF66766F);
  static const Color green = const Color(0xFF2CA01C);
  static const Color lightGreen = const Color(0xFFDAF7D5);
  static const Color mediumGreen = const Color(0xFFB3E3BD);
  static const Color transparent = const Color(0xFF00000000);
  static const Color skyBlue = const Color(0xFF64B5F6);
  static const Color orangeYellow = const Color(0xFFFFA726);
  static const Color red = const Color(0xFFC62828);
  static const Color lightCyan = const Color(0xFF73D7D3);
  static const Color lightOrange = const Color(0xFFFF9781);
  static const Color lightPurple = const Color(0xFF8998FE);
  static const Color averageGray = const Color(0xFFaaaab3);
  static const Color averageGreen = const Color(0xFFb1e3b1);

  /*Variables for URL FormData Key*/

  static const societyId = 'SOCIETY_ID';
  static const flat = 'FLAT';
  static const block = 'BLOCK';
  static const ticketNo = 'TICKET_NO';
  static const userID = 'USER_ID';
  static const parentTicket = 'PARENT_TICKET';
  static const status = 'STATUS';
  static const message = 'MESSAGE';
  static const societyName = 'Society_Name';
  static const userEmail = 'Email';
  static const societyEmail = 'Society_Email';
  static const SUBJECT = 'SUBJECT';
  static const COMPLAINT_AREA = 'COMPLAINT_AREA';
  static const TYPE = 'TYPE';
  static const Type = 'Type';
  static const type = 'type';
  static const CATEGORY = 'CATEGORY';
  static const PRIORITY = 'PRIORITY';
  static const NAME = 'NAME';
  static const ATTACHMENT = 'ATTACHMENT';
  static const ATTACHMENT_NAME = 'ATTACHMENT_NAME';
  static const DESCRIPTION = 'DESCRIPTION';
  static const SEND_TO = 'SEND_TO';
  static const SMS_TYPE = 'sms_type';
  static const name = 'name';
  static const meeting_name = 'meeting_name';
  static const meeting_date = 'meeting_date';
  static const time = 'time';
  static const minute = 'minute';
  static const time_type = 'time_type';
  static const venue = 'venue';
  static const FLATS = 'FLATS';
  static const COMMENT = 'COMMENT';
  static const ESCALATION_LEVEL = 'ESCALATION_LEVEL';
  static const GENDER = 'GENDER';
  static const DOB = 'DOB';
  static const USER_NAME = 'USER_NAME';
  static const MOBILE = 'MOBILE';
  static const BLOOD_GROUP = 'BLOOD_GROUP';
  static const OCCUPATION = 'OCCUPATION';
  static const HOBBIES = 'HOBBIES';
  static const IDENTITY_PROOF = 'IDENTITY_PROOF';
  static const LIVES_HERE = 'LIVES_HERE';
  static const NOTE = 'NOTE';
  static const VEHICLE_NO = 'VEHICLE_NO';
  static const MODEL = 'MODEL';
  static const WHEEL = 'WHEEL';
  static const STICKER_NO = 'STICKER_NO';
  static const MOBILE_NO = "MOBILE_NO";
  static const DATE = "DATE";
  static const INVOICE_NO = "INVOICE_NO";
  static const RECEIPT_NO = "RECEIPT_NO";
  static const AMOUNT = "AMOUNT";
  static const REFERENCE_NO = "REFERENCE_NO";
  static const TRANSACTION_MODE = "TRANSACTION_MODE";
  static const TRANSACTION_TYPE = "TRANSACTION_TYPE";
  static const BANK_ACCOUNTNO = "BANK_ACCOUNTNO";
  static const BANK = "BANK";
  static const LEDGER_ID = "LEDGER_ID";
  static const PAYMENT_DATE = "PAYMENT_DATE";
  static const NARRATION = "NARRATION";
  static const CHEQUE_BANKNAME = "CHEQUE_BANKNAME";
  static const PROFILE_PHOTO = "PROFILE_PHOTO";
  static const ALTERNATE_CONTACT1 = "ALTERNATE_CONTACT1";
  static const ALTERNATE_CONTACT2 = "ALTERNATE_CONTACT2";
  static const Email = "Email";
  static const Phone = "Phone";
  static const Contact = "CONTACT";
  static const STAFF_NAME = "STAFF_NAME";
  static const QUALIFICATION = "QUALIFICATION";
  static const ADDRESS = "ADDRESS";
  static const NOTES = 'NOTES';
  static const PHOTO = 'PHOTO';
  static const ROLE = 'ROLE';
  static const NUMBER = 'NUMBER';
  static const Email_id = 'Email_id';
  static const RESPONSE = 'RESPONSE';
  static const orderID = 'ORDER_ID';
  static const TOKEN_ID = 'TOKEN_ID';
  static const GCM_ID = 'gcm_id';
  static const android_version = 'android_version';
  static const android_type = 'android_type';
  static const ios_version = 'ios_version';
  static const ios_type = 'ios_type';
  static const GatePass_Delivery = 'Delivery';
  static const GatePass_Taxi = 'Taxi';
  static const ID = 'ID';
  static const OPTION = 'OPTION';
  static const SR_NO = 'SR_NO';
  static const EMAIL_ID = 'EMAIL_ID';
  static const SID = 'SID';
  static const Rate = 'Rate';
  static const id = 'id';
  static const CONSUMER_NO = 'CONSUMER_NO';
  static const PARKING_SLOT = 'PARKING_SLOT';
  static const AREA = 'AREA';
  static const GSTIN_NO = 'GSTIN_NO';
  static const BILLING_NAME = 'BILLING_NAME';
  static const INTERCOM = 'INTERCOM';
  static const unit = 'unit';
  static const member = 'member';
  static const notForModerator = 'Not_For_Moderator';
  static const note = 'note';
  static const PHONE = 'PHONE';
  static const EMAIL = 'EMAIL';
  static const AGREEMENT_FROM = 'AGREEMENT_FROM';
  static const AGREEMENT_TO = 'AGREEMENT_TO';
  static const AGREEMENT = 'AGREEMENT';
  static const RENTED_TO = 'RENTED_TO';
  static const Noc_Issue = 'Noc_Issue';

  /*Server Response Key*/

  static const STATUS = "status";
  static const MESSAGE = "message";
  static const DATA = "data";
  static const Front = "front";
  static const bank = "bank";
  static const category = "category";
  static const Year = "Year";
  static const head_details = "head_details";
  static const PassCode = "pass_code";
  static const ExpiredTime = "expire_time";
  static const OTP = "otp";
  static const commitee_member = "commitee_member";
  static const society_member = "society_member";
  static const emergency = "emergency";
}

class GatePassStatus {
  static const REJECTED = "Rejected";
  static const APPROVED = "Accepted";
  static const LEAVE_AT_GATE = "Leave at gate";
  static const WAIT_AT_GATE = "Wait at gate";
}

class GatePassFields {
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
  static const GCM_ID="GCM_ID";
}

class NotificationTypes{

  static const String TYPE_EVENT = "Event";
  static const String TYPE_MEETING = "Meeting";
  static const String TYPE_ANNOUNCEMENT = "Announcement";
  static const String TYPE_ASSIGN_COMPLAINT = "AssignComplaint";
  static const String TYPE_COMPLAINT = "Complaint";
  static const String TYPE_VISITOR = "Visitor";
  static const String TYPE_FVISITOR = "FVisitor";
  static const String TYPE_SInApp = "SInapp";
  static const String TYPE_VISITOR_VERIFY = "Visitor_verify";
  static const String TYPE_POLL = "Poll";
  static const String TYPE_BILL = "Bill";
  static const String TYPE_RECEIPT = "Receipt";
  static const String TYPE_WEB = "Web";
  static const String TYPE_BROADCAST = "Broadcast";
  static const String TYPE_NEW_OFFER = "New_Offer";
  static const String TYPE_INTERESTED_CUSTOMER = "Interested_Customer";

}

class SocietyRun {
  static const companyName = "Convivial Software Pvt. Ltd.";
  static const salesContact = "+91 8055551809";
  static const salesContact1 = "+91 8082697529";
  //static const supportContact = "020 46304333";
  static const supportContact = "+91 7058684440";
  static const webSite = "http://www.convivialsolutions.com/";
  static const salesEmail = "sales@societyrun.com";
  static const supportEmail = "support@societyrun.com";
  static const puneAddress = "Office No. - 906, Rama Equator, Morwadi, Pimpri- 411018";
  static const mumbaiAddress = "F149 Fantasia Business Park, Vashi, Navi Mumbai - 400705";
//static const versionCode="1.0.0";
}

class AppPackageInfo {
  static var appName, packageName, version, buildNumber;
}

class AppPermission {
  static bool isSocHelpDeskPermission = false;
  static var socHelpDeskPermission = 'HELPDESK';
  
  static bool isSocGatePassPermission = false;
  static var socGatePassPermission = 'GATEPASS';
  
  static bool isSocExpensePermission = false;
  static var socExpensePermission = 'EXPENCE';
  
  static bool isSocAddVehiclePermission = false;
  static var socAddVehiclePermission = 'AddVehicle';

  static bool isSocPayAmountEditPermission = false;
  static var socPayAmountEditPermission = 'PayAmountEdit';

  static bool isSocPayAmountNoLessPermission = false;
  static var socPayAmountNoLessPermission = 'PayAmountNoLess';

  static bool isUserMyUnitPermission = false;
  static var userMyUnitPermission = '';
  
  static bool isUserDirectoryPermission = false;
  static var userDirectoryPermission = '';
  
  static bool isUserGatePassPermission = false;
  static var userGatePassPermission = '';
  
  static bool isUserAddMemberPermission = false;
  static var userAddMemberPermission = 'addMember';
  
  static bool isUserHelpDeskPermission = false;
  static var userHelpDeskPermission = 'helpDesk';
  
  static bool isUserDocumentPermission = false;
  static var userDocumentPermission = '';
  
  static bool isUserClassifiedPermission = false;
  static var userClassifiedPermission = '';
  
  static bool isUserViewFacilityPermission = false;
  static var userViewFacilityPermission = '';
  
  static bool isUserAddFacilityPermission = false;
  static var userAddFacilityPermission = '';
  
  static bool isUserViewDocumentsPermission = false;
  static var userViewDocumentsPermission = '';
  
  static bool isUserAdminPermission = false;
  static var userAdminPermission = 'admin';
  
  static bool isUserAdminGatePassPermission = false;
  static var userAdminGatePassPermission = '';
  
  static bool isUserAdminHelpDeskPermission = false;
  static var userAdminHelpDeskPermission = 'adminHelpdesk';
  
  static bool isUserManagementPermission = false;
  static var userManagementPermission = '';
  
  static bool isUserAddCommitteePermission = false;
  static var userAddCommitteePermission = '';
  
  static bool isUserAddPollPermission = false;
  static var userAddPollPermission = '';
  
  static bool isUserUploadDocumentsPermission=false;
  static var userUploadDocumentsPermission = '';
  
  static bool isUserAddBroadCastPermission=false;
  static var userAddBroadCastPermission = '';
  
  static bool isUserViewReportsPermission=false;
  static var userViewReportsPermission = '';
  
  static bool isUserVehiclePhonePermission=false;
  static var uerVehiclePhonePermission = '';
  
  static bool isUserMemberPhonePermission=false;
  static var userMemberPhonePermission = '';
  
  static bool isUserCommitteeEmailPermission=false;
  static var userCommitteeEmailPermission = '';
  
  static bool isUserCommitteePhonePermission=false;
  static var userCommitteePhonePermission = '';

  static bool isAddExpensePermission=false;
  static var addExpensePermission = 'Accounting';


//addMember,gatepass,classifieds,myUnit,directory,viewFacility,helpDesk,viewDocuments,admin,adminGatepass,
// adminHelpdesk,userManagement,addCommitee,addPoll,uploadDocuments,AddFacility,addBroadcast,viewReports,vehiclePhone,
// memberPhone,commiteeEmail,commiteePhone,rentalTenantManagement,editSociety,Accounting,editVoucher,deleteVoucher,
// generateBill,generateInvoice,createReceipts,createVoucher,bulkPayment,deletebulkPayment,editBill,deletebulkBill,editPayment
}
