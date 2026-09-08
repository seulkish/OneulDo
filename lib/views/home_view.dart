// filename: ../views/home_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/status_badge.dart';
import '../widgets/employee_profile_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 실제 데이터 연결 지점
    const status = WorkStatus.fieldWork;
    const targetTime = '09:00';
    const window = '08:00 ~ 11:00';
    const place = '중앙도서관 3층 열람실';
    const progress = 0.0; // 0.0 ~ 1.0

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('좋은 아침입니다')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 영역
                EmployeeProfileHeader(
                  status: status,
                  name: '이오늘',
                  company: '새싹컴퍼니',
                  department: 'IT개발준비팀',
                  position: '사원',
                  employeeNumber: '20260902',
                  imagePath: 'assets/images/sample_employee.png',
                ),

                // 근무 정보 및 버튼 영역
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '목표 출근 시각',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.inkFaint,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        targetTime,
                        style: textTheme.displaySmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Row(
                        children: [
                          Expanded(
                            child: _InfoBox(
                              title: '출근 가능 시간대',
                              content: window,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoBox(
                              title: '근무지',
                              content: place,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: AppColors.fill,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '소정 근로 4시간 중 ${(progress * 100).toInt()}%',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.inkFaint,
                            ),
                          ),
                          Text(
                            '4시간 0분 남음',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.inkFaint,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // AppCard 안에 CommonButton 배치
                      CommonButton(
                        text: '출근하기',
                        version: ButtonVersion.normal,
                        status: status,
                        onPressed: () {
                          // TODO: 출근 처리
                          showConfirmDialog(
                            context: context,
                            title: '출근 확인',
                            message: '현재 위치에서 출근 처리할까요?',
                            confirmText: '출근하기',
                            onConfirm: () {
                              debugPrint('출근 확인 버튼 클릭');
                            },
                          );
                        },
                      ),
                      // CommonButton(
                      //   text: '퇴근하기',
                      //   onPressed: () {
                      //     showConfirmDialog(
                      //       context: context,
                      //       title: '퇴근 확인',
                      //       message: '오늘 근무를 종료하고 퇴근 처리할까요?',
                      //       confirmText: '퇴근하기',
                      //       onConfirm: () {
                      //         debugPrint('퇴근 확인 버튼 클릭');
                      //       },
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String content;

  const _InfoBox({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 96,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.inkFaint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}