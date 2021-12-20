import 'package:flutter/material.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'GlobalVariables.dart';

class CustomAppBar extends StatefulWidget  implements PreferredSizeWidget {

  String title;
  List<Widget>? actions;
  Widget? leading;
  PreferredSize? bottom;

  CustomAppBar({
    required this.title, this.actions,
    this.leading,
    this.bottom
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => new Size.fromHeight(bottom!=null? 80.0 : kToolbarHeight);
}

class _CustomAppBarState
    extends State<CustomAppBar> /*implements PreferredSizeWidget*/ {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppBar(
      title: text(widget.title,
          textColor: GlobalVariables.white,
          fontSize: GlobalVariables.textSizeMedium),
        backgroundColor: GlobalVariables.primaryColor,
        centerTitle: true,
      leading: widget.leading?? InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: AppIcon(
          Icons.arrow_back,
          iconColor: GlobalVariables.white,
        ),
      ),
      actions: widget.actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
        color: GlobalVariables.white
        ),
      ),
      bottom: widget.bottom,
    );
  }
}
