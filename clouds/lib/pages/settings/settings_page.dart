import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  
  const SettingsPage({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _autoDetectEnabled = false;
  bool _saveToGallery = true;
  String _selectedLanguage = 'ภาษาไทย';
  String _imageQuality = 'สูง';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // โหลดค่าการตั้งค่าจาก SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _autoDetectEnabled = prefs.getBool('autoDetectEnabled') ?? false;
      _saveToGallery = prefs.getBool('saveToGallery') ?? true;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'ภาษาไทย';
      _imageQuality = prefs.getString('imageQuality') ?? 'สูง';
    });
  }

  // บันทึกค่าการตั้งค่าลง SharedPreferences
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
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
          'ตั้งค่า',
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
            // การแสดงผล
            _buildSectionHeader('การแสดงผล', isDarkMode),
            _buildSettingCard(
              isDarkMode: isDarkMode,
              children: [
                _buildSwitchTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'โหมดมืด',
                  subtitle: 'เปลี่ยนธีมเป็นโทนสีเข้ม',
                  value: _isDarkMode,
                  isDarkMode: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                    _saveSetting('isDarkMode', value);
                    widget.toggleTheme();
                  },
                ),
                _buildDivider(isDarkMode),
                _buildDropdownTile(
                  icon: Icons.language_rounded,
                  title: 'ภาษา',
                  value: _selectedLanguage,
                  items: ['ภาษาไทย'],
                  isDarkMode: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                    _saveSetting('selectedLanguage', value);
                  },
                ),
              ],
            ),
            
            // การแจ้งเตือน
            _buildSectionHeader('การแจ้งเตือน', isDarkMode),
            _buildSettingCard(
              isDarkMode: isDarkMode,
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_rounded,
                  title: 'การแจ้งเตือน',
                  subtitle: 'รับการแจ้งเตือนจากแอป',
                  value: _notificationsEnabled,
                  isDarkMode: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSetting('notificationsEnabled', value);
                  },
                ),
              ],
            ),
            
            
            // ข้อมูลและความเป็นส่วนตัว
            _buildSectionHeader('ข้อมูลและความเป็นส่วนตัว', isDarkMode),
            _buildSettingCard(
              isDarkMode: isDarkMode,
              children: [
                
                _buildDivider(isDarkMode),
                _buildListTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'ลบข้อมูลทั้งหมด',
                  subtitle: 'ลบประวัติและข้อมูลทั้งหมด',
                  isDarkMode: isDarkMode,
                  onTap: () => _showDeleteDataDialog(isDarkMode),
                  textColor: AppColors.error,
                ),
              ],
            ),
            
            // เกี่ยวกับ
            _buildSectionHeader('เกี่ยวกับ', isDarkMode),
            _buildSettingCard(
              isDarkMode: isDarkMode,
              children: [
                _buildListTile(
                  icon: Icons.info_outline_rounded,
                  title: 'เวอร์ชัน',
                  subtitle: 'Little Nimbus v1.0.0',
                  isDarkMode: isDarkMode,
                  onTap: () {},
                ),
                _buildDivider(isDarkMode),
                _buildListTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'นโยบายความเป็นส่วนตัว',
                  subtitle: 'อ่านนโยบายความเป็นส่วนตัว',
                  isDarkMode: isDarkMode,
                  onTap: () {},
                ),
                _buildDivider(isDarkMode),
                _buildListTile(
                  icon: Icons.description_outlined,
                  title: 'เงื่อนไขการใช้งาน',
                  subtitle: 'อ่านเงื่อนไขการใช้งาน',
                  isDarkMode: isDarkMode,
                  onTap: () {},
                ),
              ],
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: GoogleFonts.notoSansThai(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white54 : AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required List<Widget> children, required bool isDarkMode}) {
    return Container(
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
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDarkMode,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDarkMode 
              ? AppColors.darkPrimary.withOpacity(0.2) 
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
          size: 20,
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
          color: isDarkMode ? Colors.white54 : AppColors.textMuted,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required bool isDarkMode,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDarkMode 
              ? AppColors.darkPrimary.withOpacity(0.2) 
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
          size: 20,
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
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.notoSansThai(
                  fontSize: 13,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          underline: SizedBox(),
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
          ),
          borderRadius: BorderRadius.circular(8),
          dropdownColor: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDarkMode,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (textColor ?? (isDarkMode ? AppColors.darkPrimary : AppColors.primary)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: textColor ?? (isDarkMode ? AppColors.darkPrimary : AppColors.primary),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.notoSansThai(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor ?? (isDarkMode ? Colors.white : AppColors.textPrimary),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.notoSansThai(
          fontSize: 12,
          color: isDarkMode ? Colors.white54 : AppColors.textMuted,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: isDarkMode ? Colors.white38 : AppColors.textMuted,
      ),
      onTap: onTap,
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

  void _showClearCacheDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'ล้างแคช',
          style: GoogleFonts.notoSansThai(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'คุณต้องการล้างข้อมูลแคชทั้งหมดหรือไม่?',
          style: GoogleFonts.notoSansThai(
            color: isDarkMode ? Colors.white70 : AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.notoSansThai(
                color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ล้างแคชเรียบร้อยแล้ว'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'ล้าง',
              style: GoogleFonts.notoSansThai(
                color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'ลบข้อมูลทั้งหมด',
          style: GoogleFonts.notoSansThai(
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
        content: Text(
          'การดำเนินการนี้จะลบข้อมูลทั้งหมดของคุณและไม่สามารถกู้คืนได้',
          style: GoogleFonts.notoSansThai(
            color: isDarkMode ? Colors.white70 : AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.notoSansThai(
                color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ลบข้อมูลเรียบร้อยแล้ว'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text(
              'ลบ',
              style: GoogleFonts.notoSansThai(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}