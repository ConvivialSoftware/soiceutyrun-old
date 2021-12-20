import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/Activities/MyComplex.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/Models/Announcement.dart';
import 'package:societyrun/Models/CommitteeDirectory.dart';
import 'package:societyrun/Models/Documents.dart';
import 'package:societyrun/Models/EmergencyDirectory.dart';
import 'package:societyrun/Models/NeighboursDirectory.dart';
import 'package:societyrun/Models/Poll.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

class MyComplexResponse extends ChangeNotifier{

  List<Announcement> announcementList = <Announcement>[];
  List<Announcement> meetingList = <Announcement>[];
  List<Announcement> eventList = <Announcement>[];
  List<Poll> pollList = <Poll>[];
  List<Documents> documentList = <Documents>[];

  List<DirectoryType> directoryList = <DirectoryType>[];

  List<NeighboursDirectory> _neighbourList = <NeighboursDirectory>[];
  List<CommitteeDirectory> _committeeList = <CommitteeDirectory>[];
  List<EmergencyDirectory> _emergencyList = <EmergencyDirectory>[];


  List<NeighboursDirectory> neighbourList = <NeighboursDirectory>[];
  List<CommitteeDirectory> committeeList = <CommitteeDirectory>[];
  List<EmergencyDirectory> emergencyList = <EmergencyDirectory>[];

  bool isLoading = true;
  String? errMsg;

  Future<dynamic> getAnnouncementData(String type) async{

    if(type=='Announcement') {
      if(announcementList.length==0){
        isLoading=true;
        notifyListeners();
      }
    }
    if(type=='Meeting') {
      if(meetingList.length==0){
        isLoading=true;
        notifyListeners();
      }
    }
    if(type=='Event') {
      if(eventList.length==0){
        isLoading=true;
        notifyListeners();
      }
    }

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    await restClient.getAnnouncementData(societyId, type, userId).then((value) {
      if (value.status!) {
        List<dynamic> _list = value.data!;
        if(type=='Announcement') {
          announcementList =
          List<Announcement>.from(_list.map((i) => Announcement.fromJson(i)));
          print("_announcementList length : " +
              announcementList.length.toString());
        }
        if(type=='Meeting') {
          meetingList =
          List<Announcement>.from(_list.map((i) => Announcement.fromJson(i)));
          print("meetingList length : " +
              meetingList.length.toString());
        }
        if(type=='Event') {
          eventList =
          List<Announcement>.from(_list.map((i) => Announcement.fromJson(i)));
          print("eventList length : " +
              eventList.length.toString());
        }

        isLoading=false;
        notifyListeners();
      }

    });
    return announcementList;
  }

  Future<dynamic> getAnnouncementPollData(String type) async {

    if(pollList.length==0){
      isLoading=true;
      notifyListeners();
    }

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();
    await restClient.getAnnouncementPollData(societyId, type, block, flat, userId)
        .then((value) {

      if (value.status!) {
        List<dynamic> _list = value.data!;
        pollList = List<Poll>.from(_list.map((i) => Poll.fromJson(i)));

        print("announcementPoll : " + _list.length.toString());
        isLoading=false;
        notifyListeners();
      }

    });

    return pollList;
  }

  void getDocumentData() async {

    if(documentList.length==0){
      isLoading=true;
      notifyListeners();
    }

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    await  restClient.getDocumentData(societyId, userId).then((value) {

      if (value.status!) {
        List<dynamic> _list = value.data!;
        documentList = List<Documents>.from(_list.map((i) => Documents.fromJson(i)));
        isLoading=false;
        notifyListeners();
      }

    });
  }

  Future<void> getAllMemberDirectoryData() async {

    if(directoryList.length==0){
      isLoading=true;
      notifyListeners();
    }

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();

    await restClient.getAllMemberDirectoryData(societyId).then((value) {

      if (value.status!) {
        List<dynamic> neighbourList = value.neighbour!;
        List<dynamic> committeeList = value.committee!;
        List<dynamic> emergencyList = value.emergency!;

        _neighbourList = List<NeighboursDirectory>.from(
            neighbourList.map((i) => NeighboursDirectory.fromJson(i)));

        _committeeList = List<CommitteeDirectory>.from(
            committeeList.map((i) => CommitteeDirectory.fromJson(i)));

        _emergencyList = List<EmergencyDirectory>.from(
            emergencyList.map((i) => EmergencyDirectory.fromJson(i)));
        getDirectoryListData();
        isLoading=false;
        notifyListeners();
      }
      isLoading=false;
      notifyListeners();
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
  }

  Future<void> getNeighboursDirectoryData() async {
    isLoading=true;
    notifyListeners();
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    await restClient.getNeighboursDirectoryData(societyId).then((value) {

      if (value.status!) {
        List<dynamic> _list = value.data!;
        neighbourList = List<NeighboursDirectory>.from(_list.map((i) => NeighboursDirectory.fromJson(i)));
        isLoading=false;
        notifyListeners();
      }
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
    //return neighbourList;
  }

  Future<void> getCommitteeDirectoryData() async {
    isLoading=true;
    notifyListeners();
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();

    await restClient.getCommitteeDirectoryData(societyId).then((value) {

      if (value.status!) {
        List<dynamic> _list = value.data!;
        committeeList = List<CommitteeDirectory>.from(_list.map((i) => CommitteeDirectory.fromJson(i)));
        isLoading=false;
        notifyListeners();
      }
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
    //return committeeList;
  }

  Future<void> getEmergencyDirectoryData() async {
    isLoading=true;
    notifyListeners();
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();

    await restClient.getEmergencyDirectoryData(societyId).then((value) {

      if (value.status!) {
        List<dynamic> _list = value.data!;
        emergencyList = List<EmergencyDirectory>.from(_list.map((i) => EmergencyDirectory.fromJson(i)));
        isLoading=false;
        notifyListeners();
      }
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });

   // return emergencyList;
  }


  getDirectoryListData() {
    directoryList = [
      DirectoryType(
          directoryType: "Neighbours", directoryTypeWiseList: _neighbourList),
      DirectoryType(
          directoryType: "Committee", directoryTypeWiseList: _committeeList),
      DirectoryType(
          directoryType: "Emergency", directoryTypeWiseList: _emergencyList),
    ];
  }

}

class DirectoryType {
  String? directoryType;
  List<dynamic>? directoryTypeWiseList;

  DirectoryType({this.directoryType, this.directoryTypeWiseList});
}

class DirectoryTypeWiseData {
  String? name, field;
  bool? isCall, isMail, isSearch, isFilter;

  DirectoryTypeWiseData(
      {this.name,
        this.field,
        this.isCall,
        this.isMail,
        this.isSearch,
        this.isFilter});
}