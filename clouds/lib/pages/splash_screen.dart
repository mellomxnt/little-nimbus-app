import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Widget Function() getNextPage; // ✅ เปลี่ยนจาก Widget เป็น Function

  const SplashScreen({
    Key? key,
    required this.toggleTheme,
    required this.getNextPage, // ✅ ใช้ function แทน widget
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.getNextPage(), // ✅ เรียก function เพื่อ get หน้า
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/logo.png',
            width: screenWidth * 0.6,
          ),
        ),
      ),
    );
  }
}
