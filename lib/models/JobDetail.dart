import 'package:hiredev/models/AgeRange.dart';
import 'package:hiredev/models/Benefit.dart';
import 'package:hiredev/models/Degree.dart';
import 'package:hiredev/models/InterviewProcess.dart';
import 'package:hiredev/models/JobContractType.dart';
import 'package:hiredev/models/JobResponsibilities.dart';
import 'package:hiredev/models/ProfessionalSkill.dart';
import 'package:hiredev/models/TypeMoney.dart';
import 'package:hiredev/models/generalRequirement.dart';
import 'package:hiredev/models/job.dart';
import 'package:hiredev/models/ward.dart';

class Jobdetail {
  final String id;
  final User user;
  final String title;
  final String address;
  final String description;
  final String location;
  final String salaryFrom;
  final String salaryTo;
  final City city;
  final Ward ward;
  final District district;
  final AgeRange ageRange;
  final String salaryType;
  final JobContractType jobContractType;
  final JobType jobType;
  final String minExperience;
  final List<ProfessionalSkill> profesionalSkills;
  final List<String> skillNames;
  final String companyName;
  final List<GeneralRequirement> generalRequirements;
  final List<Benefit> benefits;
  final List<JobResponsibilities> jobResponsibilities;
  final List<InterviewProcess> interviewProcess;
  final Level level;
  final DateTime expireDate;
  final TypeMoney typeMoney;
  final Degree degree;
  final num countApply;
  final bool isNegotiable;
  final List<Skill> skills;
  final bool isActive;
  final bool isExpired;
  final List<String> candidateIds;
  final String applyLinkedin;
  final String applyWebsite;
  final String applyEmail;
  final num salaryRangeMax;
  final num salaryRangeMin;
  final DateTime postedDate;
  final DateTime createdAt;

  Jobdetail({
    required this.id,
    required this.user,
    required this.title,
    required this.address,
    required this.description,
    required this.location,
    required this.salaryFrom,
    required this.salaryTo,
    required this.city,
    required this.ward,
    required this.district,
    required this.ageRange,
    required this.salaryType,
    required this.jobContractType,
    required this.jobType,
    required this.minExperience,
    required this.profesionalSkills,
    required this.skillNames,
    required this.companyName,
    required this.generalRequirements,
    required this.benefits,
    required this.jobResponsibilities,
    required this.interviewProcess,
    required this.level,
    required this.expireDate,
    required this.typeMoney,
    required this.degree,
    required this.countApply,
    required this.isNegotiable,
    required this.skills,
    required this.isActive,
    required this.isExpired,
    required this.candidateIds,
    required this.applyLinkedin,
    required this.applyWebsite,
    required this.applyEmail,
    required this.salaryRangeMax,
    required this.salaryRangeMin,
    required this.postedDate,
    required this.createdAt,
  });

  factory Jobdetail.fromJson(Map<String, dynamic> json) {
    return Jobdetail(
      id: json['_id'] ?? '',
      user: User.fromJson(json['user_id'] ?? {}),
      title: json['title'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      salaryFrom: json['salary_from'] ?? '',
      salaryTo: json['salary_to'] ?? '',
      city: City.fromJson(json['city_id'] ?? {}),
      ward: Ward.fromJson(json['ward_id'] ?? {}),
      district: District.fromJson(json['district_id'] ?? {}),
      ageRange: AgeRange.fromJson(json['age_range'] ?? {}),
      salaryType: json['salary_type'] ?? '',
      jobContractType: JobContractType.fromJson(
        json['job_contract_type'] ?? {},
      ),
      jobType: JobType.fromJson(json['job_type'] ?? {}),
      minExperience: json['min_experience'] ?? '',
      profesionalSkills:
          (json['professional_skills'] as List<dynamic>)
              .map((skillJson) => ProfessionalSkill.fromJson(skillJson))
              .toList(), // Ánh xạ mỗi đối tượng JSON thành một đối tượng ProfessionalSkill
      skillNames: List<String>.from(json['skill_name'] ?? []),
      companyName: json['company_name'] ?? '',
      generalRequirements:
          (json['general_requirements'] as List<dynamic>)
              .map((req) => GeneralRequirement.fromJson(req))
              .toList(),
      benefits:
          (json['benefit'] as List<dynamic>)
              .map((benefit) => Benefit.fromJson(benefit))
              .toList(),
      jobResponsibilities:
          (json['job_responsibilities'] as List<dynamic>)
              .map((req) => JobResponsibilities.fromJson(req))
              .toList(),
      interviewProcess:
          (json['interview_process'] as List<dynamic>)
              .map((process) => InterviewProcess.fromJson(process))
              .toList(),
      level: Level.fromJson(json['level'] ?? {}),
      expireDate:
          json['expire_date'] != null
              ? DateTime.parse(json['expire_date'])
              : DateTime.now(),
      typeMoney: TypeMoney.fromJson(json['type_money'] ?? {}),
      degree: Degree.fromJson(json['degree'] ?? {}),
      countApply: json['count_apply'] ?? 0,
      isNegotiable: json['is_negotiable'] ?? false,
      skills:
          (json['skills'] as List<dynamic>)
              .map((skillJson) => Skill.fromJson(skillJson))
              .toList(),
      isActive: json['is_active'] ?? false,
      isExpired: json['is_expired'] ?? false,
      candidateIds: List<String>.from(json['candidate_ids'] ?? []),
      applyLinkedin: json['apply_linkedin'] ?? '',
      applyWebsite: json['apply_website'] ?? '',
      applyEmail: json['apply_email'] ?? '',
      salaryRangeMax: json['salary_range_max'] ?? 0,
      salaryRangeMin: json['salary_range_min'] ?? 0,
      postedDate:
          json['posted_date'] != null
              ? DateTime.parse(json['posted_date'])
              : DateTime.now(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }
}
