// filename: ../views/set_workplace_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/firestore_service.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/common_text_field.dart';

import '../models/work_status.dart';
import '../models/workplace_option.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class SetWorkplaceView extends StatefulWidget {
  const SetWorkplaceView({super.key});

  @override
  State<SetWorkplaceView> createState() => _SetWorkplaceViewState();
}

class _SetWorkplaceViewState extends State<SetWorkplaceView> {
  final FirestoreService _fs = FirestoreService();
  final Geocoding _geocoding = Geocoding();

  // 입력 컨트롤러
  final TextEditingController _workplaceController =
  TextEditingController();

  // 근무지 선택 상태
  int? _selectedPlaceIndex;
  int _selectedRadius = 50;

  // 위치 상태 변수
  bool _isLocationLoading = false;
  String? _currentAddress;
  String? _locationError;
  double? _locationAccuracy;
  double? _currentLatitude;
  double? _currentLongitude;


  final List<WorkplaceOption> _workplaces = [
    const WorkplaceOption(
      name: '중앙도서관 3층 열람실',
      address: '서울 서대문구 신촌동',
      latitude: 37.5595,
      longitude: 126.9425,
      distanceMeters: 240,
    ),
    const WorkplaceOption(
      name: '스터디카페 라운지 신촌점',
      address: '서울 서대문구 연세로',
      latitude: 37.5578,
      longitude: 126.9368,
      distanceMeters: 620,
    ),
    const WorkplaceOption(
      name: '서대문 청년센터 스터디룸',
      address: '서울 서대문구 모래내로',
      latitude: 37.5732,
      longitude: 126.9237,
      distanceMeters: 1100,
    ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
      _loadWorkplace();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _workplaceController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isLocationLoading) return;

    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });

    try {
      // GPS 확인
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _setLocationError('위치 서비스가 꺼져 있습니다.');

        _showLocationSnackBar(
          message: 'GPS를 켜주세요.',
          actionLabel: '설정 열기',
          onAction: Geolocator.openLocationSettings,
        );
        return;
      }

      // 권한 확인 및 요청
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _setLocationError('위치 권한이 거부되었습니다.');
        _showLocationSnackBar(message: '위치 권한을 허용해주세요.');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _setLocationError('설정에서 위치 권한을 허용해주세요.');

        _showLocationSnackBar(
          message: '위치 권한이 차단되어 있습니다.',
          actionLabel: '앱 설정',
          onAction: Geolocator.openAppSettings,
        );
        return;
      }

      // 현재 위치 조회
      final position = await Geolocator.getCurrentPosition();

      // 주소 변환
      try {
        final placemarks = await _geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (!mounted) return;

        setState(() {
          _currentAddress = placemarks.isNotEmpty
              ? _formatAddress(placemarks.first)
              : '주소를 찾을 수 없습니다.';

          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
          _locationAccuracy = position.accuracy;
          _locationError = null;
        });
      } catch (e) {
        debugPrint('주소 변환 오류: $e');

        if (!mounted) return;

        // 주소만 실패하면 좌표로 표시
        setState(() {
          _currentAddress =
              '${position.latitude.toStringAsFixed(5)}, '
              '${position.longitude.toStringAsFixed(5)}';
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
          _locationAccuracy = position.accuracy;
          _locationError = null;
        });

        _showLocationSnackBar(message: '주소를 불러오지 못해 좌표로 표시합니다.');
      }
    } catch (e) {
      // GPS 위치 조회 자체가 실패한 경우
      debugPrint('위치 조회 오류: $e');

      _setLocationError('현재 위치를 불러오지 못했습니다.');
      _showLocationSnackBar(message: '위치 조회에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isLocationLoading = false;
        });
      }
    }
  }

  String _formatAddress(Placemark placemark) {
    final parts = [
      placemark.administrativeArea,
      placemark.locality,
      placemark.subLocality,
      placemark.thoroughfare,
    ].whereType<String>().where((value) => value.trim().isNotEmpty);

    return parts.join(' ');
  }

  void _setLocationError(String message) {
    if (!mounted) return;

    setState(() {
      _currentAddress = null;
      _locationAccuracy = null;
      _locationError = message;
    });
  }

  void _showLocationSnackBar({
    required String message,
    String? actionLabel,
    Future<bool> Function()? onAction,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: actionLabel != null && onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  onPressed: () {
                    onAction();
                  },
                )
              : null,
        ),
      );
  }

  Future<void> _saveWorkplace() async {
    final selectedIndex = _selectedPlaceIndex;

    if (selectedIndex == null) {
      _showLocationSnackBar(message: '근무지를 선택해주세요.');
      return;
    }

    final place = _workplaces[selectedIndex];

    try {
      await _fs.updateWorkplace(
        workplaceName: place.name,
        address: place.address,
        latitude: place.latitude,
        longitude: place.longitude,
        allowedRadiusMeters: _selectedRadius,
      );

      final savedData = await _fs.readWorkplace();

      if (!mounted) return;
      if (savedData == null ||
          savedData['workplaceName'] == null) {
        _showLocationSnackBar(
          message: '근무지 저장 결과를 확인하지 못했습니다.',
        );
        return;
      }

      _showLocationSnackBar(
        message: '${savedData['workplaceName']} 저장 완료',
      );

      context.go('/signup/workplace/worktime');
    } catch (e) {
      if (!mounted) return;
      _showLocationSnackBar(message: '근무지 저장에 실패했습니다: $e');
    }
  }

  Future<void> _loadWorkplace() async {
    try {
      final data = await _fs.readWorkplace();

      if (!mounted || data == null) return;

      final workplace = data['workplace'] as String?;
      final savedIndex = _workplaces.indexWhere(
            (place) => place.name == workplace,
      );

      setState(() {
        _workplaceController.text = workplace ?? '';
        _selectedPlaceIndex = savedIndex == -1 ? null : savedIndex;

        _selectedRadius =
            (data['radiusMeters'] as num?)?.toInt() ?? 50;
    });
    } catch (e) {
      if (!mounted) return;
      _showLocationSnackBar(
        message: '기존 근무지 정보를 불러오지 못했습니다.',
      );
    }
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
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
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
                'STEP 1 / 3',
                style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                '근무지를 등록합니다',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '등록한 장소 반경 안에서만 출근이 인증됩니다. 집을 벗어나야 출근이 인정되도록 집 주소는 근무지로 등록할 수 없습니다.',
              ),
              const SizedBox(height: 12),

              CommonTextField(
                controller: _workplaceController,
                label: '',
                hint: '장소 또는 주소로 검색',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: AppColors.inkFaint,
                ),
                onChange: (value) {
                  setState(() {
                    _selectedPlaceIndex = null;
                  });
                  // 검색 API 또는 검색 결과 필터링
                },
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '현재 위치 기준 추천',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLocationLoading ? null : _getCurrentLocation,
                    child: Text(
                      _isLocationLoading ? '조회 중...' : '위치 새로 고침',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _isLocationLoading
                            ? AppColors.inkFaint
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // 현재 위치
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.my_location,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isLocationLoading
                            ? '현재 위치를 확인하고 있습니다'
                            : _locationError ??
                              '현재 위치 · ${_currentAddress ?? '위치 정보 없음'}',
                      ),
                    ),
                    if (_locationAccuracy != null)
                      Text(
                        '정확도 ±${_locationAccuracy!.round()}m',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkFaint,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workplaces.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                itemBuilder: (context, index) {
                  final place = _workplaces[index];

                  return _placeCard(
                    context: context,
                    index: index,
                    title: place.name,
                    description:
                    '${place.address} · 현재 위치에서 '
                        '${place.distanceMeters?.round() ?? 0}m',
                  );
                },
              ),
              const SizedBox(height: 16),

              Text('인증 반경',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  _radiusButton(50),
                  const SizedBox(width: 8),
                  _radiusButton(100),
                  const SizedBox(width: 8),
                  _radiusButton(200),
                ],
              ),
              const SizedBox(height: 12),

              Text('반경을 벗어나면 출근이 기록되지 않습니다. 집 주변 300m는 근무지로 선택할 수 없습니다.'),
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
              onPressed: _saveWorkplace,
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

  Widget _placeCard({
    required BuildContext context,
    required int index,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedPlaceIndex == index;

    return InkWell(
      onTap: () {
        final place = _workplaces[index];

        setState(() {
          _selectedPlaceIndex = index;
          _workplaceController.text = place.name;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _radiusButton(int radius) {
    final theme = Theme.of(context);
    final isSelected = _selectedRadius == radius;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRadius = radius;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Text(
            '${radius}m',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isSelected ? AppColors.primary : AppColors.inkFaint,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
