package com.societyrun12

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentResolver
import android.graphics.PixelFormat
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.util.Log
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.Button
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        GeneratedPluginRegistrant.registerWith(flutterEngine);
//    }

    private val CHANNEL = "com.societyrun12/create_channel"
    private val CHANNEL_GATEPASS = "com.societyrun12/create_channel_gatepass"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->

            if (call.method == "createNotificationChannel") {
                val argData = call.arguments as java.util.HashMap<String, String>
                val completed = createNotificationChannel(argData)
                if (completed) {
                    result.success(completed)
                } else {
                    result.error("Error Code", "Error Message", null)
                }
            } else if (call.method == "createNotificationChannelForGatePass") {
                val argData = call.arguments as java.util.HashMap<String, Any>

                val mapData = createNotificationChannelForGatePass(argData);


            } else {
                result.notImplemented()
            }
        }

    }

    private fun createNotificationChannel(mapData: HashMap<String, String>): Boolean {
        val completed: Boolean
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Create the NotificationChannel
            val id = mapData["id"]
            val name = mapData["name"]
            val descriptionText = mapData["description"]
            //val sound = "alert.mp3"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val mChannel = NotificationChannel(id, name, importance)
            mChannel.description = descriptionText

            val soundUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + getApplicationContext().getPackageName() + "/" + R.raw.alert);
            val att = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build();

            mChannel.setSound(soundUri, att)
            // Register the channel with the system; you can't change the importance
            // or other notification behaviors after this
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(mChannel)
            completed = true
        } else {
            completed = false
        }
        return completed
    }

    private fun createNotificationChannelForGatePass(mapData: HashMap<String, Any>) : HashMap<String, String> {

        val successMap: HashMap<String, String> = hashMapOf()

        val params: WindowManager.LayoutParams = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                        or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                        or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
                        or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
                PixelFormat.TRANSLUCENT)

        val wm: WindowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        val inflater: LayoutInflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
        val myView: View = inflater.inflate(R.layout.gatepass, null)

        val approve = myView.findViewById<Button>(R.id.approve);
        val reject = myView.findViewById<Button>(R.id.reject);
        val wait = myView.findViewById<Button>(R.id.wait);

        approve.setOnClickListener {

            successMap["response"]="Approved";

        }

        reject.setOnClickListener {

            successMap["response"]="Rejected";

        }

        wait.setOnClickListener {

            successMap["response"]="Leave at Gate";

        }


        // Add layout to window manager

        // Add layout to window manager
        wm.addView(myView, params)


        return  successMap


    }

}
