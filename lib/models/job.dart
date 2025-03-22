class Job {
  final String id;
  final User user;
  final String title;
  final City city;
  final District district;
  final ContractType contractType;
  final JobType jobType;
  final List<String> skillNames;
  final Level level;
  final DateTime expireDate;
  final MoneyType moneyType;
  final int countApply;
  final bool isNegotiable;
  final List<Skill> skills;
  final bool isActive;
  final bool isExpired;
  final List<String> candidateIds;
  final int salaryRangeMax;
  final int salaryRangeMin;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.user,
    required this.title,
    required this.city,
    required this.district,
    required this.contractType,
    required this.jobType,
    required this.skillNames,
    required this.level,
    required this.expireDate,
    required this.moneyType,
    required this.countApply,
    required this.isNegotiable,
    required this.skills,
    required this.isActive,
    required this.isExpired,
    required this.candidateIds,
    required this.salaryRangeMax,
    required this.salaryRangeMin,
    required this.createdAt,
  });
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['_id'],
      user: User.fromJson(json['user_id']),
      title: json['title'],
      city: City.fromJson(json['city_id']),
      district: District.fromJson(json['district_id']),
      contractType: ContractType.fromJson(json['job_contract_type']),
      jobType: JobType.fromJson(json['job_type']),
      skillNames: List<String>.from(json['skill_name']),
      level: Level.fromJson(json['level']),
      expireDate: DateTime.tryParse(json['expire_date']) ?? DateTime.now(),
      moneyType: MoneyType.fromJson(json['type_money']),
      countApply: json['count_apply'] ?? 0,
      isNegotiable: json['is_negotiable'] ?? false,
      skills:
          (json['skills'] as List)
              .map((skill) => Skill.fromJson(skill))
              .toList(),
      isActive: json['is_active'] ?? false,
      isExpired: json['is_expired'] ?? false,
      candidateIds: List<String>.from(json['candidate_ids'] ?? []),

      // Kiểm tra null cho 'salary_range_max' và 'salary_range_min'
      salaryRangeMax:
          json['salary_range_max'] != null
              ? (json['salary_range_max'] as num).toInt()
              : 0, // Giá trị mặc định nếu null
      salaryRangeMin:
          json['salary_range_min'] != null
              ? (json['salary_range_min'] as num).toInt()
              : 0, // Giá trị mặc định nếu null

      createdAt: DateTime.tryParse(json['createdAt']) ?? DateTime.now(),
    );
  }
}

class User {
  final String id;
  final String avatarCompany;
  final String companyName;

  User({
    required this.id,
    required this.avatarCompany,
    required this.companyName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      avatarCompany: json['avatar_company'],
      companyName: json['company_name'],
    );
  }
}

class City {
  final String id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(id: json['_id'], name: json['name']);
  }
}

class District {
  final String id;
  final String name;

  District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(id: json['_id'], name: json['name']);
  }
}

class ContractType {
  final String id;
  final String name;
  final String key;

  ContractType({required this.id, required this.name, required this.key});

  factory ContractType.fromJson(Map<String, dynamic> json) {
    return ContractType(id: json['_id'], name: json['name'], key: json['key']);
  }
}

class JobType {
  final String id;
  final String name;
  final String key;

  JobType({required this.id, required this.name, required this.key});

  factory JobType.fromJson(Map<String, dynamic> json) {
    return JobType(id: json['_id'], name: json['name'], key: json['key']);
  }
}

class Level {
  final String id;
  final String name;
  final String key;

  Level({required this.id, required this.name, required this.key});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(id: json['_id'], name: json['name'], key: json['key']);
  }
}

class MoneyType {
  final String id;
  final String code;
  final String symbol;

  MoneyType({required this.id, required this.code, required this.symbol});

  factory MoneyType.fromJson(Map<String, dynamic> json) {
    return MoneyType(
      id: json['_id'],
      code: json['code'],
      symbol: json['symbol'],
    );
  }
}

class Skill {
  final String id;
  final String name;

  Skill({required this.id, required this.name});

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(id: json['_id'], name: json['name']);
  }
}
