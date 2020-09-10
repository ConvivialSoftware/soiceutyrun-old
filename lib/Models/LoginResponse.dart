import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class LoginResponse {
  String ID;
  String USER_ID;
  String SOCIETY_ID;
  String BLOCK;
  String FLAT;
  String USER_NAME;
  String MOBILE;
  String PASSWORD;
  String USER_TYPE;
  String gcm_id;
  String token_id;
  String C_DATE;
  String message;
  String Society_Name;
  String Address;
  String Reg_no;
  String Contact;
  String Email;
  String society_Permissions;
  String Name;
  String Role;
  String TYPE;
  String Photo;
  String Permissions;
  String Consumer_no;
  bool status;
  String Staff_QR_Image;
  String google_parameter;
  String User_Status;

  LoginResponse(
      {this.ID,
      this.USER_ID,
      this.SOCIETY_ID,
      this.BLOCK,
      this.FLAT,
      this.USER_NAME,
      this.MOBILE,
      this.PASSWORD,
      this.USER_TYPE,
      this.gcm_id,
      this.token_id,
      this.C_DATE,
      this.message,
      this.Society_Name,
      this.Address,
      this.Reg_no,
      this.Contact,
      this.Email,
      this.society_Permissions,
      this.Name,
      this.Role,
      this.TYPE,
      this.Photo,
      this.Permissions,
      this.Consumer_no,
      this.status,
      this.Staff_QR_Image,
      this.google_parameter,
      this.User_Status});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
        ID: json["ID"],
        USER_ID: json["USER_ID"],
        SOCIETY_ID: json["SOCIETY_ID"],
        BLOCK: json["BLOCK"],
        FLAT: json["FLAT"],
        USER_NAME: json["USER_NAME"],
        MOBILE: json["MOBILE"],
        PASSWORD: json["PASSWORD"],
        USER_TYPE: json["USER_TYPE"],
        gcm_id: json["gcm_id"],
        token_id: json["token_id"],
        C_DATE: json["C_DATE"],
        message: json["message"],
        Society_Name: json["Society_Name"],
        Address: json["Address"],
        Reg_no: json["Reg_no"],
        Contact: json["Contact"],
        Email: json["Email"],
        society_Permissions: json["society_Permissions"],
        Name: json["Name"],
        Role: json["Role"],
        TYPE: json["TYPE"],
        Photo: json["Photo"],
        Permissions: json["Permissions"],
        Consumer_no: json["Consumer_no"],
        status: json["status"],
        Staff_QR_Image: json["Staff_QR_Image"],
        google_parameter: json["google_parameter"],
        User_Status: json["User_Status"]);
  }
}
