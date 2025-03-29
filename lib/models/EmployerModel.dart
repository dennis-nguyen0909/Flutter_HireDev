class EmployerModel {
  final String? id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? address;
  final int? gender;
  final Role? role;
  final dynamic accountType; // Có thể là null hoặc kiểu dữ liệu khác
  final List<dynamic>? viewer;
  final bool? isActive;
  final bool? toggleDashboard;
  final bool? toggleFilter;
  final bool? isSearchJobsStatus;
  final bool? isSuggestionJob;
  final List<AuthProvider>? authProviders;
  final List<dynamic>? saveJobIds;
  final List<dynamic>? educationIds;
  final List<FavoriteJob>? favoriteJobs;
  final List<dynamic>? skills;
  final List<dynamic>? certificates;
  final List<dynamic>? prizes;
  final List<dynamic>? courses;
  final List<dynamic>? cvs;
  final List<dynamic>? projects;
  final List<dynamic>? workExperienceIds;
  final List<String>? jobsIds;
  final List<SocialLink>? socialLinks;
  final ProgressSetup? progressSetup;
  final int? otpAttempts;
  final bool? isOtpVerified;
  final bool? isRememberAccount;
  final String? dateFormat;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final DateTime? lastOtpSentAt;
  final dynamic otpCode;
  final String? otpExpiry;
  final dynamic otpVerifiedAt;
  final String? avatarCompany;
  final dynamic cityId;
  final dynamic districtId;
  final dynamic wardId;
  final String? bannerCompany;
  final String? companyName;
  final String? description;
  final Organization? organization;
  final bool? isProfilePrivacy;
  final bool? isResumePrivacy;
  final bool? notificationWhenEmployerRejectCv;
  final bool? notificationWhenEmployerSaveProfile;

  EmployerModel({
    this.id,
    this.email,
    this.fullName,
    this.phone,
    this.address,
    this.gender,
    this.role,
    this.accountType,
    this.viewer,
    this.isActive,
    this.toggleDashboard,
    this.toggleFilter,
    this.isSearchJobsStatus,
    this.isSuggestionJob,
    this.authProviders,
    this.saveJobIds,
    this.educationIds,
    this.favoriteJobs,
    this.skills,
    this.certificates,
    this.prizes,
    this.courses,
    this.cvs,
    this.projects,
    this.workExperienceIds,
    this.jobsIds,
    this.socialLinks,
    this.progressSetup,
    this.otpAttempts,
    this.isOtpVerified,
    this.isRememberAccount,
    this.dateFormat,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.lastOtpSentAt,
    this.otpCode,
    this.otpExpiry,
    this.otpVerifiedAt,
    this.avatarCompany,
    this.cityId,
    this.districtId,
    this.wardId,
    this.bannerCompany,
    this.companyName,
    this.description,
    this.organization,
    this.isProfilePrivacy,
    this.isResumePrivacy,
    this.notificationWhenEmployerRejectCv,
    this.notificationWhenEmployerSaveProfile,
  });

  factory EmployerModel.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['data']?['items'];
    if (itemsJson == null) {
      return EmployerModel(); // Hoặc xử lý trường hợp không có dữ liệu
    }

    var authProvidersList = itemsJson['auth_providers'] as List<dynamic>?;
    List<AuthProvider>? authProviders =
        authProvidersList?.map((item) => AuthProvider.fromJson(item)).toList();

    var favoriteJobsList = itemsJson['favorite_jobs'] as List<dynamic>?;
    List<FavoriteJob>? favoriteJobs =
        favoriteJobsList?.map((item) => FavoriteJob.fromJson(item)).toList();

    var socialLinksList = itemsJson['social_links'] as List<dynamic>?;
    List<SocialLink>? socialLinks =
        socialLinksList?.map((item) => SocialLink.fromJson(item)).toList();

    return EmployerModel(
      id: itemsJson['_id'] as String?,
      email: itemsJson['email'] as String?,
      fullName: itemsJson['full_name'] as String?,
      phone: itemsJson['phone'] as String?,
      address: itemsJson['address'] as String?,
      gender: itemsJson['gender'] as int?,
      role: itemsJson['role'] != null ? Role.fromJson(itemsJson['role']) : null,
      accountType: itemsJson['account_type'],
      viewer: itemsJson['viewer'] as List<dynamic>?,
      isActive: itemsJson['is_active'] as bool?,
      toggleDashboard: itemsJson['toggle_dashboard'] as bool?,
      toggleFilter: itemsJson['toggle_filter'] as bool?,
      isSearchJobsStatus: itemsJson['is_search_jobs_status'] as bool?,
      isSuggestionJob: itemsJson['is_suggestion_job'] as bool?,
      authProviders: authProviders,
      saveJobIds: itemsJson['save_job_ids'] as List<dynamic>?,
      educationIds: itemsJson['education_ids'] as List<dynamic>?,
      favoriteJobs: favoriteJobs,
      skills: itemsJson['skills'] as List<dynamic>?,
      certificates: itemsJson['certificates'] as List<dynamic>?,
      prizes: itemsJson['prizes'] as List<dynamic>?,
      courses: itemsJson['courses'] as List<dynamic>?,
      cvs: itemsJson['cvs'] as List<dynamic>?,
      projects: itemsJson['projects'] as List<dynamic>?,
      workExperienceIds: itemsJson['work_experience_ids'] as List<dynamic>?,
      jobsIds:
          (itemsJson['jobs_ids'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList(),
      socialLinks: socialLinks,
      progressSetup:
          itemsJson['progress_setup'] != null
              ? ProgressSetup.fromJson(itemsJson['progress_setup'])
              : null,
      otpAttempts: itemsJson['otpAttempts'] as int?,
      isOtpVerified: itemsJson['isOtpVerified'] as bool?,
      isRememberAccount: itemsJson['isRememberAccount'] as bool?,
      dateFormat: itemsJson['dateFormat'] as String?,
      createdAt:
          itemsJson['createdAt'] != null
              ? DateTime.parse(itemsJson['createdAt'])
              : null,
      updatedAt:
          itemsJson['updatedAt'] != null
              ? DateTime.parse(itemsJson['updatedAt'])
              : null,
      v: itemsJson['__v'] as int?,
      lastOtpSentAt:
          itemsJson['lastOtpSentAt'] != null
              ? DateTime.parse(itemsJson['lastOtpSentAt'])
              : null,
      otpCode: itemsJson['otpCode'],
      otpExpiry: itemsJson['otpExpiry'] as String?,
      otpVerifiedAt: itemsJson['otpVerifiedAt'],
      avatarCompany: itemsJson['avatar_company'] as String?,
      cityId: itemsJson['city_id'],
      districtId: itemsJson['district_id'],
      wardId: itemsJson['ward_id'],
      bannerCompany: itemsJson['banner_company'] as String?,
      companyName: itemsJson['company_name'] as String?,
      description: itemsJson['description'] as String?,
      organization:
          itemsJson['organization'] != null
              ? Organization.fromJson(itemsJson['organization'])
              : null,
      isProfilePrivacy: itemsJson['is_profile_privacy'] as bool?,
      isResumePrivacy: itemsJson['is_resume_privacy'] as bool?,
      notificationWhenEmployerRejectCv:
          itemsJson['notification_when_employer_reject_cv'] as bool?,
      notificationWhenEmployerSaveProfile:
          itemsJson['notification_when_employer_save_profile'] as bool?,
    );
  }
}

class Role {
  final List<dynamic>? rolePermission;
  final String? id;
  final String? roleName;

  Role({this.rolePermission, this.id, this.roleName});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      rolePermission: json['role_permission'] as List<dynamic>?,
      id: json['_id'] as String?,
      roleName: json['role_name'] as String?,
    );
  }
}

