import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/Activities/LoginPage.dart';
import 'package:societyrun/Activities/base_stateful.dart';

//import 'package:simple_permissions/simple_permissions.dart';
import 'package:societyrun/GlobalClasses/AppLanguage.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/LoginResponse.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class GlobalFunctions {
  static SharedPreferences sharedPreferences;

  static void showToast(String msg) {
    Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT);
  }

  static convertFutureToNormal(var futureKey) {
    print('futurekey: ' + futureKey.toString());
    var value;
    futureKey.then((val) {
      print('converted key : ' + val.toString());
      value = val;
    });
    print('converted final key : ' + value.toString());
    return value;
  }

  static getLoginValue() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyIsLogin)) {
      return sharedPreferences.getBool(GlobalVariables.keyIsLogin);
    } else {
      sharedPreferences.setBool(GlobalVariables.keyIsLogin, false);
      return sharedPreferences.getBool(GlobalVariables.keyIsLogin);
    }
  }

  static getUserName() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyUsername)) {
      print('username : ' +
          sharedPreferences.getString(GlobalVariables.keyUsername));
      return sharedPreferences.getString(GlobalVariables.keyUsername);
    }
    return "";
  }

  static getLoggedUserName() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences
        .getKeys()
        .contains(GlobalVariables.keyLoggedUsername)) {
      print('keyLoggedUsername : ' +
          sharedPreferences.getString(GlobalVariables.keyLoggedUsername));
      return sharedPreferences.getString(GlobalVariables.keyLoggedUsername);
    }
    return "";
  }

  static getFCMToken() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(
        Platform.isIOS ? GlobalVariables.TOKEN_ID : GlobalVariables.keyToken)) {
      return sharedPreferences.getString(
          Platform.isIOS ? GlobalVariables.TOKEN_ID : GlobalVariables.keyToken);
    }
    return "";
  }

  static getPassword() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyPassword)) {
      print('keyPassword : ' +
          sharedPreferences.getString(GlobalVariables.keyPassword));
      return sharedPreferences.getString(GlobalVariables.keyPassword);
    }
    return "";
  }

  static getDisplayName() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyName)) {
      print('display username : ' +
          sharedPreferences.getString(GlobalVariables.keyName));
      return sharedPreferences.getString(GlobalVariables.keyName);
    }
    return "";
  }

  static getMobile() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyMobile)) {
      print('display username : ' +
          sharedPreferences.getString(GlobalVariables.keyMobile));
      return sharedPreferences.getString(GlobalVariables.keyMobile);
    }
    return "";
  }

  static getUserId() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyUserId)) {
      print('display userid : ' +
          sharedPreferences.getString(GlobalVariables.keyUserId));
      return sharedPreferences.getString(GlobalVariables.keyUserId);
    }
    return "";
  }

  static getSocietyId() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keySocietyId)) {
      print('keySocietyId : ' +
          sharedPreferences.getString(GlobalVariables.keySocietyId));
      return sharedPreferences.getString(GlobalVariables.keySocietyId);
    }
    return "";
  }

  static getLoginId() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyId)) {
      print('keyId : ' + sharedPreferences.getString(GlobalVariables.keyId));
      return sharedPreferences.getString(GlobalVariables.keyId);
    }
    return "";
  }

  static getSocietyName() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keySocietyName)) {
      print('keySocietyId : ' +
          sharedPreferences.getString(GlobalVariables.keySocietyName));
      return sharedPreferences.getString(GlobalVariables.keySocietyName);
    }
    return "";
  }

  static getSocietyEmail() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyEmail)) {
      print('keySocietyId : ' +
          sharedPreferences.getString(GlobalVariables.keyEmail));
      return sharedPreferences.getString(GlobalVariables.keyEmail);
    }
    return "";
  }

  static getFlat() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyFlat)) {
      print(
          'keyFlat : ' + sharedPreferences.getString(GlobalVariables.keyFlat));
      return sharedPreferences.getString(GlobalVariables.keyFlat);
    }
    return "";
  }

  static getBlock() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyBlock)) {
      print('keyBlock : ' +
          sharedPreferences.getString(GlobalVariables.keyBlock));
      return sharedPreferences.getString(GlobalVariables.keyBlock);
    }
    return "";
  }

  static getConsumerID() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyConsumerId)) {
      print('keyConsumerId : ' +
          sharedPreferences.getString(GlobalVariables.keyConsumerId));
      return sharedPreferences.getString(GlobalVariables.keyConsumerId);
    }
    return "";
  }

  static getPhoto() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyPhoto)) {
      print('keyPhoto : ' +
          sharedPreferences.getString(GlobalVariables.keyPhoto));
      return sharedPreferences.getString(GlobalVariables.keyPhoto);
    }
    return "";
  }

  static getGoogleCoordinate() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences
        .getKeys()
        .contains(GlobalVariables.keyGoogleCoordinate)) {
      print('keyGoogleCoordinate : ' +
          sharedPreferences.getString(GlobalVariables.keyGoogleCoordinate));
      return sharedPreferences.getString(GlobalVariables.keyGoogleCoordinate);
    }
    return "";
  }

  static getSocietyPermission() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences
        .getKeys()
        .contains(GlobalVariables.keySocietyPermission)) {
      print('keySocietyPermission : ' +
          sharedPreferences.getString(GlobalVariables.keySocietyPermission));
      return sharedPreferences.getString(GlobalVariables.keySocietyPermission);
    }
    return "";
  }

  static getUserPermission() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences
        .getKeys()
        .contains(GlobalVariables.keyUserPermission)) {
      print('keyUserPermission : ' +
          sharedPreferences.getString(GlobalVariables.keyUserPermission));
      return sharedPreferences.getString(GlobalVariables.keyUserPermission);
    }
    return "";
  }

  static getDailyEntryNotification() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences
        .getKeys()
        .contains(GlobalVariables.keyDailyEntryNotification)) {
      print('keyDailyEntryNotification : ' +
          sharedPreferences
              .getBool(GlobalVariables.keyDailyEntryNotification)
              .toString());
      return sharedPreferences
          .getBool(GlobalVariables.keyDailyEntryNotification);
    }
    return true;
  }

  static getGuestEntryNotification() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences
        .getKeys()
        .contains(GlobalVariables.keyGuestEntryNotification)) {
      print('keyGuestEntryNotification : ' +
          sharedPreferences
              .getBool(GlobalVariables.keyGuestEntryNotification)
              .toString());
      return sharedPreferences
          .getBool(GlobalVariables.keyGuestEntryNotification);
    }
    return true;
  }

  static getInAppCallNotification() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences
        .getKeys()
        .contains(GlobalVariables.keyInAppCallNotification)) {
      print('keyInAppCallNotification : ' +
          sharedPreferences
              .getBool(GlobalVariables.keyInAppCallNotification)
              .toString());
      return sharedPreferences
          .getBool(GlobalVariables.keyInAppCallNotification);
    }
    return true;
  }

  static Future<void> setInAppCallNotification(
      bool inAppCallNotification) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(
        GlobalVariables.keyInAppCallNotification, inAppCallNotification);
  }

  static Future<void> setDailyEntryNotification(
      bool dailyEntryNotification) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(
        GlobalVariables.keyDailyEntryNotification, dailyEntryNotification);
  }

  static Future<void> setGuestEntryNotification(
      bool guestEntryNotification) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(
        GlobalVariables.keyGuestEntryNotification, guestEntryNotification);
  }

  static getIsNewlyArrivedNotification() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences
        .getKeys()
        .contains(GlobalVariables.keyIsNewlyArrivedNotification)) {
      print('getIsNewlyArrivedNotification : ' +
          sharedPreferences
              .getBool(GlobalVariables.keyIsNewlyArrivedNotification)
              .toString());
      return sharedPreferences
          .getBool(GlobalVariables.keyIsNewlyArrivedNotification);
    }
    return false;
  }

  static Future<void> setIsNewlyArrivedNotification(
      bool isNewlyArrivedNotification) async {
    sharedPreferences = await SharedPreferences.getInstance();
    print('setIsNewlyArrivedNotification : ' +
        isNewlyArrivedNotification.toString());
    sharedPreferences.setBool(GlobalVariables.keyIsNewlyArrivedNotification,
        isNewlyArrivedNotification);
  }

  static getUserType() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getKeys().contains(GlobalVariables.keyUserType)) {
      print('display keyUserType : ' +
          sharedPreferences.getString(GlobalVariables.keyUserType));
      return sharedPreferences.getString(GlobalVariables.keyUserType);
    }
    return "";
  }

  static getAppLanguage() async {
    AppLanguage appLanguage = AppLanguage();
    Locale _appLocale = await appLanguage.fetchLocale();
    return _appLocale;
  }

  static bool verifyLoginData(String username, String password) {
    if (username.length > 0 && password.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  static Future<void> saveDataToSharedPreferences(LoginResponse value) async {
    print('saveDataToSharedPreferences');
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(GlobalVariables.keyIsLogin, true);
    sharedPreferences.setString(GlobalVariables.keyId, value.ID);
    sharedPreferences.setString(GlobalVariables.keyUserId, value.USER_ID);
    sharedPreferences.setString(GlobalVariables.keySocietyId, value.SOCIETY_ID);
    sharedPreferences.setString(GlobalVariables.keyBlock, value.BLOCK);
    sharedPreferences.setString(GlobalVariables.keyFlat, value.FLAT);
    sharedPreferences.setString(GlobalVariables.keyUsername, value.USER_NAME);
    sharedPreferences.setString(GlobalVariables.keyPassword, value.PASSWORD);
    sharedPreferences.setString(GlobalVariables.keyMobile, value.MOBILE);
    sharedPreferences.setString(GlobalVariables.keyUserType, value.TYPE);
    sharedPreferences.setString(
        GlobalVariables.keySocietyName, value.Society_Name);
    sharedPreferences.setString(
        GlobalVariables.keySocietyAddress, value.Address);
    sharedPreferences.setString(GlobalVariables.keyEmail, value.Email);
    sharedPreferences.setString(
        GlobalVariables.keySocietyPermission, value.society_Permissions);
    sharedPreferences.setString(GlobalVariables.keyName, value.Name);
    sharedPreferences.setString(
        GlobalVariables.keyStaffQRImage, value.Staff_QR_Image);
    sharedPreferences.setString(GlobalVariables.keyPhoto, value.Photo);
    sharedPreferences.setString(
        GlobalVariables.keyUserPermission, value.Permissions);
    sharedPreferences.setString(
        GlobalVariables.keyConsumerId, value.Consumer_no);
    sharedPreferences.setString(
        GlobalVariables.keyLoggedUsername, value.LoggedUsername);
    sharedPreferences.setString(
        GlobalVariables.keyGoogleCoordinate, value.google_parameter);
    GlobalVariables.userNameValueNotifer.value = value.Name;
    GlobalVariables.userImageURLValueNotifer.value = value.Photo;
    GlobalVariables.userImageURLValueNotifer.notifyListeners();
    GlobalVariables.userNameValueNotifer.notifyListeners();
  }

  static Future<void> savePasswordToSharedPreferences(String password) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(GlobalVariables.keyPassword, password);
  }

  static Future<void> saveDisplayUserNameToSharedPreferences(
      String userName) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(GlobalVariables.keyName, userName);
  }

  static Future<void> saveUserProfileToSharedPreferences(
      String profilePic) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(GlobalVariables.keyPhoto, profilePic);
  }

  static Future<void> saveFCMToken(String token) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(
        Platform.isIOS ? GlobalVariables.TOKEN_ID : GlobalVariables.keyToken,
        token);
  }

  static backIconLayoutAndImplementation(BuildContext context, String title) {
    return Container(
      color: GlobalVariables.white,
      margin:
          EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 20, 0, 0),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
            //  color: GlobalVariables.grey,
            child: SizedBox(
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: GlobalVariables.green,
                    ))),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(
                  0, 0, MediaQuery.of(context).size.width / 10, 0),
              // color: GlobalVariables.green,
              alignment: Alignment.center,
              child: SizedBox(
                /*child: SvgPicture.asset(
                              GlobalVariables.overviewTxtPath,
                            )*/
                child: Text(
                  title,
                  style: TextStyle(
                      color: GlobalVariables.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static getAppHeaderWidgetWithoutAppIcon(BuildContext context, var height) {
    return Container(
      alignment: Alignment.topCenter,
      //color: GlobalVariables.black,
      height: height,
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: height,
          child: SvgPicture.asset(GlobalVariables.headerIconPath,
              width: MediaQuery.of(context).size.width, fit: BoxFit.fill)),
    );
  }

  static getAppHeaderWidget(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.topCenter,
          //color: GlobalVariables.black,
          height: MediaQuery.of(context).size.height / 4.2,
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SvgPicture.asset(GlobalVariables.headerIconPath,
                  width: MediaQuery.of(context).size.width, fit: BoxFit.fill)),
        ),
        Align(
          child: Container(
            margin: EdgeInsets.fromLTRB(
                0, MediaQuery.of(context).size.height / 8, 0, 0),
            child: SvgPicture.asset(
              GlobalVariables.appIconPath,
            ),
          ),
          alignment: AlignmentDirectional.topCenter,
        ),
      ],
    );
  }

  static getAppHeaderWidgetWithUserProfileImage(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SvgPicture.asset(
                GlobalVariables.headerIconPath,
                width: MediaQuery.of(context).size.width,
              )),
        ),
        Align(
          child: Container(
            margin: EdgeInsets.fromLTRB(
                0, MediaQuery.of(context).size.height / 8, 0, 0),
            child: SvgPicture.asset(
              GlobalVariables.appIconPath,
            ),
          ),
          alignment: AlignmentDirectional.topCenter,
        ),
      ],
    );
  }

  static getNormalProgressDialogInstance(BuildContext context) {
    ProgressDialog _progressDialog =
        ProgressDialog(context, type: ProgressDialogType.Normal);
    _progressDialog.style(
        message: "      Please Wait",
        borderRadius: 10.0,
        backgroundColor: GlobalVariables.mediumGreen,
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progressWidget: Center(
            // alignment: Alignment.center,
            child: CircularProgressIndicator()),
        messageTextStyle: TextStyle(
            color: GlobalVariables.white,
            fontSize: 14,
            fontWeight: FontWeight.bold));

    return _progressDialog;
  }

  static getDownLoadProgressDialogInstance(BuildContext context) {
    ProgressDialog _progressDialog =
        ProgressDialog(context, type: ProgressDialogType.Download);
    _progressDialog.style(
        message: "      Please Wait",
        borderRadius: 10.0,
        backgroundColor: GlobalVariables.mediumGreen,
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progressWidget: Center(
            // alignment: Alignment.center,
            child: CircularProgressIndicator()),
        messageTextStyle: TextStyle(
            color: GlobalVariables.white,
            fontSize: 14,
            fontWeight: FontWeight.bold));

    return _progressDialog;
  }

  static saveDuesDataToSharedPreferences(String duesRs, String duesDate) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(GlobalVariables.keyDuesRs, duesRs);
    sharedPreferences.setString(GlobalVariables.keyDuesDate, duesDate);
  }

  static getSharedPreferenceDuesData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> map = Map<String, String>();
    map = {
      GlobalVariables.keyDuesRs:
          sharedPreferences.getString(GlobalVariables.keyDuesRs.toString()),
      GlobalVariables.keyDuesDate:
          sharedPreferences.getString(GlobalVariables.keyDuesDate.toString()),
    };
    print('dues map : ' + map.toString());
    return map;
  }

  static getSelectedDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();

    print('selected year : ' + selectedDate.year.toString());

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(selectedDate.year - 50),
        lastDate: DateTime(3021));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
    }
    return selectedDate;
  }

  static getSelectedDateForDOB(BuildContext context) async {
    DateTime selectedDate = DateTime.now();

    print('selected year : ' + selectedDate.year.toString());

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(selectedDate.year - 50),
        lastDate:
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
    }
    return selectedDate;
  }

  static Future<String> getFilePath(BuildContext context) async {
    return await FilePicker.getFilePath(
      type: FileType.any,
      allowCompression: true,
      allowedExtensions: ['jpg', 'jgpe', 'png'],
      /*allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '')?.split(',')
            : null*/
    );
    /*FilePickerResult result = await FilePicker.platform.pickFiles(allowMultiple: false);

    print('FilePickerResult : '+result.toString());
    print('result.files.single.path : '+result.files.single.path.toString());

    return result.files.single.path;*/
  }

  static Future<Map<String,String>> getMultiFilePath(BuildContext context) async {

    var result = await FilePicker.getMultiFilePath(
      type: FileType.custom,
      allowCompression: true,
      allowedExtensions: ['jpg', 'jgpe', 'png'],
      /*allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '')?.split(',')
            : null*/
    );
    print('getMultiFilePath result : '+result.toString());

    return result;
  }

  static String convertFileToString(String attachmentFilePath) {
    final bytes = File(attachmentFilePath).readAsBytesSync();

    String str64 = base64Encode(bytes);

    return str64;
  }

  static void gtFileSize(String path) {
    print('Before Compress : ' + File(path).lengthSync().toString());
  }

  static Future<String> getFilePathOfCompressImage(
      String path, String targetPath) async {
    print('Path : ' + path.toString());
    print('targetPath : ' + targetPath.toString());
    var format = CompressFormat.jpeg;
    if (path.endsWith(".png")) {
      format = CompressFormat.png;
    } else if ((path.endsWith(".jpg") || path.endsWith(".jpeg"))) {
      format = CompressFormat.jpeg;
    } else if (path.endsWith(".heic")) {
      format = CompressFormat.heic;
    } else if (path.endsWith(".webp")) {
      format = CompressFormat.webp;
    }
    var _imageFile = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: 60,
      rotate: 360,
      minWidth: 400,
      format: format,
    );
    print('After Compress : ' + _imageFile.lengthSync().toString());
    return _imageFile.path;
  }

  static removeFileFromDirectory(String path) {
    final dir = Directory(path);
    dir.deleteSync(recursive: true);
  }

  static Future<String> localPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> getTemporaryDirectoryPath() async {
    Directory tempDir = await getTemporaryDirectory();

    return tempDir.path;
  }

  /* static Future<bool> isExternalStoragePermission() async {
    PermissionStatus permissionResult = await SimplePermissions.requestPermission(Permission. WriteExternalStorage);
    if (permissionResult == PermissionStatus.authorized){
      // code of read or write file in external storage (SD card)
      return true;
    }
    return false;
  }
*/

  static Future<String> downloadAttachment(var url, var _localPath) async {
    String localPath = _localPath + Platform.pathSeparator + "Download";
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    print("path >>> $localPath");
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: localPath,
      headers: {"auth": "test_for_sql_encoding"},
      //fileName: "SocietyRunImage/Document",
      showNotification: true,
      // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
    return taskId;
  }

  Future<bool> _openDownloadedFile(String id) {
    return FlutterDownloader.open(taskId: id);
  }

  static Future<void> shareData(var title, var text) async {
    await FlutterShare.share(title: title, text: text, chooserTitle: title);
  }

  static Future<void> clearSharedPreferenceData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }

  static String convertDateFormat(String date, String format) {
    String newDate;
    var dFormat = DateFormat(format);
    DateTime oldDate = DateTime.parse(date);
    newDate = dFormat.format(oldDate);

    return newDate;
  }

  static Future<File> openCamera() async {
    final picker = ImagePicker();
    final picture = await picker.getImage(source: ImageSource.camera);
    return File(picture.path);
  }

  static Future<bool> checkPermission(Permission permission) async {
    bool status = false;
    var _permissionStatus = await permission.status;
    if (_permissionStatus.isGranted) {
      status = true;
    }
    return status;
  }

  static Future<bool> askPermission(Permission permission) async {
    bool status = false;
    await permission.request().then((value) {
      if (value.isGranted) {
        status = true;
      }
    });
    return status;
  }

  static comingSoonDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          margin: EdgeInsets.all(20),
                          child: Image.asset(
                            GlobalVariables.comingSoonPath,
                            fit: BoxFit.fitWidth,
                          )),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('coming_soon_text'),
                          style: TextStyle(
                              color: GlobalVariables.black, fontSize: 18),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }));
  }

  static getDaysFromDate(String fromDate, String toDate) {
    DateTime toDateTime = DateTime.parse(toDate);
    DateTime fromDateTime = DateTime.parse(fromDate);
    final differenceInDays = fromDateTime.difference(toDateTime).inDays;

    return differenceInDays;
  }

  static forceLogoutDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return WillPopScope(
                onWillPop: () {},
                child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: SvgPicture.asset(
                            GlobalVariables.deactivateIconPath,
                            width: 60,
                            height: 60,
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(15, 25, 15, 15),
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('account_deactivate'),
                              style: TextStyle(
                                fontSize: 16,
                                color: GlobalVariables.black,
                              ),
                            )),
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width / 2,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: ButtonTheme(
                            //minWidth: MediaQuery.of(context).size.width / 2,
                            child: RaisedButton(
                              color: GlobalVariables.green,
                              onPressed: () {
                                DashBoardState.logout(context);
                              },
                              textColor: GlobalVariables.white,
                              //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side:
                                      BorderSide(color: GlobalVariables.green)),
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('logout'),
                                style: TextStyle(
                                    fontSize: GlobalVariables.textSizeMedium),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }

  static appUpdateDialog(BuildContext context, String appType) {
    bool isCompulsory = false;
    if (appType == 'Compulsary') {
      isCompulsory = true;
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return WillPopScope(
                onWillPop: () {
                  if (!isCompulsory) {
                    Navigator.of(context).pop();
                  }
                  return;
                },
                child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: Image.asset(
                            GlobalVariables.appLogoPath,
                            width: 80,
                            height: 80,
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 25, 0, 15),
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('app_update'),
                              style: TextStyle(
                                fontSize: 16,
                                color: GlobalVariables.black,
                              ),
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Visibility(
                              visible: isCompulsory ? false : true,
                              child: Container(
                                height: 50,
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: ButtonTheme(
                                  //minWidth: MediaQuery.of(context).size.width / 2,
                                  child: RaisedButton(
                                    color: GlobalVariables.green,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    textColor: GlobalVariables.white,
                                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                            color: GlobalVariables.green)),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('later'),
                                      style: TextStyle(
                                          fontSize:
                                              GlobalVariables.textSizeMedium),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 50,
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: ButtonTheme(
                                //minWidth: MediaQuery.of(context).size.width / 2,
                                child: RaisedButton(
                                  color: GlobalVariables.green,
                                  onPressed: () {
                                    if (!isCompulsory) {
                                      Navigator.of(context).pop();
                                    }
                                    String url =
                                        'https://play.google.com/store/apps/details?id=' +
                                            AppPackageInfo.packageName;
                                    //String url = 'market://details?id=" '+ AppPackageInfo.packageName;
                                    if (canLaunch(url) != null) launch(url);
                                  },
                                  textColor: GlobalVariables.white,
                                  //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: GlobalVariables.green)),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('update'),
                                    style: TextStyle(
                                        fontSize:
                                            GlobalVariables.textSizeMedium),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }

  static getAppPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    AppPackageInfo.appName = packageInfo.appName;
    AppPackageInfo.packageName = packageInfo.packageName;
    AppPackageInfo.version = packageInfo.version;
    AppPackageInfo.buildNumber = packageInfo.buildNumber;
    print('appName : ' + AppPackageInfo.appName);
    print('packageName : ' + AppPackageInfo.packageName);
    print('version : ' + AppPackageInfo.version);
    print('buildNumber : ' + AppPackageInfo.buildNumber);
  }

  static isDateGrater(String generateDate) {
    DateTime earlier = DateTime.parse(generateDate);
    earlier = earlier.add(Duration(minutes: 1));
    print('earlier : ' + earlier.toIso8601String());
    DateTime now = new DateTime.now();

    print('now : ' + now.toIso8601String());
    print('isBefore : ' + earlier.isBefore(now.toUtc()).toString());
    //assert(earlier.isBefore(now.toUtc()));
    //assert(earlier.toUtc().isBefore(now));
    if (earlier.isBefore(now.toUtc())) {
      return true;
    }

    return false;
  }

  static isDateSameOrGrater(String generateDate) {
    DateTime earlier = DateTime.parse(generateDate);
    //  print('earlier : '+ earlier.toIso8601String());
    DateTime now = new DateTime.now();
    DateTime currentDate = new DateTime(now.year, now.month, now.day);
    //  print('now : '+ now.toIso8601String());
    // print('isBefore : '+earlier.isBefore(now.toUtc()).toString());
    //   print('currentDate.difference(earlier).inDays : '+currentDate.difference(earlier).inDays.toString());
    if (currentDate.difference(earlier).inDays == 0) {
      // print('In currentDate.difference(earlier).inDays==0 Condition');
      return false;
    } else {
      if (earlier.isBefore(now.toUtc())) {
        return true;
      }
    }

    return false;
  }

  static isDateExpireForPoll(String generateDate) {
    DateTime earlier = DateTime.parse(generateDate);
    //  print('earlier : '+ earlier.toIso8601String());
    DateTime now = new DateTime.now();
    DateTime currentDate = new DateTime(now.year, now.month, now.day);
    //  print('now : '+ now.toIso8601String());
    // print('isBefore : '+earlier.isBefore(now.toUtc()).toString());
    //   print('currentDate.difference(earlier).inDays : '+currentDate.difference(earlier).inDays.toString());
    if (currentDate.difference(earlier).inDays == 0) {
      // print('In currentDate.difference(earlier).inDays==0 Condition');
      return true;
    } else {
      if (earlier.isBefore(now.toUtc())) {
        return true;
      }
    }

    return false;
  }

  static isAllowForRunApp() async {
    String username = await getUserName();
    String mobile = await getMobile();
    String loggedUsername = await getLoggedUserName();

    if (username.length == 0 &&
        mobile.length == 0 &&
        loggedUsername.length == 0) {
      return false;
    }
    return true;
  }

  static notAllowForRunAppDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return WillPopScope(
                onWillPop: () {
                  return;
                },
                child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: SvgPicture.asset(
                            GlobalVariables.anxietyIconPath,
                            width: 80,
                            height: 80,
                          ),
                        ),
                        Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.fromLTRB(0, 25, 0, 15),
                            child: Text(
                              AppLocalizations.of(context).translate('oops'),
                              style: TextStyle(
                                  fontSize: 18,
                                  color: GlobalVariables.green,
                                  fontWeight: FontWeight.bold),
                            )),
                        Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('not_allow_run_app'),
                              style: TextStyle(
                                fontSize: 16,
                                color: GlobalVariables.black,
                              ),
                            )),
                        Container(
                          alignment: Alignment.topRight,
                          height: 50,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: ButtonTheme(
                            //minWidth: MediaQuery.of(context).size.width / 2,
                            child: RaisedButton(
                              color: GlobalVariables.green,
                              onPressed: () {
                                clearSharedPreferenceData();
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            BaseLoginPage()),
                                    (Route<dynamic> route) => false);
                              },
                              textColor: GlobalVariables.white,
                              //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side:
                                      BorderSide(color: GlobalVariables.green)),
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('logout'),
                                style: TextStyle(
                                    fontSize: GlobalVariables.textSizeMedium),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }

  static setBaseContext(BuildContext context) {
    print('BaseContext is  : ' + context.toString());
    BaseStatefulState.setCtx(context);
  }

  static contactChairPersonForPermissionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          //margin: EdgeInsets.all(20),
                          child: SvgPicture.asset(
                        GlobalVariables.verifiedContactIconPath,
                        color: GlobalVariables.green,
                        width: 80,
                        height: 80,
                      )),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('contact_for_permission_text'),
                          style: TextStyle(
                              color: GlobalVariables.grey, fontSize: 16),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }));
  }

  static changeStatusColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setStatusBarColor(color, animate: true);
      FlutterStatusbarcolor.setStatusBarWhiteForeground(
          useWhiteForeground(color));
    } on Exception catch (e) {
      print(e);
    }
  }

/*static void checkRedirectFromBackgroundNotification(BuildContext context) {
    print('before isBackgroundNotification : '+GlobalVariables.isBackgroundNotification.toString());
    if(GlobalVariables.isBackgroundNotification) {
      GlobalVariables.isBackgroundNotification = false;
      print('after isBackgroundNotification : '+GlobalVariables.isBackgroundNotification.toString());
      Navigator.of(context).pop();
    }
  }*/

}
