
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class AppTextField extends StatefulWidget {

  TextEditingController controllerCallback;
  var textHintContent,
      borderWidth,
      borderRadius,
      maxLines,
      borderColor,
      readOnly,
      keyboardType,
      maxLength,
      counterText,
      textCapitalization,
      inputFormatters,
      contentPadding,
      obscureText,
      suffixIcon;

  AppTextField({@required this.textHintContent,
    @required this.controllerCallback,
    this.borderWidth = 2.0,
    this.borderRadius = 10.0,
    this.maxLines=1,
    this.borderColor=GlobalVariables.mediumGreen,
    this.readOnly=false,
    this.suffixIcon,this.keyboardType=TextInputType.text,
    this.maxLength,this.counterText='',
    this.textCapitalization=TextCapitalization.none,
    this.inputFormatters,this.contentPadding,
    this.obscureText=false,
  });

  @override
  State<StatefulWidget> createState() {
    return AppTextFieldState();
  }
}

class AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(
          color: GlobalVariables.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          )),
      child: TextField(
        controller: widget.controllerCallback,
        readOnly: widget.readOnly,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        textCapitalization:widget.textCapitalization,
        inputFormatters:widget.inputFormatters??<TextInputFormatter>[],
        obscureText: widget.obscureText,
        /*style: TextStyle(
            color: GlobalVariables.green
        ),*/
        decoration: InputDecoration(
            contentPadding: widget.contentPadding??EdgeInsets.zero,
            hintText: widget.textHintContent,
            hintStyle: TextStyle(
                color: GlobalVariables.lightGray,
                fontSize: GlobalVariables.textSizeSMedium),
            border: InputBorder.none,
          counterText: widget.counterText,
          suffixIcon: widget.suffixIcon!=null ? widget.suffixIcon:null,
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return null;
  }
}
