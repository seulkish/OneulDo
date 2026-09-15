import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_card.dart';

class PromotionStep {
  final String position;
  final int requiredPoint;

  const PromotionStep({
    required this.position,
    required this.requiredPoint,
  });
}

class PositionPathCard extends StatelessWidget {
  final String currentPosition;

  const PositionPathCard ({
    super.key,
    required this.currentPosition,
  });

  static const List<PromotionStep> steps = [
    PromotionStep(position: '인턴', requiredPoint: 0),
    PromotionStep(position: '사원', requiredPoint: 1000),
    PromotionStep(position: '주임', requiredPoint: 2000),
    PromotionStep(position: '대리', requiredPoint: 3500),
    PromotionStep(position: '과장', requiredPoint: 5500),
    PromotionStep(position: '차장', requiredPoint: 8000),
    PromotionStep(position: '부장', requiredPoint: 11000),
    PromotionStep(position: '이사', requiredPoint: 15000),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '승진 경로',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 18),

          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isCurrent = step.position == currentPosition;
            final isCompleted =
                index < steps.indexWhere(
                      (item) => item.position == currentPosition,
                );

            return _PromotionTimelineItem(
              step: step,
              isCurrent: isCurrent,
              isCompleted: isCompleted,
              isLast: index == steps.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _PromotionTimelineItem extends StatelessWidget {
  final PromotionStep step;
  final bool isCurrent;
  final bool isCompleted;
  final bool isLast;

  const _PromotionTimelineItem({
    required this.step,
    required this.isCurrent,
    required this.isCompleted,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final titleColor = isCurrent || isCompleted
        ? AppColors.ink
        : AppColors.inkFaint;

    final pointText = step.requiredPoint == 0
        ? '가입 시'
        : '누적 ${_formatPoint(step.requiredPoint)}P';

    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 세로 타임라인
          SizedBox(
            width: 30,
            height: 100,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 16,
                    bottom: -1,
                    child: Container(
                      width: 3,
                      color: AppColors.divider,
                    ),
                  ),

                Positioned(
                  top: 5,
                  child: _TimelineDot(
                    isCurrent: isCurrent,
                    isCompleted: isCompleted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // 직급 및 포인트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.position,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pointText,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: AppColors.inkFaint,
                  ),
                ),
              ],
            ),
          ),

          // 현재 상태
          if (isCurrent)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '현재',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else if (isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '달성',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: AppColors.inkFaint,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatPoint(int point) {
    return point.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final bool isCurrent;
  final bool isCompleted;

  const _TimelineDot({
    required this.isCurrent,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (isCurrent) {
      return Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFDCE8FF),
        ),
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? AppColors.inkDisabled
            : AppColors.hairline,
      ),
    );
  }
}