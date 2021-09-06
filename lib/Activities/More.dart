import 'dart:io';

import 'package:dio/dio.dart';
//import 'package:dynamic_widget/dynamic_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'base_stateful.dart';

class BaseMore extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MoreState();
  }
}

class MoreState extends BaseStatefulState<BaseMore> {

  var response="";

  @override
  void initState() {
    super.initState();
   // getJson();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
      builder: (context) =>
          Scaffold(
            appBar: AppBar(
              backgroundColor: GlobalVariables.primaryColor,
              centerTitle: true,
              elevation: 0,
              leading: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: AppIcon(
                  Icons.arrow_back,
                  iconColor: GlobalVariables.white,
                ),
              ),
              title: text(
                AppLocalizations.of(context).translate('more'),
                textColor: GlobalVariables.white,fontSize: GlobalVariables.textSizeMedium
              ),
            ),
            body: getBaseLayout(),
          ),
    );
  }

  getBaseLayout() {
    return Container(
    //  child: response.length>0 ? DynamicWidgetBuilder.build(response, context, DefaultClickListener()):Container(),
    );
  }

  Future<void> getJson() async {
    response = await rootBundle.loadString('i18n/profile.json');
    print('Response : '+response.toString());
    setState(() {
    });
  }

}

/*
class DefaultClickListener implements ClickListener{
  @override
  void onClicked(String event) {
    print("Receive click event: " + event);
  }

}
*/
