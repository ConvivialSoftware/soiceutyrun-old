package com.societyrun12;


import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import be.tramckrijte.workmanager.WorkmanagerPlugin;
//import in.jvapps.system_alert_window.SystemAlertWindowPlugin;
import io.flutter.plugins.GeneratedPluginRegistrant;
//import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService;
//import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;

public class Application extends FlutterApplication implements PluginRegistrantCallback {

    @Override
    public void onCreate() {
        super.onCreate();
        //FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this);
        WorkmanagerPlugin.setPluginRegistrantCallback(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {
//        FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
//        FirebaseCloudMessagingPluginRegistrant.registerWith(registry);
    }
}