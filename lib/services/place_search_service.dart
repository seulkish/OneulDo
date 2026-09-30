import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/workplace_option.dart';

class PlaceSearchService {
  static const _apiKey = String.fromEnvironment(
    '83e7148b61e5fa7887009930a50551b7', // TODO: 추후 보안 처리 예정
  );

  Future<List<WorkplaceOption>> searchNearby({
    required double latitude,
    required double longitude,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('카카오 REST API 키가 설정되지 않았습니다.');
    }

    // 2km 안에서 검색하고, 3곳 미만이면 5km로 확대합니다.
    var places = await _searchWithinRadius(
      latitude: latitude,
      longitude: longitude,
      radius: 2000,
    );

    if (places.length < 3) {
      places = await _searchWithinRadius(
        latitude: latitude,
        longitude: longitude,
        radius: 5000,
      );
    }

    return places.take(3).toList();
  }

  Future<List<WorkplaceOption>> _searchWithinRadius({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    final results = await Future.wait(
      ['열람실', '스터디카페', '카페'].map(
            (keyword) => _searchKeyword(
          keyword: keyword,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        ),
      ),
    );

    // 같은 장소가 여러 검색어에서 조회될 수 있으므로
    // 카카오 장소 ID를 기준으로 중복을 제거합니다.
    final uniquePlaces = <String, WorkplaceOption>{};

    for (final documents in results) {
      for (final document in documents) {
        final id = document['id']?.toString();
        final lat = double.tryParse('${document['y']}');
        final lng = double.tryParse('${document['x']}');
        final distance = double.tryParse('${document['distance']}');
        final name = document['place_name']?.toString() ?? '';

        if (id == null ||
            name.isEmpty ||
            lat == null ||
            lng == null ||
            distance == null) {
          continue;
        }

        final roadAddress =
            document['road_address_name']?.toString() ?? '';

        uniquePlaces[id] = WorkplaceOption(
          name: name,
          address: roadAddress.isNotEmpty
              ? roadAddress
              : document['address_name']?.toString() ?? '',
          latitude: lat,
          longitude: lng,
          distanceMeters: distance,
        );
      }
    }

    final places = uniquePlaces.values.toList();

    places.sort(
          (a, b) => a.distanceMeters!.compareTo(b.distanceMeters!),
    );

    return places;
  }

  Future<List<Map<String, dynamic>>> _searchKeyword({
    required String keyword,
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    final uri = Uri.https(
      'dapi.kakao.com',
      '/v2/local/search/keyword.json',
      {
        'query': keyword,
        'x': longitude.toString(),
        'y': latitude.toString(),
        'radius': radius.toString(),
        'sort': 'distance',
        'size': '3',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'KakaoAK $_apiKey',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('장소 검색 실패: HTTP ${response.statusCode}');
    }

    final body =
    jsonDecode(utf8.decode(response.bodyBytes))
    as Map<String, dynamic>;

    return (body['documents'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}