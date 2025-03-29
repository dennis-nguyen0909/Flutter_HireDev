class UserModel {
  final String? id;
  final String? email;
  final String? fullName;
  final String? roleName;
  final String? avatar;
  final String? phone;
  final String? address;
  final int? gender;
  final bool? isActive;
  final String? companyName; // Trường chung hoặc của Employer
  final String? description; // Trường chung hoặc của Employer
  // ... các trường chung khác

  UserModel({
    this.id,
    this.email,
    this.fullName,
    this.roleName,
    this.avatar,
    this.phone,
    this.address,
    this.gender,
    this.isActive,
    this.companyName,
    this.description,
    // ...
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('json: ${json}');
    var itemsJson = json;
    if (itemsJson == null) {
      return UserModel();
    }

    return UserModel(
      id: itemsJson['_id'] as String?,
      email: itemsJson['email'] as String?,
      fullName: itemsJson['full_name'] as String?,
      roleName: itemsJson['role']?['role_name'] as String?,
      avatar: itemsJson['avatar'] as String?,
      phone: itemsJson['phone'] as String?,
      address: itemsJson['address'] as String?,
      gender: itemsJson['gender'] as int?,
      isActive: itemsJson['is_active'] as bool?,
      companyName: itemsJson['company_name'] as String?, // Ánh xạ nếu có
      description: itemsJson['description'] as String?, // Ánh xạ nếu có
      // ... ánh xạ các trường chung khác
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, roleName: $roleName, avatar: $avatar, phone: $phone, address: $address, gender: $gender, isActive: $isActive, companyName: $companyName, description: $description)';
  }
}
