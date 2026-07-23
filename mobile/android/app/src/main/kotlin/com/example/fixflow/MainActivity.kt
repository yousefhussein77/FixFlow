package com.example.fixflow

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val photoRequestCode = 7315
    private var pending: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fixflow/ticket_photos")
            .setMethodCallHandler { call, result -> handle(call, result) }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "pickPhotos") {
            result.notImplemented()
            return
        }
        if (pending != null) {
            result.error("PICK_IN_PROGRESS", "Photo selection is already open.", null)
            return
        }
        pending = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            type = "image/*"
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
            addCategory(Intent.CATEGORY_OPENABLE)
        }
        startActivityForResult(intent, photoRequestCode)
    }

    @Deprecated("Deprecated by Android; retained for FlutterActivity compatibility")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != photoRequestCode) return
        val result = pending ?: return
        pending = null
        if (resultCode != Activity.RESULT_OK || data == null) {
            result.success(emptyList<Map<String, Any>>())
            return
        }
        try {
            val uris = mutableListOf<Uri>()
            data.clipData?.let { clip ->
                for (index in 0 until minOf(clip.itemCount, 5)) {
                    uris.add(clip.getItemAt(index).uri)
                }
            } ?: data.data?.let(uris::add)
            val photos = uris.map { uri ->
                val mime = contentResolver.getType(uri) ?: "application/octet-stream"
                val name = uri.lastPathSegment?.substringAfterLast('/') ?: "photo"
                val bytes = contentResolver.openInputStream(uri)?.use { it.readBytes() }
                    ?: throw IllegalStateException("Photo could not be read.")
                mapOf("name" to name, "mimeType" to mime, "bytes" to bytes)
            }
            result.success(photos)
        } catch (_: Exception) {
            result.error("PHOTO_READ_FAILED", "The selected photo could not be read.", null)
        }
    }
}
