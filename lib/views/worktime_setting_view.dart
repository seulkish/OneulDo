import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/firestore_service.dart';

import '../widgets/sub_page_app_bar.dart';
import '../widgets/app_button.dart';
import '../widgets/common_text_field.dart';

import '../models/work_status.dart';

import '../theme/app_colors.dart';

class WorktimeSettingView extends StatefulWidget {
  const WorktimeSettingView({super.key});

  @override
  State<WorktimeSettingView> createState() => _WorktimeSettingViewState();
}

class _WorktimeSettingViewState extends State<WorktimeSettingView> {
  final FirestoreService _fs = FirestoreService();

  int _workHours = 4;
  int _selectedStartHour = 9;
  bool _isSaving = false;

  static const int _minWorkHours = 1;
  static const int _maxWorkHours = 10;

  // int _selectedTimeIndex = 1;

  void _decreaseWorkHours() {
    if (_workHours <= _minWorkHours) return;

    setState(() {
      _workHours--;
    });
  }

  void _increaseWorkHours() {
    if (_workHours >= _maxWorkHours) return;

    setState(() {
      _workHours++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: SubPageAppBar(
        title: '근무 시간 설정',
        position: '사원'
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '하루 소정 근로 시간',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _WorkHourButton(
                        icon: Icons.remove,
                        onPressed: _workHours > _minWorkHours
                            ? _decreaseWorkHours
                            : null,
                      ),

                      Text(
                        '$_workHours시간',
                        style: textTheme.displaySmall?.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),

                      _WorkHourButton(
                        icon: Icons.add,
                        onPressed: _workHours < _maxWorkHours
                            ? _increaseWorkHours
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _workHours / _maxWorkHours,
                      minHeight: 13,
                      backgroundColor: AppColors.fill,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    '이 시간을 채우면 그날 근무가 정상 처리됩니다. '
                    '2시간부터 10시간까지 설정할 수 있습니다.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkFaint,
                    ),
                  ),

                  Text('* 단, 1달에 1번만 변경 가능하니 신중하게 수정해주세요.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '출근 가능 시간대',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      _buildTimeSlotButton(8, '오전 8시'),
                      const SizedBox(width: 10),
                      _buildTimeSlotButton(9, '오전 9시'),
                      const SizedBox(width: 10),
                      _buildTimeSlotButton(10, '오전 10시'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text.rich(
                    TextSpan(
                      style: textTheme.bodyMedium,
                      children: [
                        const TextSpan(
                          text: '설정한 출근 시간의 1시간 전부터 정상 출근으로 기록돼요. ',
                        ),
                        TextSpan(
                          text: '최초 설정 후 한 번 더 수정할 수 있으며, 이후에는 월 1회 변경할 수 있어요.',
                          style: const TextStyle(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ),
            const SizedBox(height: 16,),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '근무 시간 적용 결과',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _ResultRow(
                    label: '정상 처리 기준',
                    value: '하루 4시간 충족',
                  ),
                  const SizedBox(height: 12),

                  _ResultRow(
                    label: '지각 기준',
                    value: '11:00 이후 출근',
                  ),
                  const SizedBox(height: 12),

                  _ResultRow(
                    label: '퇴근 예정 시간',
                    value: '15:00',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(28, 12, 28, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonButton(
              text: _isSaving ? '저장 중...' : '변경사항 저장',
              onPressed: _isSaving ? null : _saveWorkTime,
              version: ButtonVersion.normal,
              status: WorkStatus.beforeWork,
            ),
            // const SizedBox(height: 8),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _saveWorkTime() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    // 분으로 바꿔서 계산
    final int targetStartMinutes = _selectedStartHour * 60;
    final int availableStartMinutes = targetStartMinutes - 60;
    final int availableEndMinutes = targetStartMinutes;
    final int dailyWorkMinutes = _workHours * 60;

    try {
      await _fs.updateWorkTime(
        dailyWorkMinutes: dailyWorkMinutes,
        availableStartMinutes: availableStartMinutes,
        availableEndMinutes: availableEndMinutes,
      );

      if (!mounted) return;
      context.pop();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('근무 시간 저장에 실패했습니다.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildTimeSlotButton(int hour, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedStartHour == hour;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStartHour = hour;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Text(
            '${label}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isSelected ? AppColors.primary : AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkHourButton extends StatelessWidget {
  const _WorkHourButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final double spacing = 72;
    return SizedBox(
      width: spacing,
      height: spacing,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: AppColors.ink,
          disabledForegroundColor: AppColors.inkDisabled,
          side: const BorderSide(color: AppColors.hairline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Icon(icon, size: 28),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.inkMuted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          textAlign: TextAlign.end,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}