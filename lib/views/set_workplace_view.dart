// filename: ../views/set_workplace_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oneul/widgets/common_text_field.dart';
import 'package:oneul/widgets/status_badge.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class SetWorkplaceView extends StatefulWidget {
  const SetWorkplaceView({super.key});

  @override
  State<SetWorkplaceView> createState() => _SetWorkplaceViewState();
}

class _SetWorkplaceViewState extends State<SetWorkplaceView> {
  final Geocoding _geocoding = Geocoding();

  int _selectedPlaceIndex = 0;
  int _selectedRadius = 50;

  // 위치 상태 변수
  bool _isLocationLoading = false;
  String? _currentAddress;
  String? _locationError;
  double? _locationAccuracy;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  //
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
                label: '',
                hint: '장소 또는 주소로 검색',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: AppColors.inkFaint,
                ),
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
                    Expanded(child: Text('현재 위치 · 서울 서대문구 신촌동')),
                    Text(
                      '정확도 ±8m',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.inkFaint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _placeCard(
                context: context,
                index: 0,
                title: '중앙도서관 3층 열람실',
                description: '현재 위치에서 240m · 도보 4분',
              ),
              const SizedBox(height: 8),

              _placeCard(
                context: context,
                index: 1,
                title: '스터디카페 라운지 신촌점',
                description: '현재 위치에서 620m · 도보 9분',
              ),
              const SizedBox(height: 8),

              _placeCard(
                context: context,
                index: 2,
                title: '서대문 청년센터 스터디룸',
                description: '현재 위치에서 1.1km · 버스 6분',
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
              onPressed: () {
                context.go('/signup/workplace/worktime');
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
        setState(() {
          _selectedPlaceIndex = index;
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
