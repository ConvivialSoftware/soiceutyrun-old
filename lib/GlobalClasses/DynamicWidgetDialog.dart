import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/Models/DBNotificatioPayload.dart';
import 'package:societyrun/Models/gatepass_payload.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'GlobalVariables.dart';

class DynamicWidgetDialog extends StatefulWidget {
  final DBNotificationPayload message;

  const DynamicWidgetDialog({Key key, this.message}) : super(key: key);

  @override
  _DynamicWidgetDialogState createState() => _DynamicWidgetDialogState();
}

class _DynamicWidgetDialogState extends State<DynamicWidgetDialog> {
  static const double padding = 5.0;
  static const double ovalRadius = 70.0;
  String _popupTitle="";
  String _body="";

  @override
  void initState() {
    super.initState();
    _handleMessage();

  }

  @override
  Widget build(BuildContext context) {
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
        //_buildTopAvatarWidget(),
        //_buildDialogCloseWidget(),
      ],
    );
  }

  Widget _buildDialogCard() {
    return Stack(
      children: <Widget>[

        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 1.5,
              //padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 15),
             // margin: EdgeInsets.only(top: 70.0),
              decoration: BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.circular(20),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: AppIconButton(
                      Icons.close,
                      iconColor: GlobalVariables.green,
                      onPressed: (){
                        Navigator.pop(context);
                      },),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    _popupTitle,
                    style: TextStyle(
                      color: GlobalVariables.green,
                      fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 10),
                    child: Text(
                      _body,
                      style: TextStyle(
                          color: GlobalVariables.black,
                          fontSize: 16,),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.5,
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              decoration: BoxDecoration(
                color: GlobalVariables.green,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32.0),
                    bottomRight: Radius.circular(32.0)),
              ),
              child: Container(
                child: IconButton(
                    icon: Icon(
                      Icons.share,
                      color: GlobalVariables.white,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      GlobalFunctions.shareData(
                          'PassCode', _popupTitle+'\n'+_body);
                    }),
              ),
            ),
          ],
        ),
     /*   Container(
          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/1.7,),
          //alignment: Alignment.topRight,
          child: Container(
            //alignment: Alignment.topRight,
            *//*transform: Matrix4.translationValues(
                      MediaQuery.of(context).size.width * 0.3,
                      -MediaQuery.of(context).size.width * 0.33,
                      0.0),*//*
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
              )
          ),
        ),*/
        /*Align(
          alignment: Alignment.center,
          child: Container(
            transform: Matrix4.translationValues(0.0, -120.0, 0.0),
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
                color: GlobalVariables.white, shape: BoxShape.circle),
            child: CircleAvatar(
              child: SvgPicture.asset(
                GlobalVariables.appIconPath,
                width: 20,
                height: 20,
                color: GlobalVariables.white,
              ),
            ),
          ),
        ),*/
        //_buildDialogCloseWidget(),
      ],
    );
  }

  Widget _buildTopAvatarWidget() {

    var iconPath =GlobalVariables.splashIconPath;

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

  void _handleMessage() {
      _popupTitle = widget.message.title;
      _body = widget.message.body;
  }

}
