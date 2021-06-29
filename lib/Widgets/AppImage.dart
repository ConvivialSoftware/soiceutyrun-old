
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class AppNetworkImage extends StatefulWidget {
  var image, radius, fit, borderColor, borderWidth, imageWidth, imageHeight,shape;

  AppNetworkImage(this.image,  {this.imageWidth, this.imageHeight,
     this.radius = 0.0, this.fit = BoxFit
          .fill, this.borderColor=Colors.grey, this.borderWidth=1.0,this.shape=BoxShape.circle});

  @override
  _AppNetworkImageState createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  var width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery
        .of(context)
        .size
        .width;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: widget.image.toString().contains('.svg')? SvgPicture.network(
        widget.image,
        width: widget.imageWidth,
        height: widget.imageHeight,
        //semanticsLabel: 'A shark?!',
        placeholderBuilder: (BuildContext context) => Center(
          child: Container(width: 80,height: 80,
              child: CircularProgressIndicator(backgroundColor: GlobalVariables.grey,strokeWidth: 2.0,)),
        ),
      ) : CachedNetworkImage(
        imageUrl: widget.image,
        width: widget.imageWidth,
        height: widget.imageHeight,
        imageBuilder: (context, imageProvider) =>
            Container(
              decoration: BoxDecoration(
                  shape: widget.shape,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: widget.fit,
                    //colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                  ),
                  border: Border.all(
                      color: widget.borderColor, width: widget.borderWidth)),
            ),
        placeholder: (context, url) =>
            Center(
              child: Container(width: 80,height: 80,
                  child: CircularProgressIndicator(backgroundColor: GlobalVariables.grey,strokeWidth: 2.0,)),
            ),
        errorWidget: (context, url, error) {
          print('error : '+ error.toString());
          return AppAssetsImage(
            GlobalVariables.componentUserProfilePath,
            imageWidth : widget.imageWidth,
            imageHeight :  widget.imageHeight,
            borderColor: widget.borderColor,
            borderWidth: widget.borderWidth,
            fit: widget.fit,
            radius: widget.radius,
          );
        },
      ),
    );
  }
}


class AppAssetsImage extends StatefulWidget {
  var image, radius, fit, borderColor, borderWidth, imageWidth, imageHeight,shape;

  AppAssetsImage(this.image, { this.imageWidth=24.0, this.imageHeight=24.0,
     this.radius = 0.0, this.fit = BoxFit
          .fill,this.borderColor=Colors.transparent, this.borderWidth=1.0,this.shape=BoxShape.circle});

  @override
  _AppAssetsImageState createState() => _AppAssetsImageState();
}

class _AppAssetsImageState extends State<AppAssetsImage> {
  var width;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Container(
          decoration: BoxDecoration(
              shape: widget.shape,
              border: Border.all(
                  color: widget.borderColor, width: widget.borderWidth)
          ),
          child: widget.image.toString().contains(".svg") ? SvgPicture.asset(
            widget.image,
            width: double.parse(widget.imageWidth.toString()),
            height: double.parse(widget.imageHeight.toString()),
            fit: widget.fit,
          ) : Container(
            decoration: BoxDecoration(
                shape: widget.shape,
                border: Border.all(
                    color: widget.borderColor, width: widget.borderWidth)
            ),
            child: Image.asset(
              widget.image,
              width: widget.imageWidth,
              height: widget.imageHeight,
              fit: widget.fit,
            ),
          ),
        )
    );
  }
}


class AppFileImage extends StatefulWidget {
  var image, radius, fit, borderColor, borderWidth, imageWidth, imageHeight,shape;

  AppFileImage(this.image,{ this.imageWidth, this.imageHeight,
      this.radius = 0.0, this.fit = BoxFit
          .fill,this.borderColor=Colors.grey, this.borderWidth=1.0,this.shape=BoxShape.circle});

  @override
  _AppFileImageState createState() => _AppFileImageState();
}

class _AppFileImageState extends State<AppFileImage> {
  var width;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Container(
          decoration: BoxDecoration(
              shape: widget.shape,
              border: Border.all(
                  color: widget.borderColor, width: widget.borderWidth)),
          child: Image.file(
            File(widget.image),
            width: widget.imageWidth,
            height: widget.imageHeight,
            fit: widget.fit,
          ),
        )
    );
  }
}


class AppIconButton extends StatefulWidget {
  var icon,iconColor,iconSize,onPressed;

  AppIconButton(this.icon, {this.iconSize=24.0, this.iconColor=Colors.grey,this.onPressed,});

  @override
  _AppIconButtonState createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  var width;
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: widget.onPressed,
        icon: AppIcon(widget.icon,iconColor: widget.iconColor,iconSize: widget.iconSize,)
    );
  }
}


class AppIcon extends StatefulWidget {
  var icon,iconColor,iconSize;

  AppIcon(this.icon,{this.iconColor=GlobalVariables.grey,this.iconSize=24.0});

  @override
  _AppIconState createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {

  @override
  Widget build(BuildContext context) {
    return Icon(
          widget.icon,
          color: widget.iconColor,
          size: double.parse(widget.iconSize.toString()),
        );
  }
}
