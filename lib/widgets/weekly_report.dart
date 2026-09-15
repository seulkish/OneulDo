// filename: ../widgets/weekly_report.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../theme/app_colors.dart';
import '../models/work_status.dart';
import '../theme/work_status_style.dart';
import '../widgets/selected_date_record.dart';
import '../widgets/work_summary_card.dart';

class WeeklyReport extends StatefulWidget {
  const WeeklyReport ({super.key});

  @override
  State<WeeklyReport> createState() => _WeeklyReportState();
}

class _WeeklyReportState extends State<WeeklyReport> {
  DateTime _selectedDay = DateTime.now();

  final Map<DateTime, WorkStatus> _statusByDate = {
    DateTime(2026, 9, 14): WorkStatus.completed,
    DateTime(2026, 9, 15): WorkStatus.completed,
    DateTime(2026, 9, 16): WorkStatus.working,
    DateTime(2026, 9, 17): WorkStatus.fieldWork,
  };

  WorkStatus _getStatus(DateTime day) {
    final normalizedDay = DateTime(
      day.year,
      day.month,
      day.day,
    );

    return _statusByDate[normalizedDay] ?? WorkStatus.beforeWork;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 주간 요약 카드
        WorkSummaryCard(workDays: '18일', totalWorkHours: '74h', averageWorkHours: '4.1h'),
        const SizedBox(height: 8,),
        // 요일별 근무시간 & 해당 일자 근태 상세
        WeeklyWorkChart(
          selectedDay: _selectedDay,
          statusByDate: _statusByDate,
          onDaySelected: (day) {
            setState(() {
              _selectedDay = day;
            });
          },
        ),

        const SizedBox(height: 8),

        SelectedDateRecord(
          selectedDay: _selectedDay,
          status: _getStatus(_selectedDay),
        ),
      ],
    );
  }
}

class WeeklyWorkChart extends StatelessWidget {
  final DateTime selectedDay;
  final Map<DateTime, WorkStatus> statusByDate;
  final ValueChanged<DateTime> onDaySelected;

  const WeeklyWorkChart({
    super.key,
    required this.selectedDay,
    required this.statusByDate,
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

    final workHours = <double>[
      1.5,
      4.3,
      4.3,
      3.2,
      0,
      0,
      0,
    ];

    const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

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
          Text(
            '이번 주 '
                '(${weekDays.first.month}/${weekDays.first.day}'
                ' ~ ${weekDays.last.month}/${weekDays.last.day})',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '11시간 53분',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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

                final normalizedDay = DateTime(
                  day.year,
                  day.month,
                  day.day,
                );

                final status =
                    statusByDate[normalizedDay] ?? WorkStatus.beforeWork;

                // debugPrint(
                //   '${day.month}/${day.day} | $status | ${status.progressColor}',
                // );
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onDaySelected(day),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            hours > 0 ? '${hours.toStringAsFixed(1)}h' : '예정',
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.ink
                                  : Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 8),

                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 42,
                            height: hours > 0 ? hours * 22 : 10,
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