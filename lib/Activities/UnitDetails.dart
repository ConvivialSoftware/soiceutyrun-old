import 'package:flutter/material.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseUnitDetails extends StatefulWidget {
  @override
  _BaseUnitDetailsState createState() => _BaseUnitDetailsState();
}

class _BaseUnitDetailsState extends BaseStatefulState<BaseUnitDetails> {
  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: GlobalVariables.green,
            centerTitle: true,
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
              AppLocalizations.of(context).translate('user'),
              textColor: GlobalVariables.white,
            ),
          ),
          body: getBaseUnitLayout(),
        ));
  }

  getBaseUnitLayout() {

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
                    context, 150.0),
                getUnitListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );

  }

  getUnitListDataLayout() {

    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 20, 10, 0),
      child: Builder(
          builder: (context) => GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 10,
            itemBuilder: (context, position) {

              return InkWell(
                onTap: () {

                },
                child: Container(
                  alignment: Alignment.center,
                  //width: width / 4,
                  // height: width / 4,
                  margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: GlobalVariables.white,
                  ),

                ),
              );
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );

  }

}
