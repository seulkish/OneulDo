// filename: ../views/home_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../services/firestore_service.dart';

import '../theme/app_colors.dart';
import '../theme/work_status_style.dart';

import '../widgets/add_schedule_bottom_sheet.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/app_bar.dart';
import '../widgets/employee_profile_header.dart';

import '../models/schedule.dart';
import '../models/work_status.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirestoreService _fs = FirestoreService();

  String _nickname = '';
  String _jobTitle = '인턴';
  int _totalPoints = 0;
  String _profileImageUrl = 'assets/images/sample_employee.png';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final data = await _fs.readUser();
      if (!mounted || data == null) return;

      setState(() {
        _nickname = data['nickname'] ?? '';
        _jobTitle = data['jobTitle'] ?? '인턴';
        _totalPoints = (data['point'] as num?)?.toInt() ?? 0;
        _profileImageUrl = data['profileImageUrl'] ?? 'assets/images/sample_employee.png' ;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용자 정보를 불러오지 못했습니다.'),
        ),
      );
    }
  }

  WorkStatus _status = WorkStatus.beforeWork;
  double _progress = 0.1;

  Timer? _workTimer;
  DateTime? _workStartedAt;
  DateTime? _workEndedAt;
  Duration _workedDuration = Duration.zero;
  String get _formattedWorkedTime {
    final hours = _workedDuration.inHours.toString().padLeft(2, '0');
    final minutes = (_workedDuration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_workedDuration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }
  String _formatClockTime(DateTime? time) {
    if (time == null) return '--:--';

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String get _formattedTotalWorkTime {
    final hours = _workedDuration.inHours;
    final minutes = _workedDuration.inMinutes % 60;

    return '${hours}시간 ${minutes}분';
  }

  // TODO: 실제 시간 및 GPS 검사 결과로 교체
  bool _isWithinWorkTime = true;
  bool _isWithinWorkplace = true;

  bool get _isWorking => _status == WorkStatus.working || _status == WorkStatus.overtime;

  bool get _canStartWork {
    return _status == WorkStatus.beforeWork &&
        _isWithinWorkTime &&
        _isWithinWorkplace;
  }

  String? get _unavailableReason {
    if (_status == WorkStatus.vacation) {
      return '오늘은 휴가 일정으로 출근할 수 없습니다.';
    }

    if (_status == WorkStatus.completed) {
      return '오늘의 근무가 이미 완료되었습니다.';
    }

    if (_status != WorkStatus.beforeWork) {
      return null;
    }

    if (!_isWithinWorkTime) {
      return '출근 가능 시간대가 아닙니다.';
    }

    if (!_isWithinWorkplace) {
      return '지정된 근무지 반경 안에서만 출근할 수 있습니다.';
    }

    return null;
  }

  void _confirmStartWork() {
    if (!_canStartWork) return;

    showConfirmDialog(
      context: context,
      title: '출근 확인',
      message: '현재 위치에서 출근 처리할까요?',
      confirmText: '출근하기',
      onConfirm: () {
        setState(() {
          _status = WorkStatus.working;
        });

        _startWorkTimer();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('출근 처리가 완료되었습니다.')));
      },
    );
  }

  void _confirmEndWork() {
    showConfirmDialog(
      context: context,
      title: '퇴근 확인',
      message: '오늘 근무를 종료하고 퇴근 처리할까요?',
      confirmText: '퇴근하기',
      onConfirm: () {
        final endedAt = DateTime.now();
        _workTimer?.cancel();
        setState(() {
          if (_workStartedAt != null) {
            _workedDuration =
                endedAt.difference(_workStartedAt!);
          }

          _workEndedAt = endedAt;
          _status = WorkStatus.completed;
        });
      },
    );
  }

  void _confirmStartOvertime() {
    showConfirmDialog(
      context: context,
      title: '추가 근무 확인',
      message: '추가 근무 상태로 전환할까요?',
      confirmText: '전환하기',
      onConfirm: () {
        setState(() {
          _status = WorkStatus.overtime;
        });
      },
    );
  }

  final List<Schedule> schedules = [
    const Schedule(
      time: '09:00',
      title: '출근 인증',
      status: ScheduleStatus.attendance,
    ),
    const Schedule(
      time: '09:20',
      title: '전공 인강 2강 수강',
      status: ScheduleStatus.remaining,
    ),
    const Schedule(
      time: '11:00',
      title: '알고리즘 문제 3개',
      status: ScheduleStatus.overdue,
    ),
    const Schedule(
      time: '13:10',
      title: '자소서 1문항 초안',
      status: ScheduleStatus.completed,
    ),
    const Schedule(
      time: '18:00',
      title: '퇴근 인증',
      status: ScheduleStatus.attendance,
    ),
  ];

  void _completeSchedule(Schedule targetSchedule) {
    final index = schedules.indexOf(targetSchedule);

    if (index == -1) return;

    setState(() {
      schedules[index] = Schedule(
        time: targetSchedule.time,
        title: targetSchedule.title,
        status: ScheduleStatus.completed,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('일정을 완료했어요! 포인트가 적립되었습니다 🎉'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showAddScheduleSheet() async {
    final Schedule? newSchedule = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddScheduleBottomSheet(),
    );

    if (newSchedule == null) return;

    setState(() {
      schedules.add(newSchedule);
      schedules.sort((a, b) => a.time.compareTo(b.time));
    });
  }

  void _startWorkTimer() {
    _workStartedAt = DateTime.now();
    _workedDuration = Duration.zero;

    _workTimer?.cancel();

    _workTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _workStartedAt == null) return;

      setState(() {
        _workedDuration = DateTime.now().difference(_workStartedAt!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // 일정 리스트 관련
    final generalSchedules = schedules
        .where((schedule) => schedule.status != ScheduleStatus.attendance)
        .toList();

    final int scheduleCount = generalSchedules.length;

    final int completedCount = generalSchedules
        .where((schedule) => schedule.status == ScheduleStatus.completed)
        .length;

    final bool canAddSchedule = scheduleCount <= 10;

    // 포인트 관련
    final int point = generalSchedules
        .where((schedule) => schedule.status == ScheduleStatus.completed)
        .fold<int>(0, (total, schedule) => total + schedule.status.point);

    // TODO: 실제 데이터 연결 지점
    final status = _status;
    const targetTime = '09:00';
    const workedTime = '03:12:11'; // 추후 누적 근무 시간 = 현재 시각 - 출근 시각
    const actualStartTime = '15:41';
    const window = '08:00 ~ 11:00';
    const place = '중앙도서관 3층 열람실';
    final progress = _progress; // 0.0 ~ 1.0

    return Scaffold(
      backgroundColor: AppColors.canvassub,
      appBar: CommonAppBar(
        title: '좋은 아침입니다',
        subtitle: '매일 매일, 성실하게 그리고 꾸준하게도',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필 영역
                    EmployeeProfileHeader(
                      status: status,
                      name: _nickname,
                      company: '새싹컴퍼니',
                      department: 'IT개발준비팀',
                      position: _jobTitle,
                      employeeNumber: '20260902',
                      imagePath: _profileImageUrl,
                    ),

                    // 근무 정보 및 버튼 영역
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _status == WorkStatus.completed
                              ? '오늘 총 근무 · +60P 적립'
                              : _isWorking
                                  ? '누적 근무 시간'
                                  : '목표 출근 시각',
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.inkFaint,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            _status == WorkStatus.completed
                                ? _formattedTotalWorkTime
                                : _isWorking
                                ? _formattedWorkedTime
                                : targetTime,
                            style: textTheme.displaySmall?.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            children: [
                              Expanded(
                                child: _InfoBox(
                                  title: _isWorking || _status == WorkStatus.completed
                                      ? '출근 시각'
                                      : '출근 가능 시간대',
                                  content: _isWorking || _status == WorkStatus.completed
                                      ? _formatClockTime(_workStartedAt)
                                      : window,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InfoBox(
                                  title: _status == WorkStatus.completed
                                      ? '퇴근 시각'
                                      : '근무지',
                                  content: _status == WorkStatus.completed
                                      ? _formatClockTime(_workEndedAt)
                                      : place,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: AppColors.fill,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                status.progressColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isWorking
                                    ? '소정 근로 4시간 중 ${(progress * 100).toInt()}%'
                                    : _status == WorkStatus.completed
                                    ? '오늘 근무를 완료했습니다'
                                    : '출근 후 근무 시간이 기록됩니다',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.inkFaint,
                                ),
                              ),
                              Text(
                                _isWorking ? '0시간 47분 남음' : '4시간 0분 남음',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.inkFaint,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // 출근/퇴근하기 버튼
                          if (_isWorking) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 60,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        // TODO: 근무 상태 변경 처리
                                        context.go('/leave');
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.ink,
                                        side: BorderSide(
                                          color: AppColors.inkMuted.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      child: const Text('근무 변경'),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  flex: 2,
                                  child: CommonButton(
                                    text: '퇴근하기',
                                    version: ButtonVersion.normal,
                                    status: status,
                                    onPressed: _confirmEndWork,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                if (_status != WorkStatus.beforeWork) ...[
                                  Expanded(
                                    child: SizedBox(
                                      height: 60,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          // TODO: 근무 상태 변경 처리
                                          _status == WorkStatus.completed
                                              ? () {
                                              // context.go('/');
                                              setState(() {
                                              _status = WorkStatus.overtime;
                                            });
                                          }
                                              : null;
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: AppColors.ink,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          _status == WorkStatus.completed
                                              ? '추가 근무'
                                              : '',
                                          style: _status != WorkStatus.overtime
                                              ? textTheme.labelLarge?.copyWith(fontSize: 18,color: AppColors.fill, fontWeight: FontWeight.w500)
                                              : null
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  flex: 2,
                                  child: CommonButton(
                                    text: _isWorking
                                        ? '퇴근하기'
                                        : _canStartWork
                                        ? '출근하기'
                                        : '출근할 수 없어요',
                                    version: ButtonVersion.normal,
                                    status: status,
                                    isEnabled: _isWorking || _canStartWork,
                                    onPressed: () {
                                      // TODO: 출근 처리
                                      _isWorking
                                          ? _confirmEndWork()
                                          : _confirmStartWork();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 이번 주 근무
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '이번 주 근무',
                          style: textTheme.titleMedium?.copyWith(),
                        ),
                        Text('총 21시간 40분'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _WeeklyBar(
                            day: '9/7',
                            hours: 5.2,
                            status: status,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _WeeklyBar(
                            day: '9/8',
                            hours: 3.9,
                            status: status,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _WeeklyBar(
                            day: '9/9',
                            hours: 3.7,
                            status: status,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _WeeklyBar(
                            day: '9/10',
                            hours: 0,
                            status: status,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _WeeklyBar(
                            day: '9/11',
                            hours: 0,
                            status: status,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 오늘의 근무 계획
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '오늘의 근무 계획',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$completedCount / $scheduleCount 완료',
                              style: textTheme.titleSmall?.copyWith(
                                color: AppColors.inkFaint,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            if (!canAddSchedule) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('오늘 일정은 최대 10개까지 추가할 수 있어요.'),
                                ),
                              );
                              return;
                            }

                            // 일정 추가 동작
                            _showAddScheduleSheet();
                          },
                          icon: Icon(
                            Icons.add_circle_outline_outlined,
                            size: 14,
                            color: AppColors.ink,
                            fontWeight: FontWeight.w100,
                          ),
                          label: Text(
                            '일정 추가',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),

                    //
                    ...schedules.map(
                      (schedule) => _ScheduleItem(
                        time: schedule.time,
                        title: schedule.title,
                        status: schedule.status,
                        onCompleted: () => _completeSchedule(schedule),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Divider(
                      height: 1,
                      thickness: 1.5,
                      color: AppColors.fill,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '오늘 적립',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkFaint,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.paid_rounded,
                              size: 20,
                              color: Color(0xFFFFB800),
                              // shadows: [
                              //   Shadow(
                              //     color: Color(0x33000000),
                              //     offset: Offset(0, 1),
                              //     blurRadius: 2,
                              //   )
                              // ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${point}P / 최대 100P',
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _workTimer?.cancel();
    super.dispose();
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String content;

  const _InfoBox({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 96,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.inkFaint),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            maxLines: 1, // 수정-한 줄로 제한
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBar extends StatelessWidget {
  final String day;
  final double hours;
  final WorkStatus? status;

  const _WeeklyBar({
    required this.day,
    required this.hours,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    const double maxHours = 8;
    const double maxBarHeight = 100;

    final double barHeight = hours == 0
        ? 10
        : (hours / maxHours) * maxBarHeight;

    final Color progressColor = switch (status) {
      WorkStatus.beforeWork => AppColors.primary,
      WorkStatus.working => AppColors.positive,
      WorkStatus.fieldWork => AppColors.fieldPurple,
      WorkStatus.completed => AppColors.inkMuted,
      WorkStatus.vacation => AppColors.vacation,
      WorkStatus.overtime => AppColors.liveGreen,
      WorkStatus.absent => AppColors.taskRed,
      null => AppColors.primary,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(hours == 0 ? '0.0h' : '${hours}h'),

        const SizedBox(height: 8),

        Container(
          height: maxBarHeight,
          alignment: Alignment.bottomCenter,
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: hours == 0 ? AppColors.fill : progressColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(day),
      ],
    );
  }
}

extension ScheduleStatusStyle on ScheduleStatus {
  int get point => switch (this) {
    ScheduleStatus.attendance => 50,
    _ => 5,
  };

  String get description => switch (this) {
    ScheduleStatus.attendance => '출퇴근 시 자동으로 인증돼요',
    ScheduleStatus.completed => '일정 완료',
    ScheduleStatus.overdue => '예정 시간이 지났어요',
    ScheduleStatus.remaining => '아직 시간이 남아 있어요',
  };

  BadgeColors get colors => switch (this) {
    ScheduleStatus.attendance => AppBadges.pointGain,
    ScheduleStatus.completed => AppBadges.settled,
    ScheduleStatus.overdue => AppBadges.pointLoss,
    ScheduleStatus.remaining => AppBadges.pointClaimable,
  };
}

class _ScheduleItem extends StatefulWidget {
  final String time;
  final String title;
  final ScheduleStatus status;
  final VoidCallback? onCompleted;

  const _ScheduleItem({
    required this.time,
    required this.title,
    required this.status,
    this.onCompleted,
  });

  @override
  State<_ScheduleItem> createState() => _ScheduleItemState();
}

class _ScheduleItemState extends State<_ScheduleItem> {
  late bool isCompleted;

  @override
  void initState() {
    super.initState();

    // 처음부터 완료 상태라면 취소선 표시
    isCompleted = widget.status == ScheduleStatus.completed;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final textDecoration = isCompleted
        ? TextDecoration.lineThrough
        : TextDecoration.none;

    final String pointText = isCompleted
        ? '✓ +${widget.status.point}P'
        : switch (widget.status) {
            ScheduleStatus.attendance => '인증 대기',
            ScheduleStatus.overdue => '${widget.status.point}P 적립 실패',
            ScheduleStatus.remaining => '+${widget.status.point}P 받기',
            ScheduleStatus.completed => '✓ +${widget.status.point}P',
          };

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시간
          SizedBox(
            width: 50,
            child: Text(
              widget.time,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isCompleted
                    ? AppBadges.settled.foreground
                    : widget.status.colors.foreground,
                decoration: textDecoration,
                decorationColor: AppColors.inkFaint.withValues(alpha: 0.65),
                decorationThickness: 1.0,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Row(
              // 포인트 배지를 위쪽에 정렬
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 + 설명
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: isCompleted
                              ? AppBadges.settled.foreground
                              : AppColors.ink,
                          decoration: textDecoration,
                          decorationColor: AppColors.inkFaint.withValues(
                            alpha: 0.65,
                          ),
                          decorationThickness: 1.0,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        widget.status.description,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: isCompleted
                              ? AppBadges.settled.foreground
                              : AppColors.inkFaint,
                          decoration: textDecoration,
                          decorationColor: AppColors.inkFaint.withValues(
                            alpha: 0.65,
                          ),
                          decorationThickness: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // 클릭 가능한 포인트 배지
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        isCompleted ||
                            widget.status == ScheduleStatus.attendance ||
                            widget.status == ScheduleStatus.overdue
                        ? null
                        : widget.onCompleted,
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppBadges.settled.background
                            : widget.status.colors.background,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          pointText,
                          key: ValueKey(isCompleted),
                          style: textTheme.bodySmall?.copyWith(
                            color: isCompleted
                                ? AppBadges.settled.foreground
                                : widget.status.colors.foreground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
