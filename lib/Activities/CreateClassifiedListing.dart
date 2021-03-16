import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/OwnerClassifiedResponse.dart';
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

class CreateClassifiedListingState
    extends BaseStatefulState<BaseCreateClassifiedListing> {
  var name = "", mobile = "", mail = "", photo = "";

  Map<String, String> imagesMap = Map<String, String>();

  List<String> imagePathList = List<String>();
  List<String> imagePathKeyList = List<String>();

  var width, height;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _propertyController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _localityController = TextEditingController();
  //TextEditingController _cityController = TextEditingController();
  TextEditingController _pinCodeController = TextEditingController();

  List<DropdownMenuItem<String>> _categoryListItems =
      new List<DropdownMenuItem<String>>();
  String _categorySelectedItem;

  List<String> _categoryItemTypeList = new List<String>();
  List<DropdownMenuItem<String>> _categoryItemTypeListItems =
      new List<DropdownMenuItem<String>>();
  String _categoryItemTypeSelectedItem;

  List<DropdownMenuItem<String>> _cityItemListItems =
      new List<DropdownMenuItem<String>>();
  String _cityItemSelectedItem;

  List<String> imgBinaryList =  List<String>();

  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    getSharedPrefData();
    getCategoryItemTypeData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return ChangeNotifierProvider<OwnerClassifiedResponse>.value(
        value: Provider.of<OwnerClassifiedResponse>(context),
        child: Consumer<OwnerClassifiedResponse>(
          builder: (context, value, child) {
            print('ownerClassifiedCategoryList Value : ' +
                value.ownerClassifiedCategoryList.length.toString());
            _categoryListItems = new List<DropdownMenuItem<String>>();
            for (int i = 0; i < value.ownerClassifiedCategoryList.length; i++) {
              _categoryListItems.add(DropdownMenuItem(
                value: value.ownerClassifiedCategoryList[i].Category_Name,
                child: Text(
                  value.ownerClassifiedCategoryList[i].Category_Name,
                  style: TextStyle(color: GlobalVariables.black),
                ),
              ));
            }
            _cityItemListItems = new List<DropdownMenuItem<String>>();
            for (int i = 0; i < value.cityList.length; i++) {
              _cityItemListItems.add(DropdownMenuItem(
                value: value.cityList[i].city,
                child: Text(
                  value.cityList[i].city,
                  style: TextStyle(color: GlobalVariables.black),
                ),
              ));
            }
            return Scaffold(
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
              body: getBaseLayout(value),
            );
          },
        ));
  }

  getBaseLayout(OwnerClassifiedResponse value) {
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
                getCreateClassifiedListingLayout(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getCreateClassifiedListingLayout(OwnerClassifiedResponse value) {
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
                    items: _categoryListItems,
                    value: _categorySelectedItem,
                    onChanged: (value) {
                      setState(() {
                        _categorySelectedItem = value;
                        print(
                            '_categorySelectedItem : ' + _categorySelectedItem);
                      });
                    },
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context)
                              .translate('select_category') +
                          "*",
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
                    items: _categoryItemTypeListItems,
                    value: _categoryItemTypeSelectedItem,
                    onChanged: (value) {
                      setState(() {
                        _categoryItemTypeSelectedItem = value;
                        print('_categoryItemTypeSelectedItem : ' +
                            _categoryItemTypeSelectedItem);
                      });
                    },
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('i_want_to') + "*",
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                    ),
                  ),
                ),
              ),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('title_selling') +
                        "*",
                controllerCallback: _titleController,
                borderWidth: 2.0,
              ),
              Container(
                  height: 150,
                  child: AppTextField(
                    textHintContent: AppLocalizations.of(context)
                            .translate('description_selling') +
                        "*",
                    controllerCallback: _descriptionController,
                    borderWidth: 2.0,
                    maxLines: 99,
                    contentPadding: EdgeInsets.only(
                      top: 10,
                    ),
                  )),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('property_details') +
                        "*",
                controllerCallback: _propertyController,
                borderWidth: 2.0,
              ),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('rs') + "*",
                controllerCallback: _priceController,
                borderWidth: 2.0,
                keyboardType: TextInputType.number,
              ),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('address') + "*",
                controllerCallback: _addressController,
                borderWidth: 2.0,
              ),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('locality') + "*",
                controllerCallback: _localityController,
                borderWidth: 2.0,
              ),
              Row(
                children: [
                  Flexible(
                      child: AppTextField(
                    textHintContent:
                        AppLocalizations.of(context).translate('pin_code') +
                            "*",
                    controllerCallback: _pinCodeController,
                    borderWidth: 2.0,
                    keyboardType: TextInputType.number,
                  )),
                  SizedBox(
                    width: 5.0,
                  ),
                  Flexible(
                    child: Container(
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
                          items: _cityItemListItems,
                          value: _cityItemSelectedItem,
                          onChanged: (value) {
                            setState(() {
                              _cityItemSelectedItem = value;
                              print('_cityItemSelectedItem : ' +
                                  _cityItemSelectedItem);
                            });
                          },
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: GlobalVariables.mediumGreen,
                          ),
                          underline: SizedBox(),
                          hint: Text(
                            AppLocalizations.of(context).translate('city') +
                                "*",
                            style: TextStyle(
                                color: GlobalVariables.lightGray, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                        if (value.length > 5) {
                          GlobalFunctions.showToast(
                              'Can not upload more than 5 images');
                        } else {
                          if (imagesMap.length == 0) {
                            imagesMap = value;
                          } else {
                            if (imagesMap.length + value.length > 5) {
                              GlobalFunctions.showToast(
                                  'Can not upload more than 5 images');
                            } else {
                              imagesMap.addAll(value);
                            }
                          }
                          imagePathList =
                              imagesMap.entries.map((e) => (e.value)).toList();
                          imagePathKeyList =
                              imagesMap.entries.map((e) => (e.key)).toList();
                          print('imagesMap : ' + imagesMap.length.toString());
                          print('imagePathList : ' +
                              imagePathList.length.toString());
                          print('imagePathList : ' + imagePathList.toString());
                          print('imagePathKeyList : ' +
                              imagePathKeyList.length.toString());
                          imgBinaryList = new List(imagePathList.length);
                          for (int i = 0; i < imagePathList.length; i++) {
                            GlobalFunctions.getTemporaryDirectoryPath()
                                .then((value) {
                              print('cache file Path : ' + value.toString());
                              GlobalFunctions.getFilePathOfCompressImage(
                                      imagePathList[i],
                                      value.toString() +
                                          '/' +
                                          imagePathKeyList[i])
                                  .then((value) {
                                print('Cache file path : ' + value);
                                imgBinaryList[i] =
                                    GlobalFunctions.convertFileToString(value);
                                print('imgBinaryList : ' +
                                    imgBinaryList.length.toString());
                                print('imgBinaryList : ' +
                                    imgBinaryList.toString());
                              });
                            });
                          }
                          print('imgBinaryList : ' + imgBinaryList.toString());
                          setState(() {});
                        }
                      });
                    },
                    icon: Icon(
                      Icons.camera_alt,
                      color: GlobalVariables.white,
                    ),
                    label: Text(
                      AppLocalizations.of(context).translate('add_photo'),
                      style: TextStyle(color: GlobalVariables.white),
                    )),
              ),
              imagesMap.length > 0 && imagePathList.length > 0
                  ? Container(
                      height: width / 5,
                      margin: EdgeInsets.fromLTRB(5, 10, 5, 5),
                      child: Builder(
                          builder: (context) => ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imagesMap.length,
                                itemBuilder: (context, position) {
                                  return GestureDetector(
                                    onLongPress: () {
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
                                                  decoration: boxDecoration(
                                                      color: GlobalVariables
                                                          .transparent,
                                                      radius: 16,
                                                      bgColor: GlobalVariables
                                                          .transparent),
                                                  child: InkWell(
                                                      onTap: () {
                                                        imagesMap.remove(
                                                            imagePathKeyList[
                                                                position]);
                                                        imagePathList
                                                            .removeAt(position);
                                                        imagePathKeyList
                                                            .removeAt(position);
                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {
                                                          print('imagesMap : ' +
                                                              imagesMap.length
                                                                  .toString());
                                                          print('imagePathList : ' +
                                                              imagePathList
                                                                  .length
                                                                  .toString());
                                                          print('imagePathKeyList : ' +
                                                              imagePathKeyList
                                                                  .length
                                                                  .toString());
                                                        });
                                                      },
                                                      child: Icon(
                                                        Icons.delete,
                                                        size: 25,
                                                        color: GlobalVariables
                                                            .white,
                                                      )),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      child: ClipRRect(
                                        child: Image.file(
                                          File(imagePathList[position]),
                                          width: width / 5,
                                          height: width / 5,
                                          fit: BoxFit.fill,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                //  scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                              )),
                    )
                  : Container(),
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
                      photo.isEmpty
                          ? Image.asset(
                              GlobalVariables.componentUserProfilePath,
                              width: 26,
                              height: 26,
                            )
                          : CircleAvatar(
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
                              text(name,
                                  textColor: GlobalVariables.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: GlobalVariables.textSizeMedium,
                                  textStyleHeight: 1.0),
                              text(mail,
                                  textColor: GlobalVariables.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: GlobalVariables.textSizeSmall,
                                  textStyleHeight: 1.0),
                              text(mobile,
                                  textColor: GlobalVariables.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: GlobalVariables.textSizeSmall,
                                  textStyleHeight: 1.0),
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
                child: AppButton(
                  textContent: AppLocalizations.of(context).translate('submit'),
                  onPressed: () {
                    verifyData(value);
                  },
                ),
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

    setState(() {});
  }

  void getCategoryItemTypeData() {
    _categoryItemTypeList = ["Buy", "Sell", "Rent", "Giveaway"];
    for (int i = 0; i < _categoryItemTypeList.length; i++) {
      _categoryItemTypeListItems.add(DropdownMenuItem(
        value: _categoryItemTypeList[i],
        child: Text(
          _categoryItemTypeList[i],
          style: TextStyle(color: GlobalVariables.black),
        ),
      ));
    }
    //   _selectedLivesHere = __livesHereListItems[0].value;
    setState(() {});
  }

  void verifyData(OwnerClassifiedResponse value) {
    print('verifyData imgBinaryList.length : ' + imgBinaryList.length.toString());
    print('verifyData imgBinaryList : ' + imgBinaryList.toString());

    if (_categorySelectedItem != null) {
      if (_categoryItemTypeSelectedItem != null) {
        if (_titleController.text.length > 0) {
          if (_descriptionController.text.length > 0) {
            if (_propertyController.text.length > 0) {
              if (_priceController.text.length > 0) {
                if (_addressController.text.length > 0) {
                  if (_localityController.text.length > 0) {
                    if (_cityItemSelectedItem != null) {
                      if (_pinCodeController.text.length > 0) {
                        if (imgBinaryList.length > 0) {
                          _progressDialog.show();
                          Provider.of<OwnerClassifiedResponse>(context,
                                  listen: false)
                              .insertClassifiedData(
                                  name,
                                  mail,
                                  mobile,
                                  _categorySelectedItem,
                                  _categoryItemTypeSelectedItem,
                                  _titleController.text,
                                  _descriptionController.text,
                                  _propertyController.text,
                                  _priceController.text,
                                  _localityController.text,
                                  _cityItemSelectedItem,
                                  imgBinaryList,
                                  _addressController.text,
                                  _pinCodeController.text)
                              .then((value) {
                            // print('insert value : '+ value.toString());
                            // print('insert value : '+ value.status.toString());
                            // print('insert value : '+ value.message.toString());
                            GlobalFunctions.showToast(value.message);
                            _progressDialog.hide();
                            if (value.status) {
                              GlobalFunctions.getTemporaryDirectoryPath()
                                  .then((value) {
                                GlobalFunctions.removeAllFilesFromDirectory(
                                    value);
                              });
                              Navigator.of(context).pop();
                            }
                          });
                        } else {
                          GlobalFunctions.showToast(
                              "Please select at least one Photo");
                        }
                      } else {
                        GlobalFunctions.showToast("Please Enter PinCode");
                      }
                    } else {
                      GlobalFunctions.showToast("Please Enter City");
                    }
                  } else {
                    GlobalFunctions.showToast("Please Enter Address");
                  }
                } else {
                  GlobalFunctions.showToast("Please Enter Locality");
                }
              } else {
                GlobalFunctions.showToast("Please Enter Price");
              }
            } else {
              GlobalFunctions.showToast("Please Enter Property Details");
            }
          } else {
            GlobalFunctions.showToast("Please Enter Description");
          }
        } else {
          GlobalFunctions.showToast("Please Enter Title");
        }
      } else {
        GlobalFunctions.showToast("Please Select I want to");
      }
    } else {
      GlobalFunctions.showToast("Please Select Category");
    }
  }
}
