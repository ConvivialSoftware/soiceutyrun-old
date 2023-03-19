import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Poll.dart';
import 'package:societyrun/Models/PollOption.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseViewPollGraph extends StatefulWidget {

  Poll _poll;
  List<PollOption> optionList;
  BaseViewPollGraph(this._poll,this.optionList);

  @override
  ViewPollGraphState createState() => ViewPollGraphState(_poll,optionList);
}

class ViewPollGraphState extends State<BaseViewPollGraph> {

  Poll _poll;
  List<PollOption> _optionList;
  ViewPollGraphState(this._poll,this._optionList);
  Map<String, double> dataMap={};
  var _totalParticipants=0;


  @override
  void initState() {
    super.initState();
    for(int j=0;j<_optionList.length;j++){
      dataMap[_optionList[j].ANS!] = double.parse(_optionList[j].VOTES==null ? '0' : _optionList[j].VOTES!);
      _totalParticipants += int.parse(_optionList[j].VOTES==null ? '0' : _optionList[j].VOTES!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('poll_graph'),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {

    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 150.0),
        SingleChildScrollView(
          child: AppContainer(
            child: Column(
              children: [
                Container(
                    alignment: Alignment.topCenter,
                    child: dataMap.length > 0 ? Container(
                        alignment: Alignment.topCenter,
                        //color: GlobalVariables.grey,
                        child: PieChart(
                          dataMap: dataMap,
                          animationDuration: Duration(milliseconds: 800),
                          chartLegendSpacing: 20,
                          chartRadius: 200,
                          initialAngleInDegree: 0,
                          chartType: ChartType.disc,
                          ringStrokeWidth: 20,
                          legendOptions: LegendOptions(
                            showLegendsInRow: true,
                            legendPosition: LegendPosition.top,
                            showLegends: true,
                            legendTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          chartValuesOptions: ChartValuesOptions(
                            showChartValueBackground: false,
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                          ),
                        )
                    ) : Container()
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: primaryText(
                    _poll.POLL_Q,
                  ),
                ),
                Builder(
                    builder: (context) => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        //scrollDirection: Axis.vertical,
                        itemBuilder: (context, position) {
                          return getVoteItemLayout(position);
                        },
                        itemCount: _optionList.length)
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    secondaryText(
                      !GlobalFunctions.isDateSameOrGrater(_poll.EXPIRY_DATE!) ? 'Active' : 'Expired',
                    ),
                    secondaryText(
                      "Total participants : "+ _totalParticipants.toString(),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );

  }

  getVoteItemLayout(int position) {

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              child: secondaryText(
                (position+1).toString()+')  '+_optionList[position].ANS.toString()+' - ',textColor: GlobalVariables.black,
              ),
            ),
          ),
          secondaryText(
           _optionList[position].VOTES==null ? '0' : _optionList[position].VOTES!+ ' votes',textColor: GlobalVariables.black
          )
        ],
      ),


    );

  }
}
