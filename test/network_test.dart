import 'package:hikma_health/model/location.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:test_api/test_api.dart';

main() {
  String authentication;
  test("Login", () async {
    authentication = await auth(username: 'superman', password: 'Admin123', apiBase: 'https://demo.hikmahealth.org/openmrs/ws/rest/v1');
    print(authentication == null
        ? 'Not authenticated.'
        : 'Authenticated: $authentication\n\n');
  });

  test("Login Locations", () async {
    List<Location> locationList = await getLocations(
        'https://demo.hikmahealth.org/openmrs/ws/rest/v1');
    print('${locationList.length} locations found.');
    for (Location location in locationList) {
      print('Location Name: ${location.name}.');
      print('Location ID: ${location.uuid}.');
    }
    print('\n');
  });

  test("Patient Query", () async {
    List<PatientSearchResult> patients = await queryPatient(
        auth: authentication,
        locationUuid: 'bb0e512e-d225-11e4-9c67-080027b662ec',
        query: 'test',
        apiBase: 'https://demo.hikmahealth.org/openmrs/ws/rest/v1'
    );
    for (PatientSearchResult patient in patients) {
      print(patient.name);
    }
  });

  test("Get Patient Data", () async {
    PatientPersonalInfo patient = await getPatient(
        auth: authentication,
        uuid: 'c81a13bd-a669-40ca-ae29-e8d46ece1f16',
        apiBase: 'https://demo.hikmahealth.org/openmrs/ws/rest/v1',
    );
    print('${patient.firstNameLocal} ${patient.lastNameLocal}');
  });
}
