//package com.societyrun12;
//
//import io.flutter.plugin.common.PluginRegistry;
//import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;
//import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
//import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
//import io.flutter.plugins.pathprovider.PathProviderPlugin;
//import com.tekartik.sqflite.SqflitePlugin;
//import be.tramckrijte.workmanager.WorkmanagerPlugin;
////import in.jvapps.system_alert_window.SystemAlertWindowPlugin;
//
//public final class FirebaseCloudMessagingPluginRegistrant{
//    public static void registerWith(PluginRegistry registry) {
//        if (alreadyRegisteredWith(registry)) {
//            return;
//        }
//        FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
//        FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
//        SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
//        PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
//        SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
//        WorkmanagerPlugin.registerWith(registry.registrarFor("be.tramckrijte.workmanager.WorkmanagerPlugin"));
//      //  SystemAlertWindowPlugin.registerWith(registry.registrarFor("in.jvapps.system_alert_window"));
//    }
//
//    private static boolean alreadyRegisteredWith(PluginRegistry registry) {
//        final String key = FirebaseCloudMessagingPluginRegistrant.class.getCanonicalName();
//        if (registry.hasPlugin(key)) {
//            return true;
//        }
//        registry.registrarFor(key);
//        return false;
//    }
//}