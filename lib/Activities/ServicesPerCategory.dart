import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/DescriptionOfHomeService.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ServicesResponse.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:intl/intl.dart';
import 'base_stateful.dart';

class BaseServicesPerCategory extends StatefulWidget {

  String category;
  BaseServicesPerCategory(this.category);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ServicesPerCategoryState();
  }
}

class ServicesPerCategoryState extends BaseStatefulState<BaseServicesPerCategory> {

  @override
  void initState() {
    super.initState();
    Provider.of<ServicesResponse>(context,listen: false).getServicePerCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider<ServicesResponse>.value(
        value: Provider.of<ServicesResponse>(context),
        child: Consumer<ServicesResponse>(
          builder: (context, value, child) {
            print('Consumer Value : ' + value.servicesList.toString());
            return Builder(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  backgroundColor: GlobalVariables.green,
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
                  title: Text(
                    widget.category + ' Services',
                    style: TextStyle(color: GlobalVariables.white),
                  ),
                ),
                body: value.isLoading ? GlobalFunctions.loadingWidget(context) : getBaseLayout(value),
              ),
            );
          },
        ));
  }

  getBaseLayout(ServicesResponse value) {
    return value.servicesList.length >0 ? Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 200.0),
        getHomeCareListDataLayout(value),
      ],
    ):GlobalFunctions.noDataFoundLayout(context, "No Services Found for "+ widget.category);
  }

  getHomeCareListDataLayout(ServicesResponse value) {
    return Container(
      margin: EdgeInsets.only(top: 8.0),
      child: Builder(
          builder: (context) => ListView.builder(
             scrollDirection: Axis.vertical,
            itemCount: value.servicesList.length,
            itemBuilder: (context, position) {
              return getHomeCareListItemLayout(position,value);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getHomeCareListItemLayout(int position, ServicesResponse value) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) =>
                BaseDescriptionOfHomeService(value.servicesList[position],)));
      },
      child: AppContainer(
        child: Stack(
          children: <Widget>[
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        primaryText(value.servicesList[position].Name,),
                        SizedBox(height: 4),
                        secondaryText(value.servicesList[position].Title,),
                        SizedBox(height: 8),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child:  Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        child: AppIcon(
                                          Icons.star, iconColor:
                                          GlobalVariables.orangeYellow,
                                        )),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          5, 0, 0, 0),
                                      child: secondaryText(
                                        value.servicesList[position]
                                            .Rating,fontSize: GlobalVariables.textSizeSmall
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                 /* SizedBox(
                    width: 1,
                    height: 120,
                    child: Center(
                      child: Container(
                        width: 1,
                        margin: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            left: Divider.createBorderSide(context, color: GlobalVariables.lightGray, width: 1),
                          ),
                        ),
                      ),
                    ),
                  ),*/
                  VerticalDivider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        child: text('Price Starts from',
                            textColor: GlobalVariables.grey,
                            fontSize: GlobalVariables.textSizeSMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        child: text(/*'Rs. '+NumberFormat.currency(locale: 'HI',symbol: '',decimalDigits:0).format(double.parse(value.servicesList[position].Price))*/GlobalFunctions.getCurrencyFormat(value.servicesList[position].Price),
                            textColor: GlobalVariables.black,
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          text(/*'Rs. '+NumberFormat.currency(locale: 'HI',symbol: '',decimalDigits:0).format(double.parse(value.servicesList[position].Price))*/GlobalFunctions.getCurrencyFormat(value.servicesList[position].Price),
                              textColor: GlobalVariables.black,
                              fontSize: GlobalVariables.textSizeSmall,
                              textDecoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.bold),
                          SizedBox(width: 4,),
                          text('('+value.servicesList[position].Discount+'%)',
                              textColor: GlobalVariables.green,
                              fontSize: GlobalVariables.textSizeSmall,
                              fontWeight: FontWeight.bold)
                        ],
                      ),
                      //SizedBox(width: 10),
                    ],
                  )
                ],
              ),
            ),
            /*Container(
              width: 4,
              height: 50,
              margin: EdgeInsets.only(top: 32),
              color: position % 2 == 0 ? GlobalVariables.lightPurple : GlobalVariables.orangeYellow,
            )*/
          ],
        ),
      ),
    );
  }

}