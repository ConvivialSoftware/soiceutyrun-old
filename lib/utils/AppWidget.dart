import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

BoxDecoration boxDecoration({double radius = 2, Color color = Colors.transparent, Color bgColor = GlobalVariables.white, var showShadow = false}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow ? [BoxShadow(color: GlobalVariables.black, blurRadius: 3, spreadRadius: 1)] : [BoxShadow(color: GlobalVariables.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}

Widget text(var text, {var fontSize = GlobalVariables.textSizeLargeMedium, textColor = GlobalVariables.grey, var fontFamily = GlobalVariables.fontRegular, var isCentered = false, var maxLine = 1, var latterSpacing = 0.5,var fontWeight=FontWeight.normal}) {
  return Text(text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontFamily: fontFamily, fontSize: fontSize, color: textColor, height: 1.5, letterSpacing: latterSpacing,fontWeight: fontWeight));
}

Text subHeadingText(var text) {
  return Text(
    text,
    style: TextStyle(
        fontFamily: GlobalVariables.fontRegular,
        fontSize: GlobalVariables.textSizeMedium,
        color: GlobalVariables.grey),
  );
}

Text headingText(var text) {
  return Text(
    text,
    style: TextStyle(
        fontFamily: GlobalVariables.fontBold,
        fontSize: GlobalVariables.textSizeLargeMedium,
        fontWeight: FontWeight.bold,
        color: GlobalVariables.green),
  );
}

Widget longText(var text,
    {var fontSize = GlobalVariables.textSizeLargeMedium,
      textColor = GlobalVariables.grey,
      var fontFamily = GlobalVariables.fontRegular,
      var isCentered = false,
      var maxLine = 1,
      var latterSpacing = 0.5,
      var decoration = TextDecoration.underline,
      var islongTxt = false}) {
  return Text(text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: islongTxt ? null : maxLine,
      style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: textColor,
          height: 1.5,
          letterSpacing: latterSpacing));
}

class AppButton extends StatefulWidget {
  var textContent;
  VoidCallback onPressed;

  AppButton({@required this.textContent, @required this.onPressed});

  @override
  State<StatefulWidget> createState() {
    return AppButtonState();
  }
}

class AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        onPressed: widget.onPressed,
        textColor: Colors.white,
        elevation: 4,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: const EdgeInsets.all(0.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: <Color>[GlobalVariables.green, GlobalVariables.mediumGreen]),
            borderRadius: BorderRadius.all(Radius.circular(80.0)),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                widget.textContent,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return null;
  }
}


Widget divider() {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 8),
    child: Divider(
      color: GlobalVariables.lightGray,
      height: 1,
    ),
  );
}