import 'package:hikma_health/model/location.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:test_api/test_api.dart';

main() {
  String authentication;
  test("Login", () async {
    authentication = await auth(username: 'superman', password: 'Admin123');
    print(authentication == null
        ? 'Not authenticated.'
        : 'Authenticated: $authentication\n\n');
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
        auth: authentication,
        locationUuid: 'bb0e512e-d225-11e4-9c67-080027b662ec',
        query: 'test'
    );
    for (PatientSearchResult patient in patients) {
      print(patient.name);
    }
  });

  test("Get Patient Data", () async {
    PatientPersonalInfo patient = await getPatient(
        auth: authentication,
        uuid: 'c81a13bd-a669-40ca-ae29-e8d46ece1f16'
    );
    print('${patient.firstNameLocal} ${patient.lastNameLocal}');
  });
}
