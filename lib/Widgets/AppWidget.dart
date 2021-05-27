
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

import 'package:flutter_html/html_parser.dart';
import 'package:html/dom.dart' as dom;

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
      var maxLine = 99999,
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

Widget htmlText(var text,
    {var fontSize = GlobalVariables.textSizeLargeMedium,
      textColor = GlobalVariables.grey,
      var isCentered = false,
      var maxLine = 1,
      var latterSpacing = 0.5,
      var fontWeight = FontWeight.normal,var textStyleHeight=1.5}) {
  return Html(
    useRichText: false,
    customRender: htmlCustomRenderer,
    data: text,
    defaultTextStyle: TextStyle(
        fontSize: fontSize,
        color: textColor,
        height: textStyleHeight,
        letterSpacing: latterSpacing,
        fontWeight: fontWeight
    ),
  );/*Text(text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          height: textStyleHeight,
          letterSpacing: latterSpacing,
          fontWeight: fontWeight))*/;
}

Widget htmlCustomRenderer(dom.Node node, List<Widget> children) {
  if (node is dom.Element) {
    print('node.localName : '+node.localName);
    switch (node.localName) {
      case "li":
        return customListItem(node);
    }
  }
  return null;
}

Wrap customListItem(dom.Element node) {
  return Wrap(
    //alignment: WrapAlignment.start,
    crossAxisAlignment: WrapCrossAlignment.start,
    //spacing: 5,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 4,
            backgroundColor: GlobalVariables.green,
          ),
          SizedBox(width: 8,),
          Flexible(
            child: Container(
              //padding: EdgeInsets.only(left: 5,bottom: 5),
                child: text(node.text,fontSize: GlobalVariables.textSizeSMedium,
                    maxLine: 9999,
                    textColor: GlobalVariables.grey,textStyleHeight: 1.5)
            ),
          ),
        ],
      )
    ],
  );
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

Widget verticalDivider({var thickness = 1.0}) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
    child: VerticalDivider(
      color: GlobalVariables.lightGray,
      thickness: thickness,
    ),
  );
}
