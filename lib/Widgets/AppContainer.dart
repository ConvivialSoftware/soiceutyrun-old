import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class AppContainer extends StatelessWidget {

  Widget child;
  double width,height;
  bool isListItem;
  Color color;
  final EdgeInsetsGeometry padding;


  AppContainer({this.child,width,
    height,this.isListItem=false,this.padding=const EdgeInsets.all(16.0),this.color=GlobalVariables.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding==null ? EdgeInsets.all(0) : EdgeInsets.all(16.0),
      margin: isListItem ? EdgeInsets.fromLTRB(16, 8, 16, 8) : EdgeInsets.all(16.0),
      decoration: boxDecoration(
        radius: 10.0,
        color: color,
      ),
      child: child ?? LimitedBox(
        maxWidth: 0.0,
        maxHeight: 0.0,
        child: ConstrainedBox(constraints: const BoxConstraints.expand()),
      ),
    );
  }
}
