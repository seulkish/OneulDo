// filename: models/work_setting.dart
class WorkSetting {
  final String? workplaceName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int? allowedRadiusMeters;

  final int? dailyWorkMinutes; // 하루 목표 근무시간: 분 단위
  final int? availableStartMinutes; // 출근 가능 시간-시작
  final int? availableEndMinutes; // 출근 가능 시간-종료

  final String? goal;

  const WorkSetting({
    this.workplaceName,
    this.address,
    this.latitude,
    this.longitude,
    this.allowedRadiusMeters,
    this.dailyWorkMinutes,
    this.availableStartMinutes,
    this.availableEndMinutes,
    this.goal,
  });

  WorkSetting copyWith({
    String? workplaceName,
    String? address,
    double? latitude,
    double? longitude,
    int? allowedRadiusMeters,
    int? dailyWorkMinutes,
    int? availableStartMinutes,
    int? availableEndMinutes,
    String? goal,
  }) {
    return WorkSetting(
      workplaceName: workplaceName ?? this.workplaceName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      allowedRadiusMeters:
      allowedRadiusMeters ?? this.allowedRadiusMeters,
      dailyWorkMinutes:
      dailyWorkMinutes ?? this.dailyWorkMinutes,
      availableStartMinutes:
      availableStartMinutes ?? this.availableStartMinutes,
      availableEndMinutes:
      availableEndMinutes ?? this.availableEndMinutes,
      goal: goal ?? this.goal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workplaceName': workplaceName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'allowedRadiusMeters': allowedRadiusMeters,
      'dailyWorkMinutes': dailyWorkMinutes,
      'availableStartMinutes': availableStartMinutes,
      'availableEndMinutes': availableEndMinutes,
      'goal': goal,
    };
  }

  factory WorkSetting.fromMap(Map<String, dynamic> map) {
    return WorkSetting(
      workplaceName: map['workplaceName'] as String?,
      address: map['address'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      allowedRadiusMeters:
      (map['allowedRadiusMeters'] as num?)?.toInt(),
      dailyWorkMinutes:
      (map['dailyWorkMinutes'] as num?)?.toInt(),
      availableStartMinutes:
      (map['availableStartMinutes'] as num?)?.toInt(),
      availableEndMinutes:
      (map['availableEndMinutes'] as num?)?.toInt(),
      goal: map['goal'] as String?,
    );
  }
}