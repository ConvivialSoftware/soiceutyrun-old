

import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppImage.dart';

class AppDropDown<T> extends StatefulWidget {

  ValueChanged<T> onChanged;
  List<DropdownMenuItem<T>> items;
  var icon,iconColor,iconSize,isExpanded;
  T value;


  AppDropDown(this.items,this.onChanged,{ this.icon, this.iconColor=GlobalVariables.grey,
      this.iconSize=20.0,
    required this.value,this.isExpanded=false});

  @override
  _AppDropDownState createState() => _AppDropDownState();
}

class _AppDropDownState extends State<AppDropDown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items:  widget.items,
      onChanged: widget.onChanged,
      value: widget.value,
      underline: SizedBox(),
      isExpanded: widget.isExpanded,
      icon: AppIcon(widget.icon,iconColor: widget.iconColor,iconSize: widget.iconSize,)
    );
  }
}
