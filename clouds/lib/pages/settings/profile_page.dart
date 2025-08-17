import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _displayNameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await user?.updateDisplayName(_displayNameController.text);
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อัปเดตโปรไฟล์สำเร็จ'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
          'โปรไฟล์',
          style: GoogleFonts.notoSansThai(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check_rounded : Icons.edit_rounded,
              color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
            ),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isDarkMode 
                            ? LinearGradient(
                                colors: [AppColors.darkPrimary, AppColors.darkPrimary.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: _imageFile != null
                          ? ClipOval(
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                user?.displayName?.substring(0, 1).toUpperCase() ?? '😊',
                                style: GoogleFonts.nunito(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDarkMode ? AppColors.darkPrimary : AppColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // User Info Cards
              _buildInfoCard(
                title: 'ชื่อผู้ใช้',
                content: _isEditing
                    ? TextFormField(
                        controller: _displayNameController,
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'กรอกชื่อของคุณ',
                          hintStyle: GoogleFonts.notoSansThai(
                            color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white12 : AppColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white12 : AppColors.borderLight,
                            ),
                          ),
                          fillColor: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกชื่อ';
                          }
                          return null;
                        },
                      )
                    : Text(
                        user?.displayName ?? 'ยังไม่ได้ตั้งชื่อ',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                icon: Icons.person_outline_rounded,
                isDarkMode: isDarkMode,
              ),
              
              const SizedBox(height: 16),
              
              _buildInfoCard(
                title: 'อีเมล',
                content: Text(
                  user?.email ?? 'ไม่มีอีเมล',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                icon: Icons.email_outlined,
                isDarkMode: isDarkMode,
              ),
              
              const SizedBox(height: 16),
              
              _buildInfoCard(
                title: 'UID',
                content: Text(
                  user?.uid ?? 'ไม่มี UID',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                  ),
                ),
                icon: Icons.fingerprint_rounded,
                isDarkMode: isDarkMode,
              ),
              
              const SizedBox(height: 16),
              
              _buildInfoCard(
                title: 'วันที่สร้างบัญชี',
                content: Text(
                  user?.metadata.creationTime != null
                      ? _formatDate(user!.metadata.creationTime!)
                      : 'ไม่ทราบ',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                icon: Icons.calendar_today_rounded,
                isDarkMode: isDarkMode,
              ),
              
              
              
              const SizedBox(height: 32),
              
              // Cancel button when editing
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _displayNameController.text = user?.displayName ?? '';
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'ยกเลิก',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Widget content,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.notoSansThai(
              fontSize: 11,
              color: isDarkMode ? Colors.white54 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }
}