package com.example.tfi_bagundali

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.tfi_bagundali/whatsapp_share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "shareImageToWhatsApp" -> {
                    val filePath = call.argument<String>("filePath")
                    val caption = call.argument<String>("caption") ?: ""
                    val toStatus = call.argument<Boolean>("toStatus") ?: true
                    if (filePath == null) {
                        result.error("BAD_ARGS", "filePath required", null)
                        return@setMethodCallHandler
                    }
                    shareImageToWhatsApp(filePath, caption, toStatus, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun shareImageToWhatsApp(
        filePath: String,
        caption: String,
        @Suppress("UNUSED_PARAMETER") toStatus: Boolean,
        result: MethodChannel.Result,
    ) {
        val pm = applicationContext.packageManager
        val whatsappPackage = "com.whatsapp"
        try {
            pm.getPackageInfo(whatsappPackage, 0)
        } catch (_: Exception) {
            result.error("WHATSAPP_NOT_INSTALLED", "WhatsApp is not installed", null)
            return
        }

        val file = File(filePath)
        val uri: Uri = FileProvider.getUriForFile(
            applicationContext,
            "${applicationContext.packageName}.provider",
            file,
        )

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "image/*"
            putExtra(Intent.EXTRA_STREAM, uri)
            if (caption.isNotEmpty()) {
                putExtra(Intent.EXTRA_TEXT, caption)
            }
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            setPackage(whatsappPackage)
        }

        try {
            startActivity(intent)
            result.success(null)
        } catch (e: Exception) {
            result.error("SHARE_FAILED", e.message, null)
        }
    }
}
