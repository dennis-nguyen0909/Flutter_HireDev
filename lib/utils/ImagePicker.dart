import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        print("Image path: ${pickedFile.path}"); // In đường dẫn ảnh
        return File(pickedFile.path);
      } else {
        print("No image selected");
        return null;
      }
    } catch (e) {
      print('Error picking image: $e'); // In chi tiết lỗi
      return null;
    }
  }

  Future<File?> pickImageFromCamera() async {
    return pickImage(ImageSource.camera);
  }

  Future<File?> pickImageFromGallery() async {
    return pickImage(ImageSource.gallery);
  }
}
