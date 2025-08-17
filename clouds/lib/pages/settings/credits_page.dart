import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'ไม่สามารถเปิดลิงก์: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบว่าเป็น Dark Mode หรือไม่
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded, 
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'แหล่งที่มาของข้อมูลและรูปภาพ',
          style: GoogleFonts.notoSansThai(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isDarkMode 
                    ? LinearGradient(
                        colors: [AppColors.darkPrimary, AppColors.darkPrimary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.3),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ขอบคุณผู้สร้าง',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ขอบคุณแหล่งที่มาของรูปภาพและข้อมูลที่ช่วยให้แอปนี้เกิดขึ้น',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Cloud Images Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                'แหล่งที่มาของรูปภาพเมฆ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            
            // Cloud Images Credits List - แบ่งตามกลุ่มความสูง
            // เมฆชั้นต่ำ (Low Clouds)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'เมฆชั้นต่ำ (Low Clouds)',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary),
                      ),
                    ),
                  ),
                  _buildCreditItem(
                    icon: Icons.cloud_rounded,
                    title: 'Cumulus - เมฆก้อนปุย',
                    subtitle: 'Wikipedia - Fair weather cumulus clouds',
                    url: 'https://en.wikipedia.org/wiki/Cumulus_cloud',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.cloud_rounded,
                    title: 'Stratus - เมฆชั้น',
                    subtitle: 'Wikipedia - Low-level layer clouds',
                    url: 'https://en.wikipedia.org/wiki/Stratus_cloud',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.cloud_rounded,
                    title: 'Stratocumulus - เมฆชั้นปุย',
                    subtitle: 'Wikipedia - Low lumpy gray clouds',
                    url: 'https://en.wikipedia.org/wiki/Stratocumulus_cloud',
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // เมฆชั้นกลาง (Middle Clouds)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'เมฆชั้นกลาง (Middle Clouds)',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary),
                      ),
                    ),
                  ),
                  _buildCreditItem(
                    icon: Icons.cloud_rounded,
                    title: 'Altocumulus - เมฆก้อนชั้นกลาง',
                    subtitle: 'Wikipedia - Mid-level heap clouds',
                    url: 'https://en.wikipedia.org/wiki/Altocumulus_cloud',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.cloud_rounded,
                    title: 'Altostratus - เมฆชั้นสูง',
                    subtitle: 'Wikipedia - Gray sheet clouds',
                    url: 'https://en.wikipedia.org/wiki/Altostratus_cloud',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.cloud_rounded,
                    title: 'Nimbostratus - เมฆฝน',
                    subtitle: 'Wikipedia - Rain-bearing clouds',
                    url: 'https://en.wikipedia.org/wiki/Nimbostratus_cloud',
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // เมฆชั้นสูง (High Clouds)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'เมฆชั้นสูง (High Clouds)',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary),
                      ),
                    ),
                  ),
                  _buildCreditItem(
                    icon: Icons.cloud_rounded,
                    title: 'Cirrus - เมฆเส้นใย',
                    subtitle: 'Wikipedia Commons - Wispy cirrus clouds',
                    url: 'https://commons.wikimedia.org/wiki/File:Cirrus_clouds2.jpg',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.cloud_rounded,
                    title: 'Cirrocumulus - เมฆก้อนชั้นสูง',
                    subtitle: 'Wikipedia Commons - Mackerel sky pattern',
                    url: 'https://commons.wikimedia.org/wiki/File:Cirrocumulus_clouds_Ladakh.jpg',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.cloud_rounded,
                    title: 'Cirrostratus - เมฆชั้นบาง',
                    subtitle: 'Wikipedia Commons - Thin veil clouds',
                    url: 'https://commons.wikimedia.org/wiki/File:Cirrostratus_fibratus.jpg',
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // เมฆพัฒนาในแนวตั้ง (Vertical Development)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'เมฆพัฒนาในแนวตั้ง (Vertical Development)',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary),
                      ),
                    ),
                  ),
                  _buildCreditItem(
                    icon: Icons.cloud_rounded,
                    title: 'Cumulonimbus - เมฆฝนฟ้าคะนอง',
                    subtitle: 'Wikipedia Commons - Thunderstorm cloud',
                    url: 'https://commons.wikimedia.org/wiki/File:Cumulonimbus_cloud.jpg',
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            
            // Data Sources Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
              child: Text(
                'แหล่งที่มาของข้อมูล',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildCreditItem(
                    icon: Icons.cloud_rounded,
                    title: 'ข้อมูลเมฆจาก National Weather Service',
                    subtitle: 'Cloud Classification Guide',
                    url: 'https://www.weather.gov/jetstream/clouds',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.school_rounded,
                    title: 'ข้อมูลทางการศึกษาจาก NASA',
                    subtitle: 'Earth Science Division - Cloud Atlas',
                    url: 'https://earthobservatory.nasa.gov/features/Clouds',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.book_rounded,
                    title: 'World Meteorological Organization',
                    subtitle: 'International Cloud Atlas',
                    url: 'https://cloudatlas.wmo.int/',
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            
            // Development Credits Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
              child: Text(
                'เครื่องมือและไลบรารี',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildCreditItem(
                    icon: Icons.flutter_dash,
                    title: 'Flutter Framework',
                    subtitle: 'UI toolkit สำหรับการพัฒนาแอป',
                    url: 'https://flutter.dev',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.camera_alt_rounded,
                    title: 'Camera Plugin',
                    subtitle: 'ปลั๊กอินสำหรับการใช้งานกล้อง',
                    url: 'https://pub.dev/packages/camera',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.image_rounded,
                    title: 'Image Picker',
                    subtitle: 'เลือกรูปภาพจากแกลเลอรี',
                    url: 'https://pub.dev/packages/image_picker',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.font_download_rounded,
                    title: 'Google Fonts',
                    subtitle: 'ฟอนต์ Noto Sans Thai และ Nunito',
                    url: 'https://fonts.google.com',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.open_in_new_rounded,
                    title: 'URL Launcher',
                    subtitle: 'เปิดลิงก์ภายนอกแอป',
                    url: 'https://pub.dev/packages/url_launcher',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.psychology_rounded,
                    title: 'TensorFlow Lite',
                    subtitle: 'Machine Learning สำหรับ Mobile',
                    url: 'https://www.tensorflow.org/lite',
                    isDarkMode: isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  _buildCreditItem(
                    icon: Icons.storage_rounded,
                    title: 'Shared Preferences',
                    subtitle: 'เก็บข้อมูลในเครื่อง',
                    url: 'https://pub.dev/packages/shared_preferences',
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            
            // Thank You Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.handshake_rounded,
                    color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ขอบคุณอีกครั้ง',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ขอบคุณทุกคนที่ช่วยให้แอป Little Nimbus เกิดขึ้นได้ รวมถึงชุมชนนักพัฒนาที่แบ่งปันความรู้และเครื่องมือต่างๆ',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String url,
    required bool isDarkMode,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.notoSansThai(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.notoSansThai(
          fontSize: 12,
          color: isDarkMode ? Colors.white70 : AppColors.textMuted,
        ),
      ),
      trailing: Icon(
        Icons.open_in_new_rounded,
        color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
        size: 20,
      ),
      onTap: () => _launchURL(url),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: isDarkMode ? Colors.white12 : AppColors.divider,
      ),
    );
  }
}