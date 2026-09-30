// filename: ../widgets/monthly_report.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/work_status.dart';
import '../services/firestore_service.dart';

import '../theme/app_colors.dart';
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

  final FirestoreService _fs = FirestoreService();

  Map<DateTime, Map<String, dynamic>> _recordsByDate = {};

  bool _isLoading = false;
  String? _loadError;
  int _requestId = 0;

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Map<String, dynamic>? _getRecord(DateTime date) {
    return _recordsByDate[_normalizeDate(date)];
  }

  @override
  void initState() {
    super.initState();
    _loadMonthlyRecords();
  }

  Future<void> _loadMonthlyRecords() async {
    final requestId = ++_requestId;
    final month = _focusedDay;

    setState(() {
      _isLoading = true;
      _loadError = null;
      _recordsByDate = {};
    });

    try {
      final records = await _fs.readMonthlyAttendance(month);

      final recordsByDate = <DateTime, Map<String, dynamic>>{};

      for (final record in records) {
        final date = DateTime.parse(record['dateId'] as String);
        recordsByDate[_normalizeDate(date)] = record;
      }

      if (!mounted || requestId != _requestId) return;

      setState(() {
        _recordsByDate = recordsByDate;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('월별 근태 조회 실패: $error');

      if (!mounted || requestId != _requestId) return;

      setState(() {
        _loadError = '근태 기록을 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

  void _onDaySelected(
      DateTime selectedDay,
      DateTime focusedDay,
      ) {
    // 기존과 신규 month 비교
    final monthChanged =
        _focusedDay.year != focusedDay.year ||
            _focusedDay.month != focusedDay.month;

    // 같은 날짜면 처리하지 않음
    if (isSameDay(_selectedDay, selectedDay) && !monthChanged) return;

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    if (monthChanged) {
      _loadMonthlyRecords();
    }
  }

  WorkStatus? _getStatus(DateTime day) {
    final record = _getRecord(day);

    if (record == null) return null;

    return workStatusFromFirestore(
      record['status'] as String?,
    );
  }

  @override
  Widget build(BuildContext context) {
    final workedRecords = _recordsByDate.values.where((record) {
      return record['startedAt'] != null;
    }).toList();

    final workDays = workedRecords.length;

    final totalMinutes = workedRecords.fold<int>(
      0,
          (sum, record) =>
      sum + ((record['totalWorkedMinutes'] as num?)?.toInt() ?? 0),
    );

    final totalHours = totalMinutes / 60;
    final averageHours =
    workDays == 0 ? 0.0 : totalHours / workDays;

    return Column(
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          )
        else if (_loadError != null)
          Column(
            children: [
              Text(_loadError!),
              TextButton(
                onPressed: _loadMonthlyRecords,
                child: const Text('다시 시도'),
              ),
            ],
          )
        else ...[
            // 월간 요약 카드
            WorkSummaryCard(
              workDays: '$workDays일',
              totalWorkHours: '${totalHours.toStringAsFixed(1)}h',
              averageWorkHours: '${averageHours.toStringAsFixed(1)}h',
            ),

            if (_recordsByDate.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('이번 달의 근태 기록이 없습니다.'),
              ),

            TextButton(
              onPressed: _loadMonthlyRecords,
              child: const Text('기록 새로고침'),
            ),
          ],

        const SizedBox(height: 8),

        // 월별 캘린더 & 해당 일자 근태 상세
        _buildCalendar(),

        if (!_isLoading &&
            _loadError == null &&
            _selectedDay != null) ...[
          const SizedBox(height: 8),
          SelectedDateRecord(
            selectedDay: _selectedDay!,
            record: _getRecord(_selectedDay!),
          ),
        ],
      ],
    );
  }

  Widget _buildCalendar() {
   final textTheme = Theme.of(context).textTheme;

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

       onPageChanged: (focusedDay) {
         setState(() {
           _focusedDay = focusedDay;
           _selectedDay = DateTime(
             focusedDay.year,
             focusedDay.month,
             1,
           );
         });

         _loadMonthlyRecords();
       },

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