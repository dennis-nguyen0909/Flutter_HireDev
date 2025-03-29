import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Khởi tạo FlutterSecureStorage
  final _storage = FlutterSecureStorage();

  // Khóa cho token
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  // Lưu token
  Future<void> saveToken(String accessToken, String refreshToken) async {
    await _storage.write(key: accessTokenKey, value: accessToken);
    await _storage.write(key: refreshTokenKey, value: refreshToken);
  }

  // Lấy token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }

  // Xóa token
  Future<void> removeTokens() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: userIdKey);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: accessTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: refreshTokenKey);
  }
}
