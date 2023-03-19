import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
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
      String meetingName,
      String meetingDate,
      String time,
      String minute,
      String timeType,
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
        meetingName,
        meetingDate,
        time,
        minute,
        timeType,
        venue,
        societyName);

    return result;
  }

  Future<DataResponse> waterSupplySMS(
      List<FlatMemberDetails> flats,
      String sendTo,
      String smsType,
      String date4,
      String startTime4,
      String startMinute4,
      String startTimeType4,
      String endTime4,
      String endMinute4,
      String endTimeType4,
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
        startTime4,
        startMinute4,
        startTimeType4,
        endTime4,
        endMinute4,
        endTimeType4,
        societyName);

    return result;
  }

  Future<DataResponse> waterDisruptionSMS(
      List<FlatMemberDetails> flats,
      String sendTo,
      String smsType,
      String date3,
      String startTime3,
      String startMinute3,
      String startTimeType3,
      String endTime3,
      String endMinute3,
      String endTimeType3,
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
        startTime3,
        startMinute3,
        startTimeType3,
        endTime3,
        endMinute3,
        endTimeType3,
        societyName);

    return result;

  }


  @override
  Future<DataResponse> fireDrillSMS(List<FlatMemberDetails> flats, String sendTo, String smsType,
      String date2, String startTime2, String startMinute2,
      String startTimeType2, String societyName) async {

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
        date2, startTime2,  startMinute2,
         startTimeType2,  societyName);

    return result;

  }

  Future<DataResponse> serviceDownSMS(List<FlatMemberDetails> flats, String sendTo,
      String smsType, String reason, String reason1, String date1, String startTime1,
      String startMinute1, String startTimeType1, String endTime, String endMinute,
      String endTimeType, String societyName) async {

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
        reason,  reason1,  date1,  startTime1,
         startMinute1,  startTimeType1,  endTime,  endMinute,
         endTimeType,  societyName);

    return result;


  }

  Future<DataResponse> powerOutageSMS(List<FlatMemberDetails> flats, String sendTo,
      String smsType, String date, String startTime, String startMinute, String startTimeType,
      String time, String minute, String timeType, String societyName) async {

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
        date,  startTime,  startMinute,  startTimeType,
         time,  minute,  timeType,  societyName);

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
