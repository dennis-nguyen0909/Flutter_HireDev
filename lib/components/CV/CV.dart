import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

class CV extends StatefulWidget {
  final String name;
  final String link;
  final String id;
  final Function(String) onSelected; // Changed to accept only String id
  final bool isSelected;

  const CV({
    super.key,
    required this.name,
    required this.link,
    required this.id,
    required this.onSelected,
    required this.isSelected,
  });

  @override
  State<CV> createState() => _CVState();
}

class _CVState extends State<CV> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onSelected(widget.id); // Notify parent when tapped
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
                widget.isSelected
                    ? AppColors.primaryColor
                    : Colors.transparent, // Red border if selected
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _openPdf(context, widget.link);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: Color(0xFFDA4156),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Xem chi tiết'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPdf(BuildContext context, String pdfUrl) async {
    // ... (mã mở PDF như cũ)
    try {
      final response = await http.get(Uri.parse(pdfUrl));
      final bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;
      final fileName = path.basename(pdfUrl);
      final file = File('$tempPath/$fileName');

      await file.writeAsBytes(bytes);

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
                body: PDFView(filePath: file.path),
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể mở tệp PDF: $e')));
    }
  }
}
