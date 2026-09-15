// filename: ../views/leave_request_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../widgets/app_bar.dart';
import '../theme/app_colors.dart';
import '../widgets/summary_item.dart';
import '../models/work_status.dart';
import '../theme/work_status_style.dart';
import '../widgets/app_button.dart';

class ApprovalHistory {
  final String type;
  final DateTime date;
  final String reason;
  final String status;

  const ApprovalHistory({
    required this.type,
    required this.date,
    required this.reason,
    this.status = '승인',
  });
}

class LeaveRequestView extends StatefulWidget {
  const LeaveRequestView({super.key});

  @override
  State<LeaveRequestView> createState() => _LeaveRequestViewState();
}

class _LeaveRequestViewState extends State<LeaveRequestView> {
  final TextEditingController _reasonController =
  TextEditingController();

  String _selectedType = '반차(오후)';
  bool _isAfternoon = true;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  final List<ApprovalHistory> _approvalHistories = [
    ApprovalHistory(
      type: '반차(오후)',
      date: DateTime(2026, 9, 4),
      reason: '사유 미기재',
    ),
    ApprovalHistory(
      type: '반차(오후)',
      date: DateTime(2026, 8, 21),
      reason: '병원 방문으로 연차 사용',
    ),
    ApprovalHistory(
      type: '연차',
      date: DateTime(2026, 8, 12),
      reason: '가족 행사',
    ),
    ApprovalHistory(
      type: '외근',
      date: DateTime(2026, 8, 3),
      reason: '채용 설명회 참석',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
          title: '전자 결재',
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
            _LeaveSummaryCard(),
            const SizedBox(height: 16),

            _LeaveConditionCard(),
            const SizedBox(height: 16),

            _LeaveRequestCard(
              selectedType: _selectedType,
              isAfternoon: _isAfternoon,
              startDate: _startDate,
              endDate: _endDate,
              reasonController: _reasonController,
              onTypeChanged: _changeType,
              onStartDateTap: _selectStartDate,
              onEndDateTap: _selectEndDate,
              onSubmit: _submitRequest,
            ),
            const SizedBox(height: 16),

            // 결재 이력
            _ApprovalHistoryCard(
              histories: _approvalHistories,
            ),
          ],
        ),
      )
    );
  }

  void _changeType(String type) {
    setState(() {
      _selectedType = type;
      _isAfternoon = type == '반차(오후)';
    });
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;

        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _submitRequest() {
    final reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사유를 입력해주세요.'),
        ),
      );
      return;
    }

    final documentNumber = 'ON-2026-0902-02';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text('결재가 상신되었습니다'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_selectedType · ${DateFormat('MM월 dd일(E)', 'ko_KR').format(_startDate)} 문서가 '
                    '결재선에 올라갔습니다.\n'
                    '결재자는 본인이므로 승인 페이지에서 직접 처리할 수 있습니다.',
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '문서번호',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      documentNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('상신 취소'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(50)
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.push('/leave/approval');
                    },
                    child: const Text('승인 페이지 가기'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(50)
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

}

class _LeaveSummaryCard extends StatelessWidget {
  const _LeaveSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB),),
      ),
      child: Row(
        children: [
          Expanded(child: SummaryItem(label: '잔여 연차', value: '3일')),
          _divider(),
          Expanded(child: SummaryItem(label: '이번달 사용', value: '10일')),
          _divider(),
          Expanded(child: SummaryItem(label: '발생 연차', value: '13일')),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE5E7EB),
    );
  }
}

class _LeaveConditionCard extends StatefulWidget {
  const _LeaveConditionCard({super.key});

  @override
  State<_LeaveConditionCard> createState() => _LeaveConditionCardState();
}

