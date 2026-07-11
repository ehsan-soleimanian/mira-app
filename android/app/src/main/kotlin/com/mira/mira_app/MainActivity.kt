package com.mira.mira_app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Parcelable
import android.provider.OpenableColumns
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pendingSharedItem: Map<String, Any?>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // Report nav-bar insets to Flutter on Samsung / Android 15+ edge-to-edge.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialSharedItem" -> {
                        result.success(pendingSharedItem)
                        pendingSharedItem = null
                    }
                    else -> result.notImplemented()
                }
            }
        }
        pendingSharedItem = sharedItemFromIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val item = sharedItemFromIntent(intent) ?: return
        val methodChannel = channel
        if (methodChannel == null) {
            pendingSharedItem = item
        } else {
            methodChannel.invokeMethod("sharedItem", item)
        }
    }

    private fun sharedItemFromIntent(intent: Intent?): Map<String, Any?>? {
        if (intent == null) return null
        return when (intent.action) {
            Intent.ACTION_SEND -> {
                val type = intent.type.orEmpty()
                val stream = uriFromSendIntent(intent)
                if (type == "text/plain" && stream == null) {
                    textItem(intent.getStringExtra(Intent.EXTRA_TEXT))
                } else {
                    stream?.let { fileItem(it, type) }
                }
            }
            Intent.ACTION_SEND_MULTIPLE -> {
                val type = intent.type.orEmpty()
                firstUriFromSendMultipleIntent(intent)?.let { fileItem(it, type) }
            }
            else -> null
        }
    }

    private fun fileItem(uri: Uri, fallbackMime: String): Map<String, Any?>? {
        val bytes = contentResolver.openInputStream(uri)?.use { it.readBytes() } ?: return null
        val mimeType = contentResolver.getType(uri) ?: fallbackMime
        return mapOf(
            "type" to if (mimeType.startsWith("image/")) "image" else "file",
            "filename" to displayName(uri),
            "mimeType" to mimeType,
            "bytes" to bytes,
        )
    }

    private fun textItem(text: String?): Map<String, Any?>? {
        val cleaned = text?.trim().orEmpty()
        if (cleaned.isEmpty()) return null
        return mapOf(
            "type" to "text",
            "text" to cleaned,
        )
    }

    @Suppress("DEPRECATION")
    private fun uriFromSendIntent(intent: Intent): Uri? {
        val extra = intent.getParcelableExtra<Parcelable>(Intent.EXTRA_STREAM)
        return extra as? Uri ?: intent.clipData?.getItemAt(0)?.uri
    }

    @Suppress("DEPRECATION")
    private fun firstUriFromSendMultipleIntent(intent: Intent): Uri? {
        val extras = intent.getParcelableArrayListExtra<Parcelable>(Intent.EXTRA_STREAM)
        val first = extras?.firstOrNull() as? Uri
        return first ?: intent.clipData?.getItemAt(0)?.uri
    }

    private fun displayName(uri: Uri): String {
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (index >= 0 && cursor.moveToFirst()) {
                val name = cursor.getString(index)?.trim().orEmpty()
                if (name.isNotEmpty()) return name
            }
        }
        val fallback = uri.lastPathSegment?.substringAfterLast('/')?.trim().orEmpty()
        return fallback.ifEmpty { "mira-shared-image.jpg" }
    }

    private companion object {
        const val CHANNEL = "mira/shared_import"
    }
}
