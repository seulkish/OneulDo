import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // 첫 화면을 그린 뒤 인증 상태 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkLogin();
    });
  }

  Future<void> _checkLogin() async {
    setState(() => _hasError = false);

    try {
      final user =
      await FirebaseAuth.instance.authStateChanges().first;

      if (!mounted) return;

      context.go(user == null ? '/login' : '/');
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF316DE6),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Text(
                '오늘도\n매일 매일\n출근✓',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/landing_man.png',
                fit: BoxFit.contain,
              ),
            ),
            if (_hasError)
              Positioned(
                left: 24,
                right: 24,
                bottom: 35,
                child: Column(
                  children: [
                    const Text(
                      '로그인 상태를 확인하지 못했어요.',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: _checkLogin,
                      child: const Text(
                        '다시 시도',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}