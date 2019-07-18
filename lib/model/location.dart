
class LoginLocationList {
  final List<LoginLocation> locationSearchList;

  LoginLocationList.fromJson(Map jsonMap)
      : locationSearchList = List<LoginLocation>() {
    for (var jsonLocation in jsonMap['results']) {
      locationSearchList.add(LoginLocation.fromJson(jsonLocation));
    }
  }
}

class LoginLocation {
  final String uuid;
  final String name;

  LoginLocation.fromJson(Map jsonMap)
      : uuid = jsonMap['uuid'],
        name = jsonMap['display'];
}
