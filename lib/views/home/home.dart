import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/JobCard/JobCard.dart';
import 'package:hiredev/components/PageView/PageViewCustom.dart';
import 'dart:async';
import 'package:hiredev/components/TextIcon/TextIcon.dart';
import 'package:hiredev/models/job.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final PageController _bannerPageController = PageController();
  final PageController _suggestPageController = PageController();
  int _currentPage = 0;
  int _bannerPage = 0;
  int _suggestPage = 0;
  Timer? _timer;
  bool _isLoading = false; // Đổi tên để rõ ràng hơn
  bool _isLoadingMore = false;
  int _currentPageNumber = 1; // Đổi tên để tránh trùng với biến trong hàm
  int _totalPages = 1;
  final List<Job> _jobs = []; // Đổi tên để rõ ràng hơn
  final Map<String, dynamic> _meta = {}; // Đổi tên để rõ ràng hơn
  final List<Map<String, dynamic>> _bannerItems = [
    {
      'title': 'Find Your Dream Job',
      'description': 'Thousands of jobs waiting for you',
      'color': Colors.blue.shade700,
    },
    {
      'title': 'Top Tech Companies',
      'description': 'Work with industry leaders',
      'color': Colors.green.shade700,
    },
    {
      'title': 'Remote Opportunities',
      'description': 'Work from anywhere in the world',
      'color': Colors.purple.shade700,
    },
    {
      'title': 'Career Growth',
      'description': 'Advance your developer career',
      'color': Colors.orange.shade700,
    },
    {
      'title': 'Competitive Salary',
      'description': 'Get paid what you deserve',
      'color': Colors.red.shade700,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _fetchJobs();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _bannerItems.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> _fetchJobs([
    String query = '',
    int page = 1,
    int pageSize = 12,
  ]) async {
    if (page > _totalPages || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      if (page == 1) {
        _isLoading = true; // Set loading true khi tải trang đầu tiên
      }
    });

    try {
      final apiUrl =
          query.isEmpty
              ? '${dotenv.env['API_URL']}jobs?current=$page&pageSize=$pageSize'
              : '${dotenv.env['API_URL']}jobs?current=$page&pageSize=$pageSize&query[keyword]=$query';

      final response = await ApiService().get(apiUrl);

      if (response != null &&
          response['data'] != null &&
          response['data']['items'] != null) {
        setState(() {
          List<Job> items =
              (response['data']['items'] as List).map((item) {
                return Job.fromJson(item);
              }).toList();

          if (page == 1) {
            _jobs.clear();
          }
          _jobs.addAll(items);
          _meta.clear();
          _meta.addAll(Map<String, dynamic>.from(response['data']['meta']));

          _currentPageNumber = page;
          _totalPages =
              _meta['total_pages'] ??
              1; // Sử dụng giá trị mặc định nếu không có
        });
      } else {
        // Xử lý trường hợp response hoặc data là null
        print('Error: Failed to fetch jobs or data is invalid.');
        // Có thể hiển thị thông báo lỗi cho người dùng ở đây
      }
    } catch (error) {
      print("Error fetching jobs: $error");
      // Xử lý lỗi cụ thể hơn, có thể hiển thị thông báo lỗi
    } finally {
      setState(() {
        _isLoadingMore = false;
        _isLoading = false; // Set loading false khi hoàn thành
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_jobs.map((e) => e.title).toList()); // In ra tiêu đề các job
    return Scaffold(
      body: Stack(
        children: [
          // Nội dung chính của màn hình
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 270 + MediaQuery.of(context).padding.top),
                // Các widget khác của bạn ở đây
                Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextIcon(
                              icon: Icons.book,
                              text: 'Khám phá',
                              colorIcon: AppColors.primaryColor,
                            ),
                            TextIcon(
                              icon: Icons.location_on,
                              text: 'Gần bạn',
                              colorIcon: AppColors.primaryColor,
                            ),
                            TextIcon(
                              icon: Icons.business,
                              text: 'Công ty',
                              colorIcon: AppColors.primaryColor,
                            ),
                            TextIcon(
                              icon: Icons.wallet,
                              text: 'Lương',
                              colorIcon: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        PageViewCustom(
                          title: 'Việc làm tốt nhất',
                          controller: _bannerPageController,
                          jobs: _jobs,
                          isLoading: _isLoading,
                          onPageChanged: (int page) {
                            setState(() {
                              _bannerPage = page;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        PageViewCustom(
                          title: 'Gợi ý việc làm',
                          controller: _suggestPageController,
                          jobs: _jobs,
                          isLoading: _isLoading,
                          onPageChanged: (int page) {
                            setState(() {
                              _suggestPage = page;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Thêm một widget để tải thêm khi cuộn đến cuối danh sách
                if (!_isLoading &&
                    !_isLoadingMore &&
                    _currentPageNumber < _totalPages &&
                    _jobs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _fetchJobs();
                        },
                        child: const Text('Xem thêm'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Container với gradient, đặt lên trên cùng
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: BoxConstraints(
                minHeight: 270 + MediaQuery.of(context).padding.top,
                maxWidth: double.infinity,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryColor,
                    Colors.black,
                  ], // Sử dụng Colors.black thay vì Color(0xFF000000)
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: MediaQuery.of(context).padding.top + 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'HireDev',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Image.asset('assets/LogoH.png', scale: 80),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 116, 116),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.search_sharp,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: _bannerItems.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: _bannerItems[index]['color'],
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _bannerItems[index]['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _bannerItems[index]['description'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _bannerItems.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == index
                                  ? AppColors.primaryColor
                                  : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
