// filename: ../views/set_worktime_view.dart
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:oneul/widgets/common_text_field.dart';
import 'package:oneul/widgets/status_badge.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class SetWorkTimeView extends StatefulWidget {
  const SetWorkTimeView({super.key});

  @override
  State<SetWorkTimeView> createState() => _SetWorkTimeViewState();
}

class _SetWorkTimeViewState extends State<SetWorkTimeView> {
  int _workHours = 4;

  static const int _minWorkHours = 1;
  static const int _maxWorkHours = 10;

  int _selectedTimeIndex = 1;

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
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back_ios_new),
              ),

              // 3단계 진행 바
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 1,
                      minHeight: 6,
                      color: AppColors.primary,
                      backgroundColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 1,
                      minHeight: 6,
                      color: AppColors.primary,
                      backgroundColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                'STEP 2 / 3',
                style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              Text(
                '출근 시간을 정합니다',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Text('하루 소정 근로 시간과 출근 가능 시간대를 정합니다. 이 시간대 안에 출근하면 지각이 아닙니다.'),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  border: Border.all(color: AppColors.hairline),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '하루 소정 근로 시간',
                      style: theme.textTheme.titleMedium?.copyWith(
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
                          style: theme.textTheme.displaySmall?.copyWith(
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
                      '이 시간을 채우면 그날 근무가 정상 처리됩니다.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.inkFaint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                '출근 가능 시간대',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  _buildTimeSlotButton(0, '오전 8시'),
                  const SizedBox(width: 10),
                  _buildTimeSlotButton(1, '오전 9시'),
                  const SizedBox(width: 10),
                  _buildTimeSlotButton(10, '오전 10시'),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                '설정한 출근 시간의 1시간 전부터 정상 출근으로 기록돼요. '
                '최초 설정 후 한 번 더 수정할 수 있으며, 이후에는 월 1회 변경할 수 있어요.',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(28, 12, 28, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonButton(
              text: '다음',
              onPressed: () {
                context.go('/signup/workplace/worktime/goal');
              },
              version: ButtonVersion.normal,
              status: WorkStatus.beforeWork,
            ),
            // const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  context.go('/');
                },
                child: Text(
                  '건너뛰고 시작하기',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.inkFaint,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotButton(int index, String time) {
    final theme = Theme.of(context);
    final isSelected = _selectedTimeIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTimeIndex = index;
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
            '${time}',
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
