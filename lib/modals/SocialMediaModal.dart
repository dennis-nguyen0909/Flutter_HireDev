import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SocialMediaModal extends StatefulWidget {
  const SocialMediaModal({Key? key}) : super(key: key);

  @override
  State<SocialMediaModal> createState() => _SocialMediaModalState();
}

class _SocialMediaModalState extends State<SocialMediaModal> {
  final List<String> socialPlatforms = [
    'Facebook',
    'Twitter',
    'Instagram',
    'Youtube',
    'LinkedIn',
  ];

  List<SocialLinkItem> socialLinks = [
    SocialLinkItem(),
  ]; // Start with one link item

  // Keep track of original social links to avoid re-saving
  List<SocialLinkItem> originalSocialLinks = [];

  bool isLoading = false;
  bool isLoadingData = true;
  int currentPage = 1;
  int pageSize = 10;
  int totalItems = 0;

  @override
  void initState() {
    super.initState();
    fetchSocialLinks();
  }

  Future<void> fetchSocialLinks() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;

    setState(() {
      isLoadingData = true;
    });

    try {
      final token = await SecureStorageService().getRefreshToken();
      final response = await ApiService().get(
        dotenv.get('API_URL') +
            'social-links?current=$currentPage&pageSize=$pageSize&query[user_id]=$userId',
        token: token,
      );
      print("response: ${response}");

      if (response['statusCode'] == 200) {
        final data = response['data']['items'];

        // Create new lists to avoid state update issues
        List<SocialLinkItem> newSocialLinks = [];
        List<SocialLinkItem> newOriginalLinks = [];

        if (data != null && data.isNotEmpty) {
          for (var item in data) {
            var socialLink = SocialLinkItem(
              id: item['_id'] ?? '',
              platform: item['type'] ?? 'Facebook',
              link: item['url'] ?? '',
            );
            newSocialLinks.add(socialLink);

            // Store a copy of original links
            newOriginalLinks.add(
              SocialLinkItem(
                id: item['_id'] ?? '',
                platform: item['type'] ?? 'Facebook',
                link: item['url'] ?? '',
              ),
            );
          }
        } else {
          newSocialLinks.add(SocialLinkItem());
        }

        // Update state only once with all the new data
        setState(() {
          socialLinks = newSocialLinks;
          originalSocialLinks = newOriginalLinks;
          totalItems = response['data']['meta']['total'] ?? 0;
          isLoadingData = false;
        });
      } else {
        print('Failed to load social links: ${response.statusCode}');
        setState(() {
          isLoadingData = false;
        });
      }
    } catch (e) {
      print('Exception when fetching social links: $e');
      setState(() {
        isLoadingData = false;
      });
    }
  }

  Future<void> saveSocialLinks() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;
    setState(() {
      isLoading = true;
    });

    List<Map<String, String>> result = [];
    bool hasError = false;

    for (var item in socialLinks) {
      if (item.linkController.text.isNotEmpty) {
        // Skip if this is an existing link that hasn't changed
        bool isExistingUnchangedLink = false;
        for (var original in originalSocialLinks) {
          if (item.id == original.id &&
              item.platform == original.platform &&
              item.linkController.text == original.linkController.text) {
            isExistingUnchangedLink = true;
            result.add({
              'platform': item.platform,
              'link': item.linkController.text,
            });
            break;
          }
        }

        if (!isExistingUnchangedLink) {
          try {
            final response = await ApiService().post(
              dotenv.get('API_URL') + 'social-links',
              {
                'user_id': userId,
                'type': item.platform,
                'url': item.linkController.text,
              },
              token: await SecureStorageService().getRefreshToken(),
            );
            print("responseduy: ${response}");
            if (response['statusCode'] == 201) {
              result.add({
                'platform': item.platform,
                'link': item.linkController.text,
              });
            } else {
              hasError = true;
              print('Error saving ${item.platform} link: ${response.body}');
            }
          } catch (e) {
            hasError = true;
            print('Exception when saving ${item.platform} link: $e');
          }
        }
      }
    }

    setState(() {
      isLoading = false;
    });

    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Some links could not be saved. Please try again.'),
        ),
      );
    } else {
      Navigator.pop(context, result);
    }
  }

  Future<void> deleteSocialLink(String id) async {
    if (id.isEmpty) return; // Skip if ID is empty

    // Don't set loading state to avoid UI flicker
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;
    final token = await SecureStorageService().getRefreshToken();

    try {
      final response = await ApiService().delete(
        dotenv.get('API_URL') + 'social-links',
        {
          'ids': [id],
        },
        token: token,
      );
      print("response: ${response}");

      if (response['statusCode'] == 200) {
        // Instead of calling fetchSocialLinks which would show loading indicator,
        // we can just update our local state since we already know what was deleted
        setState(() {
          // The item was already removed from socialLinks in the onPressed handler
          // We just need to update originalSocialLinks to match
          originalSocialLinks.removeWhere((item) => item.id == id);
          totalItems = totalItems > 0 ? totalItems - 1 : 0;
        });
      } else {
        print('Failed to delete social link: ${response.statusCode}');
        // If deletion failed on the server, we should refresh to get accurate data
        await fetchSocialLinks();
      }
    } catch (e) {
      print('Exception when deleting social link: $e');
      // If there was an exception, refresh to get accurate data
      await fetchSocialLinks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final modalHeight = screenHeight - statusBarHeight - 50;

    return Container(
      height: modalHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Liên kết xã hội',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child:
                isLoadingData
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display all social link items
                          for (int i = 0; i < socialLinks.length; i++)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Liên kết ${i + 1}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (socialLinks[i].id.isNotEmpty)
                                      Text(
                                        'ID: ${socialLinks[i].id}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width:
                                          100, // Reduced width from 120 to 100
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: socialLinks[i].platform,
                                          icon: Icon(
                                            Icons.keyboard_arrow_down,
                                            size: 18,
                                          ), // Smaller icon
                                          isExpanded: true,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ), // Reduced padding
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              socialLinks[i].platform =
                                                  newValue!;
                                            });
                                          },
                                          items:
                                              socialPlatforms.map<
                                                DropdownMenuItem<String>
                                              >((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                      fontSize:
                                                          11, // Smaller font size
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller:
                                                  socialLinks[i].linkController,
                                              decoration: InputDecoration(
                                                hintText: 'Profile link/url...',
                                                hintStyle: TextStyle(
                                                  fontSize: 11,
                                                ), // Smaller hint text
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                filled: true,
                                                fillColor: Colors.grey.shade100,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8,
                                                    ), // Reduced padding
                                                isDense:
                                                    true, // Makes the input field more compact
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                              ), // Smaller input text
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              final idToDelete =
                                                  socialLinks[i].id;
                                              print("socialLinks: $idToDelete");

                                              setState(() {
                                                socialLinks.removeAt(i);
                                              });

                                              if (idToDelete.isNotEmpty) {
                                                deleteSocialLink(idToDelete);
                                              }
                                            },
                                            constraints: BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            iconSize: 18, // Smaller icon
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12), // Reduced spacing
                              ],
                            ),

                          // Pagination controls if needed
                          if (totalItems > pageSize)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back_ios, size: 16),
                                    onPressed:
                                        currentPage > 1
                                            ? () {
                                              setState(() {
                                                currentPage--;
                                                fetchSocialLinks();
                                              });
                                            }
                                            : null,
                                    color:
                                        currentPage > 1
                                            ? Colors.blue
                                            : Colors.grey,
                                  ),
                                  Text(
                                    'Trang $currentPage / ${(totalItems / pageSize).ceil()}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                    onPressed:
                                        currentPage <
                                                (totalItems / pageSize).ceil()
                                            ? () {
                                              setState(() {
                                                currentPage++;
                                                fetchSocialLinks();
                                              });
                                            }
                                            : null,
                                    color:
                                        currentPage <
                                                (totalItems / pageSize).ceil()
                                            ? Colors.blue
                                            : Colors.grey,
                                  ),
                                ],
                              ),
                            ),

                          // Add new social link button
                          Container(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  // Add a new social link item without refreshing the entire list
                                  socialLinks.add(SocialLinkItem());
                                });
                              },
                              icon: Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.black,
                              ), // Smaller icon
                              label: Text(
                                'Thêm liên kết mới',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ), // Smaller text
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ), // Reduced padding
                                minimumSize: Size(
                                  double.infinity,
                                  32,
                                ), // Full width button
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Save button
                          Container(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: isLoading ? null : saveSocialLinks,
                              child:
                                  isLoading
                                      ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(
                                        'Lưu',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ), // Smaller text
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ), // Reduced padding
                                minimumSize: Size(
                                  double.infinity,
                                  32,
                                ), // Full width button
                                disabledBackgroundColor: Colors.grey.shade200,
                                disabledForegroundColor: Colors.grey.shade500,
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

// Helper class to manage each social link item
class SocialLinkItem {
  String id;
  String platform;
  TextEditingController linkController;

  SocialLinkItem({this.id = '', this.platform = 'Facebook', String link = ''})
    : linkController = TextEditingController(text: link);

  void dispose() {
    linkController.dispose();
  }
}
