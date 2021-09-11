import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AddExpense.dart';
import 'package:societyrun/Activities/Dues.dart';
import 'package:societyrun/Activities/UnitUserDetails.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseUnit extends StatefulWidget {
 // const BaseUnit({Key? key}) : super(key: key);
  bool isRegisteredUnit;
  bool isDuesUnit;
  bool isAddExpense;

  BaseUnit({this.isRegisteredUnit=false,this.isDuesUnit=false,this.isAddExpense=false});

  @override
  _BaseUnitState createState() => _BaseUnitState();
}

class _BaseUnitState extends State<BaseUnit> {

  List<DropdownMenuItem<String>> _unitListItems =
  new List<DropdownMenuItem<String>>();
  String _unitSelectedItem;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    Provider.of<UserManagementResponse>(context,listen: false).getUnitDetails("").then((value) {
      getUnitData(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return ChangeNotifierProvider<UserManagementResponse>.value(
        value: Provider.of<UserManagementResponse>(context),
      child: Consumer<UserManagementResponse>(builder: (context,value,child){
        return value.isLoading ?
        GlobalFunctions.loadingWidget(context) :
        Container(
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
                              10, MediaQuery.of(context).size.height / 30, 16, 0),
                          padding: EdgeInsets.only(right: 20),
                          decoration: boxDecoration(radius: 10.0,color: GlobalVariables.primaryColor,bgColor: GlobalVariables.primaryColor),
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
                    getUnitListDataLayout(value),
                  ],
                ),
              ),
            ],
          ),
        );
      }),

    );
  }

  getUnitListDataLayout(UserManagementResponse userManagementResponse) {

    List<UnitDetails> unitDetailsList = List<UnitDetails>();
    if(!widget.isRegisteredUnit){
      unitDetailsList = userManagementResponse.unitDetailsList;
    }else{
      unitDetailsList = userManagementResponse.unitDetailsList;
      for(int i=0;i<unitDetailsList.length;i++){
        unitDetailsList.removeWhere((item) => item.unitMember.length == 0);
      }
    }

    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(10, 80, 10, 0),
      child: Builder(
          builder: (context) => GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: unitDetailsList.length,
            itemBuilder: (context, position) {
              return InkWell(
                onTap: () {

                  if(widget.isDuesUnit){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BaseDues(isAdmin: true,mBlock:unitDetailsList[position].BLOCK,
                                mFlat :unitDetailsList[position].FLAT)));
                  }else if(widget.isAddExpense){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => BaseAddExpense(isAdmin: true,mBlock:unitDetailsList[position].BLOCK,
                            mFlat :unitDetailsList[position].FLAT)))
                        .then((value) {
                      GlobalFunctions.setBaseContext(context);
                    });
                  }else {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            BaseUnitUserDetails(unitDetailsList[position].BLOCK,
                                unitDetailsList[position].FLAT)));
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  //width: width / 4,
                  // height: width / 4,
                  margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: position%2==0 ? GlobalVariables.averageGray : GlobalVariables.averageGreen,
                  ),
                  child: text(unitDetailsList[position].BLOCK +' '+unitDetailsList[position].FLAT,
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
          textColor: GlobalVariables.primaryColor,
        ),
      ));
    }
    _unitSelectedItem = _unitListItems[0].value;
    setState(() {

    });
  }
}
