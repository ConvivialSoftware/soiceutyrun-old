import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/Models/approve_gatepass_request.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

import 'GlobalVariables.dart';

class GatePassDialog extends StatefulWidget {
  final Map<String, dynamic> message;

  const GatePassDialog({Key key, this.message}) : super(key: key);

  @override
  _GatePassDialogState createState() => _GatePassDialogState();
}

class _GatePassDialogState extends State<GatePassDialog> {
  ProgressDialog _progressDialog;
  static const double padding = 16.0;
  static const double ovalRadius = 66.0;
  String _from;
  String _block;
  String _visitorName;
  String _noOfVisitors;
  String _visitorType;
  String _visitorContact;
  String _societyId;
  String _vid;
  String _uid;
  String _inBy;
  String _reason;

  @override
  void initState() {
    super.initState();
    _handleMessage();
    _getSocietyData();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildDialogCard(),
        _buildTopAvatarWidget(),
        _buildDialogCloseWidget(),
      ],
    );
  }

  Widget _buildDialogCard() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
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
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 60,
          ),
          Text(
            "from: $_from",
            style: TextStyle(
                color: GlobalVariables.green,
                fontSize: 18,
                fontWeight: FontWeight.w200),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "$_block",
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Guest is waiting',
            style: TextStyle(
                color: GlobalVariables.green,
                fontSize: 18,
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
    );
  }

  Widget _buildTopAvatarWidget() {
    return Positioned(
      top: padding,
      left: padding,
      right: padding,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.width * 0.3,
        decoration:
            BoxDecoration(color: GlobalVariables.white, shape: BoxShape.circle),
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: ClipOval(child: Container()),
        ),
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
        CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(GlobalVariables.userProfileIconPath),
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
            onPressed: () {},
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
        _getApproveButton(),
      ],
    );
  }

  Widget _getDenyButton() {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {},
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

  Widget _getApproveButton() {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            _approveGatePass();
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
    if (widget.message.containsKey('data')) {
      final dynamic data = widget.message['data'];
      _from = data['FROM_VISITOR'];
      _vid = data['VID'];
      _uid = data['USER_ID'];
      _block = data['REASON'];
      _visitorName = data['VISITOR_NAME'];
      _visitorType = data['TYPE'];
      _visitorContact = data['CONTACT'];
      _noOfVisitors = "5";
      _inBy = data['IN_BY'];
      _reason = data['REASON'];
    }

    if (widget.message.containsKey('notification')) {
      final dynamic notification = widget.message['notification'];
    }
  }

  void _getSocietyData() async {
    _societyId = await GlobalFunctions.getSocietyId();
  }

  void _approveGatePass() {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    ApproveGatePassRequest request = new ApproveGatePassRequest(
        _vid,
        _uid,
        _reason,
        _noOfVisitors,
        _from,
        VisitorStatus.APPROVED,
        _inBy,
        _societyId);
    _progressDialog.show();
    restClient.postApproveGatePass(request).then((value) {
      GlobalFunctions.showToast(value.message);
      _progressDialog.hide();
      if (value.status) {
        //todo hide dialog
      }
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            _progressDialog.hide();
          }
          break;
        default:
      }
    });
  }
}
