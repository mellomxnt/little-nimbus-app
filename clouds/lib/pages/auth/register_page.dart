import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../home.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const RegisterPage({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _error;



  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'รหัสผ่านไม่ตรงกัน');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'สมัครสมาชิกสำเร็จ',
              style: GoogleFonts.notoSansThai(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.mintGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(toggleTheme: widget.toggleTheme),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _getErrorMessage(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'อีเมลนี้มีผู้ใช้งานแล้วค่ะ';
      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้องค่ะ';
      case 'weak-password':
        return 'รหัสผ่านไม่แข็งแรงพอค่ะ';
      default:
        return 'เกิดข้อผิดพลาด กรุณาลองใหม่ค่ะ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Back button
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.lightGray,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                size: 16,
                                color: AppColors.grayText,
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Cute cloud character with different expression
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.pastelPink.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Main cloud body
                            Container(
                              width: 70,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            // Cloud puffs
                            Positioned(
                              left: 10,
                              top: 20,
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 20,
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // Cute winking eyes
                            Positioned(
                              bottom: 30,
                              child: Row(
                                children: [
                                  //Normal eye
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Normal eye
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                            
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // App name
                      Text(
                        'Register',
                        style: GoogleFonts.nunito(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.grayText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'สร้างบัญชีใหม่เพื่อเริ่มต้นใช้งาน',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 13,
                          color: AppColors.grayText.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Email field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.lightGray,
                            width: 1.5,
                          ),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.notoSansThai(
                            fontSize: 14,
                            color: AppColors.grayText,
                          ),
                          decoration: InputDecoration(
                            hintText: 'อีเมล',
                            hintStyle: GoogleFonts.notoSansThai(
                              fontSize: 14,
                              color: AppColors.grayText.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.mail_outline_rounded,
                              color: AppColors.grayText.withOpacity(0.5),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกอีเมล';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'รูปแบบอีเมลไม่ถูกต้อง';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.lightGray,
                            width: 1.5,
                          ),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.notoSansThai(
                            fontSize: 14,
                            color: AppColors.grayText,
                          ),
                          decoration: InputDecoration(
                            hintText: 'รหัสผ่าน',
                            hintStyle: GoogleFonts.notoSansThai(
                              fontSize: 14,
                              color: AppColors.grayText.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.grayText.withOpacity(0.5),
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.grayText.withOpacity(0.5),
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกรหัสผ่าน';
                            }
                            if (value.length < 6) {
                              return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Confirm Password field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.lightGray,
                            width: 1.5,
                          ),
                        ),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: GoogleFonts.notoSansThai(
                            fontSize: 14,
                            color: AppColors.grayText,
                          ),
                          decoration: InputDecoration(
                            hintText: 'ยืนยันรหัสผ่าน',
                            hintStyle: GoogleFonts.notoSansThai(
                              fontSize: 14,
                              color: AppColors.grayText.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.grayText.withOpacity(0.5),
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.grayText.withOpacity(0.5),
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณายืนยันรหัสผ่าน';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      // Error message
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.pastelPink.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _error!,
                            style: GoogleFonts.notoSansThai(
                              color: Colors.red[400],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),

                      // Register button
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.pastelPink,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'สมัครสมาชิก',
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'มีบัญชีอยู่แล้ว? ',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 13,
                              color: AppColors.grayText.withOpacity(0.7),
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(
                              'เข้าสู่ระบบ',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 13,
                                color: AppColors.pastelPink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}