
//import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/RentalRequestUserDetails.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseRentalRequest extends StatefulWidget {
  BaseRentalRequest();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RentalRequestState();
  }
}

class RentalRequestState extends State<BaseRentalRequest>
    with SingleTickerProviderStateMixin {

  //ProgressDialog _progressDialog;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
    Provider.of<UserManagementResponse>(context, listen: false)
        .getRentalRequest();
    });
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    //_progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);

    // TODO: implement build
    return ChangeNotifierProvider<UserManagementResponse>.value(
      value: Provider.of(context),
      child: Consumer<UserManagementResponse>(
        builder: (context, value, child) {
          return Builder(
            builder: (context) => Scaffold(
              backgroundColor: GlobalVariables.veryLightGray,
              appBar:
              CustomAppBar(
                title: AppLocalizations.of(context).translate('rental_request'),
                ),
              body: getRentalRequestLayout(value),
            ),
          );
        },
      ),
    );
  }

  /* getTabLayout() {
    return PreferredSize(
      preferredSize: Size.fromHeight(40.0),
      child: TabBar(
        tabs: [
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Tab(
              text: AppLocalizations.of(context).translate('register_user'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Tab(
              text: AppLocalizations.of(context).translate('unregister_user'),
            ),
          )
        ],
        controller: _tabController,
        unselectedLabelColor: GlobalVariables.white30,
        indicatorColor: GlobalVariables.white,
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: true,
        labelColor: GlobalVariables.white,
      ),
    );
  }
*/
  getRentalRequestLayout(UserManagementResponse value) {
    // print('MyTicketLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 150.0),
        !value.isLoading
            ? getRentalRequestListDataLayout(value) : GlobalFunctions.loadingWidget(context),
      ],
    );
  }

  getRentalRequestListDataLayout(UserManagementResponse value) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            //padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(
                0, 8, 0, 0),
            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: value.rentalRequestList.length,
                      itemBuilder: (context, position) {
                        return getRentalRequestListItemLayout(position, value);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          ),
        ],
      ),
    );
  }

  getRentalRequestListItemLayout(int position, UserManagementResponse value) {
    List<Tenant> tenantDetailsList = List<Tenant>.from(value
        .rentalRequestList[position].tenant_name!
        .map((i) => Tenant.fromJson(i)));
    var tenantName = tenantDetailsList[0].NAME;
    /*for (int i = 0; i < tenantDetailsList.length; i++) {
      tenantName += ', ' + tenantDetailsList[i].NAME;
    }*/

    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> BaseRentalRequestUserDetails(value.rentalRequestList[position])));
      },
      child: AppContainer(
        isListItem: true,
        child: Column(
          children: <Widget>[
            Container(
             // padding: EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(top: 5),
                      // padding: EdgeInsets.all(20),
                      // alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25)),
                      child: AppAssetsImage(
                        value.rentalRequestList[position].RENTED_TO!.toLowerCase()=='family' ? GlobalVariables.familyImagePath
                        : value.rentalRequestList[position].RENTED_TO!.toLowerCase()=='group'? GlobalVariables.bachelorsImagePath
                        : GlobalVariables.commercialImagePath,
                        imageWidth: 40.0,
                        imageHeight: 40.0,
                        borderColor: GlobalVariables.transparent,
                        borderWidth: 0.0,
                        fit: BoxFit.cover,
                        //radius: 15.0,
                      )),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                //  color:GlobalVariables.grey,
                                child: Flexible(
                                  child: text(tenantDetailsList.length>1 ? tenantName!.replaceFirst(",", "")+' + '+(tenantDetailsList.length-1).toString():tenantName!.replaceFirst(",", ""),
                                      textColor: GlobalVariables.primaryColor,
                                      fontSize: GlobalVariables.textSizeMedium,
                                      fontWeight: FontWeight.bold,
                                      textStyleHeight: 1.0),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                decoration: boxDecoration(
                                  bgColor: GlobalVariables.skyBlue,
                                  color: GlobalVariables.white,
                                  radius: GlobalVariables.textSizeSmall,
                                ),
                                child: text(
                                    tenantDetailsList[0].BLOCK! +
                                        ' ' +
                                        tenantDetailsList[0].FLAT!,
                                    fontSize: GlobalVariables.textSizeSmall,
                                    textColor: GlobalVariables.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              /*Container(
                                child: AppIcon(
                                  Icons.phone_android,
                                  iconColor: GlobalVariables.grey,
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),*/
                              Container(
                                child: text(
                                    tenantDetailsList[0].MOBILE,
                                    fontSize: GlobalVariables.textSizeSMedium,
                                    textColor: GlobalVariables.black,
                                    textStyleHeight: 1.0),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              /*Container(
                                child: AppIcon(
                                  Icons.date_range,
                                  iconColor: GlobalVariables.grey,
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),*/
                              Container(
                                child: text(
                                    'Expires on '+GlobalFunctions.convertDateFormat(value.rentalRequestList[position].AGREEMENT_TO!, "dd-MM-yyyy"),
                                    fontSize: GlobalVariables.textSizeSMedium,
                                    textColor: GlobalVariables.grey,
                                    textStyleHeight: 1.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
/*


  getTenantsLayout(UserManagementResponse value) {
   
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
                getTenantsListDataLayout(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getTenantsListDataLayout(UserManagementResponse value) {
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
            itemCount: 5,
            itemBuilder: (context, position) {
              return getTenantsListItemLayout(position,value);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getTenantsListItemLayout(int position, UserManagementResponse value) {

    PollOption pollOption = PollOption();
    pollOption.isSelected=false;
    return InkWell(
      onTap: () async {

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
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: pollOption.isSelected == true
                          ? GlobalVariables.green
                          : GlobalVariables.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: pollOption.isSelected == true
                            ? GlobalVariables.green
                            : GlobalVariables.mediumGreen,
                        width: 2.0,
                      )),
                  child: AppIcon(
                    Icons.check,
                    iconColor: pollOption.isSelected == true
                        ? GlobalVariables.white
                        : GlobalVariables.transparent,
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: text(
                      name,
                      textColor: GlobalVariables.green, fontSize: GlobalVariables.textSizeMedium,
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  void _handleTabSelection() {

      _callAPI(_tabController.index);

  }

  void _callAPI(int index) {
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        switch (index) {
          case 0:
            {

            }
            break;
          case 1:
            {

            }
            break;
        }
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }


  Future<void> getSharedPreferenceData() async {
    userId = await GlobalFunctions.getUserId();
    name = await GlobalFunctions.getDisplayName();
    photo = await GlobalFunctions.getPhoto();
    phone = await GlobalFunctions.getMobile();
    email = await GlobalFunctions.getUserName();
    consumerId = await GlobalFunctions.getConsumerID();
    societyName = await GlobalFunctions.getSocietyName();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();
    societyId = await GlobalFunctions.getSocietyId();
    userType = await GlobalFunctions.getUserType();

    print('UserId : ' + userId);
    print('Name : ' + name);
    print('Photo : ' + photo);
    print('Phone : ' + phone);
    print('EmailId : ' + email);
    print('ConsumerId : ' + consumerId);
    setState(() {});
  }*/
}
