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

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': user.toJson(),
      'title': title,
      'city_id': city.toJson(),
      'district_id': district.toJson(),
      'job_contract_type': contractType.toJson(),
      'job_type': jobType.toJson(),
      'skill_name': skillNames,
      'level': {'_id': level.id, 'name': level.name, 'key': level.key},
      'expire_date': expireDate.toIso8601String(),
      'type_money': {
        '_id': moneyType.id,
        'code': moneyType.code,
        'symbol': moneyType.symbol,
      },
      'count_apply': countApply,
      'is_negotiable': isNegotiable,
      'skills':
          skills.map((skill) => {'_id': skill.id, 'name': skill.name}).toList(),
      'is_active': isActive,
      'is_expired': isExpired,
      'candidate_ids': candidateIds,
      'salary_range_max': salaryRangeMax,
      'salary_range_min': salaryRangeMin,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    try {
      return Job(
        id: json['_id'] ?? '',
        user:
            json['user_id'] is Map<String, dynamic>
                ? User.fromJson(json['user_id'])
                : User(id: '', avatarCompany: '', companyName: ''),
        title: json['title'] ?? '',
        city:
            json['city_id'] is Map<String, dynamic>
                ? City.fromJson(json['city_id'])
                : City(id: '', name: ''),
        district:
            json['district_id'] is Map<String, dynamic>
                ? District.fromJson(json['district_id'])
                : District(id: '', name: ''),
        contractType:
            json['job_contract_type'] is Map<String, dynamic>
                ? ContractType.fromJson(json['job_contract_type'])
                : ContractType(id: '', name: '', key: ''),
        jobType:
            json['job_type'] is Map<String, dynamic>
                ? JobType.fromJson(json['job_type'])
                : JobType(id: '', name: '', key: ''),
        skillNames:
            json['skill_name'] is List
                ? List<String>.from(json['skill_name'])
                : [],
        level:
            json['level'] is Map<String, dynamic>
                ? Level.fromJson(json['level'])
                : Level(id: '', name: '', key: ''),
        expireDate:
            DateTime.tryParse(json['expire_date'] ?? '') ?? DateTime.now(),
        moneyType:
            json['type_money'] is Map<String, dynamic>
                ? MoneyType.fromJson(json['type_money'])
                : MoneyType(id: '', code: '', symbol: ''),
        countApply: json['count_apply'] ?? 0,
        isNegotiable: json['is_negotiable'] ?? false,
        skills:
            json['skills'] is List
                ? (json['skills'] as List)
                    .where((skill) => skill is Map<String, dynamic>)
                    .map((skill) => Skill.fromJson(skill))
                    .toList()
                : [],
        isActive: json['is_active'] ?? false,
        isExpired: json['is_expired'] ?? false,
        candidateIds:
            json['candidate_ids'] is List
                ? List<String>.from(json['candidate_ids'])
                : [],
        salaryRangeMax:
            json['salary_range_max'] != null
                ? (json['salary_range_max'] is num
                    ? (json['salary_range_max'] as num).toInt()
                    : 0)
                : 0,
        salaryRangeMin:
            json['salary_range_min'] != null
                ? (json['salary_range_min'] is num
                    ? (json['salary_range_min'] as num).toInt()
                    : 0)
                : 0,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      print("Error parsing Job: $e");
      return Job(
        id: '',
        user: User(id: '', avatarCompany: '', companyName: ''),
        title: '',
        city: City(id: '', name: ''),
        district: District(id: '', name: ''),
        contractType: ContractType(id: '', name: '', key: ''),
        jobType: JobType(id: '', name: '', key: ''),
        skillNames: [],
        level: Level(id: '', name: '', key: ''),
        expireDate: DateTime.now(),
        moneyType: MoneyType(id: '', code: '', symbol: ''),
        countApply: 0,
        isNegotiable: false,
        skills: [],
        isActive: false,
        isExpired: false,
        candidateIds: [],
        salaryRangeMax: 0,
        salaryRangeMin: 0,
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  String toString() {
    return "Job(id: $id, title: $title, city: $city, district: $district, contractType: $contractType, jobType: $jobType, skillNames: $skillNames, level: $level, expireDate: $expireDate, moneyType: $moneyType, countApply: $countApply, isNegotiable: $isNegotiable, skills: $skills, isActive: $isActive, isExpired: $isExpired, candidateIds: $candidateIds, salaryRangeMax: $salaryRangeMax, salaryRangeMin: $salaryRangeMin, createdAt: $createdAt)";
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

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'avatar_company': avatarCompany,
      'company_name': companyName,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      avatarCompany: json['avatar_company'] ?? '',
      companyName: json['company_name'] ?? '',
    );
  }
}

class City {
  final String id;
  final String name;

  City({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }

  factory City.fromJson(Map<String, dynamic> json) {
    return City(id: json['_id'] ?? '', name: json['name'] ?? '');
  }
}

class District {
  final String id;
  final String name;

  District({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }

  factory District.fromJson(Map<String, dynamic> json) {
    return District(id: json['_id'] ?? '', name: json['name'] ?? '');
  }
}

class ContractType {
  final String id;
  final String name;
  final String key;

  ContractType({required this.id, required this.name, required this.key});

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'key': key};
  }

  factory ContractType.fromJson(Map<String, dynamic> json) {
    return ContractType(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      key: json['key'] ?? '',
    );
  }
}

class JobType {
  final String id;
  final String name;
  final String key;

  JobType({required this.id, required this.name, required this.key});

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'key': key};
  }

  factory JobType.fromJson(Map<String, dynamic> json) {
    return JobType(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      key: json['key'] ?? '',
    );
  }
}

class Level {
  final String id;
  final String name;
  final String key;

  Level({required this.id, required this.name, required this.key});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      key: json['key'] ?? '',
    );
  }
}

class MoneyType {
  final String id;
  final String code;
  final String symbol;

  MoneyType({required this.id, required this.code, required this.symbol});

  factory MoneyType.fromJson(Map<String, dynamic> json) {
    return MoneyType(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      symbol: json['symbol'] ?? '',
    );
  }
}

class Skill {
  final String id;
  final String name;

  Skill({required this.id, required this.name});

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(id: json['_id'] ?? '', name: json['name'] ?? '');
  }
}
