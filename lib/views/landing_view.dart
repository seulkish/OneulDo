import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF316DE6),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          context.go('/login');
        },
        child: SafeArea(
          child: Stack(
            children: [
              // 기존 로고/문구
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

              // 남자 이미지
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Image.asset(
                  'assets/images/landing_man.png',
                  fit: BoxFit.contain,
                ),
              ),

              // 이미지 위 안내 문구
              const Positioned(
                left: 0,
                right: 0,
                bottom: 35,
                child: Text(
                  '화면을 눌러 시작하기',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
