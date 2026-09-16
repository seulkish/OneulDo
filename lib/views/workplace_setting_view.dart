// filename: views/workplace_setting_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/sub_page_app_bar.dart';
import '../widgets/app_button.dart';
import '../widgets/common_text_field.dart';
import '../theme/app_colors.dart';

import '../models/work_status.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class WorkplaceSettingView extends StatefulWidget {
  const WorkplaceSettingView({super.key});

  @override
  State<WorkplaceSettingView> createState() => _WorkplaceSettingViewState();
}

class _WorkplaceSettingViewState extends State<WorkplaceSettingView> {
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvassub,
      appBar: SubPageAppBar(
        title: '근무지 설정',
        position: '사원',
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
            // 현재 등록된 근무지 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.shadow3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 등록된 근무지',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkFaint,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '중앙도서관 3층 열람실',
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '인증 반경 50m · GPS 인증 필수',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 지도 영역
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 178,
                      color: AppColors.fill,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 임시 지도 - 추후 GoogleMap으로 변경
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _MapGridPainter(),
                            ),
                          ),

                          // 인증 반경
                          Container(
                            width: 116,
                            height: 116,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                            ),
                          ),

                          // 현재 위치 점
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                          ),

                          // 장소 정보
                          Positioned(
                            left: 16,
                            bottom: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '중앙도서관 3층 열람실 · 반경 50m',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.inkMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16,),

            // 근무지 변경 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.shadow3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '근무지 변경',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.inkMuted,
                      // fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  CommonTextField(
                    label: '',
                    hint: '장소 또는 주소로 검색',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.inkFaint,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 현재 위치
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            '현재 위치 · ${_currentAddress ?? '서울 서대문구 신촌동'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        TextButton(
                          onPressed:
                          _isLocationLoading ? null : _getCurrentLocation,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _isLocationLoading ? '조회 중...' : '새로 고침',
                            style: textTheme.bodyMedium?.copyWith(
                              color: _isLocationLoading
                                  ? AppColors.inkFaint
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _placeCard(
                    context: context,
                    index: 0,
                    title: '중앙도서관 3층 열람실',
                    description: '현재 위치에서 240m · 도보 4분',
                  ),
                  const SizedBox(height: 10),

                  _placeCard(
                    context: context,
                    index: 1,
                    title: '스터디카페 라운지 신촌점',
                    description: '현재 위치에서 620m · 도보 9분',
                  ),
                  const SizedBox(height: 10),

                  _placeCard(
                    context: context,
                    index: 2,
                    title: '서대문 청년센터 스터디룸',
                    description: '현재 위치에서 1.1km · 버스 6분',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 인증 반경 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.shadow3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '인증 반경',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.inkMuted,
                      // fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _radiusButton(50),
                      const SizedBox(width: 8),
                      _radiusButton(100),
                      const SizedBox(width: 8),
                      _radiusButton(200),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text(
                    '반경을 벗어나면 출근이 기록되지 않습니다. '
                        '집 주변 300m는 근무지로 선택할 수 없습니다.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkFaint,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(28, 12, 28, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonButton(
              text: '근무지 저장',
              onPressed: () {
                context.go('/my-page');
              },
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

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.18)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}