import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class AppButton extends StatefulWidget {
  var textContent;
  VoidCallback onPressed;
  Color bgColor;
  Color textColor;
  var radius, fontWeight;
  EdgeInsets padding;

  AppButton(
      {@required this.textContent,
      required this.onPressed,
      this.bgColor = GlobalVariables.primaryColor,
      this.textColor = GlobalVariables.white,
      this.radius = 10.0,
      this.fontWeight = FontWeight.w600,
      this.padding = const EdgeInsets.all(0.0)});

  @override
  State<StatefulWidget> createState() {
    return AppButtonState();
  }
}

class AppButtonState extends State<AppButton> {
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: widget.padding,
      color: widget.bgColor,
      onPressed: widget.onPressed,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.radius),
          side: BorderSide(color: widget.bgColor)),
      child: text(widget.textContent,
          fontSize: GlobalVariables.textSizeMedium,
          textColor: widget.textColor,
          fontWeight: widget.fontWeight),
    );
  }

  @override
  State<StatefulWidget>? createState() {
    // TODO: implement createState
    return null;
  }
}
