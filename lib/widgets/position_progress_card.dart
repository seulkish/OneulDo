// filename: widgets/position_progress_card.dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_card.dart';

class PositionProgressCard extends StatelessWidget {
  final int currentPoint;
  final String currentPosition;

  const PositionProgressCard({
    super.key,
    required this.currentPoint,
    required this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // 사원 구간: 1,000P ~ 2,000P
    const int currentLevelPoint = 1000;
    const int nextLevelPoint = 2000;

    final int remainingPoint =
    (nextLevelPoint - currentPoint).clamp(0, nextLevelPoint);

    final double progress = (
        (currentPoint - currentLevelPoint) /
            (nextLevelPoint - currentLevelPoint)
    ).clamp(0.0, 1.0);

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _PointInfo(
                  label: '현재 직급',
                  value: currentPosition,
                  valueColor: AppColors.ink,
                  valueStyle: textTheme.displaySmall,
                ),
              ),
              _PointInfo(
                label: '누적 포인트',
                value: '${_formatPoint(currentPoint)}P',
                valueColor: AppColors.primaryPressed,
                valueStyle: textTheme.displaySmall,
                crossAxisAlignment: CrossAxisAlignment.end,
              ),
            ],
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.fill,
              valueColor: const AlwaysStoppedAnimation(
                AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  '다음 직급 사원까지 ${_formatPoint(remainingPoint)}P',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkFaint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatPoint(int point) {
    return point
        .toString()
        .replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
    );
  }
}

class _PointInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final TextStyle? valueStyle;
  final CrossAxisAlignment crossAxisAlignment;

  const _PointInfo({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.valueStyle,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.inkFaint,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: valueStyle?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}