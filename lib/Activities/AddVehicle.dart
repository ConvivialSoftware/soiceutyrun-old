import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseAddVehicle extends StatefulWidget {
  //String memberType;
  //BaseAddVehicle(this.memberType);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddVehicleState();
  }
}

class AddVehicleState extends BaseStatefulState<BaseAddVehicle> {
  TextEditingController _vehicleNoController = TextEditingController();
  TextEditingController _vehicleModelController = TextEditingController();
  TextEditingController _vehicleStickerController = TextEditingController();

  String _selectedVehicleType = "2 Wheeler";

  ProgressDialog _progressDialog;

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: AppBar(
          backgroundColor: GlobalVariables.primaryColor,
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
          title: text(
            AppLocalizations.of(context).translate('add_vehicle'),
            textColor: GlobalVariables.white, fontSize: GlobalVariables.textSizeMedium
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 200.0),
        getAddVehicleLayout(),
      ],
    );
  }

  getAddVehicleLayout() {
    return SingleChildScrollView(
      child: AppContainer(
        child: Column(
          children: <Widget>[
            AppTextField(
              textHintContent:
                  AppLocalizations.of(context).translate('vehicle_no') + '*',
              controllerCallback: _vehicleNoController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                new WhitelistingTextInputFormatter(RegExp("[A-Z0-9\\-]")),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: <Widget>[
                  Container(
                    child: InkWell(
                      //  splashColor: GlobalVariables.mediumGreen,
                      onTap: () {
                        _selectedVehicleType = "2 Wheeler";
                        setState(() {});
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: _selectedVehicleType == "2 Wheeler"
                                      ? GlobalVariables.primaryColor
                                      : GlobalVariables.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: _selectedVehicleType == "2 Wheeler"
                                        ? GlobalVariables.primaryColor
                                        : GlobalVariables.secondaryColor,
                                    width: 2.0,
                                  )),
                              child: AppIcon(Icons.check,
                                  iconColor: GlobalVariables.white),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: text(
                                  AppLocalizations.of(context)
                                      .translate('2_wheeler'),
                                  textColor: GlobalVariables.primaryColor,
                                  fontSize: GlobalVariables.textSizeMedium),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: InkWell(
                      //  splashColor: GlobalVariables.mediumGreen,
                      onTap: () {
                        _selectedVehicleType = "4 Wheeler";
                        setState(() {});
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: _selectedVehicleType == "4 Wheeler"
                                      ? GlobalVariables.primaryColor
                                      : GlobalVariables.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: _selectedVehicleType == "4 Wheeler"
                                        ? GlobalVariables.primaryColor
                                        : GlobalVariables.secondaryColor,
                                    width: 2.0,
                                  )),
                              child: AppIcon(Icons.check,
                                  iconColor: GlobalVariables.white),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: text(
                                AppLocalizations.of(context)
                                    .translate('4_wheeler'),
                                textColor: GlobalVariables.primaryColor,
                                fontSize: GlobalVariables.textSizeMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            AppTextField(
              textHintContent:
                  AppLocalizations.of(context).translate('model_name') + '*',
              controllerCallback: _vehicleModelController,
            ),
            AppTextField(
              textHintContent:
                  AppLocalizations.of(context).translate('sticker'),
              controllerCallback: _vehicleStickerController,
            ),
            Container(
              alignment: Alignment.topLeft,
              height: 45,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: AppButton(
                textContent: AppLocalizations.of(context).translate('submit'),
                onPressed: () {
                  verifyVehicle();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addVehicle() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();

    _progressDialog.show();
    restClient
        .addVehicle(
            societyId,
            block,
            flat,
            _vehicleNoController.text,
            _vehicleModelController.text,
            _selectedVehicleType,
            _vehicleStickerController.text,
            userId)
        .then((value) {
      print('add vehicle Status value : ' + value.toString());
      if (value.status) {
        Navigator.pop(context);
      }
      GlobalFunctions.showToast(value.message);

      _progressDialog.hide();
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            _progressDialog.hide();
          }
          break;
        default:
      }
    });
  }

  void verifyVehicle() {
    if (_vehicleNoController.text.length > 0) {
      if (_vehicleModelController.text.length > 0) {
        // if(_vehicleStickerController.text.length>0){
        addVehicle();
        /* }else{
          GlobalFunctions.showToast("Please Enter Sticker");
        }*/
      } else {
        GlobalFunctions.showToast("Please Enter ModelName");
      }
    } else {
      GlobalFunctions.showToast("Please Enter Vehicle Number");
    }
  }
}
