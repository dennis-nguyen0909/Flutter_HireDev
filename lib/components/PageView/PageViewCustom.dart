import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/JobCard/JobCard.dart';
import 'package:hiredev/models/job.dart';

class PageViewCustom extends StatefulWidget {
  final PageController controller;
  final List<Job> jobs;
  final bool isLoading;
  final Function(int) onPageChanged;
  final String title;

  const PageViewCustom({
    Key? key,
    required this.controller,
    required this.jobs,
    required this.isLoading,
    required this.onPageChanged,
    required this.title,
  }) : super(key: key);

  @override
  _PageViewCustomState createState() => _PageViewCustomState();
}

class _PageViewCustomState extends State<PageViewCustom> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        widget.isLoading
            ? const Center(child: CircularProgressIndicator())
            : widget.jobs.isEmpty
            ? const Center(child: Text('Không có việc làm nào.'))
            : Column(
              children: [
                SizedBox(
                  height: 400, // Điều chỉnh chiều cao phù hợp
                  child: PageView.builder(
                    controller: widget.controller,
                    onPageChanged: widget.onPageChanged,
                    itemCount: (widget.jobs.length / 3).ceil(),
                    itemBuilder: (context, pageIndex) {
                      int startIndex = pageIndex * 3;
                      int endIndex = (startIndex + 3).clamp(
                        0,
                        widget.jobs.length,
                      );
                      List<Job> pageJobs = widget.jobs.sublist(
                        startIndex,
                        endIndex,
                      );

                      return Column(
                        children:
                            pageJobs.map((job) => JobCard(job: job)).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SmoothPageIndicator(
                    controller: widget.controller,
                    count: (widget.jobs.length / 3).ceil(),
                    effect: WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
      ],
    );
  }
}
