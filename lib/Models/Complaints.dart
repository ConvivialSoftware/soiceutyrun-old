import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/Models/ComplaintCategory.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

class HelpDeskResponse extends ChangeNotifier{

  List<Complaints> complaintList = <Complaints>[];
  List<Complaints> openComplaintList = <Complaints>[];
  List<Complaints> closeComplaintList = <Complaints>[];
  List<ComplaintCategory> complaintCategoryList = <ComplaintCategory>[];
  bool isLoading = true;
  String? errMsg;


  Future<dynamic> getUnitComplaintData(bool isAssignComplaint) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();
   await restClient.getComplaintsData(societyId, block, flat,userId,isAssignComplaint).then((value) {
      if (value.status!) {
        List<dynamic> _list = value.data!;
        print('complaint list length : ' + _list.length.toString());

        complaintList = <Complaints>[];
        openComplaintList = <Complaints>[];
        closeComplaintList = <Complaints>[];
        complaintList = List<Complaints>.from(_list.map((i)=>Complaints.fromJson(i)));

        // print("Complaint List : " + _complaintList.toString());
        for (int i = 0; i < complaintList.length; i++) {
          print('status : '+complaintList[i].toString());
          if (complaintList[i].STATUS!.toLowerCase() == 'completed' ||
              complaintList[i].STATUS!.toLowerCase() == 'close') {
            closeComplaintList.add(complaintList[i]);
          }else{
            openComplaintList.add(complaintList[i]);
          }
        }

        print('complaint openlist length : ' + openComplaintList.length.toString());
        print('complaint closelist length : ' + closeComplaintList.length.toString());
      }
      isLoading=false;
      notifyListeners();
    });

    return complaintList;
  }

  Future<dynamic> getComplaintCategoryData() async{

    if(complaintCategoryList.length==0) {
      isLoading = true;
      notifyListeners();
    }
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
   await restClient.getComplaintsCategoryData(societyId).then((value) {
      if (value.status!) {
        List<dynamic> _list = value.data!;
        //  print("category list : "+_list.toString());
        complaintCategoryList = List<ComplaintCategory>.from(_list.map((i)=>ComplaintCategory.fromJson(i)));

      }
      isLoading=false;
      notifyListeners();
    });
    return complaintCategoryList;
  }

}


@JsonSerializable()
class Complaints {
  String? TICKET_NO;
  String? SUBJECT;
  String? CATEGORY;
  String? COMPLAINT_AREA;
  String? NATURE;
  String? TYPE;
  String? BLOCK;
  String? FLAT;
  String? DESCRIPTION;
  String? ATTACHMENT;
  String? DATE;
  String? COMMENT_COUNT;
  String? STATUS;
  String? VENDOR;
  String? EDIT_DATE;
  String? PRIORITY;
  String? ATTACHMENT_NAME;
  String? NAME;
  String? ESCALATION_LEVEL;

  Complaints(
      {this.TICKET_NO,
      this.SUBJECT,
      this.CATEGORY,
      this.COMPLAINT_AREA,
      this.NATURE,
      this.TYPE,
      this.BLOCK,
      this.FLAT,
      this.DESCRIPTION,
      this.ATTACHMENT,
      this.DATE,
      this.COMMENT_COUNT,
      this.STATUS,
      this.VENDOR,
      this.EDIT_DATE,
      this.PRIORITY,
      this.ATTACHMENT_NAME,
      this.NAME,
      this.ESCALATION_LEVEL});

  factory Complaints.fromJson(Map<String, dynamic> json) {
    //  print('complaint ststus : '+json['STATUS']);

    return Complaints(
        TICKET_NO: json['TICKET_NO'],
        SUBJECT: json['SUBJECT'],
        CATEGORY: json['CATEGORY'],
        COMPLAINT_AREA: json['COMPLAINT_AREA'],
        NATURE: json['NATURE'],
        TYPE: json['TYPE'],
        BLOCK: json['BLOCK']??'',
        FLAT: json['FLAT']??'',
        DESCRIPTION: json['DESCRIPTION'],
        ATTACHMENT: json['ATTACHMENT'],
        DATE: json['DATE'],
        COMMENT_COUNT: json['COMMENT_COUNT'],
        STATUS: json['STATUS'],
        VENDOR: json['VENDOR'],
        EDIT_DATE: json['EDIT_DATE'],
        PRIORITY: json['PRIORITY'],
        ATTACHMENT_NAME: json['ATTACHMENT_NAME'],
        NAME: json['NAME'],
        ESCALATION_LEVEL: json['ESCALATION_LEVEL']);
  }
}
