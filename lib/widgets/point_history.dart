import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_card.dart';

class PointHistory extends StatelessWidget {
  const PointHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final histories = [
      const PointHistoryData(
        title: '정시 출근',
        date: '오늘 09:12',
        point: 50,
      ),
      const PointHistoryData(
        title: '계획 완료 · 알고리즘 문제 3개',
        date: '오늘 11:40',
        point: 5,
      ),
      const PointHistoryData(
        title: '계획 완료 · 전공 인강 2강',
        date: '오늘 11:05',
        point: 5,
      ),
      const PointHistoryData(
        title: '무단 결근',
        date: '8월 25일',
        point: -40,
      ),
    ];

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '포인트 내역',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),

          ...histories.map(
                (history) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PointHistoryItem(history: history),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointHistoryItem extends StatelessWidget {
  final PointHistoryData history;

  const _PointHistoryItem({
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isGain = history.point > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                history.title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                history.date,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkFaint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '${isGain ? '+' : ''}${history.point}P',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: isGain
                ? AppColors.primaryPressed
                : AppBadges.pointLoss.foreground,
          ),
        ),
      ],
    );
  }
}

class PointHistoryData {
  final String title;
  final String date;
  final int point;

  const PointHistoryData({
    required this.title,
    required this.date,
    required this.point,
  });
}