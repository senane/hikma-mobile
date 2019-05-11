import 'package:hikma_health/model/location_search_result.dart';

class LocationSearchList {
  final List<LocationSearchResult> locationSearchList;

  LocationSearchList.fromJson(Map jsonMap)
      : locationSearchList = List<LocationSearchResult>() {
    for (var jsonLocation in jsonMap['results']) {
      locationSearchList.add(LocationSearchResult.fromJson(jsonLocation));
    }
  }
}