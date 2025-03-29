import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/models/UserMode.dart'; // Import UserModel chung
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  final ApiService _apiService;
  final SecureStorageService secureStorageService = SecureStorageService();
  UserProvider(this._apiService);

  UserModel? get user => _user;

  String? get role => _user?.roleName;

  bool get isEmployer => _user?.roleName == 'EMPLOYER';
  bool get isCandidate => _user?.roleName == 'USER';

  Future<void> fetchUserDetails(String userId) async {
    print('Fetching user details for ID: $userId');
    try {
      final token = await secureStorageService.getAccessToken();
      print('Token obtained: $token');
      final userDetails = await _apiService.get(
        dotenv.env['API_URL']! + 'users/$userId',
        token: token,
      );
      print('User details response: $userDetails');
      if (userDetails != null) {
        print(userDetails['data']['items']);
        _user = UserModel.fromJson(userDetails['data']['items']);
        print('User object after parsing: $_user');
        notifyListeners();
        print('UserProvider notified listeners');
      } else {
        print('User details is null');
        _user = null;
        notifyListeners();
      }
    } catch (error) {
      print('Error fetching user details in UserProvider: $error');
      _user = null;
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
