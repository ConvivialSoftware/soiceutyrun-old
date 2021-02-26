
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/utils/AppWidget.dart';

class AppButton extends StatefulWidget {
  var textContent;
  VoidCallback onPressed;
  Color bgColor;
  Color textColor;
  var radius;

  AppButton({@required this.textContent,
    @required this.onPressed,
    this.bgColor = GlobalVariables.green,
    this.textColor = GlobalVariables.white,
    this.radius = 10.0});

  @override
  State<StatefulWidget> createState() {
    return AppButtonState();
  }
}

class AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: widget.bgColor,
      onPressed: widget.onPressed,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.radius),
          side: BorderSide(color: widget.bgColor)),
      child: text(widget.textContent,
          fontSize: GlobalVariables.textSizeMedium,
          textColor: widget.textColor),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return null;
  }
}
