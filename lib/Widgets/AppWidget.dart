
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

BoxDecoration boxDecoration({double radius = 2,
  Color color = Colors.transparent,
  Color bgColor = GlobalVariables.white,double width=1.0,
  var showShadow = false}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow
        ? [
      BoxShadow(
          color: GlobalVariables.grey, blurRadius: 2, spreadRadius: 1)
    ]
        : [BoxShadow(color: GlobalVariables.transparent)],
    border: Border.all(color: color,width: width),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}

Widget text(var text,
    {var fontSize = GlobalVariables.textSizeLargeMedium,
      textColor = GlobalVariables.grey,
      var isCentered = false,
      var maxLine = 1,
      var latterSpacing = 0.5,
      var fontWeight = FontWeight.normal,var textStyleHeight=1.5}) {
  return Text(text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          height: textStyleHeight,
          letterSpacing: latterSpacing,
          fontWeight: fontWeight));
}

Widget longText(var text,
    {var fontSize = GlobalVariables.textSizeLargeMedium,
      textColor = GlobalVariables.grey,
      var isCentered = false,
      var maxLine = 1,
      var latterSpacing = 0.5,
      var decoration = TextDecoration.underline,
      var islongTxt = false}) {
  return Text(text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: islongTxt ? null : maxLine,
      style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          height: 1.5,
          letterSpacing: latterSpacing));
}

Widget divider({var thickness = 1.0}) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
    child: Divider(
      color: GlobalVariables.lightGray,
      thickness: thickness,
    ),
  );
}
