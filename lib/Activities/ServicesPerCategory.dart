import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/DescriptionOfHomeService.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ServicesResponse.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseServicesPerCategory extends StatefulWidget {

  String category;
  BaseServicesPerCategory(this.category);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ServicesPerCategoryState();
  }
}

class ServicesPerCategoryState extends BaseStatefulState<BaseServicesPerCategory> {

  @override
  void initState() {
    super.initState();
    Provider.of<ServicesResponse>(context,listen: false).getServicePerCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider<ServicesResponse>.value(
        value: Provider.of<ServicesResponse>(context),
        child: Consumer<ServicesResponse>(
          builder: (context, value, child) {
            print('Consumer Value : ' + value.servicesList.toString());
            return Builder(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  backgroundColor: GlobalVariables.green,
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
                  title: Text(
                    widget.category + ' Services',
                    style: TextStyle(color: GlobalVariables.white),
                  ),
                ),
                body: value.isLoading ? GlobalFunctions.loadingWidget(context) : getBaseLayout(value),
              ),
            );
          },
        ));
  }

  getBaseLayout(ServicesResponse value) {
    return value.servicesList.length >0 ? Container(
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
                    context, 200.0),
                getHomeCareListDataLayout(value),
              ],
            ),
          ),
        ],
      ),
    ):GlobalFunctions.noDataFoundLayout(context, "No Services Found for "+ widget.category);
  }

  getHomeCareListDataLayout(ServicesResponse value) {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: Builder(
          builder: (context) => ListView.builder(
             scrollDirection: Axis.vertical,
            itemCount: value.servicesList.length,
            itemBuilder: (context, position) {
              return getHomeCareListItemLayout(position,value);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getHomeCareListItemLayout(int position, ServicesResponse value) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) =>
                BaseDescriptionOfHomeService(value.servicesList[position],)));
      },
      child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: boxDecoration(radius: 10),
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 8),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  text(value.servicesList[position].Name,
                                      fontSize: GlobalVariables.textSizeSMedium,
                                      maxLine: 2,
                                      textColor: GlobalVariables.green,fontWeight: FontWeight.w500),
                                  SizedBox(height: 4),
                                  text(value.servicesList[position].Title,
                                      textColor:
                                      GlobalVariables.grey,
                                      fontSize:
                                      GlobalVariables.textSizeSmall,
                                      maxLine: 2),
                                ],
                              ),
                            ),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.start,
                      ),
                      Divider(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: text('Rs. '+value.servicesList[position].Price,
                                textColor: GlobalVariables.black,
                                fontSize: GlobalVariables.textSizeSmall,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child:  Row(
                                    children: <Widget>[
                                      Container(
                                          child: AppIcon(
                                            Icons.star,
                                            iconColor:
                                            GlobalVariables.orangeYellow,
                                            iconSize: 15,
                                          )),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(
                                            5, 0, 0, 0),
                                        child: Text(
                                          value.servicesList[position]
                                              .Rating,
                                          style: TextStyle(
                                            color: GlobalVariables
                                                .grey,
                                            fontSize: GlobalVariables.textSizeSmall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //SizedBox(width: 10),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  width: 4,
                  height: 35,
                  margin: EdgeInsets.only(top: 16),
                  color: position % 2 == 0 ? GlobalVariables.lightPurple : GlobalVariables.orangeYellow,
                )
              ],
            ),
          )),
    );
  }

}