package com.example.my_first_app

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Tên channel phải trùng với MethodChannel khai báo trong lib/main.dart.
    private val channelName = "lab_a5/implicit_intents"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Đăng ký nơi nhận lệnh từ Flutter. Mỗi lần Flutter gọi invokeMethod,
        // đoạn when bên dưới sẽ kiểm tra tên method và mở Intent tương ứng.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "dial" -> {
                            // ACTION_DIAL mở màn hình gọi điện với số đã điền sẵn.
                            // Cách này không cần xin quyền CALL_PHONE.
                            val phone = call.argument<String>("phone").orEmpty()
                            startActivity(Intent(Intent.ACTION_DIAL, Uri.parse("tel:$phone")))
                            result.success(null)
                        }

                        "web" -> {
                            // ACTION_VIEW với URL sẽ nhờ trình duyệt hoặc app phù hợp mở trang web.
                            val url = call.argument<String>("url").orEmpty()
                            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                            result.success(null)
                        }

                        "share" -> {
                            // ACTION_SEND tạo implicit Intent chia sẻ văn bản.
                            // createChooser bắt Android hiện bảng chọn ứng dụng chia sẻ.
                            val subject = call.argument<String>("subject").orEmpty()
                            val text = call.argument<String>("text").orEmpty()
                            val intent = Intent(Intent.ACTION_SEND).apply {
                                type = "text/plain"
                                putExtra(Intent.EXTRA_SUBJECT, subject)
                                putExtra(Intent.EXTRA_TEXT, text)
                            }
                            startActivity(Intent.createChooser(intent, "Chia sẻ qua"))
                            result.success(null)
                        }

                        else -> result.notImplemented()
                    }
                } catch (error: ActivityNotFoundException) {
                    // Nếu emulator/máy thật không có app xử lý Intent, báo lỗi về Flutter
                    // để Flutter hiện SnackBar thay vì làm ứng dụng bị crash.
                    result.error("NO_ACTIVITY", "Máy chưa có ứng dụng phù hợp để mở", null)
                }
            }
    }
}
