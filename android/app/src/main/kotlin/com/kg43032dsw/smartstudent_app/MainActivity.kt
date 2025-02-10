package com.kg43032dsw.smartstudent_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.content.Intent
import android.provider.Settings
import android.app.NotificationManager
import android.content.Context
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val KANAL = "tryb_skupienia"
    private lateinit var menedzerPowiadomien: NotificationManager

    override fun configureFlutterEngine(silnik: FlutterEngine) {
        super.configureFlutterEngine(silnik)
        menedzerPowiadomien = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        MethodChannel(silnik.dartExecutor.binaryMessenger, KANAL).setMethodCallHandler { wywolanie, wynik ->
            when (wywolanie.method) {
                "wlaczTrybSkupienia" -> {
                    if (!menedzerPowiadomien.isNotificationPolicyAccessGranted) {
                        startActivity(Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS))
                    }
                    menedzerPowiadomien.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_NONE)
                    wynik.success(true)
                }
                "wylaczTrybSkupienia" -> {
                    menedzerPowiadomien.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
                    wynik.success(true)
                }
                else -> wynik.notImplemented()
            }
        }
    }
}