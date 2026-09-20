class WorkSetting {
  final String workplaceName;
  final String address;
  final double latitude;
  final double longitude;
  final int allowedRadiusMeters;

  // 분 단위
  final int targetWorkMinutes;

  // 출근 가능 시간
  final int startHour;
  final int endHour;

  const WorkSetting({
    required this.workplaceName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.allowedRadiusMeters,
    required this.targetWorkMinutes,
    required this.startHour,
    required this.endHour,
  });

  WorkSetting copyWith({
    String? workplaceName,
    String? address,
    double? latitude,
    double? longitude,
    int? allowedRadiusMeters,
    int? targetWorkMinutes,
    int? startHour,
    int? endHour,
  }) {
    return WorkSetting(
      workplaceName: workplaceName ?? this.workplaceName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      allowedRadiusMeters:
      allowedRadiusMeters ?? this.allowedRadiusMeters,
      targetWorkMinutes:
      targetWorkMinutes ?? this.targetWorkMinutes,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
    );
  }
}