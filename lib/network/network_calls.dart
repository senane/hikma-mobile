import 'dart:convert';

import 'package:hikma_health/model/location.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/model/session.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

const String API_BASE =
    'https://demo.hikmahealth.org/openmrs/ws/rest/v1';

Future<String> auth({@required username, @required password}) async {
  String basicAuth = createBasicAuth(username, password);
  return baseAuth(auth: basicAuth);
}

Future<String> baseAuth({@required auth}) async {
  var response = await http
      .get('$API_BASE/session', headers: {'authorization': auth},)
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
  return session.authenticated ? auth : null;
}

Future<List<Location>> getLocations() async {
  var response = await http
      .get('$API_BASE/location?tag=Login Location')
      .timeout(Duration(seconds: 10));
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
  return LocationList.fromJson(responseJson).locationList;
}

Future<List<PatientSearchResult>> queryPatient({
  @required String auth,
  @required String locationUuid,
  @required String query}) async {
  var response = await http.get('$API_BASE/bahmnicore/search/patient'
      '?loginLocationUuid=$locationUuid&q=$query',
    headers: {'authorization': auth},)
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

Future<PatientPersonalInfo> getPatient({
  @required String auth,
  @required String uuid}) async {
  var response = await http.get('$API_BASE/patient/$uuid?v=full',
    headers: {'authorization': auth},).timeout(Duration(seconds: 30));
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

Future<PatientIds> createPatient({@required auth, @required Map body}) async {
  var data = json.encode(body).replaceAll('"null"', 'null');
  var response = await http
      .post('$API_BASE/bahmnicore/patientprofile', body: data,
      headers: {'authorization': auth, 'content-type': 'application/json'})
      .timeout(Duration(seconds: 30));

  if (response == null) {
    print('network_calls.dart: Status: ${response.statusCode},'
        ' Make sure you\'re connected');
    throw ('Status: ${response.statusCode}, Make sure you\'re connected');
  }
  if (response.statusCode == 401) {
    return null;
  }
  final responseJson = json.decode(response.body);
  return PatientIds.fromJson(responseJson);
}

Future<http.Response> updatePatient({
  @required auth,
  @required Map body,
  @required String uuid}) async {
  var data = json.encode(body).replaceAll('"null"', 'null');
  var response = await http
      .post('$API_BASE/bahmnicore/patientprofile/$uuid?v=full', body: data,
      headers: {'authorization': auth, 'content-type': 'application/json'})
      .timeout(Duration(seconds: 30));

  if (response == null) {
    print('network_calls.dart: Status: ${response.statusCode},'
        ' Make sure you\'re connected');
    throw ('Status: ${response.statusCode}, Make sure you\'re connected');
  }
  if (response.statusCode == 401) {
    return null;
  }
  return response;
}

String createBasicAuth(String username, String password) =>
    'Basic ' + base64Encode(utf8.encode('$username:$password'));
