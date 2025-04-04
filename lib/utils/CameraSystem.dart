import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraSystem {
  final ImagePicker _picker = ImagePicker();

  // Hàm mở camera và chụp ảnh
  Future<XFile?> takePhoto(BuildContext context) async {
    try {
      // Mở camera để chụp ảnh
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      // Kiểm tra nếu người dùng đã chụp ảnh
      if (image != null) {
        return image;
      } else {
        // Nếu không có ảnh, trả về null
        return null;
      }
    } catch (e) {
      // Xử lý ngoại lệ nếu có lỗi khi mở camera
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi mở camera: $e")));
      return null;
    }
  }
}
