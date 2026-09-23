// filename: ../views/home_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String _profileImageUrl = 'assets/images/sample_employee.png';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeHome();
  }

  Future<void> _loadUserProfile() async {
    try {
      final data = await _fs.readUser();
      if (!mounted || data == null) return;

      setState(() {
        _nickname = data['nickname'] ?? '';
        _jobTitle = data['jobTitle'] ?? '인턴';
        _profileImageUrl =
            data['profileImageUrl'] ?? 'assets/images/sample_employee.png';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사용자 정보를 불러오지 못했습니다.')));
    }
  }

  Future<void> _checkWorkplaceLocation() async {
    if (_isCheckingLocation) return;

    setState(() {
      _isCheckingLocation = true;
      _locationError = null;
    });

    try {
      // 1. 지정 근무지 좌표와 인증 반경 조회
      final workSettings = await _fs.readWorkSettings();

      if (workSettings == null) {
        throw Exception('근무지 정보가 없습니다.');
      }

      final workplaceLatitude = (workSettings['latitude'] as num?)?.toDouble();
      final workplaceLongitude = (workSettings['longitude'] as num?)
          ?.toDouble();
      final allowedRadiusMeters = (workSettings['allowedRadiusMeters'] as num?)
          ?.toInt();

      if (workplaceLatitude == null ||
          workplaceLongitude == null ||
          allowedRadiusMeters == null) {
        throw Exception('근무지 위치와 인증 반경을 먼저 설정해주세요.');
      }

      // 2. 기기 위치 서비스 확인
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('기기의 위치 서비스를 켜주세요.');
      }

      // 3. 위치 권한 확인
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 필요합니다.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('설정에서 위치 권한을 허용해주세요.');
      }

      // 4. 현재 위치 좌표 조회
      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 5. 현재 위치와 근무지 사이 거리 계산
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        workplaceLatitude,
        workplaceLongitude,
      );

      // 6. 인증 반경 이내인지 판단
      final isWithinWorkplace = distance <= allowedRadiusMeters;

      if (!mounted) return;

      setState(() {
        _currentPosition = currentPosition;
        _workSettings = workSettings;
        _updateWorkTimeAvailability();
        _distanceFromWorkplace = distance;
        _isWithinWorkplace = isWithinWorkplace;
      });
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      setState(() {
        _isWithinWorkplace = false;
        _locationError = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLocation = false;
        });
      }
    }
  }

  Future<void> _loadTodayAttendance() async {
    try {
      final data = await _fs.readTodayAttendance();

      if (!mounted) return;

      if (data == null) {
        setState(() {
          _status = WorkStatus.beforeWork;
          _workStartedAt = null;
          _workEndedAt = null;
          _workedDuration = Duration.zero;
        });
        return;
      }

      final status = workStatusFromFirestore(data['status'] as String?);

      final startedAt = (data['startedAt'] as Timestamp?)?.toDate().toLocal();

      final endedAt = (data['endedAt'] as Timestamp?)?.toDate().toLocal();

      final overtimeStartedAt = (data['overtimeStartedAt'] as Timestamp?)
          ?.toDate()
          .toLocal();

      final totalWorkedMinutes =
          (data['totalWorkedMinutes'] as num?)?.toInt() ?? 0;

      setState(() {
        _status = status;
        _workStartedAt = startedAt;
        _workEndedAt = endedAt;

        if (status == WorkStatus.working || status == WorkStatus.fieldWork) {
          _workedDuration = startedAt == null
              ? Duration.zero
              : DateTime.now().difference(startedAt);
        } else if (status == WorkStatus.overtime) {
          final workedMinutes = (data['workedMinutes'] as num?)?.toInt() ?? 0;

          final fieldWorkMinutes =
              (data['fieldWorkMinutes'] as num?)?.toInt() ?? 0;

          // 기존 일반 근무 또는 외근 시간을 보관
          _baseWorkedMinutes = workedMinutes + fieldWorkMinutes;

          // Firestore에 저장된 추가 근무 시작 시각을 보관
          _overtimeStartedAt = overtimeStartedAt;

          final overtimeDuration = _overtimeStartedAt == null
              ? Duration.zero
              : DateTime.now().difference(_overtimeStartedAt!);

          _workedDuration =
              Duration(minutes: _baseWorkedMinutes) +
              overtimeDuration;
        } else {
          _workedDuration =
              Duration(minutes: totalWorkedMinutes);
        }
      });

      if (_isWorking) {
        _startStatusTimer();
      }
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('근무 상태를 불러오지 못했습니다: $message')));
    }
  }

  Future<void> _initializeHome() async {
    await Future.wait([_loadUserProfile(), _checkWorkplaceLocation()]);

    await _loadTodayAttendance();
  }

  WorkStatus _status = WorkStatus.beforeWork;
  //double _progress = 0.1;
  double get _progress {
    final requiredMinutes = (_workSettings?['dailyWorkMinutes'] as num?)
        ?.toInt();

    if (requiredMinutes == null || requiredMinutes <= 0) {
      return 0;
    }

    return (_workedDuration.inSeconds / (requiredMinutes * 60)).clamp(0.0, 1.0);
  }

  Timer? _workTimer;
  DateTime? _workStartedAt;
  DateTime? _workEndedAt;
  DateTime? _overtimeStartedAt;
  int _baseWorkedMinutes = 0;
  Duration _workedDuration = Duration.zero;
  String get _formattedWorkedTime {
    final hours = _workedDuration.inHours.toString().padLeft(2, '0');
    final minutes = (_workedDuration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_workedDuration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  DateTime get _koreaNow {
    return DateTime.now().toUtc().add(const Duration(hours: 9));
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

    return '$hours시간 $minutes분';
  }

  void _updateWorkTimeAvailability() {
    final startMinutes =
    (_workSettings?['availableStartMinutes'] as num?)
        ?.toInt();

    final endMinutes =
    (_workSettings?['availableEndMinutes'] as num?)
        ?.toInt();

    if (startMinutes == null || endMinutes == null) {
      _isWithinWorkTime = false;
      return;
    }

    final now = _koreaNow;
    final currentMinutes = now.hour * 60 + now.minute;

    _isWithinWorkTime =
        currentMinutes >= startMinutes &&
            currentMinutes <= endMinutes;
  }

  bool _isWithinWorkTime = false;
  bool? _isWithinWorkplace;

  bool _isCheckingLocation = false;
  bool _isStartingWork = false;
  bool _isEndingWork = false;
  double? _distanceFromWorkplace;
  String? _locationError;

  Position? _currentPosition;
  Map<String, dynamic>? _workSettings;

  bool get _isWorking =>
      _status == WorkStatus.working ||
      _status == WorkStatus.fieldWork ||
      _status == WorkStatus.overtime;

  bool get _canStartWork {
    return _status == WorkStatus.beforeWork &&
        _isWithinWorkTime &&
        _isWithinWorkplace == true &&
        !_isCheckingLocation;
  }

  String get _primaryButtonText {
    return switch (_status) {
      WorkStatus.beforeWork => _isCheckingLocation
          ? '위치 확인 중'
          : _canStartWork
          ? '출근하기'
          : '출근할 수 없어요',

      WorkStatus.working => '퇴근하기',
      WorkStatus.fieldWork => '외근 종료하기',
      WorkStatus.overtime => '추가 근무 종료',
      WorkStatus.completed => '근무 완료',
      WorkStatus.vacation => '휴가',
      WorkStatus.absent => '결근',
    };
  }

  VoidCallback? get _primaryButtonAction {
    return switch (_status) {
      WorkStatus.beforeWork =>
      _canStartWork ? _confirmStartWork : null,

      WorkStatus.working ||
      WorkStatus.fieldWork ||
      WorkStatus.overtime =>
      _confirmEndWork,

      WorkStatus.completed ||
      WorkStatus.vacation ||
      WorkStatus.absent =>
      null,
    };
  }

  String get _formattedDistance {
    final distance = _distanceFromWorkplace;

    if (distance == null) return '-';

    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }

    return '${distance.round()}m';
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

    if (_isCheckingLocation) {
      return '현재 위치를 확인하고 있습니다.';
    }

    if (_locationError != null) {
      return _locationError;
    }

    if (!_isWithinWorkTime) {
      return '출근 가능 시간대가 아닙니다.';
    }

    if (_isWithinWorkplace != true) {
      final distance = _distanceFromWorkplace;

      if (distance != null) {
        return '근무지에서 약 $_formattedDistance 떨어져 있어 출근할 수 없습니다.';
      }

      return '지정된 근무지 반경 안에서만 출근할 수 있습니다.';
    }

    return null;
  }

  void _showStatusError(String message) {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('근무 상태 확인'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startWork() async {
    if (_isStartingWork) return;

    if (_status != WorkStatus.beforeWork) {
      _showStatusError('이미 출근했거나 근무가 완료되었습니다.');
      return;
    }

    final position = _currentPosition;
    final workSettings = _workSettings;
    final distance = _distanceFromWorkplace;

    if (position == null ||
        workSettings == null ||
        distance == null ||
        _isWithinWorkplace != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS 인증 정보가 없습니다. 위치를 다시 확인해주세요.')),
      );
      return;
    }

    final requiredWorkMinutes = (workSettings['dailyWorkMinutes'] as num?)
        ?.toInt();

    final availableEndMinutes = (workSettings['availableEndMinutes'] as num?)
        ?.toInt();

    if (requiredWorkMinutes == null || availableEndMinutes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('근무 시간 설정을 확인해주세요.')));
      return;
    }

    setState(() {
      _isStartingWork = true;
    });

    try {
      final isFieldWork = await _fs.hasApprovedFieldWorkForToday();

      final isCreated = await _fs.saveAttendanceRecord(
        requiredWorkMinutes: requiredWorkMinutes,
        availableEndMinutes: availableEndMinutes,
        latitude: position.latitude,
        longitude: position.longitude,
        distanceMeters: distance,
        isFieldWork: isFieldWork,
      );

      if (!mounted) return;

      if (!isCreated) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('오늘은 이미 출근 처리되었습니다.')));
        return;
      }

      setState(() {
        _status = isFieldWork ? WorkStatus.fieldWork : WorkStatus.working;

        _workStartedAt = DateTime.now();
        _workEndedAt = null;
        _workedDuration = Duration.zero;
      });

      _startStatusTimer();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('출근 처리가 완료되었습니다.')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('출근 기록 저장에 실패했습니다: $e')));

      debugPrint('오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isStartingWork = false;
        });
      }
    }
  }

  Future<void> _endWork() async {
    if (_isEndingWork) return;

    if (!_isWorking) {
      _showStatusError(
        '현재 상태에서는 퇴근할 수 없습니다.',
      );
      return;
    }

    setState(() {
      _isEndingWork = true;
    });

    try {
      final isUpdated = await _fs.saveEndWork();

      if (!mounted) return;

      if (!isUpdated) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('오늘은 이미 퇴근 처리되었습니다.')));
        return;
      }

      _workTimer?.cancel();

      await _loadTodayAttendance();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('퇴근 처리가 완료되었습니다.')));
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      debugPrint('퇴근 처리 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isEndingWork = false;
        });
      }
    }
  }

  void _confirmStartWork() async {
    await _checkWorkplaceLocation();

    if (!mounted) return;

    if (!_canStartWork) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_unavailableReason ?? '현재 위치에서는 출근할 수 없습니다.')),
      );
      return;
    }

    showConfirmDialog(
      context: context,
      title: '출근 확인',
      message: '현재 위치에서 출근 처리할까요?',
      confirmText: '출근하기',
      onConfirm: () async {
        await _startWork();
      },
    );
  }

  void _confirmEndWork() {
    showConfirmDialog(
      context: context,
      title: '퇴근 확인',
      message: '오늘 근무를 종료하고 퇴근 처리할까요?',
      confirmText: '퇴근하기',
      onConfirm: () async {
        await _endWork();
      },
    );
  }

  void _confirmStartOvertime() {
    if (_status != WorkStatus.completed) {
      _showStatusError(
        '퇴근 완료 후에만 추가 근무를 시작할 수 있습니다.',
      );
      return;
    }

    showConfirmDialog(
      context: context,
      title: '추가 근무 확인',
      message: '추가 근무를 시작할까요?',
      confirmText: '시작하기',
      onConfirm: () async {
        try {
          final isStarted = await _fs.startOvertime();

          if (!mounted) return;

          if (!isStarted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('추가 근무가 이미 시작되었습니다.')));
            return;
          }

          setState(() {
            _baseWorkedMinutes = _workedDuration.inMinutes;
            _overtimeStartedAt = DateTime.now();
            _status = WorkStatus.overtime;
          });

          // 근무 상태에 따른 타이머 시작
          _startStatusTimer();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('추가 근무를 시작했습니다.')));
        } catch (e) {
          if (!mounted) return;

          final message = e.toString().replaceFirst('Exception: ', '');

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
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

  void _startStatusTimer() {
    _workTimer?.cancel();

    _workTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        if (_status == WorkStatus.working || _status == WorkStatus.fieldWork) {
          if (_workStartedAt != null) {
            _workedDuration = DateTime.now().difference(_workStartedAt!);
          }
        }

        if (_status == WorkStatus.overtime && _overtimeStartedAt != null) {
          final overtimeDuration = DateTime.now().difference(
            _overtimeStartedAt!,
          );

          _workedDuration =
              Duration(minutes: _baseWorkedMinutes) + overtimeDuration;
        }
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

    final bool canAddSchedule = scheduleCount < 10;

    // 포인트 관련
    final int point = generalSchedules
        .where((schedule) => schedule.status == ScheduleStatus.completed)
        .fold<int>(0, (total, schedule) => total + schedule.status.point);

    String formatWorkDuration(int minutes) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      if (remainingMinutes == 0) {
        return '$hours시간';
      }

      return '$hours시간 $remainingMinutes분';
    }

    String formatTime(int minutes) {
      final hour = minutes ~/ 60;
      final minute = minutes % 60;

      return '${hour.toString().padLeft(2, '0')}:'
          '${minute.toString().padLeft(2, '0')}';
    }

    final status = _status;
    final place = _workSettings?['workplaceName'] as String? ?? '근무지 미설정';
    final dailyWorkMinutes = (_workSettings?['dailyWorkMinutes'] as num?)?.toInt() ?? 0;
    final availableStartMinutes = (_workSettings?['availableStartMinutes'] as num?)?.toInt() ?? 0;
    final availableEndMinutes = (_workSettings?['availableEndMinutes'] as num?)?.toInt() ?? 0;
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
                                : formatWorkDuration(dailyWorkMinutes),
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
                                  title:
                                      _isWorking ||
                                          _status == WorkStatus.completed
                                      ? '출근 시각'
                                      : '출근 가능 시간대',
                                  content:
                                      _isWorking ||
                                          _status == WorkStatus.completed
                                      ? _formatClockTime(_workStartedAt)
                                      : '${formatTime(availableStartMinutes)} ~ '
                                        '${formatTime(availableEndMinutes)}',
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

                          // 출근 불가 사유
                          if (!_isWorking && _unavailableReason != null) ...[
                            Text(
                              _unavailableReason!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.taskRed,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // 출근/퇴근하기 버튼
                          Row(
                            children: [
                              // 근무 중에는 근무 변경 버튼 표시
                              if (_isWorking &&
                                  _status != WorkStatus.overtime) ...[
                                Expanded(
                                  child: SizedBox(
                                    height: 60,
                                    child: OutlinedButton(
                                      onPressed: () {
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
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text('근무 변경'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],

                              // 퇴근 완료 후에는 추가 근무 버튼 표시
                              if (_status == WorkStatus.completed) ...[
                                Expanded(
                                  child: SizedBox(
                                    height: 60,
                                    child: OutlinedButton(
                                      onPressed: _confirmStartOvertime,
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.fill,
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        '추가 근무',
                                        style: textTheme.labelLarge?.copyWith(
                                          fontSize: 18,
                                          color: AppColors.fill,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],

                              // 모든 상태에서 공통으로 사용하는 기본 버튼
                              Expanded(
                                flex: 2,
                                child: CommonButton(
                                  text: _primaryButtonText,
                                  version: ButtonVersion.normal,
                                  status: status,
                                  isEnabled: _primaryButtonAction != null,
                                  onPressed: _primaryButtonAction,
                                ),
                              ),
                            ],
                          )
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
