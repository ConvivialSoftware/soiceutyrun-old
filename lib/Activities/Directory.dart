import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/MyComplex.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/CommitteeDirectory.dart';
import 'package:societyrun/Models/EmergencyDirectory.dart';
import 'package:societyrun/Models/NeighboursDirectory.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseDirectory extends StatefulWidget {
 // String pageName;
 // BaseDirectory(this.pageName);

  DirectoryType directory ;
  BaseDirectory(this.directory);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DirectoryState(directory);
  }
}

class DirectoryState extends State<BaseDirectory> {


  var societyId, flat, block;

  ProgressDialog _progressDialog;
  DirectoryType directory ;
  DirectoryState(this.directory);

  List<NeighboursDirectory> _neighbourList = List<NeighboursDirectory>();
  List<CommitteeDirectory> _committeeList = List<CommitteeDirectory>();
  List<EmergencyDirectory> _emergencyList = List<EmergencyDirectory>();

  bool isNeighbours=false;
  bool isCommittee=false;
  bool isEmergency=false;

  @override
  void initState() {
    super.initState();

    if(directory.directoryType=='Neighbours'){
      isNeighbours=true;
      isCommittee=false;
      isEmergency=false;
      _committeeList.clear();
      _emergencyList.clear();
      getNeighboursDirectoryData();
    }

    if(directory.directoryType=='Committee'){
      isCommittee=true;
      isNeighbours=false;
      isEmergency=false;
      _neighbourList.clear();
      _emergencyList.clear();
      getCommitteeDirectoryData();

    }
    if(directory.directoryType=='Emergency'){
      isCommittee=false;
      isNeighbours=false;
      isEmergency=true;
      _neighbourList.clear();
      _committeeList.clear();
      getEmergencyDirectoryData();
    }

  }

