import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/Unit.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';

class BaseUnitDetails extends StatefulWidget {

  bool isDuesUnit,isAddExpense;
  BaseUnitDetails({this.isDuesUnit=false,this.isAddExpense=false});

  @override
  _BaseUnitDetailsState createState() => _BaseUnitDetailsState();
}

class _BaseUnitDetailsState extends State<BaseUnitDetails> {

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<UserManagementResponse>.value(
        value: Provider.of<UserManagementResponse>(context),
      child: Consumer<UserManagementResponse>(builder: (context,value,child){
        return Builder(
            builder: (context) => Scaffold(
              appBar: CustomAppBar(
                title:  AppLocalizations.of(context).translate('unit'),
              ),
              body: BaseUnit(isDuesUnit: widget.isDuesUnit,isAddExpense: widget.isAddExpense,),
            ));
      }),
    );
  }
}
