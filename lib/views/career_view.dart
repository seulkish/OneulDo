// filename: ../views/career_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oneul/widgets/app_bar.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/position_badge.dart';
import '../widgets/position_progress_card.dart';
import '../widgets/position_path_card.dart';
import '../widgets/point_history.dart';

import '../models/work_status.dart';
import '../theme/work_status_style.dart';

class CareerView extends StatelessWidget {
  final WorkStatus status;
  const CareerView({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentPosition = '사원';

    return Scaffold(
      backgroundColor: AppColors.canvassub,
      appBar: CommonAppBar(
          title: '커리어',
          subtitle: '매일 매일, 성실하게 그리고 꾸준하게도'
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              PositionProgressCard(currentPoint: 1240, currentPosition: currentPosition,),
              const SizedBox(height: 16),
              const PointHistory(),
              const SizedBox(height: 16),
              PositionPathCard(currentPosition: currentPosition),
              TextButton(
                child: Text('홈으로 가기'),
                onPressed: () {
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
