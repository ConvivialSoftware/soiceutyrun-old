import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Poll.dart';
import 'package:societyrun/Models/PollOption.dart';
import 'package:societyrun/Widgets/AppImage.dart';
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
      dataMap[_optionList[j].ANS] = double.parse(_optionList[j].VOTES==null ? '0' : _optionList[j].VOTES);
      _totalParticipants += int.parse(_optionList[j].VOTES==null ? '0' : _optionList[j].VOTES);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: text(
            AppLocalizations.of(context).translate('poll_graph'),
              textColor: GlobalVariables.white,
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {

    return Container(
      width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 150.0),
                SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(
                        20, MediaQuery.of(context).size.height / 20, 20, 0),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: GlobalVariables.white,
                        borderRadius: BorderRadius.circular(20)),
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
                          child: Container(
                            margin: EdgeInsets.all(10),
                            alignment: Alignment.topLeft,
                            child: text(
                              _poll.POLL_Q,textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeNormal,fontWeight: FontWeight.bold
                            ),
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
                        Container(
                          height: 2,
                          color: GlobalVariables.mediumGreen,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Divider(
                            height: 2,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: text(
                                  !GlobalFunctions.isDateSameOrGrater(_poll.EXPIRY_DATE) ? 'Active' : 'Expired',
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeMedium
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: text(
                                  "Total participants : "+ _totalParticipants.toString(),
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeMedium
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              child: text(
                (position+1).toString()+')  '+_optionList[position].ANS.toString()+' - ',textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeMedium,fontWeight: FontWeight.normal
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: text(
             _optionList[position].VOTES==null ? '0' : _optionList[position].VOTES+ ' votes',textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeMedium,fontWeight: FontWeight.normal
            ),
          )
        ],
      ),


    );

  }
}
