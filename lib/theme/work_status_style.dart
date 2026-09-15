// filename: ../theme/work_status_style.dart
import 'package:flutter/material.dart';

import '../models/work_status.dart';
import 'app_colors.dart';

extension WorkStatusStyle on WorkStatus {
  String get label => switch (this) {
    WorkStatus.beforeWork => '출근 전',
    WorkStatus.working => '근무 중',
    WorkStatus.fieldWork => '외근 중',
    WorkStatus.completed => '퇴근 완료',
    WorkStatus.vacation => '휴가 중',
    WorkStatus.overtime => '야근 중',
    WorkStatus.absent => '결근',
  };

  String get monthlyLabel {
    switch (this) {
      case WorkStatus.beforeWork:
        return '미확인';
      case WorkStatus.working:
      case WorkStatus.completed:
        return '정상 출근';
      case WorkStatus.fieldWork:
        return '외근';
      case WorkStatus.vacation:
        return '휴가';
      case WorkStatus.overtime:
        return '추가 근무';
      case WorkStatus.absent:
        return '결근';
      // default:
      //   return label;
    }
  }

  Color get progressColor => switch (this) {
    WorkStatus.beforeWork => AppColors.primary,
    WorkStatus.working => AppColors.positive,
    WorkStatus.fieldWork => AppColors.fieldPurple,
    WorkStatus.completed => AppColors.inkMuted,
    WorkStatus.vacation => AppColors.vacation,
    WorkStatus.overtime => AppColors.liveGreen,
    WorkStatus.absent => AppColors.taskRed,
    null => AppColors.primary,
  };

  BadgeColors get badgeColors => switch (this) {
    WorkStatus.beforeWork || WorkStatus.working => AppBadges.normal,
    WorkStatus.fieldWork => AppBadges.fieldWork,
    WorkStatus.completed => AppBadges.done,
    WorkStatus.vacation => AppBadges.vacation,
    WorkStatus.overtime => AppBadges.overtime,
    WorkStatus.absent => AppBadges.absent,
    null => AppBadges.normal,
  };
  // 월간 캘린더 상태 색상 : 글자색 사용
  Color get markerColor => badgeColors.foreground;
}
