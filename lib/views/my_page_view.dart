// filename: ../views/my_page_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyPageView extends StatelessWidget {
  const MyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('마이페이지'),
      ),
    );
  }
}
