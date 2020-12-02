import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/Activities/StaffDetails.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

import 'base_stateful.dart';

class BaseStaffListPerCategory extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return StaffListPerCategoryState();
  }
}

class StaffListPerCategoryState extends BaseStatefulState<BaseStaffListPerCategory> {

  ProgressDialog _progressDialog;
  var userId = "",
      name = "",
      photo = "",
      societyId="",
      flat="",
      block="";
  var email = '', phone = '', consumerId = '', societyName = '';
  @override
  void initState() {
    super.initState();
    getSharedPreferenceData();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getUnitComplaintData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
      _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
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
            AppLocalizations.of(context).translate('staff_category'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body:  getStaffListPerCategoryLayout(),
      ),
    );
  }

  getStaffListPerCategoryLayout() {
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
                    context, 180.0),
                getStaffListPerCategoryListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getStaffListPerCategoryListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 20, 10, 0),
      padding: EdgeInsets.all(20), // height: MediaQuery.of(context).size.height / 0.5,
      decoration: BoxDecoration(
          color: GlobalVariables.white,
          borderRadius: BorderRadius.circular(20)),

      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
            itemCount: 3,
            itemBuilder: (context, position) {
              return getStaffListPerCategoryListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getStaffListPerCategoryListItemLayout(int position) {
    return InkWell(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BaseStaffDetails()));
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
       // padding: EdgeInsets.all(10),
       // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Column(
          children: [
            Row(
              children: [
                //profileLayout(),
                Container(
                    padding: EdgeInsets.all(10),
                    // alignment: Alignment.center,
                    /* decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25)),*/
                    child: photo.length == 0
                        ? Image.asset(
                      GlobalVariables.componentUserProfilePath,
                      width: 60,
                      height: 60,
                    )
                        : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(photo),
                              fit: BoxFit.cover),
                          border: Border.all(
                              color:
                              GlobalVariables.mediumGreen,
                              width: 2.0)),
                    )),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Archana Nilesh Suryavanshi',
                            style: TextStyle(
                                color: GlobalVariables.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                  child: Icon(
                                    Icons.star,
                                    color: GlobalVariables.skyBlue,
                                    size: 15,
                                  )
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                  '4.3',
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Icon(
                                    Icons.fiber_manual_record,
                                    color: GlobalVariables.orangeYellow,
                                    size: 10,
                                  )
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                  '3 House',
                                  style: TextStyle(
                                    color: GlobalVariables.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Icon(Icons.arrow_forward_ios,color: GlobalVariables.lightGray,),
                ),
              ],
            ),
            Container(
              //color: GlobalVariables.black,
              //margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Divider(
                thickness: 1,
                color: GlobalVariables.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getSharedPreferenceData() async {
    userId = await GlobalFunctions.getUserId();
    name = await GlobalFunctions.getDisplayName();
   // photo = await GlobalFunctions.getPhoto();
    phone = await GlobalFunctions.getMobile();
    email = await GlobalFunctions.getUserName();
    consumerId = await GlobalFunctions.getConsumerID();
    societyName = await GlobalFunctions.getSocietyName();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();
    societyId = await GlobalFunctions.getSocietyId();

    print('UserId : ' + userId);
    print('Name : ' + name);
    print('Photo : ' + photo);
    print('Phone : ' + phone);
    print('EmailId : ' + email);
    print('ConsumerId : ' + consumerId);
    setState(() {});
  }

  Future<void> getUnitComplaintData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);

  }

}
