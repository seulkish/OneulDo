// filename: models/workplace_option.dart
/// 장소 검색 후보 목록 페이지
class WorkplaceOption {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? distanceMeters;

  const WorkplaceOption({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
  });
}