class _LeaveConditionCardState extends State<_LeaveConditionCard> {

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE1E3E6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목과 기준 월
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '연차 발생 조건',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '9월 기준',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 진행률
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.95,
              minHeight: 12,
              backgroundColor: AppColors.fill,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,//WorkStatus.vacation.progressColor,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 진행률 설명
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '이번 달 근무 74시간 / 80시간',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
              Text(
                '연차 1일 발생까지 6시간',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 연차 발생 조건 안내
          Text(
            '한 달 정한 근로를 모두 채우면 다음 달 연차 1일이 발생합니다. '
                '발생분은 최대 3일까지 이월되고, 이월분은 반차·반차로도 나눌 수 있습니다.',
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.inkMuted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaveRequestCard extends StatelessWidget {
  final String selectedType;
  final bool isAfternoon;
  final DateTime startDate;
  final DateTime endDate;
  final TextEditingController reasonController;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final VoidCallback onSubmit;

  const _LeaveRequestCard({
    required this.selectedType,
    required this.isAfternoon,
    required this.startDate,
    required this.endDate,
    required this.reasonController,
    required this.onTypeChanged,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE1E3E6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '휴가·외근·출장 신청서 기안',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            '항목 선택',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.inkMuted,
            ),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: '연차',
                child: Text('연차', style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w500
                ),),
              ),
              DropdownMenuItem(
                value: '반차(오전)',
                child: Text('반차(오전)', style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w500
                ),),
              ),
              DropdownMenuItem(
                value: '반차(오후)',
                child: Text('반차(오후)', style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w500
                ),),
              ),
              DropdownMenuItem(
                value: '외근',
                child: Text('외근', style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w500
                ),),
              ),
              DropdownMenuItem(
                value: '출장',
                child: Text('출장', style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w500
                ),),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onTypeChanged(value);
              }
            },
          ),

          if (selectedType == '반차(오전)' ||
              selectedType == '반차(오후)') ...[
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _HalfDayButton(
                    label: '오전',
                    isSelected: !isAfternoon,
                    onTap: () => onTypeChanged('반차(오전)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HalfDayButton(
                    label: '오후',
                    isSelected: isAfternoon,
                    onTap: () => onTypeChanged('반차(오후)'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              '연차 0.5일 차감',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          ],

          const SizedBox(height: 16),

          Text(
            '사용 기간',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.inkMuted,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onStartDateTap,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '시작일',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.inkFaint,
                        weight: 300,
                      ),
                    ),
                    child: Text(_formatDate(startDate)),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('~'),
              ),

              Expanded(
                child: InkWell(
                  onTap: onEndDateTap,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '종료일',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.inkFaint,
                        weight: 300,
                      ),
                    ),
                    child: Text(_formatDate(endDate)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            '사유',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.inkMuted,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: reasonController,
            maxLines: 5,
            maxLength: 50,
            decoration: const InputDecoration(
              hintText: '사유를 입력해주세요.',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 8),

          CommonButton(text: '결재 상신', onPressed: onSubmit)
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    return '${date.month}월 ${date.day}일 '
        '(${weekdays[date.weekday - 1]})';
  }
}

class _HalfDayButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HalfDayButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        foregroundColor: isSelected
            ? AppColors.primary
            : AppColors.inkMuted,
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : const Color(0xFFE1E3E6),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label),
    );
  }
}

class _ApprovalHistoryCard extends StatelessWidget {
  final List<ApprovalHistory> histories;

  const _ApprovalHistoryCard({
    required this.histories,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE1E3E6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '결재 이력',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          for (int index = 0; index < histories.length; index++) ...[
            _ApprovalHistoryItem(
              history: histories[index],
            ),
            if (index != histories.length - 1)
              const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _ApprovalHistoryItem extends StatelessWidget {
  final ApprovalHistory history;

  const _ApprovalHistoryItem({
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${history.type} · ${_formatDate(history.date)}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  history.reason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F5DE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              history.status,
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF23812D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    return '${date.month}월 ${date.day}일 '
        '(${weekdays[date.weekday - 1]})';
  }
}