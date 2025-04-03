import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:webview_flutter/webview_flutter.dart'; // Import thư viện webview
import 'package:path/path.dart' as path;

class DocxPdfViewer {
  Future<Widget> generateViewerFromFile(
    String filePath,
    String fileName,
  ) async {
    try {
      final fileExtension = path.extension(fileName).toLowerCase();
      print(filePath);
      print(fileExtension);
      if (fileExtension == '.pdf') {
        // Use flutter_cached_pdfview for PDF files
        return PDF().fromUrl(
          filePath,
          placeholder:
              (progress) => Center(
                child: CircularProgressIndicator(value: progress / 100),
              ),
          errorWidget:
              (error) => Center(
                child: Text(
                  'Error loading PDF: $error',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, color: Colors.red),
                ),
              ),
        );
      } else if (fileExtension == '.docx' || fileExtension == '.doc') {
        // Use WebView for DOCX and DOC files
        return WebView(
          initialUrl:
              'https://docs.google.com/viewer?url=$filePath', // Sử dụng Google Docs Viewer
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            // _webViewController = webViewController;  // You can uncomment this if you need to access the controller later
          },
        );
      } else {
        return Center(
          child: Text(
            'Unsupported file type: $fileExtension',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
        );
      }
    } catch (e) {
      print("Document viewer error: $e");
      return Center(
        child: Text(
          'Error processing file: $e',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, color: Colors.red),
        ),
      );
    }
  }

  // Các phần còn lại của class DocxPdfViewer giữ nguyên
  void openDocumentViewer(
    BuildContext context,
    String filePath,
    String fileName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: Text(
                  'Xem chi tiết',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFDA4156), Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: buildViewer(filePath, fileName),
            ),
      ),
    );
  }

  Widget buildViewer(String filePath, String fileName) {
    return FutureBuilder<Widget>(
      future: generateViewerFromFile(filePath, fileName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return Center(child: Text('No data'));
        }
      },
    );
  }
}
