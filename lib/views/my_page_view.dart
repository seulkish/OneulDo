// filename: ../views/my_page_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class MyPageView extends StatelessWidget {
  const MyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text('dd'),
            CommonButton(
              text: '로그인',
              onPressed: () {
                context.go('/login');
              },
              version: ButtonVersion.login,
            ),

            const SizedBox(height: 8,),

            CommonButton(
              text: '회원가입',
              onPressed: () {
                context.go('/signup');
              },
              version: ButtonVersion.login,
            ),

            const SizedBox(height: 8,),

            CommonButton(
              text: '근무지 설정',
              onPressed: () {
                context.go('/signup/workplace');
              },
              version: ButtonVersion.login,
            ),

            const SizedBox(height: 8,),

            CommonButton(
              text: '출근시간 설정',
              onPressed: () {
                context.go('/signup/workplace/worktime');
              },
              version: ButtonVersion.login,
            ),

            const SizedBox(height: 8,),

            TextButton(
              child: Text('로그아웃'),
              onPressed: () {
                // firebase 연동 후 signOut() 추가 예정
                // await FirebaseAuth.instance.signOut();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
