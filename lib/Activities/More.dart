
//import 'package:dynamic_widget/dynamic_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';

class BaseMore extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MoreState();
  }
}

class MoreState extends State<BaseMore> {

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
            appBar: CustomAppBar(
              title: AppLocalizations.of(context).translate('more'),
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
