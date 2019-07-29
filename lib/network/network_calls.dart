import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hikma_health/model/location.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/model/session.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

Future<String> auth(
    {@required username, @required password, @required String apiBase}) async {
  String basicAuth = createBasicAuth(username, password);
  return baseAuth(auth: basicAuth, apiBase: apiBase);
}

Future<String> baseAuth({@required auth, @required String apiBase}) async {
  var response = await http
      .get('$apiBase/session', headers: {'authorization': auth},)
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

Future<List<Location>> getLocations(String apiBase) async {
  var response = await http
      .get('$apiBase/location?tag=Login Location')
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
  return LocationList.fromJson(responseJson).locationList;
}

Future<List<PatientSearchResult>> queryPatient({
  @required String auth,
  @required String locationUuid,
  @required String query,
  @required String apiBase}) async {
  var response = await http.get('$apiBase/bahmnicore/search/patient'
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
  List<PatientSearchResult> patientResultList = [];
  for (var patient in responseJson['pageOfResults']) {
    NetworkImage avatar = getPatientPhoto(auth: auth, uuid: patient['uuid'], apiBase: apiBase);
    patientResultList.add(PatientSearchResult.fromJson(patient, avatar));
  }
  return PatientSearchList.fromResultList(patientResultList).patientSearchList;
}

Future<PatientPersonalInfo> getPatient({
  @required String auth,
  @required String uuid,
  @required String apiBase}) async {
  var response = await http.get('$apiBase/patient/$uuid?v=full',
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

Future<PatientIds> createPatient(
    {@required auth, @required Map body, @required String apiBase}) async {
  var data = json.encode(body).replaceAll('"null"', 'null');
  var response = await http
      .post('$apiBase/bahmnicore/patientprofile', body: data,
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

updatePatient({
  @required String auth,
  @required Map body,
  @required String uuid,
  @required String apiBase}) async {
  var data = json.encode(body).replaceAll('"null"', 'null');
  var response = await http
      .post('$apiBase/bahmnicore/patientprofile/$uuid?v=full', body: data,
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
}

String createBasicAuth(String username, String password) =>
    'Basic ' + base64Encode(utf8.encode('$username:$password'));

NetworkImage getPatientPhoto({
  @required String auth,
  @required String uuid,
  @required String apiBase,}) {
  return NetworkImage(
      '$apiBase/patientImage?patientUuid=$uuid',
      headers: {'authorization': auth},
  );
}