import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';

import 'GlobalVariables.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  var title;
  //var scafold_key;
  BuildContext context;

  //CustomAppBar.ScafoldKey(this.title,this.context,this.scafold_key);

  CustomAppBar(this.title, this.context);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppBar(
          title: Text(title),
        backgroundColor: GlobalVariables.green,
        centerTitle: true,
          leading: getIconButton());

  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);

  navigatePage() {
    Navigator.of(context).pop();
  }

  getIconButton() {
   // if (title != AppLocalizations.of(context).translate('overview')) {
      return IconButton(
          icon: Icon(Icons.arrow_back, color: GlobalVariables.white),
          onPressed: () => navigatePage());
   /* } else {
      return IconButton(
          icon: Icon(Icons.dehaze, color: GlobalVariables.white),
          onPressed: () => scafold_key.currentState.openDrawer());
    }*/
  }
}
