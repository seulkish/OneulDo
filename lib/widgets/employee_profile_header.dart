// filename: lib/widgets/employee_profile_header.dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/status_badge.dart';

class EmployeeProfileHeader extends StatelessWidget {
  final WorkStatus status;
  final String name;
  final String company;
  final String department;
  final String position;
  final String employeeNumber;
  final String imagePath;

  const EmployeeProfileHeader({
    super.key,
    required this.status,
    required this.name,
    required this.company,
    required this.department,
    required this.position,
    required this.employeeNumber,
    required this.imagePath,
  });

  Color get _backgroundColor {
    return switch (status) {
      WorkStatus.beforeWork => AppBadges.normal.background,
      WorkStatus.working => AppBadges.approved.background,
      WorkStatus.fieldWork => AppBadges.fieldWork.background,
      WorkStatus.completed => AppColors.fill,
      WorkStatus.vacation => AppBadges.vacation.background,
      WorkStatus.overtime => AppBadges.overtime.background,
      WorkStatus.absent => AppBadges.absent.background,
    };
  }

  Color get _nameColor {
    return switch (status) {
      WorkStatus.beforeWork => AppColors.primary,
      WorkStatus.working => AppColors.positive,
      WorkStatus.fieldWork => AppColors.fieldPurple,
      WorkStatus.completed => AppColors.inkMuted,
      WorkStatus.vacation => AppColors.vacation,
      WorkStatus.overtime => AppColors.positive,
      WorkStatus.absent => AppColors.taskRed,
    };
  }

  String get _message {
    return switch (status) {
      WorkStatus.beforeWork => '오늘도 활기차게 시작하세요',
      WorkStatus.working => '오늘의 근무를 진행하고 있어요',
      WorkStatus.fieldWork => '현재 외근 업무를 진행하고 있어요',
      WorkStatus.completed => '오늘도 수고하셨습니다',
      WorkStatus.vacation => '오늘은 휴가, 푹 쉬고 오세요!',
      WorkStatus.overtime => '추가 근무 중입니다',
      WorkStatus.absent => '오늘의 출근 기록이 없습니다',
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      color: _backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.field),
            child: Image.asset(
              imagePath,
              width: 120,
              height: 160,
              fit: BoxFit.cover,

              // 이미지 오류가 발생해도 화면 전체가 깨지지 않게 처리
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 160,
                  color: AppColors.fill,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.inkDisabled,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: AppSpacing.xl),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: textTheme.headlineSmall!.copyWith(
                        color: _nameColor,
                        fontWeight: FontWeight.bold,
                      ),
                      child: Text(name),
                    ),

                    StatusBadge(status: status),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                Text(
                  company,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  '$department · $position',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  'NO. $employeeNumber',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}