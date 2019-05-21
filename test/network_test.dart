import 'package:hikma_health/model/location.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:test_api/test_api.dart';
import 'package:hikma_health/network/network_calls.dart';

main() {
  String sessionId;
  test("Login", () async {
    sessionId = await authenticate(username: 'superman', password: 'Admin123');
    print(sessionId == null ? 'Not authenticated.' : 'Authenticated. Session ID: $sessionId\n\n');
  });

  test("Login Locations", () async {
    LocationSearchList locations = await getLocations();
    List<LocationSearchResult> locationList = locations.locationSearchList;
    print('${locationList.length} locations found.');
    for (LocationSearchResult location in locationList) {
      print('Location Name: ${location.name}.');
      print('Location ID: ${location.uuid}.');
    }
    print('\n');
  });

  test("Patient Query", () async {
    List<PatientSearchResult> patients = await queryPatient(
        'bb0e512e-d225-11e4-9c67-080027b662ec',
        'LOL');
    for (PatientSearchResult patient in patients) {
      print(patient.name);
    }
  });

  test("Get Patient Data", () async {
    PatientPersonalInfo patient = await getPatient(
        '9bcbbe57-a551-4d2d-a50d-0ca17a0dea25');
    print('${patient.firstNameLocal} ${patient.lastNameLocal}');
  });
}
