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
          ],
        ),
      ),
    );
  }
}
