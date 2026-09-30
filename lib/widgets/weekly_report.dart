// filename: ../widgets/weekly_report.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/work_status.dart';
import '../services/firestore_service.dart';

import '../theme/app_colors.dart';
import '../theme/work_status_style.dart';

import '../widgets/selected_date_record.dart';
import '../widgets/work_summary_card.dart';

class WeeklyReport extends StatefulWidget {
  const WeeklyReport({super.key});

  @override
  State<WeeklyReport> createState() => _WeeklyReportState();
}

class _WeeklyReportState extends State<WeeklyReport> {
  final FirestoreService _fs = FirestoreService();

  DateTime _selectedDay = DateTime.now();

  Map<DateTime, Map<String, dynamic>> _recordsByDate = {};
  bool _isLoading = true;
  String? _loadError;

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  void initState() {
    super.initState();
    _loadWeeklyRecords();
  }

  Future<void> _loadWeeklyRecords() async {
    final selectedDate = _dateOnly(_selectedDay);

    // 월요일부터 다음 월요일 직전까지 조회
    final startOfWeek = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final records = await _fs.readAttendanceByPeriod(
        startDate: startOfWeek,
        endDateExclusive: startOfWeek.add(const Duration(days: 7)),
      );

      final recordsByDate = <DateTime, Map<String, dynamic>>{};

      for (final record in records) {
        final date = DateTime.parse(record['dateId'] as String);
        recordsByDate[_dateOnly(date)] = record;
      }

      if (!mounted) return;

      setState(() {
        _recordsByDate = recordsByDate;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('주간 근태 조회 실패: $error');

      if (!mounted) return;

      setState(() {
        _loadError = '주간 근태 기록을 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Column(
        children: [
          Text(_loadError!),
          TextButton(onPressed: _loadWeeklyRecords, child: const Text('다시 시도')),
        ],
      );
    }

    // 기존 그래프에 전달할 상태와 근무시간
    final statusByDate = <DateTime, WorkStatus>{};
    final minutesByDate = <DateTime, int>{};

    for (final entry in _recordsByDate.entries) {
      statusByDate[entry.key] = workStatusFromFirestore(
        entry.value['status'] as String?,
      );

      minutesByDate[entry.key] =
          (entry.value['totalWorkedMinutes'] as num?)?.toInt() ?? 0;
    }

    final workDays = _recordsByDate.values.where((record) {
      return record['startedAt'] != null;
    }).length;

    final totalMinutes = minutesByDate.values.fold<int>(
      0,
      (sum, minutes) => sum + minutes,
    );

    final totalHours = totalMinutes / 60;
    final averageHours = workDays == 0 ? 0.0 : totalHours / workDays;

    return Column(
      children: [
        // 주간 요약 카드
        WorkSummaryCard(
          workDays: '$workDays일',
          totalWorkHours: '${totalHours.toStringAsFixed(1)}h',
          averageWorkHours: '${averageHours.toStringAsFixed(1)}h',
        ),

        const SizedBox(height: 8),

        // 요일별 근무시간 & 해당 일자 근태 상세
        WeeklyWorkChart(
          selectedDay: _selectedDay,
          statusByDate: statusByDate,
          minutesByDate: minutesByDate,
          onDaySelected: (day) {
            if (isSameDay(_selectedDay, day)) return;
            setState(() {
              _selectedDay = day;
            });
          },
        ),

        const SizedBox(height: 8),

        SelectedDateRecord(
          selectedDay: _selectedDay,
          record: _recordsByDate[_dateOnly(_selectedDay)],
        ),
      ],
    );
  }
}

class WeeklyWorkChart extends StatelessWidget {
  final DateTime selectedDay;
  final Map<DateTime, WorkStatus> statusByDate;
  final Map<DateTime, int> minutesByDate;
  final ValueChanged<DateTime> onDaySelected;

  const WeeklyWorkChart({
    super.key,
    required this.selectedDay,
    required this.statusByDate,
    required this.minutesByDate,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final startOfWeek = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    ).subtract(Duration(days: selectedDay.weekday - 1));

    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    final workHours = weekDays.map((day) {
      final date = DateTime(day.year, day.month, day.day);
      return (minutesByDate[date] ?? 0) / 60;
    }).toList();

    final totalMinutes = weekDays.fold<int>(0, (sum, day) {
      final date = DateTime(day.year, day.month, day.day);
      return sum + (minutesByDate[date] ?? 0);
    });

    // 실제 근무시간이 길어도 그래프 영역을 넘지 않도록 높이 조절
    final maxHours = workHours.fold<double>(
      0,
      (max, hours) => hours > max ? hours : max,
    );

    const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E3E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 주 '
            '(${weekDays.first.month}/${weekDays.first.day}'
            ' ~ ${weekDays.last.month}/${weekDays.last.day})',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),

          const SizedBox(height: 8),

          Text(
            '${totalMinutes ~/ 60}시간 ${totalMinutes % 60}분',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(weekDays.length, (index) {
                final day = weekDays[index];
                final hours = workHours[index];
                final isSelected = isSameDay(selectedDay, day);

                final normalizedDay = DateTime(day.year, day.month, day.day);

                final status =
                    statusByDate[normalizedDay] ?? WorkStatus.beforeWork;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onDaySelected(day),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            minutesByDate.containsKey(normalizedDay)
                                ? '${hours.toStringAsFixed(1)}h'
                                : '-',
                            style: TextStyle(
                              color: isSelected ? AppColors.ink : Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 8),

                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 42,
                            height: hours > 0 ? (hours / maxHours) * 100 : 10,
                            decoration: BoxDecoration(
                              color: status == WorkStatus.beforeWork
                                  ? AppColors.inkFaint.withValues(alpha: 0.15)
                                  : status.progressColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE1E3E6),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            dayLabels[index],
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
