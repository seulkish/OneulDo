// filename: widgets/selected_date_record.dart
import 'package:flutter/material.dart';

import '../models/work_status.dart';
import '../theme/app_colors.dart';
import '../theme/work_status_style.dart';
import '../widgets/status_badge.dart';

class SelectedDateRecord extends StatelessWidget {
  final DateTime selectedDay;
  final WorkStatus status;

  const SelectedDateRecord({
    super.key,
    required this.selectedDay,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE1E3E6),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${selectedDay.month}월 ${selectedDay.day}일 근태 기록',
                style: textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              StatusBadge(
                status: status,
                label: status.monthlyLabel,
              ),
              const Spacer(),
              Text(
                '* 날짜를 선택하세요',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(
                child: _WorkSummaryItem(
                  label: '출근',
                  value: '10:06',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _WorkSummaryItem(
                  label: '퇴근',
                  value: '14:44',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _WorkSummaryItem(
                  label: '근무 시간',
                  value: '10h 20m',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  '중앙도서관 3층 열람실',
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+65P',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _StudyRecordItem(
            startTime: '10:14',
            title: '자소서 2문항 다듬기',
            duration: '1시간 55분',
          ),
          const SizedBox(height: 12),
          const _StudyRecordItem(
            startTime: '12:14',
            title: '기업 분석 정리',
            duration: '1시간 30분',
          ),
          const SizedBox(height: 12),
          const _StudyRecordItem(
            startTime: '13:49',
            title: '스터디 준비',
            duration: '55분',
          ),
        ],
      ),
    );
  }
}

class _WorkSummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _WorkSummaryItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 84,
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.inkMuted,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyRecordItem extends StatelessWidget {
  final String startTime;
  final String title;
  final String duration;

  const _StudyRecordItem({
    required this.startTime,
    required this.title,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            startTime,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          duration,
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}