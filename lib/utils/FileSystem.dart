import 'package:file_picker/file_picker.dart';

abstract class FileSystemBase {
  void onFileSelected(String? filePath);
  void onFilePickCancelled();
  void onFilePickError(dynamic error);
}

class FileSystem {
  static Future<String?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        String? filePath = result.files.single.path;
        print('File path: $filePath'); // Print the file path for debugging
        return filePath;
      } else {
        // User canceled the picker
        print('User canceled file picker');
        return null;
      }
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }
}

// Example of a class that uses FileSystem
class FileUploader implements FileSystemBase {
  String? _filePath;

  Future<void> selectFile() async {
    String? filePath = await FileSystem.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (filePath != null) {
      onFileSelected(filePath);
    } else {
      onFilePickCancelled();
    }
  }

  @override
  void onFileSelected(String? filePath) {
    _filePath = filePath;
    // Implement file upload logic here
  }

  @override
  void onFilePickCancelled() {
    // Handle cancellation
  }

  @override
  void onFilePickError(error) {
    // Handle error
  }
}
