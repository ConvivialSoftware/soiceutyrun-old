import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/Models/DBNotificatioPayload.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'GlobalVariables.dart';

class DynamicWidgetDialog extends StatefulWidget {
  final DBNotificationPayload? message;

  const DynamicWidgetDialog({Key? key, this.message}) : super(key: key);

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
        return Future.value(true);
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
              width: MediaQuery.of(context).size.width / 1.2,
             // margin: EdgeInsets.only(top: 70.0),
              decoration: BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.circular(20),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0)),
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
                    child: Container(
                      margin: EdgeInsets.only(top: 5,right: 5),
                      child: AppIconButton(
                        Icons.close,
                        iconColor: GlobalVariables.primaryColor,
                        iconSize: 24.0,
                        onPressed: (){
                          Navigator.pop(context);
                        },),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(
                            _popupTitle,
                            textColor : GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: text(
                            _body,
                            textColor: GlobalVariables.black,
                            fontSize: GlobalVariables.textSizeSMedium,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.2,
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              decoration: BoxDecoration(
                color: GlobalVariables.primaryColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0)),
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
              color: GlobalVariables.primaryColor, shape: BoxShape.circle),
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
      _popupTitle = widget.message!.title!;
      _body = widget.message!.body!;
  }

}
