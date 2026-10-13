import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'routes/app_router.dart';
import '../theme/app_theme.dart';

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('ko_KR');

  usePathUrlStrategy();
  runApp(const OneulApp());
}

const double kMaxScreenWidth = 500.0; // web에서 앱이 차지할 최대 너비
const double kMinScreenHeight = 800.0;// web에서 앱이 차지할 최소 높이

class OneulApp extends StatelessWidget {
  const OneulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'OneulDo: 오늘부터 나두',
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: router,
      // max 고정
      builder: (context, child) {
        if (!kIsWeb) return child!;
        final mediaQuery = MediaQuery.of(context);
        final width = min(mediaQuery.size.width, kMaxScreenWidth);
        final height = max(mediaQuery.size.height, kMinScreenHeight);
        return ColoredBox(
          color: Colors.grey.shade200,
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: width,
                height: height,
                child: MediaQuery(
                  data: mediaQuery.copyWith(size: Size(width, height)),
                  child: child!,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}