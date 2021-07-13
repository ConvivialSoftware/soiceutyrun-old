import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/Models/gatepass_payload.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:url_launcher/url_launcher.dart';

import 'GlobalVariables.dart';

class GatePassDialog extends StatefulWidget {
  final GatePassPayload message;

  const GatePassDialog({Key key, this.message}) : super(key: key);

  @override
  _GatePassDialogState createState() => _GatePassDialogState();
}

class _GatePassDialogState extends State<GatePassDialog> {
  ProgressDialog _progressDialog;
  static const double padding = 5.0;
  static const double ovalRadius = 70.0;
  String _from="";
  String _block="";
  String _visitorName="";
  String _noOfVisitors="";
  String _visitorType;
  String _visitorContact="";
  String _societyId="";
  String _vid="";
  String _uid="";
  String _inBy="";
  String _reason="";
  String _inDate="";
  String _inTime="";
  String _visitorImage="";
  String _popupTitle="";
  String _id="";
  String _gcm_id="";

  @override
  void initState() {
    super.initState();
    _handleMessage();
    _getSocietyData();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return WillPopScope(
      onWillPop: (){
        return;
      },
      child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildDialogCard(),
        _buildTopAvatarWidget(),
        //_buildDialogCloseWidget(),
      ],
    );
  }

  Widget _buildDialogCard() {
    return Container(
      margin: EdgeInsets.only(top: ovalRadius),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Wrap(
        children: <Widget>[
          Column(
            children: <Widget>[
              SizedBox(
                height: 80,
              ),
              Text(
                "From: $_from",
                style: TextStyle(
                    color: GlobalVariables.green,
                    fontSize: 20,
                    fontWeight: FontWeight.w300),
              ),
             /* SizedBox(
                height: 20,
              ),
              Text(
                "$_block",
                style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),*/
              SizedBox(
                height: 20,
              ),
              Text(
               _popupTitle,
                style: TextStyle(
                    color: GlobalVariables.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              _buildCallWidget(),
              SizedBox(
                height: 20,
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                  child: Divider(
                    thickness: 2,
                  )),
              SizedBox(
                height: 10,
              ),
              _getButtonWidget(),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopAvatarWidget() {

    var iconPath =GlobalVariables.visitorIconPath;
   // _visitorType==GlobalVariables.GatePass_Taxi
    if(_visitorType==GlobalVariables.GatePass_Taxi){
      iconPath = GlobalVariables.taxiIconPath;
    }else if(_visitorType==GlobalVariables.GatePass_Delivery){
      iconPath = GlobalVariables.deliveryManIconPath;
    }

    return Positioned(
      top: padding,
      left: padding,
      right: padding,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.width * 0.3,
        decoration:
            BoxDecoration(color: GlobalVariables.white, shape: BoxShape.circle),
        child: CircleAvatar(
          child: SvgPicture.asset(
            iconPath,width: 70,height: 70,color: GlobalVariables.white,),),
      ),
    );
  }

  Widget _buildDialogCloseWidget() {
    return Positioned(
      top: 45,
      right: 0,
      child: Container(
          width: 42.0,
          height: 42.0,
          decoration: BoxDecoration(
              color: GlobalVariables.green, shape: BoxShape.circle),
          child: InkWell(
            child: Icon(
              Icons.close,
              color: GlobalVariables.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          )),
    );
  }

  Widget _buildCallWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _visitorImage!=null ? CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white10,
          backgroundImage: NetworkImage(_visitorImage),
        ):CircleAvatar(
          radius: 24,
          backgroundColor: GlobalVariables.lightGreen,
        ),
        SizedBox(
          width: 20.0,
        ),
        Text(
          "$_visitorName",
          style: TextStyle(
              color: GlobalVariables.green,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 10.0,
        ),
        Opacity(
          opacity: 0.3,
          child: IconButton(
            icon: Icon(Icons.call),
            iconSize: 24.0,
            color: GlobalVariables.green,
            onPressed: () {
              _launchCall();
            },
          ),
        ),
      ],
    );
  }

  Widget _getButtonWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _getDenyButton(),
        _getLeaveWaitButton(),
        _getApproveButton(),
      ],
    );
  }

  Widget _getDenyButton() {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            GlobalFunctions
                .checkInternetConnection()
                .then((internet) {
              if (internet) {
                _rejectGatePass();
              } else {
                GlobalFunctions.showToast(AppLocalizations.of(context)
                    .translate('pls_check_internet_connectivity'));
              }
            });
          },
          child: Container(
            width: 48.0,
            height: 48.0,
            decoration:
                BoxDecoration(color: Colors.grey[600], shape: BoxShape.circle),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'DENY',
          style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _getLeaveWaitButton() {
    return Visibility(
      visible: _visitorType==GlobalVariables.GatePass_Delivery || _visitorType==GlobalVariables.GatePass_Taxi ? true : false,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              GlobalFunctions
                  .checkInternetConnection()
                  .then((internet) {
                if (internet) {
                  _leaveWaitGatePass();
                } else {
                  GlobalFunctions.showToast(AppLocalizations.of(context)
                      .translate('pls_check_internet_connectivity'));
                }
              });
            },
            child: Container(
              width: 48.0,
              height: 48.0,
              decoration:
                  BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
              child: Icon(
                _visitorType==GlobalVariables.GatePass_Delivery ? Icons.location_city : Icons.pan_tool,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            _visitorType==GlobalVariables.GatePass_Delivery  ? GatePassStatus.LEAVE_AT_GATE :  GatePassStatus.WAIT_AT_GATE ,
            style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _getApproveButton() {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            GlobalFunctions
                .checkInternetConnection()
                .then((internet) {
              if (internet) {
               _approveGatePass();
              } else {
                GlobalFunctions.showToast(AppLocalizations.of(context)
                    .translate('pls_check_internet_connectivity'));
              }
            });
          },
          child: Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
                color: GlobalVariables.green, shape: BoxShape.circle),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'APPROVE',
          style: TextStyle(
              color: GlobalVariables.green,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _handleMessage() {
      _from =widget.message.fROMVISITOR;
      _vid = widget.message.vID;
      _uid = widget.message.uSERID;
      _block = widget.message.rEASON;
      _visitorName = widget.message.vISITORNAME;
      _visitorType = widget.message.vSITORTYPE;
      _visitorContact = widget.message.cONTACT;
      _noOfVisitors = widget.message.nOOFVISITORS;
      _inBy = widget.message.iNBY;
      _reason = widget.message.rEASON;
      _inDate = widget.message.iNDATE;
      _inTime = widget.message.iNTIME;
      _visitorImage = widget.message.iMAGE;
      _popupTitle = widget.message.title;
      _id = widget.message.iD;
      _gcm_id = widget.message.GCM_ID;
  }

  void _getSocietyData() async {
    _societyId = await GlobalFunctions.getSocietyId();
  }

  Future<void> _approveGatePass() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    //String gcmId = await GlobalFunctions.getFCMToken();
    _progressDialog.show();
    restClient
        .postApproveGatePass(_id, GatePassStatus.APPROVED, _gcm_id, _societyId)
        .then((value) {
      print('status : ' + value.status.toString());
      _progressDialog.hide();
      if (value.status) {
        GlobalFunctions.showToast(value.message);
        Navigator.pop(context);
      }
    }).catchError((Object obj) {
      _progressDialog.hide();
      print('res : ' + obj.toString());
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            Navigator.pop(context);
          }
          break;
        default:
      }
    });
  }


  Future<void> _rejectGatePass() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
   // String gcmId = await GlobalFunctions.getFCMToken();
    _progressDialog.show();
    restClient
        .postApproveGatePass(_id, GatePassStatus.REJECTED, _gcm_id, _societyId)
        .then((value) {
      print('status : ' + value.status.toString());
      _progressDialog.hide();
      if (value.status) {
        GlobalFunctions.showToast(value.message);
        Navigator.pop(context);
      }
    }).catchError((Object obj) {
      _progressDialog.hide();
      print('res : ' + obj.toString());
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            Navigator.pop(context);
          }
          break;
        default:
      }
    });
  }

  Future<void> _leaveWaitGatePass() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    // String gcmId = await GlobalFunctions.getFCMToken();
    _progressDialog.show();
    restClient
        .postApproveGatePass(_id, _visitorType==GlobalVariables.GatePass_Delivery  ? GatePassStatus.LEAVE_AT_GATE :  GatePassStatus.WAIT_AT_GATE , _gcm_id, _societyId)
        .then((value) {
      print('status : ' + value.status.toString());
      _progressDialog.hide();
      if (value.status) {
        GlobalFunctions.showToast(value.message);
        Navigator.pop(context);
      }
    }).catchError((Object obj) {
      _progressDialog.hide();
      print('res : ' + obj.toString());
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            Navigator.pop(context);
          }
          break;
        default:
      }
    });
  }


  void _launchCall(){
    launch("tel:$_visitorContact");
  }
}
