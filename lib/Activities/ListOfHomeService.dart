import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:societyrun/Activities/DescriptionOfHomeService.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/ChangeLanguageNotifier.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class BaseListOfHomeService extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ListOfHomeServiceState();
  }
}

class ListOfHomeServiceState extends State<BaseListOfHomeService> {


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
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      getHomeCareListDataLayout(),
                    ],
                  ),
                ),
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
      margin: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).size.height / 80, 20, 0),
      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
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
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Text(_homeCareList[position].title,style: TextStyle(
                        color: GlobalVariables.green,fontSize: 18,fontWeight: FontWeight.w400
                      ),),
                    ),
                  ),
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
                                  .veryLightGray,
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
            Container(
              margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
              alignment: Alignment.topLeft,
              child: Text(_homeCareList[position].subDesc,style: TextStyle(
                  color: GlobalVariables.lightGray,fontSize: 14,
              ),),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Text(_homeCareList[position].startPrice,style: TextStyle(
                          color: GlobalVariables.mediumGreen,fontSize: 16,fontWeight: FontWeight.w400
                      ),),
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _homeCareList[position].isCall ?
                        Container(
                            margin:EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Icon(
                              Icons.call,
                              color:
                              GlobalVariables.mediumGreen,
                              size: 24,
                            )) : Container(),
                        _homeCareList[position].isMail ?
                        Container(
                            margin:EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Icon(
                              Icons.mail_outline,
                              color:
                              GlobalVariables.mediumGreen,
                              size: 24,
                            )):Container(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
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
