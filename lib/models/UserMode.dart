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
  final String? companyName;
  final String? description;
  final bool? toggleDashboard;
  final bool? toggleFilter;
  final bool? isSearchJobsStatus;
  final bool? isSuggestionJob;
  final List<dynamic>? favoriteJobs;
  final List<dynamic>? skills;
  final List<dynamic>? certificates;
  final List<dynamic>? prizes;
  final List<dynamic>? courses;
  final List<dynamic>? cvs;
  final List<dynamic>? saveJobIds;
  final List<dynamic>? educationIds;
  final List<dynamic>? workExperienceIds;
  final String? background;
  final String? introduce;
  final String? portFolio;
  final String? birthday;
  final bool? noExperience;
  final int? totalExperienceMonths;
  final int? totalExperienceYears;
  final Map<String, dynamic>? cityId;
  final Map<String, dynamic>? districtId;
  final Map<String, dynamic>? wardId;
  final String? nameCity;
  final String? nameDistrict;
  final String? nameWard;
  final bool? isProfilePrivacy;
  final bool? isResumePrivacy;
  final bool? notificationWhenEmployerSaveProfile;
  final bool? notificationWhenEmployerRejectCv;

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
    this.toggleDashboard,
    this.toggleFilter,
    this.isSearchJobsStatus,
    this.isSuggestionJob,
    this.favoriteJobs,
    this.skills,
    this.certificates,
    this.prizes,
    this.courses,
    this.cvs,
    this.saveJobIds,
    this.educationIds,
    this.workExperienceIds,
    this.background,
    this.introduce,
    this.portFolio,
    this.birthday,
    this.noExperience,
    this.totalExperienceMonths,
    this.totalExperienceYears,
    this.cityId,
    this.districtId,
    this.wardId,
    this.nameCity,
    this.nameDistrict,
    this.nameWard,
    this.isProfilePrivacy,
    this.isResumePrivacy,
    this.notificationWhenEmployerSaveProfile,
    this.notificationWhenEmployerRejectCv,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("json: ${json['city_id']}");
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
      companyName: itemsJson['company_name'] as String?,
      description: itemsJson['description'] as String?,
      toggleDashboard: itemsJson['toggle_dashboard'] as bool?,
      toggleFilter: itemsJson['toggle_filter'] as bool?,
      isSearchJobsStatus: itemsJson['is_search_jobs_status'] as bool?,
      isSuggestionJob: itemsJson['is_suggestion_job'] as bool?,
      favoriteJobs: itemsJson['favorite_jobs'] as List<dynamic>?,
      skills: itemsJson['skills'] as List<dynamic>?,
      certificates: itemsJson['certificates'] as List<dynamic>?,
      prizes: itemsJson['prizes'] as List<dynamic>?,
      courses: itemsJson['courses'] as List<dynamic>?,
      cvs: itemsJson['cvs'] as List<dynamic>?,
      saveJobIds: itemsJson['save_job_ids'] as List<dynamic>?,
      educationIds: itemsJson['education_ids'] as List<dynamic>?,
      workExperienceIds: itemsJson['work_experience_ids'] as List<dynamic>?,
      background: itemsJson['background'] as String?,
      introduce: itemsJson['introduce'] as String?,
      portFolio: itemsJson['port_folio'] as String?,
      birthday: itemsJson['birthday'] as String?,
      noExperience: itemsJson['no_experience'] as bool?,
      totalExperienceMonths: itemsJson['total_experience_months'] as int?,
      totalExperienceYears: itemsJson['total_experience_years'] as int?,
      cityId: itemsJson['city_id'] as Map<String, dynamic>?,
      districtId: itemsJson['district_id'] as Map<String, dynamic>?,
      wardId: itemsJson['ward_id'] as Map<String, dynamic>?,
      nameCity: itemsJson['name_city'] as String?,
      nameDistrict: itemsJson['name_district'] as String?,
      nameWard: itemsJson['name_ward'] as String?,
      isProfilePrivacy: itemsJson['is_profile_privacy'] as bool?,
      isResumePrivacy: itemsJson['is_resume_privacy'] as bool?,
      notificationWhenEmployerSaveProfile:
          itemsJson['notification_when_employer_save_profile'] as bool?,
      notificationWhenEmployerRejectCv:
          itemsJson['notification_when_employer_reject_cv'] as bool?,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, roleName: $roleName, avatar: $avatar, phone: $phone, address: $address, gender: $gender, isActive: $isActive, companyName: $companyName, description: $description, cityId: $cityId, districtId: $districtId, wardId: $wardId, nameCity: $nameCity, nameDistrict: $nameDistrict, nameWard: $nameWard)';
  }
}
