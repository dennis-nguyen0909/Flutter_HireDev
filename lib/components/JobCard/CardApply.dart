import 'package:flutter/material.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/models/TypeMoney.dart';
import 'package:hiredev/utils/currency.dart';

class CardApply extends StatefulWidget {
  const CardApply({
    super.key,
    required this.jobImage,
    required this.companyName,
    required this.jobTitle,
    required this.isNegotiable,
    required this.city,
    required this.district,
    required this.salaryRangeMin,
    required this.salaryRangeMax,
    required this.typeMoney,
  });
  final String jobImage;
  final String companyName;
  final String jobTitle;
  final bool isNegotiable;
  final String city;
  final String district;
  final num salaryRangeMin;
  final num salaryRangeMax;
  final String typeMoney;

  @override
  State<CardApply> createState() => _CardApplyState();
}

class _CardApplyState extends State<CardApply> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Image.network(widget.jobImage, width: 40, height: 40),
                SizedBox(width: 10),
                Text(widget.companyName),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text(
                  widget.jobTitle,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 5),
            widget.isNegotiable == "true"
                ? Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 5),
                    Text(
                      "Thương lượng",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                )
                : Row(
                  children: [
                    Text(
                      "Lương: ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      "${Currency.formatCurrencyWithSymbol(widget.salaryRangeMin.toInt(), widget.typeMoney)} - ${Currency.formatCurrencyWithSymbol(widget.salaryRangeMax.toInt(), widget.typeMoney)}",
                    ),
                  ],
                ),

            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey),
                SizedBox(width: 2),
                Text(widget.city + ", " + widget.district),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
