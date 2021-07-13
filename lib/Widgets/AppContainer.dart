import 'package:flutter/material.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class AppContainer extends StatelessWidget {

  Widget child;
  double width,height;

  AppContainer({this.child,width,
    height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(8.0),
      decoration: boxDecoration(
        radius: 10.0,
      ),
      child: child ?? LimitedBox(
        maxWidth: 0.0,
        maxHeight: 0.0,
        child: ConstrainedBox(constraints: const BoxConstraints.expand()),
      ),
    );
  }
}
