// filename: ../views/study_record_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/position_badge.dart';
import '../widgets/app_bar.dart';
import '../widgets/period_tab.dart';
import '../widgets/weekly_report.dart';
import '../widgets/monthly_report.dart';

import '../models/work_status.dart';
import '../theme/work_status_style.dart';

class StudyRecordView extends StatefulWidget {
  const StudyRecordView({super.key});

  @override
  State<StudyRecordView> createState() => _StudyRecordViewState();
}

class _StudyRecordViewState extends State<StudyRecordView> {
  PeriodType _selectedPeriod = PeriodType.weekly;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvassub,
      appBar: CommonAppBar(
          title: '근태 리포트',
          subtitle: '매일 매일, 성실하게 그리고 꾸준하게도'
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          children: [
            PeriodTab(
              selectedPeriod: _selectedPeriod,
              onChanged: (period) {
                setState(() {
                  _selectedPeriod = period;
                });
              }
            ),

            const SizedBox(height: 16),

            if (_selectedPeriod == PeriodType.weekly)
              const WeeklyReport()
            else
              const MonthlyReport()
          ],
        ),
      )
    );
  }
}