  @override
  Widget build(BuildContext context) {
      _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back,
              color: GlobalVariables.white,
            ),
          ),
          title: Text(
            directory.directoryType+' '+AppLocalizations.of(context).translate('directory'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body:  getDirectoryLayout(),
      ),
    );
  }

  getDirectoryLayout() {
    print('getDirectoryLayout Tab Call');
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 180.0),
                getDirectoryListDataLayout()
              ],
            ),
          ),
        ],
      ),
    );
  }

  getDirectoryListDataLayout() {

    int length=0;

    if(isNeighbours)
      length = _neighbourList.length;

    if(isCommittee)
      length = _committeeList.length;

    if(isEmergency)
      length = _emergencyList.length;


    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 20, 10, 0),
      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
            itemCount: length,
            itemBuilder: (context, position) {
              return getDirectoryDescListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getDirectoryDescListItemLayout(int position) {

    bool phone=false,email=false;
    String name='',field='',address='',permission='',flat='',callNumber='',emailId='';
    if(directory.directoryType=='Committee'){
      name =  _committeeList[position].NAME==null ? '' : _committeeList[position].NAME;

      field =  _committeeList[position].POST==null ? '' : _committeeList[position].POST;

      flat =   _committeeList[position].FLAT==null ||  _committeeList[position].BLOCK==null ? '' : _committeeList[position].BLOCK+' '+_committeeList[position].FLAT;

      _committeeList[position].EMAIL.length!= 0 ? email=true : email=false;

      _committeeList[position].PHONE.length != 0 ? phone=true : phone=false;

      if(phone)
        callNumber = _committeeList[position].PHONE;

      if(email)
        emailId = _committeeList[position].EMAIL;
    }

    if(directory.directoryType=='Neighbours'){
      name =  _neighbourList[position].NAME==null ? '' : _neighbourList[position].NAME;

      field =  _neighbourList[position].TYPE==null ? '' : _neighbourList[position].TYPE;

      flat =   _neighbourList[position].FLAT==null ||  _neighbourList[position].BLOCK==null ? '' : _neighbourList[position].BLOCK+' '+_neighbourList[position].FLAT;

      permission = _neighbourList[position].PERMISSIONS;
      if(_neighbourList[position].Phone!=null) {
        if (permission.contains('memberPhone')) {
          phone = true;
        } else {
          phone = false;
        }

        if (phone)
          callNumber = _neighbourList[position].Phone;
      }

    }

    if(directory.directoryType=='Emergency'){
      name =  _emergencyList[position].Name ==null ? '' : _emergencyList[position].Name;

      address =  _emergencyList[position].Address ==null ? '' : _emergencyList[position].Address;

      field =  _emergencyList[position].Name ==null ? '' : _emergencyList[position].Name;

      _emergencyList[position].Contact_No.length != 0 ? phone=true : phone=false;

      if (phone)
        callNumber = _emergencyList[position].Contact_No;
    }

    return directory.directoryType!='Emergency' ? Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: GlobalVariables.white),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
             !isEmergency ?  Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 5, 5, 0),
                  child: Text(flat,style: TextStyle(color: GlobalVariables.black,fontSize: 16,fontWeight: FontWeight.bold),),
                ),
              ):Container(),
                phone
                    ? Flexible(
                      child: InkWell(
                        onTap: () {
                          print('callNumber : '+callNumber.toString());
                          launch("tel://" + callNumber);
                        },
                        child: Container(
                  //color: GlobalVariables.lightGray,
                            // color: GlobalVariables.black,
                            // height: 10,
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                            child: Icon(
                              Icons.call,
                              color: GlobalVariables.mediumGreen,
                              size: 24,
                            ),
                          ),
                      ),
                    )
                    : Container(),
            ],
          ),
          !isEmergency ? Container(
            height: 1,
            color: GlobalVariables.lightGray,
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Divider(
              height: 1,
            ),
          ): Container(),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                  child: Text(name,style: TextStyle(color: GlobalVariables.black,fontSize: 18,fontWeight: FontWeight.bold),),
                ),
              ),
              email
                  ? Flexible(
                child: InkWell(
                  onTap: (){
                    Uri _emailUri = Uri(
                      scheme: 'mailto',
                      path: emailId,
                      queryParameters: {
                        'subject':''
                      }

                    );
                    launch(_emailUri.toString());
                  },
                  child: Container(
                    // color: GlobalVariables.lightGray,
                    // color: GlobalVariables.black,
                    // height: 10,
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                    child: Icon(
                      Icons.email,
                      color: GlobalVariables.mediumGreen,
                      size: 24,
                    ),
                  ),
                ),
              )
                  : Container(
                // width: 24,height: 24,
              ),
            ],
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(10, 5, 5, 5),
            child: Text(field,style: TextStyle(color: GlobalVariables.grey,fontSize: 16,),),
          ),
        ],
      ),
    ) : Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: GlobalVariables.white),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                  child: Text(name,style: TextStyle(color: GlobalVariables.black,fontSize: 18,fontWeight: FontWeight.bold),),
                ),
              ),
              phone
                  ? Flexible(
                child: InkWell(
                  onTap: () {
                    print('callNumber : '+callNumber.toString());
                    launch("tel://" + callNumber);
                  },
                  child: Container(
                    //color: GlobalVariables.lightGray,
                    // color: GlobalVariables.black,
                    // height: 10,
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                    child: Icon(
                      Icons.call,
                      color: GlobalVariables.mediumGreen,
                      size: 24,
                    ),
                  ),
                ),
              )
                  : Container(),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                  child: Text(address,style: TextStyle(color: GlobalVariables.black,fontSize: 18,fontWeight: FontWeight.normal),),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(10, 5, 5, 5),
            child: Text(field,style: TextStyle(color: GlobalVariables.grey,fontSize: 16,),),
          ),
        ],
      ),
    );
  }

  Future<void> getNeighboursDirectoryData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getNeighboursDirectoryData(societyId).then((value) {
      _progressDialog.hide();
      if (value.status) {
        List<dynamic> _list = value.data;
        _neighbourList = List<NeighboursDirectory>.from(_list.map((i) => NeighboursDirectory.fromJson(i)));
        setState(() {});
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
  }

Future<void> getCommitteeDirectoryData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getCommitteeDirectoryData(societyId).then((value) {
      _progressDialog.hide();
      if (value.status) {
        List<dynamic> _list = value.data;
        _committeeList = List<CommitteeDirectory>.from(_list.map((i) => CommitteeDirectory.fromJson(i)));
        setState(() {});
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
  }

Future<void> getEmergencyDirectoryData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getEmergencyDirectoryData(societyId).then((value) {
      _progressDialog.hide();
      if (value.status) {
        List<dynamic> _list = value.data;
        _emergencyList = List<EmergencyDirectory>.from(_list.map((i) => EmergencyDirectory.fromJson(i)));
        setState(() {});
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
  }

}
