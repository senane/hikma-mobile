
class LocationSearchList {
  final List<LocationSearchResult> locationSearchList;

  LocationSearchList.fromJson(Map jsonMap)
      : locationSearchList = List<LocationSearchResult>() {
    for (var jsonLocation in jsonMap['results']) {
      locationSearchList.add(LocationSearchResult.fromJson(jsonLocation));
    }
  }
}

class LocationSearchResult {
  final String uuid;
  final String name;

  LocationSearchResult.fromJson(Map jsonMap)
      : uuid = jsonMap['uuid'],
        name = jsonMap['display'];
}
