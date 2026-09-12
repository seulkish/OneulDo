import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/common_text_field.dart';
import '../widgets/app_button.dart';
import '../models/schedule.dart';

class AddScheduleBottomSheet extends StatefulWidget {
  const AddScheduleBottomSheet({super.key});

  @override
  State<AddScheduleBottomSheet> createState() => _AddScheduleBottomSheetState();
}

class _AddScheduleBottomSheetState extends State<AddScheduleBottomSheet> {
  final TextEditingController _titleController = TextEditingController();

  TimeOfDay? _selectedTime;

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: '일정 시간 선택',
      cancelText: '취소',
      confirmText: '선택',
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.fill,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            '일정 추가',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '오늘 진행할 일정을 등록해보세요.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.inkFaint,
            ),
          ),

          const SizedBox(height: 24),

          Column(
            children: [
              CommonTextField(
                label: '일정 등록',
                hint: '예: 알고리즘 문제 3개 풀기',
                controller: _titleController,
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.fill),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedTime == null
                              ? '시간을 선택해주세요'
                              : _formatTime(_selectedTime!),
                          style: textTheme.bodyLarge?.copyWith(
                            color: _selectedTime == null
                                ? AppColors.inkFaint
                                : AppColors.ink,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.inkFaint,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              CommonButton(
                text: '추가하기',
                onPressed: () {
                  final title = _titleController.text.trim();

                  if (title.isEmpty || _selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('일정과 시간을 모두 입력해주세요.'),
                      ),
                    );
                    return;
                  }

                  final newSchedule = Schedule(
                    time: _formatTime(_selectedTime!),
                    title: title,
                    status: ScheduleStatus.remaining,
                  );

                  Navigator.pop(context, newSchedule);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
