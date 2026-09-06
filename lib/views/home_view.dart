// filename: ../views/home_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘부터'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/login'),
          child: const Text('로그인 화면으로'),
        ),
      ),
    );
  }
}