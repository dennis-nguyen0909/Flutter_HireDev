import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FacebookLoginScreen extends StatefulWidget {
  @override
  _FacebookLoginScreenState createState() => _FacebookLoginScreenState();
}

class _FacebookLoginScreenState extends State<FacebookLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập với Facebook')),
      body: WebView(
        initialUrl: dotenv.env['API_LOGIN_FACEBOOK'],
        javascriptMode: JavascriptMode.unrestricted,
        onPageStarted: (String url) {
          // Xử lý khi WebView chuyển trang
          print('Đang tải trang: $url');
          if (url.contains("redirect-uri")) {
            // Kiểm tra URL và lấy mã token hoặc thông tin đăng nhập
            // Sau khi thành công, bạn có thể điều hướng về trang chính hoặc làm các hành động tiếp theo
            Navigator.pop(context); // Đóng WebView
          }
        },
        onWebViewCreated: (WebViewController webViewController) {
          // Xử lý khi WebView được tạo
        },
        onPageFinished: (String url) {
          // Xử lý khi trang WebView đã tải xong
        },
      ),
    );
  }
}
