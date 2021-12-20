
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

import 'package:flutter_html/html_parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:url_launcher/url_launcher.dart';

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

Widget primaryText(var text,
    {var fontSize = GlobalVariables.textSizeMedium,
      textColor = GlobalVariables.primaryColor,
      var isCentered = false,
      var maxLine = 99999,
      var latterSpacing = 0.5,
      var fontWeight = FontWeight.bold,var textStyleHeight=1.5}) {
  return Text(text??'',
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: double.parse(fontSize.toString()),
          color: textColor,
          height: textStyleHeight,
          letterSpacing: latterSpacing,
          fontFamily: 'sans-serif',
          fontWeight: fontWeight));
}

Widget secondaryText(var text,
    {var fontSize = GlobalVariables.textSizeSMedium,
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
          fontSize: double.parse(fontSize.toString()),
          color: textColor,
          height: textStyleHeight,
          letterSpacing: latterSpacing,
          fontFamily: 'sans-serif',
          fontWeight: fontWeight));
}

Widget text(var text,
    {var fontSize = GlobalVariables.textSizeLargeMedium,
      textColor = GlobalVariables.grey,
      var isCentered = false,
      var maxLine = 99999,
      var textDecoration = TextDecoration.none,
      var latterSpacing = 0.5,
      var fontWeight = FontWeight.normal,var textStyleHeight=1.5}) {
  return Text(text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: double.parse(fontSize.toString()),
          color: textColor,
          height: textStyleHeight,
          letterSpacing: latterSpacing,
          fontFamily: 'sans-serif',
          fontWeight: fontWeight,
          decoration: textDecoration
      ));
}

Widget htmlText(var text,
    {var fontSize = GlobalVariables.textSizeLargeMedium,
      textColor = GlobalVariables.grey,
      var isCentered = false,
      var maxLine = 1,
      var latterSpacing = 0.5,
      var fontWeight = FontWeight.normal,var textStyleHeight=1.5}) {
  return Html(
      data: text,
    onLinkTap: (url, _, __, ___) {
      launch(url!);
    },


  )/* Html(
    //useRichText: false,
    customRender: htmlCustomRenderer,
    data: text,
    defaultTextStyle: TextStyle(
        fontSize: double.parse(fontSize.toString()),
        color: textColor,
        fontFamily: 'sans-serif',
        height: textStyleHeight,
        letterSpacing: latterSpacing,
        fontWeight: fontWeight
    ),
  );*//*Text(text,
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

Widget? htmlCustomRenderer(dom.Node? node, List<Widget> children) {
  if (node is dom.Element) {
    print('node.localName : '+node.localName!);
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
            backgroundColor: GlobalVariables.primaryColor,
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
          fontFamily: 'sans-serif',
          letterSpacing: latterSpacing));
}

Widget divider({var thickness = 0.5}) {
  return Padding(
    padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
    child: Divider(
      color: GlobalVariables.veryLightGray,
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

Widget smallTextContainerOutlineLayout(textString){

  return Container(
    padding: EdgeInsets.fromLTRB(15, 3, 15, 3),
    decoration: BoxDecoration(
        color: GlobalVariables.primaryColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: GlobalVariables.transparent,
          width: 1.0,
        )),
    child: Row(
      children: [
        text(
            textString,
            textColor: GlobalVariables.white,
            fontSize:
            GlobalVariables.textSizeSmall,
            fontWeight: FontWeight.normal),
        //SizedBox(width: 8,),
       // AppIcon(Icons.arrow_forward_ios_sharp,iconColor: GlobalVariables.white,iconSize: 12,)
      ],
    ),
  );

}

Widget indicator({bool? isActive,Color activeColor=GlobalVariables.white , Color inactiveColor=GlobalVariables.grey}) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 150),
    margin: EdgeInsets.symmetric(horizontal: 4.0),
    height: isActive! ? 6.0 : 4.0,
    width: isActive ? 6.0 : 4.0,
    decoration: BoxDecoration(
      color: isActive ? activeColor : inactiveColor,
      borderRadius: BorderRadius.all(Radius.circular(50)),
    ),
  );
}