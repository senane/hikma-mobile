class LocationSearchResult {
  final String uuid;
  final String name;

  LocationSearchResult.fromJson(Map jsonMap)
      : uuid = jsonMap['uuid'],
        name = jsonMap['display'];
}
