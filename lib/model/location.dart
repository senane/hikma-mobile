class LocationList {
  final List<Location> locationList;

  LocationList.fromJson(Map jsonMap)
      : locationList = List<Location>() {
    for (var jsonLocation in jsonMap['results']) {
      locationList.add(Location.fromJson(jsonLocation));
    }
  }
}

class Location {
  final String uuid;
  final String name;

  Location.fromJson(Map jsonMap)
      : uuid = jsonMap['uuid'],
        name = jsonMap['display'];
}
