import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocxWebView extends StatelessWidget {
  final String docxUrl;

  DocxWebView({required this.docxUrl});

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://docs.google.com/viewer?url=$docxUrl',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}

// Sử dụng:
// DocxWebView(docxUrl: 'YOUR_DOCX_URL'),
