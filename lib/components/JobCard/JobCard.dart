import 'package:flutter/material.dart';
import 'package:hiredev/screens/jobDetail/JobDetail.dart';
import 'package:hiredev/models/job.dart';
import 'package:hiredev/utils/currency.dart';

class JobCard extends StatefulWidget {
  final Job job;
  final Color backgroundColor;
  final bool isBorder;
  final Color borderColor;

  JobCard({
    required this.job,
    this.backgroundColor = Colors.white,
    this.isBorder = true,
    this.borderColor = Colors.grey,
  });

  @override
  State<StatefulWidget> createState() => JobCardState();
}

class JobCardState extends State<JobCard> {
  void onPressDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                JobDetailScreen(id: widget.job.id, title: widget.job.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      widget.job.user.avatarCompany,
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.job.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          widget.job.user.companyName,
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
                            widget.job.isNegotiable
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
                                    "${Currency.formatCurrencyWithSymbol(widget.job.salaryRangeMin, widget.job.moneyType.code)} - ${Currency.formatCurrencyWithSymbol(widget.job.salaryRangeMax, widget.job.moneyType.code)}",
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
                                widget.job.district.name,
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
