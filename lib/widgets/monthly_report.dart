// filename: ../widgets/monthly_report.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../theme/app_colors.dart';
import '../models/work_status.dart';
import '../theme/work_status_style.dart';
import '../widgets/selected_date_record.dart';
import '../widgets/work_summary_card.dart';

class MonthlyReport extends StatefulWidget {
  const MonthlyReport({super.key});

  @override
  State<MonthlyReport> createState() => _MonthlyReportState();
}

class _MonthlyReportState extends State<MonthlyReport> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  void _onDaySelected(
      DateTime selectedDay,
      DateTime focusedDay,
      ) {
    if (isSameDay(_selectedDay, selectedDay)) return;

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  final Map<DateTime, WorkStatus> _statusByDate = {
    DateTime(2026, 9, 3): WorkStatus.completed,
    DateTime(2026, 9, 4): WorkStatus.fieldWork,
    DateTime(2026, 9, 5): WorkStatus.completed,
    DateTime(2026, 9, 7): WorkStatus.absent,
    DateTime(2026, 9, 21): WorkStatus.vacation,
  };

  WorkStatus? _getStatus(DateTime day) {
    for (final entry in _statusByDate.entries) {
      if (isSameDay(entry.key, day)) {
        return entry.value;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // 월간 요약 카드
        WorkSummaryCard(workDays: '18일', totalWorkHours: '74h', averageWorkHours: '4.1h'),
        const SizedBox(height: 8,),

        // 월별 캘린더 & 해당 일자 근태 상세
        _buildCalendar(),
        if (_selectedDay != null && _getStatus(_selectedDay!) != null) ...[
          const SizedBox(height: 8),
          SelectedDateRecord(
            selectedDay: _selectedDay!,
            status: _getStatus(_selectedDay!)!, // 추후-attendanceRecord.status, 예정
          ),
        ],
      ],
    );
  }

  Widget _buildCalendar() {
   final textTheme = Theme.of(context).textTheme;
   final textColor = AppColors.primary;

   return Container(
     padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
     decoration: BoxDecoration(
       color: Colors.white, 
       borderRadius: BorderRadius.circular(24),
       border: Border.all(
         color: const Color(0xFFE5E7EB),
       ),
       boxShadow: const [
         BoxShadow(
           color: Color(0x0A000000),
           blurRadius: 8,
           offset: Offset(0, 2),
         ),
       ],
     ),
     child: TableCalendar(
       locale: 'ko_KR',
       focusedDay: _focusedDay,
       firstDay: DateTime(2020, 1, 1),
       lastDay: DateTime(2030, 12, 31),

       selectedDayPredicate: ((day) {
         return isSameDay(_selectedDay, day);
       }),

       onDaySelected: _onDaySelected,

       eventLoader: (day) {
         final status = _getStatus(day);

         if (status == null) {
           return [];
         }

         return [status];
       },

       calendarBuilders: CalendarBuilders(
         markerBuilder: (context, day, events) {
           if (events.isEmpty) return null;

           final status = events.first as WorkStatus;

           // 상태 마커 반환
           return Align(
             alignment: Alignment.bottomCenter,
             child: Container(
               width: 6,
               height: 6,
               decoration: BoxDecoration(
                 color: status.markerColor,
                 shape: BoxShape.rectangle,
                 borderRadius: BorderRadius.circular(12),
               ),
             ),
           );
         },
         selectedBuilder: (context, day, _) {
           return Container(
             margin: const EdgeInsets.all(6),
             decoration: BoxDecoration(
               color: Colors.blue.withValues(alpha: 0.15),
               border: Border.all(
                 color: Colors.blue,
                 width: 2,
               ),
               borderRadius: BorderRadius.circular(12),
             ),
             alignment: Alignment.center,
             child: Text(
               '${day.day}',
               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                 color: Colors.blue,
                 fontWeight: FontWeight.w600,
               ),
             ),
           );
         },
         todayBuilder: (context, day, focusedDay) {
           return Container(
             margin: const EdgeInsets.all(6),
             decoration: BoxDecoration(
               color: AppColors.canvassub,
               borderRadius: BorderRadius.circular(12),
             ),
             alignment: Alignment.center,
             child: Text(
               '${day.day}',
               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                 color: const Color(0xFF263244),
                 fontWeight: FontWeight.w500,
               ),
             ),
           );
         },
       ),

       // 캘린터 스타일 설정
       rowHeight: 52,
       daysOfWeekHeight: 30,

       calendarFormat: CalendarFormat.month,
       availableCalendarFormats: const {
         CalendarFormat.month: 'Month'
       },

       headerStyle: HeaderStyle(
         titleCentered: true,
       ),

       calendarStyle: CalendarStyle(
         defaultDecoration: BoxDecoration(
           shape: BoxShape.rectangle,
         ),

         selectedDecoration: const BoxDecoration(),
         selectedTextStyle: textTheme.bodyMedium!.copyWith(
           color: Colors.blue,
           fontWeight: FontWeight.w600,
         ),

         todayDecoration: const BoxDecoration(),
         todayTextStyle: textTheme.bodyMedium!.copyWith(
           color: const Color(0xFF263244),
           fontWeight: FontWeight.w500,
         ),
       ),
     ),
   );
  }
}