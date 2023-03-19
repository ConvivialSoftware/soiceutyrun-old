import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:societyrun/Activities/StaffListPerCategory.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/StaffCount.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';


class BaseStaffCategory extends StatefulWidget {

  bool isHideAppBar=false;
  String type;


  BaseStaffCategory(this.isHideAppBar,this.type);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return StaffCategoryState();
  }
}

class StaffCategoryState extends State<BaseStaffCategory> {

  ProgressDialog? _progressDialog;
  List<StaffCount>? _staffListCount = <StaffCount>[];

  @override
  void initState() {
    super.initState();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
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

    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        //resizeToAvoidBottomPadding: false,
        appBar: !widget.isHideAppBar ? CustomAppBar(
          title: AppLocalizations.of(context).translate('staff_category'),
        ):null,
        body:  getStaffCategoryLayout(),
      ),
    );
  }

  getStaffCategoryLayout() {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 180.0),
        getStaffCategoryListDataLayout(),
      ],
    );
  }

  getStaffCategoryListDataLayout() {
    return _staffListCount!.length>0 ? Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          0, 16, 0, 0),
      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
            itemCount: _staffListCount!.length,
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
                    BaseStaffListPerCategory(_staffListCount![position].ROLE!,widget.type,)));
      },
      child: AppContainer(
        isListItem: true,
       // width: MediaQuery.of(context).size.width / 1.1,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: text(_staffListCount![position].ROLE,
                        fontSize: GlobalVariables.textSizeMedium),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: text(_staffListCount![position].Role_count,fontSize: GlobalVariables.textSizeSmall),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: AppIcon(Icons.arrow_forward_ios,iconColor: GlobalVariables.lightGray,),
                ),
              ],
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

    _progressDialog!.show();
    restClient.staffCount(societyId,'Staff').then((value) {
      _progressDialog!.dismiss();
      List<dynamic> _list = value.data!;
      _staffListCount = List<StaffCount>.from(_list.map((i)=>StaffCount.fromJson(i)));
      setState(() {});
    });

  }

}
