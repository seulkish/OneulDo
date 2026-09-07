// filename: ../views/login_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_button.dart';
import '../widgets/common_text_field.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  // String? email;
  // String? password;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('로그인', style: theme.textTheme.displaySmall),
              const SizedBox(height: 8),

              Text(
                '1인 기업 대표이자 사원으로\n오늘도 목표를 향해 출근해 볼까요?',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('이메일', style: theme.textTheme.bodyMedium),
                  ),
                  const SizedBox(height: 8),
                  CommonTextField(label: '이메일을 입력해주세요'),
                  const SizedBox(height: 24),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('비밀번호', style: theme.textTheme.bodyMedium),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            '비밀번호 재설정',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  CommonTextField(label: '*******'), // 비밀번호 기능-isPassword: true
                ],
              ),
              const SizedBox(height: 48),

              CommonButton(
                text: '로그인',
                onPressed: () {
                  context.go('/home');
                },
                version: ButtonVersion.login,
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 18),
                    child: Text(
                      '간편 로그인',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              CommonButton(
                text: '카카오로 시작하기',
                version: ButtonVersion.kakao,
                onPressed: () {},
              ),
              const SizedBox(height: 12),

              CommonButton(
                text: '네이버로 시작하기',
                version: ButtonVersion.naver,
                onPressed: () {},
              ),
              const SizedBox(height: 12),

              CommonButton(
                text: '구글로 시작하기',
                version: ButtonVersion.google,
                icon: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    // color: const Color(0xFFD9DCE2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {},
              ),
              const SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '계정이 없으면?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      '회원가입',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
