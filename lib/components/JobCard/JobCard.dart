import 'package:flutter/material.dart';
import 'package:hiredev/screens/jobDetail/JobDetail.dart';
import 'package:hiredev/models/job.dart';
import 'package:hiredev/utils/currency.dart';

class JobCard extends StatefulWidget {
  final dynamic job;
  final Color backgroundColor;
  final bool isBorder;
  final Color borderColor;
  final bool isDisplayHeart;
  final bool isFavorite;

  JobCard({
    required this.job,
    this.backgroundColor = Colors.white,
    this.isBorder = true,
    this.borderColor = Colors.grey,
    this.isDisplayHeart = true,
    this.isFavorite = false,
  });

  @override
  State<StatefulWidget> createState() => JobCardState();
}

class JobCardState extends State<JobCard> {
  void onPressDetail() {
    print("jobId ${widget.job}");
    String jobId = '';
    String jobTitle = '';

    if (widget.job is Map) {
      final Map jobMap = widget.job as Map;

      // Handle job_id case
      if (jobMap.containsKey('job_id') && jobMap['job_id'] != null) {
        if (jobMap['job_id'] is Map) {
          jobId = jobMap['job_id']['_id'] ?? '';
          jobTitle = jobMap['job_id']['title'] ?? '';
        } else {
          // If job_id is not a map but a string ID
          jobId = jobMap['job_id'].toString();
        }
      }

      // Fallback to direct properties if job_id doesn't have what we need
      if (jobId.isEmpty) {
        jobId = jobMap['_id'] ?? '';
      }

      if (jobTitle.isEmpty) {
        jobTitle = jobMap['title'] ?? '';
      }
    } else if (widget.job != null) {
      // Handle Job object case
      jobId = widget.job.id ?? '';
      jobTitle = widget.job.title ?? '';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(id: jobId, title: jobTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("duyjob ${(widget.job)}");

    // Helper functions to get data regardless of job type
    String getAvatarCompany() {
      if (widget.job is Map) {
        if ((widget.job as Map).containsKey('job_id') &&
            (widget.job as Map)['job_id'] is Map &&
            (widget.job as Map)['job_id'].containsKey('user_id')) {
          return (widget.job as Map)['job_id']['user_id']['avatar_company'] ??
              '';
        } else if ((widget.job as Map).containsKey('user_id')) {
          return (widget.job as Map)['user_id']['avatar_company'] ?? '';
        }
        return '';
      }
      return widget.job.user.avatarCompany;
    }

    String getJobTitle() {
      if (widget.job is Map) {
        if ((widget.job as Map).containsKey('job_id') &&
            (widget.job as Map)['job_id'] is Map) {
          return (widget.job as Map)['job_id']['title'] ?? '';
        } else if ((widget.job as Map).containsKey('title')) {
          return (widget.job as Map)['title'] ?? '';
        }
        return '';
      }
      return widget.job.title;
    }

    String getCompanyName() {
      if (widget.job is Map) {
        if ((widget.job as Map).containsKey('job_id') &&
            (widget.job as Map)['job_id'] is Map &&
            (widget.job as Map)['job_id'].containsKey('user_id')) {
          return (widget.job as Map)['job_id']['user_id']['company_name'] ?? '';
        } else if ((widget.job as Map).containsKey('user_id')) {
          return (widget.job as Map)['user_id']['company_name'] ?? '';
        }
        return '';
      }
      return widget.job.user.companyName;
    }

    bool getIsNegotiable() {
      if (widget.job is Map) {
        if ((widget.job as Map).containsKey('job_id') &&
            (widget.job as Map)['job_id'] is Map) {
          return (widget.job as Map)['job_id']['is_negotiable'] ?? false;
        }
        return (widget.job as Map)['is_negotiable'] ?? false;
      }
      return widget.job.isNegotiable;
    }

    String getDistrictName() {
      if (widget.job is Map) {
        if ((widget.job as Map).containsKey('job_id') &&
            (widget.job as Map)['job_id'] is Map &&
            (widget.job as Map)['job_id'].containsKey('district_id')) {
          return (widget.job as Map)['job_id']['district_id']['name'] ?? '';
        } else if ((widget.job as Map).containsKey('district_id')) {
          return (widget.job as Map)['district_id']['name'] ?? '';
        }
        return '';
      }
      return widget.job.district.name;
    }

    int getSalaryMin() {
      if (widget.job is Map) {
        if ((widget.job as Map).containsKey('job_id') &&
            (widget.job as Map)['job_id'] is Map) {
          return ((widget.job as Map)['job_id']['salary_range_min'] ?? 0)
              as int;
        }
        return ((widget.job as Map)['salary_range_min'] ?? 0) as int;
      }
      return widget.job.salaryRangeMin;
    }

    int getSalaryMax() {
      if (widget.job is Map) {
        if ((widget.job as Map).containsKey('job_id') &&
            (widget.job as Map)['job_id'] is Map) {
          return ((widget.job as Map)['job_id']['salary_range_max'] ?? 0)
              as int;
        }
        return ((widget.job as Map)['salary_range_max'] ?? 0) as int;
      }
      return widget.job.salaryRangeMax;
    }

    String getMoneyTypeCode() {
      if (widget.job is Map) {
        if ((widget.job as Map).containsKey('job_id') &&
            (widget.job as Map)['job_id'] is Map &&
            (widget.job as Map)['job_id'].containsKey('money_type')) {
          return (widget.job as Map)['job_id']['money_type']['code'] ?? 'USD';
        } else if ((widget.job as Map).containsKey('money_type')) {
          return (widget.job as Map)['money_type']['code'] ?? 'USD';
        }
        return 'USD';
      }
      return widget.job.moneyType.code;
    }

    return GestureDetector(
      onTap: onPressDetail,
      child: Container(
        margin: EdgeInsets.all(0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                widget.isBorder
                    ? BorderSide(color: widget.borderColor)
                    : BorderSide.none,
          ),
          elevation: 4,
          color: widget.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      getAvatarCompany(),
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.business,
                              color: Colors.grey[600],
                            ),
                          ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getJobTitle(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(getCompanyName()),
                        Text(
                          getCompanyName(),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            getIsNegotiable()
                                ? Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ), // Padding inside the border
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xFF666666), // Border color
                                      width: 0.5, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ), // Optional: Make the corners rounded
                                  ),
                                  child: Text(
                                    "Negotiable",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                )
                                : Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ), // Padding inside the border
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xFF666666), // Border color
                                      width: 0.5, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ), // Optional: Make the corners rounded
                                  ),
                                  child: Text(
                                    "${Currency.formatCurrencyWithSymbol(getSalaryMin(), getMoneyTypeCode())} - ${Currency.formatCurrencyWithSymbol(getSalaryMax(), getMoneyTypeCode())}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                        SizedBox(width: 10),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ), // Padding inside the border
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFF666666), // Border color
                                  width: 0.5, // Border width
                                ),
                                borderRadius: BorderRadius.circular(
                                  20,
                                ), // Optional: Make the corners rounded
                              ),
                              child: Text(
                                getDistrictName(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (widget.isDisplayHeart)
                      Row(
                        children: [
                          Icon(Icons.favorite_border, color: Color(0xFF666666)),

                          // Text(widget.job.district.name),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
