import 'package:flutter/material.dart';
import 'package:societyrun/Activities/DescriptionOfHomeService.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseServicesPerCategory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ServicesPerCategoryState();
  }
}

class ServicesPerCategoryState extends BaseStatefulState<BaseServicesPerCategory> {


  List<HomeCare> _homeCareList = List<HomeCare>();

  @override
  void initState() {
    super.initState();
    getHomeCareList();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
            child: Icon(
              Icons.arrow_back,
              color: GlobalVariables.white,
            ),
          ),
          title: Text(
            AppLocalizations.of(context).translate('home_services'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
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
                    context, 200.0),
                getHomeCareListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getHomeCareListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: Builder(
          builder: (context) => ListView.builder(
             scrollDirection: Axis.vertical,
            itemCount: _homeCareList.length,
            itemBuilder: (context, position) {
              return getHomeCareListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getHomeCareListItemLayout(int position) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) =>
                BaseDescriptionOfHomeService()));
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
                                  text(_homeCareList[position].title,
                                      fontSize: GlobalVariables.textSizeSMedium,
                                      maxLine: 2,
                                      textColor: GlobalVariables.green,fontWeight: FontWeight.w500),
                                  SizedBox(height: 4),
                                  text(_homeCareList[position].subDesc,
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
                            child: text(_homeCareList[position].startPrice,
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
                                          child: Icon(
                                            Icons.star,
                                            color:
                                            GlobalVariables.orangeYellow,
                                            size: 15,
                                          )),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(
                                            5, 0, 0, 0),
                                        child: Text(
                                          _homeCareList[position]
                                              .rateCount,
                                          style: TextStyle(
                                            color: GlobalVariables
                                                .grey,
                                            fontSize: 12,
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

  getHomeCareList(){

    _homeCareList = [

      HomeCare(title: "Siddhivinayak Traders",subDesc: "AC Repair and Maintainance",startPrice: "Price Starts from: Rs. 200",
      rateCount: "4.3",isCall: true,isMail: true),
      HomeCare(title: "Balaji Plumbers",subDesc: "Plumbing Service",startPrice: "Price Starts from: Rs. 200",
          rateCount: "4.5",isCall: true,isMail: false),
      HomeCare(title: "Rajesh Electronics",subDesc: "Electronics",startPrice: "Price Starts from: Rs. 250",
          rateCount: "3.6",isCall: true,isMail: false),
      HomeCare(title: "Star HardWare and Electronics",subDesc: "Hardware & Electronics",startPrice: "Price Starts from: Rs. 500",
          rateCount: "4.4",isCall: true,isMail: true),
      HomeCare(title: "Madhuram Packaging",subDesc: "Plastic Bags & Packaging",startPrice: "Price Starts from: Rs. 200",
          rateCount: "2.9",isCall: true,isMail: true),
      HomeCare(title: "Krishna Repairs",subDesc: "AC Repair and Maintainance",startPrice: "Price Starts from: Rs. 500",
          rateCount: "3.2",isCall: true,isMail: false),
      HomeCare(title: "Sudar Hardware",subDesc: "Hardware & Electronics",startPrice: "Price Starts from: Rs. 300",
          rateCount: "4.8",isCall: true,isMail: true),

    ];


  }
}

class HomeCare {
  String title, subDesc, startPrice, rateCount;
  bool isCall, isMail;

  HomeCare(
      {this.title,
      this.subDesc,
      this.startPrice,
      this.rateCount,
      this.isCall,
      this.isMail});
}
