import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hikma_health/model/location.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/model/session.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String API_BASE =
    'https://demo-staging.hikmahealth.org/openmrs/ws/rest/v1';

Future<String> authenticate({username, password}) async {
  String basicAuth = createBasicAuth(username, password);
  return baseAuthenticate(basicAuth: basicAuth);
}

Future<String> baseAuthenticate({basicAuth}) async {
  final storage = FlutterSecureStorage();
  var response = await http
      .get('$API_BASE/session', headers: {'authorization': basicAuth},)
      .timeout(Duration(seconds: 30));
  if (response == null) {
    print('network_calls.dart: Status: ${response.statusCode},'
        ' Make sure you\'re connected');
    throw ('Status: ${response.statusCode}, Make sure you\'re connected');
  } else if (response.statusCode == 401) {
    print('network_calls.dart: Status: ${response.statusCode},'
        ' Make sure your credentials are correct');
    throw ('Status: ${response.statusCode}, '
        'Make sure your credentials are correct');
  }
  final responseJson = json.decode(response.body);
  Session session = Session.fromJson(responseJson);
  if (session.authenticated) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth', basicAuth);
    await storage.write(key: 'auth', value: basicAuth);
    return session.id;
  }
  return session.authenticated ? session.id : null;
}

Future<LocationSearchList> getLocations() async {
  String basicAuth = createBasicAuth('superman', 'Admin123');
  var response = await http
      .get('$API_BASE/location?tag=Login Location',
    headers: {'authorization': basicAuth},)
      .timeout(Duration(seconds: 30));
  if (response == null) {
    print('network_calls.dart: Status: ${response.statusCode},'
        ' Make sure you\'re connected');
    throw ('Status: ${response.statusCode}, Make sure you\'re connected');
  } else if (response.statusCode == 401) {
    print('network_calls.dart: Status: ${response.statusCode},'
        ' Make sure your credentials are correct');
    throw ('Status: ${response.statusCode}, '
        'Make sure your credentials are correct');
  }
  final responseJson = json.decode(response.body);
  LocationSearchList locations = LocationSearchList.fromJson(responseJson);
  return locations;
}

Future<List<PatientSearchResult>> queryPatient(
    String locationUuid, String query) async {
  String basicAuth = createBasicAuth('superman', 'Admin123');
  var response = await http
      .get('$API_BASE/bahmnicore/search/patient'
      '?loginLocationUuid=$locationUuid'
      '&q=$query',
    headers: {'authorization': basicAuth},)
      .timeout(Duration(seconds: 30));
  if (response == null) {
    print('network_calls.dart: Status: ${response.statusCode},'
        ' Make sure you\'re connected');
    throw ('Status: ${response.statusCode}, '
        'Make sure you\'re connected');
  }
  if (response.statusCode == 401) {
    return null;
  }
  final responseJson = json.decode(response.body);
  return PatientSearchList.fromJson(responseJson).patientSearchList;
}

Future<PatientPersonalInfo> getPatient(String patientUuid) async {
  String basicAuth = createBasicAuth('superman', 'Admin123');
  var response = await http
      .get('$API_BASE/patient/$patientUuid?v=full',
    headers: {'authorization': basicAuth},)
      .timeout(Duration(seconds: 30));
  if (response == null) {
    print('network_calls.dart: Status: ${response.statusCode},'
        ' Make sure you\'re connected');
    throw ('Status: ${response.statusCode}, '
        'Make sure you\'re connected');
  }
  if (response.statusCode == 401) {
    return null;
  }
  final responseJson = json.decode(response.body);
  return PatientPersonalInfo.fromJson(responseJson);
}

Future<String> createPatient({Map body}) async {
  String basicAuth = createBasicAuth('superman', 'Admin123');
  var data = json.encode(body).replaceAll('"null"', 'null');
  var response = await http
      .post('$API_BASE/bahmnicore/patientprofile', body: data,
      headers: {'authorization': basicAuth, 'content-type': 'application/json'})
      .timeout(Duration(seconds: 30));

  if (response == null) {
    print('network_calls.dart: Status: ${response.statusCode},'
        ' Make sure you\'re connected');
    throw ('Status: ${response.statusCode}, Make sure you\'re connected');
  }
  if (response.statusCode == 401) {
    return null;
  }
  return response.body;
}

String createBasicAuth(String username, String password) =>
    'Basic ' + base64Encode(utf8.encode('$username:$password'));
