import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/DescriptionOfHomeService.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ServicesResponse.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseOwnerServices extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OwnerServicesState();
  }
}

class OwnerServicesState extends BaseStatefulState<BaseOwnerServices> {


  var _myRate=0.0;

  @override
  void initState() {
    super.initState();
   // getHomeCareList();
    Provider.of<ServicesResponse>(context,listen: false).getOwnerServices();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider<ServicesResponse>.value(
        value: Provider.of<ServicesResponse>(context),
        child: Consumer<ServicesResponse>(
          builder: (context, value, child) {
            print('Consumer Value : ' + value.ownerServicesList.toString());
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
                    AppLocalizations.of(context).translate('my_services'),
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
                getHomeCareListDataLayout(value),
              ],

            ),
          ),
        ],
      ),
    );
  }

  getHomeCareListDataLayout(ServicesResponse value) {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: Builder(
          builder: (context) => ListView.builder(
             scrollDirection: Axis.vertical,
            itemCount: value.ownerServicesList.length,
            itemBuilder: (context, position) {
              return getHomeCareListItemLayout(position,value.ownerServicesList);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getHomeCareListItemLayout(int position, List<Services> servicesList) {
    return InkWell(
      onTap: (){
        /*Navigator.push(context, MaterialPageRoute(
            builder: (context) =>
                BaseDescriptionOfHomeService()));*/
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
                                  text(servicesList[position].Name,
                                      fontSize: GlobalVariables.textSizeSMedium,
                                      maxLine: 2,
                                      textColor: GlobalVariables.green,fontWeight: FontWeight.w500),
                                  SizedBox(height: 4),
                                  text(servicesList[position].Title==null?'':servicesList[position].Title,
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          /*Container(
                            child: text('Rs. '+servicesList[position].Price,
                                textColor: GlobalVariables.black,
                                fontSize: GlobalVariables.textSizeSmall,
                                fontWeight: FontWeight.bold),
                          ),*/
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
                                      InkWell(

                                        onTap: (){

                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  StatefulBuilder(builder:
                                                      (BuildContext context,
                                                      StateSetter setState) {
                                                    return Dialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                25.0)),
                                                        child: showMyRattingBar(setState,servicesList[position].Id));
                                                  }));

                                        },

                                        child: Container(
                                          margin: EdgeInsets.fromLTRB(
                                              5, 0, 0, 0),
                                          child: text(AppLocalizations.of(context).translate('add_ratting'),fontSize: GlobalVariables.textSizeSmall,fontWeight: FontWeight.bold,textColor: GlobalVariables.skyBlue),
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

  showMyRattingBar(StateSetter _setState, String serviceId) {
  //  print('after setstate : ' + myRate.toString());
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                child: RatingBar.builder(
                  initialRating: 0.0,
                  itemCount: 5,
                  allowHalfRating: true,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return Icon(
                          Icons.sentiment_very_dissatisfied,
                          color: Colors.red,
                        );
                      case 1:
                        return Icon(
                          Icons.sentiment_dissatisfied,
                          color: Colors.redAccent,
                        );
                      case 2:
                        return Icon(
                          Icons.sentiment_neutral,
                          color: Colors.amber,
                        );
                      case 3:
                        return Icon(
                          Icons.sentiment_satisfied,
                          color: Colors.lightGreen,
                        );
                      case 4:
                        return Icon(
                          Icons.sentiment_very_satisfied,
                          color: Colors.green,
                        );
                      default:
                        return Container();
                    }
                  },
                  onRatingUpdate: (rating) {
                    print(rating);
                    _myRate = rating;

                  },
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Text('0.0',
                  //myRate.toStringAsFixed(1).toString(),
                  style: TextStyle(
                      color: GlobalVariables.skyBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              if (_myRate > 0) {
                Navigator.of(context).pop();
                Provider.of<ServicesResponse>(context,listen: false).updateServiceRatting(serviceId,_myRate.toString()).then((value) {
                  if(value.status){
                    _myRate=0.0;
                  }
                  GlobalFunctions.showToast(value.message);
                });
              } else {
                GlobalFunctions.showToast(
                    'Please Select Rate at least grater that Zero');
              }
            },
            child: Container(
              height: 50,
              width: 200,
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(10, 20, 0, 0),
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: BoxDecoration(
                  color: GlobalVariables.green,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: GlobalVariables.transparent,
                    width: 3.0,
                  )),
              child: FlatButton(
                  onPressed: () {},
                  child: Text(
                    'Submit',
                    style: TextStyle(color: GlobalVariables.white),
                  )),
            ),
          )
        ],
      ),
    );
  }

  /*getHomeCareList(){

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


  }*/
}
