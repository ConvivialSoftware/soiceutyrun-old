
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations{

  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of (BuildContext context){
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String,String> _localizedStrings;

  Future<bool> load() async {

    print('Load() : '+ locale.languageCode);
    print('Path : '+'i18n/${locale.languageCode}.json');
    String jsonString = await rootBundle.loadString('i18n/${locale.languageCode}.json');
   // print('jsonString : '+jsonString);
    Map<String,dynamic> jsonMap = json.decode(jsonString);
   // print('jsonMap : '+jsonMap.toString());
    _localizedStrings = jsonMap.map((key, value) {

   //   print('_localizedStrings : '+ _localizedStrings.toString());

      return MapEntry(key,value.toString());
    });
    return true;
  }

  String translate(String key){
    return _localizedStrings[key];
  }

}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations>{

  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // TODO: implement isSupported
    return ['en','hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async{
    // TODO: implement load
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    // TODO: implement shouldReload
    return false;
  }

}