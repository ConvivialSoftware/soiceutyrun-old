
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class AppLanguage extends ChangeNotifier{

  Locale _appLocale = Locale('en');

  Locale get appLocal => _appLocale;

  fetchLocale() async{

    var pref = await SharedPreferences.getInstance();
    if(pref.getString(GlobalVariables.keyLanguageCode)==null){
      _appLocale= Locale('en');
      return _appLocale;
    }
    _appLocale = Locale(pref.getString(GlobalVariables.keyLanguageCode)!);
    return _appLocale;

  }


  void changeLanguage(Locale type) async{

    var pref = await SharedPreferences.getInstance();
    if(_appLocale==type){
      return;
    }
    if(type==Locale('hi')){
      _appLocale = Locale('hi');
      await pref.setString(GlobalVariables.keyLanguageCode, 'hi');
    }else{
      _appLocale = Locale('en');
      await pref.setString(GlobalVariables.keyLanguageCode, 'en');
    }
    notifyListeners();
  }

}