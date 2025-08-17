import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class CloudNewsPage extends StatefulWidget {
  const CloudNewsPage({Key? key}) : super(key: key);

  @override
  _CloudNewsPageState createState() => _CloudNewsPageState();
}

class _CloudNewsPageState extends State<CloudNewsPage> with TickerProviderStateMixin {
  List<dynamic> _news = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchCloudNews();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _fetchCloudNews() async {
    const apiKey = '???????????????????';
    final url = Uri.parse(
        'https://newsapi.org/v2/everything?q=weather OR clouds OR sky&language=en&sortBy=publishedAt&apiKey=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _news = data['articles'] ?? [];
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _news = [];
          _isLoading = false;
          _errorMessage = 'ไม่สามารถโหลดข่าวได้ กรุณาลองใหม่อีกครั้ง';
        });
      }
    } catch (e) {
      setState(() {
        _news = [];
        _isLoading = false;
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาตรวจสอบอินเทอร์เน็ต';
      });
    }
  }

  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ไม่สามารถเปิดลิงก์ได้',
            style: GoogleFonts.notoSansThai(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} วันที่แล้ว';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ชั่วโมงที่แล้ว';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} นาทีที่แล้ว';
      } else {
        return 'เมื่อสักครู่';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ข่าวสารเมฆและอากาศ',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'ข้อมูลล่าสุดจากทั่วโลก',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          
          // Refresh Button
          GestureDetector(
            onTap: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _fetchCloudNews();
            },
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? AppColors.darkPrimary.withOpacity(0.2) 
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode 
                      ? AppColors.darkPrimary.withOpacity(0.3) 
                      : AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> newsItem, int index, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? AppColors.darkPrimary.withOpacity(0.1) 
                : AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchURL(newsItem['url'] ?? ''),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with source and time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? AppColors.darkAccent.withOpacity(0.2) 
                            : AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        newsItem['source']?['name'] ?? 'Unknown',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 10,
                          color: isDarkMode ? AppColors.darkAccent : AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(newsItem['publishedAt']),
                      style: GoogleFonts.notoSansThai(
                        fontSize: 10,
                        color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Title
                Text(
                  newsItem['title'] ?? 'ไม่มีหัวข้อ',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Description
                if (newsItem['description'] != null && newsItem['description'].toString().isNotEmpty)
                  Text(
                    newsItem['description'],
                    style: GoogleFonts.notoSansThai(
                      fontSize: 13,
                      color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 16),
                
                // Footer
                Row(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 16,
                      color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'อ่านเต็ม',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 12,
                        color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: isDarkMode ? Colors.white54 : AppColors.textMuted,
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

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? AppColors.darkPrimary.withOpacity(0.2) 
                  : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: isDarkMode 
                  ? AppColors.darkPrimary.withOpacity(0.8) 
                  : AppColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _errorMessage.isNotEmpty ? _errorMessage : 'ไม่พบข่าวในขณะนี้',
            style: GoogleFonts.notoSansThai(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'กรุณาลองใหม่อีกครั้งในภายหลัง',
            style: GoogleFonts.notoSansThai(
              fontSize: 12,
              color: isDarkMode ? Colors.white54 : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _fetchCloudNews();
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              'ลองใหม่',
              style: GoogleFonts.notoSansThai(
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? AppColors.darkPrimary.withOpacity(0.2) 
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? AppColors.darkPrimary : AppColors.primary
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'กำลังโหลดข่าวสาร...',
            style: GoogleFonts.notoSansThai(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'รอสักครู่นะคะ',
            style: GoogleFonts.notoSansThai(
              fontSize: 12,
              color: isDarkMode ? Colors.white54 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildHeader(isDarkMode),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState(isDarkMode)
                      : _news.isEmpty
                          ? _buildEmptyState(isDarkMode)
                          : RefreshIndicator(
                              onRefresh: _fetchCloudNews,
                              color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                              backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                itemCount: _news.length,
                                itemBuilder: (context, index) {
                                  return _buildNewsCard(_news[index], index, isDarkMode);
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}