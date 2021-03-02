import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseCreateClassifiedListing extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CreateClassifiedListingState();
  }
}

class CreateClassifiedListingState extends BaseStatefulState<BaseCreateClassifiedListing> {
  var name="", mobile="", mail="",photo="";

  Map<String, String> imagesMap=Map<String, String>();

  List<String> imagePathList=List<String>();
  List<String> imagePathKeyList=List<String>();

  var width,height;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _propertyController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _localityController = TextEditingController();
  TextEditingController _cityController = TextEditingController();


  @override
  void initState() {
    super.initState();
    getSharedPrefData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back,
              color: GlobalVariables.white,
            ),
          ),
          title: Text(
            AppLocalizations.of(context).translate('create_listing'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 200.0),
                getCreateClassifiedListingLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getCreateClassifiedListingLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 40),
        padding: EdgeInsets.all(
            20), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  AppLocalizations.of(context).translate('add_new_listing'),
                  style: TextStyle(
                      color: GlobalVariables.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 2.0,
                    )),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: null,
                    onChanged: null,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('select_category')+"*",
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 2.0,
                    )),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: null,
                    onChanged: null,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('i_want_to')+"*",
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                    ),
                  ),
                ),
              ),
              AppTextField(textHintContent: AppLocalizations.of(context).translate('title_selling')+"*", controllerCallback: _titleController,borderWidth: 2.0,),
              Container(height: 150, child: AppTextField(textHintContent: AppLocalizations.of(context).translate('description_selling')+"*", controllerCallback: _descriptionController,borderWidth: 2.0,maxLines: 99,contentPadding: EdgeInsets.only(top: 10,),)),
              AppTextField(textHintContent: AppLocalizations.of(context).translate('property_details')+"*", controllerCallback: _propertyController,borderWidth: 2.0,),
              AppTextField(textHintContent: AppLocalizations.of(context).translate('rs')+"*", controllerCallback: _priceController,borderWidth: 2.0,keyboardType: TextInputType.number,),
              Row(
                children: [
                  Flexible(child: AppTextField(textHintContent: AppLocalizations.of(context).translate('locality')+"*", controllerCallback: _localityController,borderWidth: 2.0,)),
                  SizedBox(width: 5.0,),
                  Flexible(child: AppTextField(textHintContent: AppLocalizations.of(context).translate('city')+"*", controllerCallback: _cityController,borderWidth: 2.0,)),
                ],
              ),
              Container(
                width: 140,
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.mediumGreen,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.transparent,
                      width: 3.0,
                    )),
                child: FlatButton.icon(
                    onPressed: () {
                      GlobalFunctions.getMultiFilePath(context).then((value) {

                        if(value.length>5){
                          GlobalFunctions.showToast('Can not upload more than 5 images');
                        }else {
                          if(imagesMap.length==0) {
                            imagesMap = value;
                          }else{
                            if(imagesMap.length+value.length>5){
                              GlobalFunctions.showToast('Can not upload more than 5 images');
                            }else {
                              imagesMap.addAll(value);
                            }
                          }
                          imagePathList = imagesMap.entries.map((e) => (e.value)).toList();
                          imagePathKeyList = imagesMap.entries.map((e) => (e.key)).toList();
                          print('imagesMap : ' + imagesMap.length.toString());
                          print('imagePathList : ' + imagePathList.length.toString());
                          print('imagePathKeyList : ' + imagePathKeyList.length.toString());
                          setState(() {
                          });
                        }
                      });
                    },
                    icon: Icon(
                      Icons.camera_alt,
                      color: GlobalVariables.white,
                    ),
                    label: Text(
                      AppLocalizations.of(context)
                          .translate('add_photo'),
                      style: TextStyle(color: GlobalVariables.white),
                    )),
              ),
              imagesMap.length>0 && imagePathList.length>0 ? Container(
                height: width / 5,
                margin:EdgeInsets.fromLTRB(5,10,5,5),
                child: Builder(
                    builder: (context) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagesMap.length,
                      itemBuilder: (context, position) {
                        return GestureDetector(
                          onLongPress: (){
                            showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (BuildContext context) {
                                  return Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      Container(
                                        width: 100,
                                        height: 50,
                                        decoration: boxDecoration(color: GlobalVariables.transparent, radius: 16, bgColor: GlobalVariables.transparent),
                                        child: InkWell(
                                            onTap: (){
                                              imagesMap.remove(imagePathKeyList[position]);
                                              imagePathList.removeAt(position);
                                              imagePathKeyList.removeAt(position);
                                              Navigator.of(context).pop();
                                              setState(() {
                                                print('imagesMap : ' + imagesMap.length.toString());
                                                print('imagePathList : ' + imagePathList.length.toString());
                                                print('imagePathKeyList : ' + imagePathKeyList.length.toString());
                                              });
                                            },
                                            child: Icon(Icons.delete,size: 25,color: GlobalVariables.white,)),
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: Container(
                            margin: EdgeInsets.all(5),
                            child: ClipRRect(
                              child: Image.file(File(imagePathList[position]),width: width/5,height: width/5,fit: BoxFit.fill,),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
              ):Container(),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: boxDecoration(
                    bgColor: GlobalVariables.white,
                    radius: 10,
                    color: GlobalVariables.mediumGreen,
                    width: 2.0),
                child: Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.only(left: 5),
                  child: Row(
                    children: <Widget>[
                      photo.isEmpty ? Image.asset(
                        GlobalVariables.componentUserProfilePath,
                        width: 26,
                        height: 26,
                      ): CircleAvatar(
                        radius: 13,
                        backgroundColor: GlobalVariables.mediumGreen,
                        backgroundImage: NetworkImage(photo),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          padding: EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              text(name,textColor: GlobalVariables.green,fontWeight: FontWeight.bold,fontSize: GlobalVariables.textSizeMedium,textStyleHeight: 1.0),
                              text(mail,textColor: GlobalVariables.grey,fontWeight: FontWeight.bold,fontSize: GlobalVariables.textSizeSmall,textStyleHeight: 1.0),
                              text(mobile,textColor: GlobalVariables.grey,fontWeight: FontWeight.bold,fontSize: GlobalVariables.textSizeSmall,textStyleHeight: 1.0),
                            ],
                          ),
                        ),
                      ),
                      /*Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                            color:GlobalVariables.green,
                            borderRadius: BorderRadius.circular(30)),
                        child:Icon(Icons.edit,color: GlobalVariables.white,size: 20,)
                      ),*/
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                height: 45,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: AppButton(textContent: AppLocalizations.of(context).translate('submit'),onPressed: (){

                },),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getSharedPrefData() async {

    name = await GlobalFunctions.getDisplayName();
    mail = await GlobalFunctions.getUserName();
    mobile = await GlobalFunctions.getMobile();
    photo = await GlobalFunctions.getPhoto();

    setState(() {

    });
  }
}