class AuthProvider {
  final String? id;
  final String? providerName;
  final String? providerId;

  AuthProvider({this.id, this.providerName, this.providerId});

  factory AuthProvider.fromJson(Map<String, dynamic> json) {
    return AuthProvider(
      id: json['_id'] as String?,
      providerName: json['provider_name'] as String?,
      providerId: json['provider_id'] as String?,
    );
  }
}

class FavoriteJob {
  final String? id;
  final String? userId;
  final String? jobId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  FavoriteJob({
    this.id,
    this.userId,
    this.jobId,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory FavoriteJob.fromJson(Map<String, dynamic> json) {
    return FavoriteJob(
      id: json['_id'] as String?,
      userId: json['user_id'] as String?,
      jobId: json['job_id'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'] as int?,
    );
  }
}

class SocialLink {
  final String? id;
  final String? userId;
  final String? type;
  final String? url;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  SocialLink({
    this.id,
    this.userId,
    this.type,
    this.url,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      id: json['_id'] as String?,
      userId: json['user_id'] as String?,
      type: json['type'] as String?,
      url: json['url'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'] as int?,
    );
  }
}

class ProgressSetup {
  final bool? companyInfo;
  final bool? foundingInfo;
  final bool? socialInfo;
  final bool? contact;
  final String? id;

  ProgressSetup({
    this.companyInfo,
    this.foundingInfo,
    this.socialInfo,
    this.contact,
    this.id,
  });

  factory ProgressSetup.fromJson(Map<String, dynamic> json) {
    return ProgressSetup(
      companyInfo: json['company_info'] as bool?,
      foundingInfo: json['founding_info'] as bool?,
      socialInfo: json['social_info'] as bool?,
      contact: json['contact'] as bool?,
      id: json['_id'] as String?,
    );
  }
}

class Organization {
  final String? id;
  final String? owner;
  final String? industryType;
  final String? organizationType;
  final String? yearOfEstablishment;
  final String? teamSize;
  final String? companyWebsite;
  final String? companyVision;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Organization({
    this.id,
    this.owner,
    this.industryType,
    this.organizationType,
    this.yearOfEstablishment,
    this.teamSize,
    this.companyWebsite,
    this.companyVision,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['_id'] as String?,
      owner: json['owner'] as String?,
      industryType: json['industry_type'] as String?,
      organizationType: json['organization_type'] as String?,
      yearOfEstablishment: json['year_of_establishment'] as String?,
      teamSize: json['team_size'] as String?,
      companyWebsite: json['company_website'] as String?,
      companyVision: json['company_vision'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'] as int?,
    );
  }
}
