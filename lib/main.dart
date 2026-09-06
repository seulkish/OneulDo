import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';

import 'routes/app_router.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

import 'views/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const OneulApp());
}

class OneulApp extends StatelessWidget {
  const OneulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'OneulDo: 오늘부터 나두',
      theme: AppTheme.light,
      themeMode: ThemeMode.light
    );
  }
}