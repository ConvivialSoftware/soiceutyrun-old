import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

import 'base_stateful.dart';

class BaseStaffCategory extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return StaffCategoryState();
  }
}

class StaffCategoryState extends BaseStatefulState<BaseStaffCategory> {

  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
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
        body:  getStaffCategoryLayout(),
      ),
    );
  }

  getStaffCategoryLayout() {
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
                getStaffCategoryListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getStaffCategoryListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 10, 10, 0),
      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
            itemCount: 0,
            itemBuilder: (context, position) {
              return getStaffCategoryListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getStaffCategoryListItemLayout(int position) {
    return InkWell(
      onTap: () async {

      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Row(
          children: [
            Expanded(
              child: Container(
                child: Text('Maid'),
              ),
            ),
            Container(
              child: Text('20'),
            ),
            Container(
              child: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getUnitComplaintData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);

  }

}
