import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../theme/app_colors.dart';
import '../home.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const LoginPage({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
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
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage(toggleTheme: widget.toggleTheme)),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _getErrorMessage(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginAnonymously() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInAnonymously();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage(toggleTheme: widget.toggleTheme)),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _getErrorMessage(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _error = 'ยกเลิกการเข้าสู่ระบบ';
          _isLoading = false;
        });
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage(toggleTheme: widget.toggleTheme)),
        );
      }
    } catch (e) {
      setState(() => _error = 'เกิดข้อผิดพลาด กรุณาลองใหม่ค่ะ');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'ไม่พบบัญชีนี้ค่ะ';
      case 'wrong-password':
        return 'รหัสผ่านไม่ถูกต้องค่ะ';
      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้องค่ะ';
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
                      // Cute cloud character
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.softBlue.withOpacity(0.3),
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
                            // Cute face
                            Positioned(
                              bottom: 30,
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                        'Little Nimbus',
                        style: GoogleFonts.nunito(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.grayText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'เรียนรู้เรื่องเมฆแบบง่ายๆ',
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

                      // Login button
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.softBlue,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
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
                                  'เข้าสู่ระบบ',
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.lightGray,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'หรือ',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 12,
                                color: AppColors.grayText.withOpacity(0.5),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.lightGray,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),

                      // Google sign in
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.lightGray,
                            width: 1.5,
                          ),
                        ),
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/google_icon.png',
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'เข้าสู่ระบบด้วย Google',
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 14,
                                  color: AppColors.grayText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),

                      // Anonymous login
                      TextButton(
                        onPressed: _isLoading ? null : _loginAnonymously,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: Text(
                          'เข้าใช้งานแบบไม่ระบุตัวตน',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 13,
                            color: AppColors.grayText.withOpacity(0.7),
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.grayText.withOpacity(0.3),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ยังไม่มีบัญชี? ',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 13,
                              color: AppColors.grayText.withOpacity(0.7),
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RegisterPage(
                                          toggleTheme: widget.toggleTheme,
                                        ),
                                      ),
                                    );
                                  },
                            child: Text(
                              'สมัครสมาชิก',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 13,
                                color: AppColors.softBlue,
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