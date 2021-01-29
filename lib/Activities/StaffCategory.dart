import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/Activities/StaffListPerCategory.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Models/StaffCount.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

import 'base_stateful.dart';

class BaseStaffCategory extends StatefulWidget {

  bool isHideAppBar=false;


  BaseStaffCategory(this.isHideAppBar);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return StaffCategoryState(this.isHideAppBar);
  }
}

class StaffCategoryState extends BaseStatefulState<BaseStaffCategory> {

  ProgressDialog _progressDialog;
  List<StaffCount> _staffListCount = List<StaffCount>();

  bool isHideAppBar=false;
  StaffCategoryState(this.isHideAppBar);

  @override
  void initState() {
    super.initState();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getStaffCountData();
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
        appBar: !isHideAppBar ? AppBar(
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
        ):null,
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
    return _staffListCount.length>0 ? Container(
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
            itemCount: _staffListCount.length,
            itemBuilder: (context, position) {
              return getStaffCategoryListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    ):Container();
  }

  getStaffCategoryListItemLayout(int position) {
    return InkWell(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BaseStaffListPerCategory(_staffListCount[position].ROLE)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: Text(_staffListCount[position].ROLE),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Text(_staffListCount[position].Role_count),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Icon(Icons.arrow_forward_ios,color: GlobalVariables.lightGray,),
                ),
              ],
            ),
            Container(
              //color: GlobalVariables.black,
              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
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

  Future<void> getStaffCountData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();

    _progressDialog.show();
    restClient.staffCount(societyId).then((value) {
      _progressDialog.hide();
      List<dynamic> _list = value.data;
      _staffListCount = List<StaffCount>.from(_list.map((i)=>StaffCount.fromJson(i)));
      setState(() {});
    });

  }

}
