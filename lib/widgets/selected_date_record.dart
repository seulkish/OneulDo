// filename: widgets/selected_date_record.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/work_status.dart';
import '../theme/app_colors.dart';
import '../theme/work_status_style.dart';
import '../widgets/status_badge.dart';

class SelectedDateRecord extends StatelessWidget {
  final DateTime selectedDay;
  final Map<String, dynamic>? record;

  const SelectedDateRecord({
    super.key,
    required this.selectedDay,
    required this.record,
  });

  String _formatTime(dynamic value) {
    if (value is! Timestamp) return '-';

    final koreaTime =
    value.toDate().toUtc().add(const Duration(hours: 9));

    return '${koreaTime.hour.toString().padLeft(2, '0')}:'
        '${koreaTime.minute.toString().padLeft(2, '0')}';
  }

  int _minutes(dynamic value) {
    return (value as num?)?.toInt() ?? 0;
  }

  String _formatDuration(int minutes) {
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final data = record;

    final status = data == null
        ? null
        : workStatusFromFirestore(data['status'] as String?);

    final totalMinutes = _minutes(data?['totalWorkedMinutes']);
    final fieldWorkMinutes = _minutes(data?['fieldWorkMinutes']);
    final overtimeMinutes = _minutes(data?['overtimeMinutes']);

    final isWorking =
        status == WorkStatus.working ||
            status == WorkStatus.fieldWork ||
            status == WorkStatus.overtime;

    final attendanceLabel = switch (data?['attendanceStatus']) {
      'normal' => '정상 출근',
      'late' => '지각',
      _ => null,
    };

    final workplaceName = data?['workplaceName'] as String?;
    final earnedPoint = (data?['earnedPoint'] as num?)?.toInt();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 좁은 화면에서도 제목과 배지가 넘치지 않도록 Wrap 사용
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${selectedDay.month}월 '
                    '${selectedDay.day}일 근태 기록',
                style: textTheme.titleMedium,
              ),
              if (status != null)
                StatusBadge(
                  status: status,
                  label: status.label,
                ),
            ],
          ),

          const SizedBox(height: 20),

          if (data == null)
            Text(
              '해당 날짜의 근태 기록이 없습니다.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _WorkSummaryItem(
                    label: '출근',
                    value: _formatTime(data['startedAt']),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _WorkSummaryItem(
                    label: '퇴근',
                    value: _formatTime(data['endedAt']),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _WorkSummaryItem(
                    label: '근무 시간',
                    value: _formatDuration(totalMinutes),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (attendanceLabel != null)
              Text(
                '출근 구분: $attendanceLabel',
                style: textTheme.bodyMedium,
              ),

            if (fieldWorkMinutes > 0) ...[
              const SizedBox(height: 8),
              Text(
                '외근 시간: ${_formatDuration(fieldWorkMinutes)}',
                style: textTheme.bodyMedium,
              ),
            ],

            if (overtimeMinutes > 0 ||
                data['overtimeStartedAt'] != null) ...[
              const SizedBox(height: 8),
              Text(
                '추가 근무 시간: ${_formatDuration(overtimeMinutes)}',
                style: textTheme.bodyMedium,
              ),
              Text(
                '추가 근무 종료: '
                    '${_formatTime(data['overtimeEndedAt'])}',
                style: textTheme.bodyMedium,
              ),
            ],

            if (isWorking) ...[
              const SizedBox(height: 8),
              Text(
                '근무 시간은 종료 후 저장된 값으로 반영됩니다.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
            ],

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    workplaceName == null || workplaceName.isEmpty
                        ? '근무지 정보 없음'
                        : workplaceName,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium,
                  ),
                ),
                if (earnedPoint != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${earnedPoint >= 0 ? '+' : ''}${earnedPoint}P',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
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