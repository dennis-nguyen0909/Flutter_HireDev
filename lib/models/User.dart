class User {
  final String id;
  final List<SocialLink> socialLinks;
  final String avatarCompany;
  final String bannerCompany;
  final String companyName;
  final Organization organization;

  User({
    required this.id,
    required this.socialLinks,
    required this.avatarCompany,
    required this.bannerCompany,
    required this.companyName,
    required this.organization,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<SocialLink> socialLinksList = [];
    if (json['social_links'] != null) {
      socialLinksList = List<SocialLink>.from(
        json['social_links'].map((link) => SocialLink.fromJson(link)),
      );
    }

    return User(
      id: json['_id'] ?? '',
      socialLinks: socialLinksList,
      avatarCompany: json['avatar_company'] ?? '',
      bannerCompany: json['banner_company'] ?? '',
      companyName: json['company_name'] ?? '',
      organization: Organization.fromJson(json['organization'] ?? {}),
    );
  }
}

class SocialLink {
  final String id;
  final String userId;
  final String type;
  final String url;
  final String createdAt;
  final String updatedAt;
  final int v;

  SocialLink({
    required this.id,
    required this.userId,
    required this.type,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }
}

class Organization {
  final String id;
  final String owner;
  final String industryType;
  final String organizationType;
  final String yearOfEstablishment;
  final String teamSize;
  final String companyWebsite;
  final String companyVision;
  final String createdAt;
  final String updatedAt;
  final int v;

  Organization({
    required this.id,
    required this.owner,
    required this.industryType,
    required this.organizationType,
    required this.yearOfEstablishment,
    required this.teamSize,
    required this.companyWebsite,
    required this.companyVision,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['_id'] ?? '',
      owner: json['owner'] ?? '',
      industryType: json['industry_type'] ?? '',
      organizationType: json['organization_type'] ?? '',
      yearOfEstablishment: json['year_of_establishment'] ?? '',
      teamSize: json['team_size'] ?? '',
      companyWebsite: json['company_website'] ?? '',
      companyVision: json['company_vision'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }
}
