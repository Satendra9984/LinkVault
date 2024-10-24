package com.example.link_vault

import io.flutter.embedding.android.FlutterActivity

import android.net.Uri
import android.os.Bundle
import androidx.browser.customtabs.CustomTabsClient
import androidx.browser.customtabs.CustomTabsServiceConnection
import androidx.browser.customtabs.CustomTabsSession
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CUSTOM_TABS_CLIENT_CHANNEL = "custom_tabs_client"
    private var customTabsClient: CustomTabsClient? = null
    private var customTabsSession: CustomTabsSession? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CUSTOM_TABS_CLIENT_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "warmUp" -> {
                    warmUpBrowser()
                    result.success(true)
                }
                "mayLaunchUrl" -> {
                    val url = call.argument<String>("url")
                    result.success(mayLaunchUrl(url))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun warmUpBrowser() {
        CustomTabsClient.bindCustomTabsService(this, "com.android.chrome", object : CustomTabsServiceConnection() {
            override fun onCustomTabsServiceConnected(name: android.content.ComponentName, client: CustomTabsClient) {
                customTabsClient = client
                customTabsSession = client.newSession(null)
                customTabsClient?.warmup(0)
            }

            override fun onServiceDisconnected(name: android.content.ComponentName) {
                customTabsClient = null
            }
        })
    }

    private fun mayLaunchUrl(url: String?): Boolean {
        return customTabsSession?.mayLaunchUrl(Uri.parse(url), null, null) ?: false
    }
}
