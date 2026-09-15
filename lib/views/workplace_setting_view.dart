// filename: views/workplace_setting_view.dart
import 'package:flutter/material.dart';

import '../widgets/app_bar.dart';
import '../theme/app_colors.dart';

class WorkplaceSettingView extends StatelessWidget {
  const WorkplaceSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvassub,
      appBar: const CommonAppBar(
        title: '근무지 설정',
        subtitle: '출퇴근을 인증할 장소를 관리해요',
      ),
      body: const Center(
        child: Text('근무지 설정 화면'),
      ),
    );
  }
}