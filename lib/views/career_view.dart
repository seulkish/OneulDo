// filename: ../views/career_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class CareerView extends StatelessWidget {
  const CareerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CommonButton(
              text: '홈으로 가기',
              onPressed: (){context.go('/');},
              version: ButtonVersion.login,
            ),
          ],
        ),
      ),
    );
  }
}
