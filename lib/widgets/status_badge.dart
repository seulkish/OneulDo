// filename: ../widgets/status_badge.dart

import 'package:flutter/material.dart';
import 'package:oneul/theme/app_colors.dart';
import '../theme/app_theme.dart';

enum WorkStatus { beforeWork, working, fieldWork, completed, vacation, overtime, absent }

class StatusBadge extends StatelessWidget {
  final WorkStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final String text;
    final BadgeColors colors;
    final textTheme = Theme.of(context).textTheme;

    switch (status) {
      case WorkStatus.beforeWork:
        text = '출근 전';
        colors = AppBadges.notStarted;
      case WorkStatus.working:
        text = '근무 중';
        colors = AppBadges.normal;

      case WorkStatus.fieldWork:
        text = '외근 중';
        colors = AppBadges.fieldWork;

      case WorkStatus.completed:
        text = '퇴근 완료';
        colors = AppBadges.done;

      case WorkStatus.vacation:
        text = '휴가 중';
        colors = AppBadges.vacation;

      case WorkStatus.overtime:
        text = '야근 중';
        colors = AppBadges.overtime;

      case WorkStatus.absent:
        text = '결근';
        colors = AppBadges.absent;
    }
    ;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      width: text.length * 20,
      child: Row(
        children: [
          Text(
            text,
            style: textTheme.labelSmall,
          ),
          const SizedBox(width: 6,),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: colors.foreground,
              shape: BoxShape.circle
            ),
          )
        ],
      ),
    );
  }
}
