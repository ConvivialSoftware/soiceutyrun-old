import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AddAgreement.dart';
import 'package:societyrun/Activities/AddNewMemberByAdmin.dart';
import 'package:societyrun/Activities/AddStaffMember.dart';
import 'package:societyrun/Activities/AddVehicle.dart';
import 'package:societyrun/Activities/DisplayProfileInfo.dart';
import 'package:societyrun/Activities/DisplayTenantInfo.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/StaffDetails.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseUnitUserDetails extends StatefulWidget {
  String block, flat;

  BaseUnitUserDetails(this.block, this.flat);

  @override
  _BaseUnitUserDetailsState createState() => _BaseUnitUserDetailsState();
}

class _BaseUnitUserDetailsState extends State<BaseUnitUserDetails> {
  TextEditingController billerNameTextController = TextEditingController();
  TextEditingController areaTextController = TextEditingController();
  TextEditingController intercomTextController = TextEditingController();
  TextEditingController gstinNoTextController = TextEditingController();
  TextEditingController parkingSlotTextController = TextEditingController();

  List<DropdownMenuItem<String>> _unitRoleListItems =
      <DropdownMenuItem<String>>[];

  String? _unitRoleSelectedItem, societyId;

  ProgressDialog? _progressDialog;

  @override
  void initState() {
    super.initState();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    getUnitRole();
    _unitRoleSelectedItem = 'Owned';

    Provider.of<UserManagementResponse>(context, listen: false)
        .getUnitDetailsMemberForAdminData(widget.block, widget.flat, true)
        .then((value) {
      billerNameTextController.text = value[0].BILLING_NAME!;
      areaTextController.text = value[0].AREA!;
      //intercomTextController.text = '0';
      gstinNoTextController.text = value[0].GSTIN_NO!;
      parkingSlotTextController.text = value[0].PARKING_SLOT!;
      intercomTextController.text = value[0].INTERCOM ?? '';
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserManagementResponse>.value(
      value: Provider.of<UserManagementResponse>(context),
      child: Consumer<UserManagementResponse>(builder: (context, value, child) {
        return Builder(
          builder: (context) => Scaffold(
            backgroundColor: GlobalVariables.veryLightGray,
            appBar: CustomAppBar(
              title: widget.block + ' ' + widget.flat,
            ),
            body: getBaseLayout(value),
          ),
        );
      }),
    );
  }

  getBaseLayout(UserManagementResponse userManagementResponse) {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 150.0),
        userManagementResponse.isLoading
            ? GlobalFunctions.loadingWidget(context)
            : getMyHouseholdLayout(userManagementResponse),
      ],
    );
  }

  /* getUnitUserDetailsLayout(UserManagementResponse userManagementResponse) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            profileLayout(userManagementResponse),
            getMyHouseholdLayout(userManagementResponse),
          ],
        ),
      ),
    );
  }*/

  profileLayout(UserManagementResponse userManagementResponse) {
    return InkWell(
      onTap: () {},
      child: Align(
        alignment: Alignment.center,
        child: Container(
          // height: double.infinity,
          // color: GlobalVariables.black,
          //width: MediaQuery.of(context).size.width / 1.2,
          margin: EdgeInsets.fromLTRB(
              0,
              MediaQuery.of(context).size.height / 30,
              0,
              0), //margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Card(
            shape: (RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0))),
            elevation: 2.0,
            //  shadowColor: GlobalVariables.green.withOpacity(0.3),
            margin: EdgeInsets.all(16),
            color: GlobalVariables.white,
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AppAssetsImage(
                      GlobalVariables.whileBGPath,
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          padding: EdgeInsets.all(16),
                          // alignment: Alignment.center,
                          /* decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25)),*/
                          child: AppAssetsImage(
                            GlobalVariables.shopIconPath,
                            imageWidth: 50.0,
                            imageHeight: 50.0,
                            borderColor: GlobalVariables.transparent,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 0.0,
                          )),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    child: text(
                                        AppLocalizations.of(context)
                                                .translate('biller_name') +
                                            ' : ',
                                        textColor: GlobalVariables.primaryColor,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Flexible(
                                    child: Container(
                                      child: text(
                                        userManagementResponse
                                                    .unitDetailsListForAdmin
                                                    .length >
                                                0
                                            ? userManagementResponse
                                                .unitDetailsListForAdmin[0]
                                                .BILLING_NAME
                                            : '',
                                        textColor: GlobalVariables.black,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    child: text(
                                        AppLocalizations.of(context)
                                                .translate('area') +
                                            ' : ',
                                        textColor: GlobalVariables.primaryColor,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    child: text(
                                      userManagementResponse
                                          .unitDetailsListForAdmin[0].AREA,
                                      textColor: GlobalVariables.black,
                                      fontSize: GlobalVariables.textSizeSMedium,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    child: text(
                                        AppLocalizations.of(context)
                                                .translate('consumer_no') +
                                            ' : ',
                                        textColor: GlobalVariables.primaryColor,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Flexible(
                                    child: Container(
                                      child: text(
                                        userManagementResponse
                                            .unitDetailsListForAdmin[0]
                                            .CONSUMER_NO,
                                        textColor: GlobalVariables.black,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    child: text(
                                        AppLocalizations.of(context)
                                                .translate('gstin') +
                                            ' : ',
                                        textColor: GlobalVariables.primaryColor,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    child: text(
                                      userManagementResponse
                                          .unitDetailsListForAdmin[0].GSTIN_NO,
                                      textColor: GlobalVariables.black,
                                      fontSize: GlobalVariables.textSizeSMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 20, 10, 20),
                        child: AppIconButton(Icons.edit,
                            iconColor: GlobalVariables.primaryColor,
                            iconSize: GlobalVariables.textSizeLarge,
                            onPressed: () {
                          showEditUnitDetailsLayout(userManagementResponse);
                        }),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* getMyHouseholdLayout(UserManagementResponse value) {
    print('MyHouseHold Tab Call');
    return Container(
      width: MediaQuery.of(context).size.width,
      //height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
               Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: text(
                        AppLocalizations.of(context)
                            .translate('my_family'),
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                   Container(
                        child: MaterialButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BaseAddNewMemberByAdmin(
                                        widget.block,
                                        widget.flat)));
                            print('result back : ' + result.toString());
                            if (result != 'back') {
                              Provider.of<UserManagementResponse>(
                                  context,
                                  listen: false)
                                  .getUnitMemberData();
                            }
                          },
                          child: text(
                            AppLocalizations.of(context)
                                .translate('plus_add'),
                            textColor: GlobalVariables.white,
                            fontSize: GlobalVariables.textSizeSmall,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                  color: GlobalVariables.green)),
                          textColor: GlobalVariables.white,
                          color: GlobalVariables.green,
                        ))
                  ],
                ),
              ),
               value.memberListForAdmin.length > 0
                  ? Container(
                alignment: Alignment.topLeft,
                //padding: EdgeInsets.all(10),
                margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                height: 190,
                child: Builder(
                    builder: (context) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: value.memberListForAdmin.length,
                      itemBuilder: (context, position) {
                        return getContactListItemLayout(
                            value.memberListForAdmin, position, true);
                      },
                      //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
              )
                  : Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(20),
                child: text(
                    AppLocalizations.of(context)
                        .translate('add_family_details'),
                    textColor: GlobalVariables.grey,
                    fontSize: GlobalVariables.textSizeSMedium),
              ),
              SizedBox(height: 16,),
              Container(
                alignment: Alignment.topLeft, //color: GlobalVariables.white,
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: text(
                        AppLocalizations.of(context).translate('my_tenant'),
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                            child: MaterialButton(
                              onPressed: () {
                                */ /* final result = await*/ /* Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BaseAddAgreement(widget.block, widget.flat, false)));
                              },
                              child: text(
                                AppLocalizations.of(context)
                                    .translate('add_agreement'),
                                textColor: GlobalVariables.white,
                                fontSize: GlobalVariables.textSizeSmall,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: GlobalVariables.green)),
                              textColor: GlobalVariables.white,
                              color: GlobalVariables.green,
                            )),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                            child: MaterialButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BaseAddNewMemberByAdmin(
                                            widget.block,
                                            widget.flat)));
                                print('result back : ' + result.toString());
                                if (result != 'back') {
                                  Provider.of<UserManagementResponse>(context,
                                      listen: false)
                                      .getUnitMemberData();
                                }
                              },
                              child: text(
                                AppLocalizations.of(context).translate('plus_add'),
                                textColor: GlobalVariables.white,
                                fontSize: GlobalVariables.textSizeSmall,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: GlobalVariables.green)),
                              textColor: GlobalVariables.white,
                              color: GlobalVariables.green,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              value.tenantListForAdmin.length > 0
                  ? Container(
                alignment: Alignment.topLeft,
                //padding: EdgeInsets.all(10),
                margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                //  width: 600,
                height: 190,
                child: Builder(
                    builder: (context) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: value.tenantListForAdmin.length,
                      itemBuilder: (context, position) {
                        return getContactListItemLayout(
                            value.tenantListForAdmin, position, true);
                      },
                      //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
              )
                  : Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(20),
                child: text(
                    AppLocalizations.of(context)
                        .translate('add_tenant_details'),
                    textColor: GlobalVariables.grey,
                    fontSize: GlobalVariables.textSizeSMedium),
              ),
              SizedBox(height: 16,),
              Container(
                alignment: Alignment.topLeft, //color: GlobalVariables.white,
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: text(
                        AppLocalizations.of(context).translate('my_staff'),
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Visibility(
                      visible: true,
                      child: Container(
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BaseStaffCategory(false)));
                            },
                            child: text(
                              AppLocalizations.of(context).translate('plus_add'),
                              textColor: GlobalVariables.white,
                              fontSize: GlobalVariables.textSizeSmall,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: GlobalVariables.green)),
                            textColor: GlobalVariables.white,
                            color: GlobalVariables.green,
                          )),
                    ),
                  ],
                ),
              ),
              value.staffListForAdmin.length > 0
                  ? Container(
                alignment: Alignment.topLeft,
                //padding: EdgeInsets.all(10),
                margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                // width: 600,
                height: 190,
                child: Builder(
                    builder: (context) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: value.staffListForAdmin.length,
                      itemBuilder: (context, position) {
                        return getContactListItemLayout(
                            value.staffListForAdmin, position, false);
                      },
                      //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
              )
                  : Container(
                padding: EdgeInsets.all(20),
                child: text(
                    AppLocalizations.of(context)
                        .translate('add_staff_details'),
                    textColor: GlobalVariables.grey,
                    fontSize: GlobalVariables.textSizeSMedium),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                alignment: Alignment.topLeft, //color: GlobalVariables.white,
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: text(
                        AppLocalizations.of(context).translate('my_vehicle'),
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                        child: MaterialButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BaseAddVehicle()));
                            print('result back : ' + result.toString());
                            if (result != 'back') {
                              Provider.of<UserManagementResponse>(context,
                                  listen: false)
                                  .getUnitMemberData();
                            }
                          },
                          child: text(
                            AppLocalizations.of(context)
                                .translate('plus_add'),
                            textColor: GlobalVariables.white,
                            fontSize: GlobalVariables.textSizeSmall,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: GlobalVariables.green)),
                          textColor: GlobalVariables.white,
                          color: GlobalVariables.green,
                        ))
                  ],
                ),
              ),
              Column(
               // mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  value.vehicleListForAdmin.length > 0
                      ? Container(
                    //height: 500,
                    //padding: EdgeInsets.all(10),
                    margin: EdgeInsets.fromLTRB(16, 0, 16, 20),
                    decoration: BoxDecoration(
                        color: GlobalVariables.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Builder(
                        builder: (context) => ListView.builder(
                          physics:
                          const NeverScrollableScrollPhysics(),
                          // scrollDirection: Axis.horizontal,
                          itemCount: value.vehicleListForAdmin.length,
                          itemBuilder: (context, position) {
                            return getVehicleRecentTransactionListItemLayout(
                                position, value);
                          },
                          //  scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        )),
                  )
                      : Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(20),
                    child: text(
                        AppLocalizations.of(context)
                            .translate('add_vehicle_details'),
                        textColor: GlobalVariables.grey,
                        fontSize: GlobalVariables.textSizeSMedium),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }*/

  getMyHouseholdLayout(UserManagementResponse value) {
    print('MyHouseHold Tab Call');
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 150.0),
          Container(
            child: Column(
              children: [
                profileLayout(value),
                getFamilyLayout(value),
                getTenantLayout(value),
                getStaffLayout(value),
                getVehicleLayout(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getFamilyLayout(UserManagementResponse value) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: text(
                  AppLocalizations.of(context).translate('my_family'),
                  textColor: GlobalVariables.black,
                  fontSize: GlobalVariables.textSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppUserPermission.isUserAddMemberPermission
                  ? InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BaseAddNewMemberByAdmin(
                                    widget.block, widget.flat)));
                        print('result back : ' + result.toString());
                        if (result != 'back') {
                          Provider.of<UserManagementResponse>(context,
                                  listen: false)
                              .getUnitMemberData();
                        }
                      },
                      child: smallTextContainerOutlineLayout(
                          AppLocalizations.of(context).translate('add')),
                    )
                  : Container(),
            ],
          ),
        ),
        value.memberListForAdmin.length > 0
            ? AppContainer(
                child: Builder(
                    builder: (context) => ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: value.memberListForAdmin.length,
                          itemBuilder: (context, position) {
                            return getContactListItemLayout(
                                value.memberListForAdmin, position, 'family');
                          },
                          //  scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        )),
              )
            : Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(16),
                child: text(
                    AppLocalizations.of(context)
                        .translate('add_family_details'),
                    textColor: GlobalVariables.grey,
                    fontSize: GlobalVariables.textSizeSMedium),
              )
      ],
    );
  }

  getTenantLayout(UserManagementResponse value) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          //color: GlobalVariables.white,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: text(
                  AppLocalizations.of(context).translate('my_tenant'),
                  textColor: GlobalVariables.black,
                  fontSize: GlobalVariables.textSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BaseAddAgreement(
                                  widget.block, widget.flat, true)));
                    },
                    child: smallTextContainerOutlineLayout(
                      AppLocalizations.of(context).translate('add_tenant'),
                    ),
                  ),
                  /*   SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BaseAddNewMemberByAdmin(widget.block,widget.flat)));
                      print('result back : ' + result.toString());
                      if (result != 'back') {
                        Provider.of<UserManagementResponse>(context,
                            listen: false)
                            .getUnitMemberData();
                      }
                    },
                    child: smallTextContainerOutlineLayout(
                      AppLocalizations.of(context).translate('add'),
                    ),
                  ),*/
                ],
              ),
            ],
          ),
        ),
        value.tenantListForAdmin.length > 0
            ? AppContainer(
                child: Builder(
                    builder: (context) => ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: value.tenantListForAdmin.length,
                          itemBuilder: (context, position) {
                            return getContactListItemLayout(
                                value.tenantListForAdmin, position, 'tenant',
                                userManagementInstance: value);
                          },
                          //  scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        )),
              )
            : Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(16),
                child: text(
                    AppLocalizations.of(context)
                        .translate('add_tenant_details'),
                    textColor: GlobalVariables.grey,
                    fontSize: GlobalVariables.textSizeSMedium),
              ),
      ],
    );
  }

  getStaffLayout(UserManagementResponse value) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          //color: GlobalVariables.white,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: text(
                  AppLocalizations.of(context).translate('my_staff'),
                  textColor: GlobalVariables.black,
                  fontSize: GlobalVariables.textSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BaseAddStaffMember()));
                },
                child: smallTextContainerOutlineLayout(
                  AppLocalizations.of(context).translate('add'),
                ),
              ),
            ],
          ),
        ),
        value.staffListForAdmin.length > 0
            ? AppContainer(
                child: Builder(
                    builder: (context) => ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: value.staffListForAdmin.length,
                          itemBuilder: (context, position) {
                            return getContactListItemLayout(
                                value.staffListForAdmin, position, 'staff');
                          },
                          //  scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        )),
              )
            : Container(
                padding: EdgeInsets.all(16),
                child: text(
                    AppLocalizations.of(context).translate('add_staff_details'),
                    textColor: GlobalVariables.grey,
                    fontSize: GlobalVariables.textSizeSMedium),
              ),
      ],
    );
  }

  getVehicleLayout(UserManagementResponse value) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          //color: GlobalVariables.white,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: text(
                  AppLocalizations.of(context).translate('my_vehicle'),
                  textColor: GlobalVariables.black,
                  fontSize: GlobalVariables.textSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSocietyPermission.isSocAddVehiclePermission
                  ? InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BaseAddVehicle()));
                        print('result back : ' + result.toString());
                        if (result != 'back') {
                          Provider.of<UserManagementResponse>(context,
                                  listen: false)
                              .getUnitMemberData();
                        }
                      },
                      child: smallTextContainerOutlineLayout(
                          AppLocalizations.of(context).translate('add')),
                    )
                  : Container(),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            value.vehicleListForAdmin.length > 0
                ? AppContainer(
                    child: Builder(
                        builder: (context) => ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              // scrollDirection: Axis.horizontal,
                              itemCount: value.vehicleListForAdmin.length,
                              itemBuilder: (context, position) {
                                return getVehicleRecentTransactionListItemLayout(
                                    position, value);
                              },
                              //  scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                            )),
                  )
                : Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(16),
                    child: text(
                        AppLocalizations.of(context)
                            .translate('add_vehicle_details'),
                        textColor: GlobalVariables.grey,
                        fontSize: GlobalVariables.textSizeSMedium),
                  ),
          ],
        ),
      ],
    );
  }

  getContactListItemLayout(var _list, int position, String memberType,
      {UserManagementResponse? userManagementInstance}) {
    var call = '', email = '', userId, userType;
    if (memberType == 'family' || memberType == 'tenant') {
      call = _list[position].Phone.toString();
      userId = _list[position].ID.toString();
      userType = _list[position].TYPE.toString();
      //    email = _list[position].EMAIL.toString();
    } else {
      call = _list[position].CONTACT.toString();
      userId = _list[position].SID.toString();
    }
    if (call == 'null') {
      call = '';
    }

    return InkWell(
      onTap: () async {
        print('userId : ' + userId);
        print('societyId : ' + societyId!);
        if (memberType == 'family') {
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BaseDisplayProfileInfo(userId, userType)));
          if (result == 'back') {
            Provider.of<UserManagementResponse>(context, listen: false)
                .getUnitMemberData();
          }
        } else if (memberType == 'tenant') {
          List<TenantRentalRequest> tenantRentalRequest =
              userManagementInstance!
                  .tenantAgreementListForAdmin
                  .where(
                      (element) => element.ID == _list[position].AGREEMENT_ID)
                  .toList();
//private/var/mobile/Containers/Data/Application/7C6B9535-92F8-437A-ABE7-BE8F1CA0F15E/tmp/com.convivial.SocietyRunApp-Inbox/Pay Slip September pdf (1).pdf
          if (tenantRentalRequest.length > 0) {
            var result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BaseTenantInfo(tenantRentalRequest[0], true)));
            if (result == 'back') {
              Provider.of<UserManagementResponse>(context, listen: false)
                  .getUnitMemberData();
            }
          }
        } else {
          print('_list[position] : ' + _list[position].toString());
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseStaffDetails(_list[position])));
          if (result == 'back') {
            Provider.of<UserManagementResponse>(context, listen: false)
                .getUnitMemberData();
          }
        }
      },
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    //margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: memberType == 'family' || memberType == 'tenant'
                        ? _list[position].PROFILE_PHOTO.length == 0
                            ? AppAssetsImage(
                                GlobalVariables.componentUserProfilePath,
                                imageWidth: 50.0,
                                imageHeight: 50.0,
                                borderColor: GlobalVariables.grey,
                                borderWidth: 1.0,
                                fit: BoxFit.cover,
                                radius: 25.0,
                              )
                            : AppNetworkImage(
                                _list[position].PROFILE_PHOTO,
                                imageWidth: 50.0,
                                imageHeight: 50.0,
                                borderColor: GlobalVariables.grey,
                                borderWidth: 1.0,
                                fit: BoxFit.cover,
                                radius: 25.0,
                              )
                        : _list[position].IMAGE.length == 0
                            ? AppAssetsImage(
                                GlobalVariables.componentUserProfilePath,
                                imageWidth: 50.0,
                                imageHeight: 50.0,
                                borderColor: GlobalVariables.grey,
                                borderWidth: 1.0,
                                fit: BoxFit.cover,
                                radius: 25.0,
                              )
                            : AppNetworkImage(
                                _list[position].IMAGE,
                                imageWidth: 50.0,
                                imageHeight: 50.0,
                                borderColor: GlobalVariables.grey,
                                borderWidth: 1.0,
                                fit: BoxFit.cover,
                                radius: 25.0,
                              )),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      primaryText(
                        memberType == 'family' || memberType == 'tenant'
                            ? _list[position].NAME
                            : _list[position].STAFF_NAME,
                        maxLine: 2,
                      ),
                      call.length > 0
                          ? InkWell(
                              onTap: () {
                                launch("tel://" + call);
                              },
                              child: secondaryText(call,
                                  maxLine: 2,
                                  textColor: GlobalVariables.skyBlue),
                            )
                          : memberType == 'family' || memberType == 'tenant'
                              ? InkWell(
                                  onTap: () async {
                                    var result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BaseEditProfileInfo(
                                                    userId, societyId)));
                                    if (result == 'profile') {
                                      Provider.of<UserManagementResponse>(
                                              context,
                                              listen: false)
                                          .getUnitMemberData();
                                    }
                                  },
                                  child: Container(
                                    //margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                                    alignment: Alignment.topLeft,
                                    child: secondaryText(
                                      AppLocalizations.of(context)
                                          .translate('add_phone'),
                                      textColor: GlobalVariables.skyBlue,
                                    ),
                                  ),
                                )
                              : Container(),
                    ],
                  ),
                ),
                Container(
                  child: AppIconButton(
                    Icons.share,
                    iconColor: GlobalVariables.grey,
                    iconSize: 20.0,
                    onPressed: () {
                      String name =
                          memberType == 'family' || memberType == 'tenant'
                              ? _list[position].NAME
                              : _list[position].STAFF_NAME;
                      String title = '';
                      String text = 'Name : ' + name + '\nContact : ' + call;
                      memberType == 'family' || memberType == 'tenant'
                          ? title = _list[position].NAME
                          : title = _list[position].STAFF_NAME;
                      print('titlee : ' + title);
                      GlobalFunctions.shareData(title, text);
                    },
                  ),
                )
              ],
            ),
            position != _list.length - 1 ? Divider() : Container(),
            /*call.length > 0
                ? Container(
                    // margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              launch("tel://" + call);
                            },
                            child: Container(
                              width: double.infinity,
                              child: AppIconButton(
                                Icons.call,
                                iconColor: GlobalVariables.green,
                                iconSize: 20.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30, child: verticalDivider()),
                        Flexible(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              String name = family
                                  ? _list[position].NAME
                                  : _list[position].STAFF_NAME;
                              String title = '';
                              String text =
                                  'Name : ' + name + '\nContact : ' + call;
                              family
                                  ? title = _list[position].NAME
                                  : title = _list[position].STAFF_NAME;
                              print('titlee : ' + title);
                              GlobalFunctions.shareData(title, text);
                            },
                            child: Container(
                              width: double.infinity,
                              child: AppIconButton(
                                Icons.share,
                                iconColor: GlobalVariables.grey,
                                iconSize: 20.0,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ))
                : family
                    ? InkWell(
                        onTap: () async {
                          var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BaseEditProfileInfo(userId, societyId)));
                          if (result == 'profile') {
                            Provider.of<UserManagementResponse>(context,
                                    listen: false)
                                .getUnitMemberData();
                          }
                        },
                        child: Container(
                          //margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                          alignment: Alignment.center,
                          child: text(
                            '+ ' +
                                AppLocalizations.of(context)
                                    .translate('add_phone'),
                            textColor: GlobalVariables.grey,
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      )
                    : Container()*/
          ],
        ),
      ),
    );
  }

  getVehicleRecentTransactionListItemLayout(
      int position, UserManagementResponse value) {
    return Container(
      //padding: EdgeInsets.all(10),
      //margin: position == 0 ? EdgeInsets.only(top: 10) : EdgeInsets.all(0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: getIconForVehicle(
                    value.vehicleListForAdmin[position].WHEEL!),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: primaryText(
                    value.vehicleListForAdmin[position].MODEL,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: secondaryText(
                      value.vehicleListForAdmin[position].VEHICLE_NO,
                      /* textColor: GlobalVariables.grey,
                        fontSize: GlobalVariables.textSizeMedium,
                        textStyleHeight: 1.0*/
                    ),
                  ),
                  /*AppPermission.isSocAddVehiclePermission
                      ? */
                  InkWell(
                    onTap: () {
                      print('Delete Position :' + position.toString());
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: deleteVehicleLayout(position, value),
                                );
                              }));
                    },
                    child: Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: AppIcon(
                          Icons.delete,
                          iconColor: GlobalVariables.secondaryColor,
                        )),
                  )
                  // : Container(),
                ],
              )
            ],
          ),
          position != value.vehicleListForAdmin.length - 1
              ? Divider()
              : Container(),
        ],
      ),
    );
  }

  deleteVehicleLayout(int position, UserManagementResponse value) {
    return AppContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: text(
              AppLocalizations.of(context).translate('sure_delete'),
              fontSize: GlobalVariables.textSizeLargeMedium,
              textColor: GlobalVariables.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        deleteVehicle(position, value);
                      },
                      child: text(
                        AppLocalizations.of(context).translate('yes'),
                        textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Container(
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: text(
                        AppLocalizations.of(context).translate('no'),
                        textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  getIconForVehicle(String vehicleType) {
    if (vehicleType == '4 Wheeler' ||
        vehicleType == '4' ||
        vehicleType == 'four') {
      return AppIcon(
        Icons.directions_car,
        iconColor: GlobalVariables.secondaryColor,
        iconSize: 20.0,
      );
    } else if (vehicleType == '2 Wheeler' ||
        vehicleType == '2' ||
        vehicleType == 'two') {
      return AppIcon(
        Icons.motorcycle,
        iconColor: GlobalVariables.secondaryColor,
        iconSize: 20.0,
      );
    } else {
      return AppIcon(
        Icons.motorcycle,
        iconColor: GlobalVariables.secondaryColor,
        iconSize: 20.0,
      );
    }
  }

  Future<void> deleteVehicle(
      int position, UserManagementResponse UserManagementResponse) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String id = UserManagementResponse.vehicleListForAdmin[position].ID!;
    _progressDialog!.show();
    restClient.deleteVehicle(id, societyId).then((value) {
      _progressDialog!.dismiss();
      if (value.status!) {
        UserManagementResponse.vehicleListForAdmin.removeAt(position);
        setState(() {});
      }
      GlobalFunctions.showToast(value.message!);
    });
  }

  showEditUnitDetailsLayout(UserManagementResponse userManagementResponse) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter _setState) {
              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                child: Container(
                  margin: EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: GlobalVariables.white),
                  // height: MediaQuery.of(context).size.width * 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            child: text(
                              AppLocalizations.of(context)
                                  .translate('update_unit_details'),
                              textColor: GlobalVariables.primaryColor,
                              fontSize: GlobalVariables.textSizeLargeMedium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          AppTextField(
                              textHintContent: 'Enter BillerName',
                              controllerCallback: billerNameTextController),
                          SizedBox(
                            height: 8,
                          ),
                          AppTextField(
                            textHintContent: 'Enter Area',
                            controllerCallback: areaTextController,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          AppTextField(
                            textHintContent: 'Enter Intercom/HomePhone',
                            controllerCallback: intercomTextController,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          AppTextField(
                              textHintContent: 'Enter GSTIN No',
                              controllerCallback: gstinNoTextController),
                          SizedBox(
                            height: 8,
                          ),
                          AppTextField(
                              textHintContent: 'Enter Parking Slot',
                              controllerCallback: parkingSlotTextController),
                          SizedBox(
                            height: 4,
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            decoration: BoxDecoration(
                                color: GlobalVariables.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: GlobalVariables.secondaryColor,
                                  width: 2.0,
                                )),
                            child: ButtonTheme(
                              //alignedDropdown: true,
                              child: DropdownButton(
                                items: _unitRoleListItems,
                                onChanged: (value) {
                                  _unitRoleSelectedItem = value as String;
                                  print('_selctedItem:' +
                                      _unitRoleSelectedItem.toString());
                                  setState(() {
                                    _progressDialog!.show();
                                  });
                                },
                                value: _unitRoleSelectedItem,
                                underline: SizedBox(),
                                isExpanded: true,
                                icon: AppIcon(
                                  Icons.keyboard_arrow_down,
                                  iconColor: GlobalVariables.primaryColor,
                                ),
                                iconSize: GlobalVariables.textSizeNormal,
                                selectedItemBuilder: (BuildContext context) {
                                  // String txt =  _societyListItems.elementAt(position).value;
                                  return _unitRoleListItems.map((e) {
                                    return Container(
                                        alignment: Alignment.topLeft,
                                        margin:
                                            EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: text(
                                          _unitRoleSelectedItem,
                                          textColor:
                                              GlobalVariables.primaryColor,
                                        ));
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: AppButton(
                                textContent: AppLocalizations.of(context)
                                    .translate('submit'),
                                onPressed: () async {
                                  String consumerNo =
                                      await GlobalFunctions.getConsumerID();

                                  _progressDialog!.show();

                                  Provider.of<UserManagementResponse>(context,
                                          listen: false)
                                      .editUnitDetails(
                                          widget.block,
                                          userManagementResponse.unitDetailsList
                                              .firstWhereOrNull(
                                                  (e) => e.FLAT == widget.flat)!
                                              .ID!,
                                          consumerNo,
                                          parkingSlotTextController.text,
                                          areaTextController.text,
                                          gstinNoTextController.text,
                                          billerNameTextController.text,
                                          intercomTextController.text)
                                      .then((value) {
                                    _progressDialog!.dismiss();

                                    GlobalFunctions.showToast(value.message!);
                                    if (value.status!) {
                                      Navigator.of(context).pop();
                                    }
                                  });
                                }),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }));
  }

  Future<void> getUnitRole() async {
    societyId = await GlobalFunctions.getSocietyId();
    List<String> _unitRoleList = ['Owned', 'Rented'];

    for (int i = 0; i < _unitRoleList.length; i++) {
      _unitRoleListItems.add(DropdownMenuItem(
        value: _unitRoleList[i],
        child: text(
          _unitRoleList[i],
          textColor: GlobalVariables.primaryColor,
        ),
      ));
    }
    if (_unitRoleSelectedItem == null) {
      _unitRoleSelectedItem = _unitRoleListItems[0].value;
    }
    setState(() {});
  }
}
