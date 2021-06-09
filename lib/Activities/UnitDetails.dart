import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/UnitUserDetails.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseUnitDetails extends StatefulWidget {

  bool isAppbarDisplay;

  BaseUnitDetails(this.isAppbarDisplay);

  @override
  _BaseUnitDetailsState createState() => _BaseUnitDetailsState();
}

class _BaseUnitDetailsState extends BaseStatefulState<BaseUnitDetails> {
  List<DropdownMenuItem<String>> _unitListItems =
      new List<DropdownMenuItem<String>>();

  String _unitSelectedItem;

  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    Provider.of<UserManagementResponse>(context,listen: false).getUnitDetails(null).then((value) {
      getUnitData(value);
    });
  }
  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return ChangeNotifierProvider<UserManagementResponse>.value(
        value: Provider.of<UserManagementResponse>(context),
      child: Consumer<UserManagementResponse>(builder: (context,value,child){
        return Builder(
            builder: (context) => Scaffold(
              appBar: widget.isAppbarDisplay ? AppBar(
                backgroundColor: GlobalVariables.green,
                centerTitle: true,
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
                  AppLocalizations.of(context).translate('unit'),
                  textColor: GlobalVariables.white,
                ),
              ):PreferredSize(child: SizedBox(), preferredSize: Size(0, 0),),
              body: getBaseUnitLayout(value),
            ));
      }),
    );
  }

  getBaseUnitLayout(UserManagementResponse userManagementResponse) {
    return userManagementResponse.isLoading ? GlobalFunctions.loadingWidget(context) :Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.white,
      ),
      child: Column(
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                //GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 150.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 50,
                      width: 120,
                      alignment: Alignment.center,
                      margin: EdgeInsets.fromLTRB(
                          10, MediaQuery.of(context).size.height / 30, 30, 0),
                     padding: EdgeInsets.only(right: 20),
                     decoration: boxDecoration(radius: 30.0,color: GlobalVariables.green,bgColor: GlobalVariables.green),
                     // color: GlobalVariables.black,
                      child: ButtonTheme(
                        //alignedDropdown: true,
                        child: DropdownButton(
                          items: _unitListItems,
                          onChanged: (value) {
                            _unitSelectedItem = value;
                            print('_selctedItem:' + _unitSelectedItem.toString());
                            setState(() {
                              _progressDialog.show();
                              Provider.of<UserManagementResponse>(context,listen: false).getUnitDetails(_unitSelectedItem).then((value) {
                                _progressDialog.hide();
                              });
                            });
                          },
                          value: _unitSelectedItem,
                          underline: SizedBox(),
                          isExpanded: true,
                          icon: AppIcon(
                            Icons.keyboard_arrow_down,
                            iconColor: GlobalVariables.white,
                          ),
                          iconSize: GlobalVariables.textSizeNormal,
                          selectedItemBuilder: (BuildContext context) {
                            // String txt =  _societyListItems.elementAt(position).value;
                            return _unitListItems.map((e) {
                              return Container(
                                  alignment: Alignment.center,
                                  //margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
                                  child: text(
                                    _unitSelectedItem,
                                    textColor: GlobalVariables.white,
                                  ));
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                getUnitListDataLayout(userManagementResponse),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getUnitListDataLayout(UserManagementResponse userManagementResponse) {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 10, 10, 0),
      child: Builder(
          builder: (context) => GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: userManagementResponse.unitDetailsList.length,
                itemBuilder: (context, position) {
                  return InkWell(
                    onTap: () {

                      Navigator.push(context, MaterialPageRoute(builder: (context)=>  BaseUnitUserDetails(userManagementResponse.unitDetailsList[position].BLOCK,userManagementResponse.unitDetailsList[position].FLAT)));

                    },
                    child: Container(
                      alignment: Alignment.center,
                      //width: width / 4,
                      // height: width / 4,
                      margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: position%2==0 ? GlobalVariables.averageGray : GlobalVariables.averageGreen,
                      ),
                      child: text(userManagementResponse.unitDetailsList[position].BLOCK +' '+userManagementResponse.unitDetailsList[position].FLAT,
                          textColor: GlobalVariables.white,fontWeight: FontWeight.bold,fontSize: GlobalVariables.textSizeMedium),
                    ),
                  );
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  void getUnitData(List<Block> _unitList) {

    for (int i = 0; i < _unitList.length; i++) {
      _unitListItems.add(DropdownMenuItem(
        value: _unitList[i].BLOCK,
        child: text(
          _unitList[i].BLOCK,
          textColor: GlobalVariables.green,
        ),
      ));
    }
    _unitSelectedItem = _unitListItems[0].value;
    setState(() {

    });
  }
}
