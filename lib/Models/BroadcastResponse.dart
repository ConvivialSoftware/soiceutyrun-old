import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/DataResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

class BroadcastResponse extends ChangeNotifier {
  List<FlatMemberDetails> flatMemberList = <FlatMemberDetails>[];
  bool isLoading = true;
  String? errMsg;

  Future<dynamic> getFlatMemberDetails() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();

    await restClient.flatNo(societyId).then((value) {
      flatMemberList = List<FlatMemberDetails>.from(
          value.data!.map((i) => FlatMemberDetails.fromJson(i)));
      isLoading = false;
      notifyListeners();
    });

    return flatMemberList;
  }

  Future<DataResponse> postNotificationBroadcast(
      flats, sendTo, subject, description) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    String societyName = await GlobalFunctions.getSocietyName();
    String societyEmail = await GlobalFunctions.getSocietyEmail();

    List<String> ar = <String>[];
    for (int i = 0; i < flats.length; i++) {
      ar.add(flats[i].ID);
    }
    var result = await restClient.broadcastNotification(
        societyId,userId, ar, sendTo, subject, description, societyName, societyEmail);

    return result;
  }

  Future<DataResponse> postMailBroadcast(
      flats, String? attachment, sendTo, subject, description) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    String societyName = await GlobalFunctions.getSocietyName();
    String societyEmail = await GlobalFunctions.getSocietyEmail();

    List<String> ar = <String>[];
    for (int i = 0; i < flats.length; i++) {
      ar.add(flats[i].ID);
    }

    var result = await restClient.broadcastMail(societyId,userId, ar, attachment,
        sendTo, subject, description, societyName, societyEmail);

    return result;
  }

  Future<DataResponse> importantCommunicationSMS(List<FlatMemberDetails> flats,
      String sendTo, String smsType, String name, String societyName) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    List<String> ar = <String>[];
    for (int i = 0; i < flats.length; i++) {
      ar.add(flats[i].ID!);
    }

    var result = await restClient.importantCommunicationSMS(
        societyId,userId, ar, sendTo, smsType, name, societyName);

    return result;
  }

  Future<DataResponse> meetingSMS(
      List<FlatMemberDetails> flats,
      String sendTo,
      String smsType,
      String meeting_name,
      String meeting_date,
      String time,
      String minute,
      String time_type,
      String venue,
      String societyName) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    List<String> ar = <String>[];
    for (int i = 0; i < flats.length; i++) {
      ar.add(flats[i].ID!);
    }
    var result = await restClient.meetingSMS(
        societyId,
        userId,
        ar,
        sendTo,
        smsType,
        meeting_name,
        meeting_date,
        time,
        minute,
        time_type,
        venue,
        societyName);

    return result;
  }

  Future<DataResponse> waterSupplySMS(
      List<FlatMemberDetails> flats,
      String sendTo,
      String smsType,
      String date4,
      String start_time4,
      String start_minute4,
      String start_time_type4,
      String end_time4,
      String end_minute4,
      String end_time_type4,
      String societyName) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    List<String> ar = <String>[];
    for (int i = 0; i < flats.length; i++) {
      ar.add(flats[i].ID!);
    }
    var result = await restClient.waterSupplySMS(
        societyId,
        userId,
        ar,
        sendTo,
        smsType,
        date4,
        start_time4,
        start_minute4,
        start_time_type4,
        end_time4,
        end_minute4,
        end_time_type4,
        societyName);

    return result;
  }

  Future<DataResponse> waterDisruptionSMS(
      List<FlatMemberDetails> flats,
      String sendTo,
      String smsType,
      String date3,
      String start_time3,
      String start_minute3,
      String start_time_type3,
      String end_time3,
      String end_minute3,
      String end_time_type3,
      String societyName) async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    List<String> ar = <String>[];
    for (int i = 0; i < flats.length; i++) {
      ar.add(flats[i].ID!);
    }
    var result = await restClient.waterDisruptionSMS(
        societyId,
        userId,
        ar,
        sendTo,
        smsType,
        date3,
        start_time3,
        start_minute3,
        start_time_type3,
        end_time3,
        end_minute3,
        end_time_type3,
        societyName);

    return result;

  }


  @override
  Future<DataResponse> fireDrillSMS(List<FlatMemberDetails> flats, String sendTo, String smsType,
      String date2, String start_time2, String start_minute2,
      String start_time_type2, String societyName) async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    List<String> ar = <String>[];
    for (int i = 0; i < flats.length; i++) {
      ar.add(flats[i].ID!);
    }
    var result = await restClient.fireDrillSMS(
        societyId,
        userId,
        ar,
        sendTo,
        smsType,
        date2, start_time2,  start_minute2,
         start_time_type2,  societyName);

    return result;

  }

  Future<DataResponse> serviceDownSMS(List<FlatMemberDetails> flats, String sendTo,
      String smsType, String reason, String reason1, String date1, String start_time1,
      String start_minute1, String start_time_type1, String end_time, String end_minute,
      String end_time_type, String societyName) async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    List<String> ar = <String>[];
    for (int i = 0; i < flats.length; i++) {
      ar.add(flats[i].ID!);
    }
    var result = await restClient.serviceDownSMS(
        societyId,
        userId,
        ar,
        sendTo,
        smsType,
        reason,  reason1,  date1,  start_time1,
         start_minute1,  start_time_type1,  end_time,  end_minute,
         end_time_type,  societyName);

    return result;


  }

  Future<DataResponse> powerOutageSMS(List<FlatMemberDetails> flats, String sendTo,
      String smsType, String date, String start_time, String start_minute, String start_time_type,
      String time, String minute, String time_type, String societyName) async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    List<String> ar = <String>[];
    for (int i = 0; i < flats.length; i++) {
      ar.add(flats[i].ID!);
    }
    var result = await restClient.powerOutageSMS(
        societyId,
        userId,
        ar,
        sendTo,
        smsType,
        date,  start_time,  start_minute,  start_time_type,
         time,  minute,  time_type,  societyName);

    return result;


  }


}

class BroadcastSendTo {
  String sendToValue, sendToName;

  BroadcastSendTo(this.sendToValue, this.sendToName);
}

class FlatMemberDetails {
  String? NAME, BLOCK, FLAT, ID, TYPE;

  FlatMemberDetails({this.NAME, this.BLOCK, this.FLAT, this.ID, this.TYPE});

  factory FlatMemberDetails.fromJson(Map<String, dynamic> json) {
    return FlatMemberDetails(
        ID: json['ID'],
        BLOCK: json['BLOCK'],
        NAME: json['NAME'],
        TYPE: json['TYPE'],
        FLAT: json['FLAT']);
  }
}

class SMSTypes {
  String smsTypeName, smsTypeValue;

  SMSTypes(this.smsTypeName, this.smsTypeValue);
}

class Hours {
  String hoursName, hoursValue;

  Hours(this.hoursName, this.hoursValue);
}

class Minutes {
  String minName, minValue;

  Minutes(this.minName, this.minValue);
}

class AMPM {
  String ampmName, ampmValue;

  AMPM(this.ampmName, this.ampmValue);
}
