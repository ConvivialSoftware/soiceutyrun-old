package com.societyrun12;

import com.societyrun12.FirebaseCloudMessagingPluginRegistrant;

import androidx.annotation.NonNull;
import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;
import be.tramckrijte.workmanager.WorkmanagerPlugin;
//import in.jvapps.system_alert_window.SystemAlertWindowPlugin;

public class Application extends FlutterApplication implements PluginRegistrantCallback {

    @Override
    public void onCreate() {
        super.onCreate();
        FlutterFirebaseMessagingService.setPluginRegistrant(this);
        WorkmanagerPlugin.setPluginRegistrantCallback(this);
       // SystemAlertWindowPlugin.setPluginRegistrant(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {

        FirebaseCloudMessagingPluginRegistrant.registerWith(registry);
    }
}