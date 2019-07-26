import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sqlcipher/sqlite.dart';
import 'package:hikma_health/database/database_helper.dart';
import 'package:hikma_health/model/location.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:meta/meta.dart';

import '../constants.dart';

class UserRepository {

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    String basicAuth = await auth(
        username: username,
        password: password,
        apiBase: await readInstance());
    return basicAuth;
  }

  Future<String> authenticateBasic() async {
    String auth = await _secureStorage.read(key: 'auth');
    String basicAuth = await baseAuth(
        auth: auth,
        apiBase: await readInstance());
    return basicAuth;
  }

  Future<void> persistAuth(String auth) async {
    /// write to keystore/keychain
    await _secureStorage.write(key: 'auth', value: auth);
  }

  Future<void> deleteAuth() async {
    /// delete from keystore/keychain
    await _secureStorage.delete(key: 'auth');
  }

  Future<String> readAuth() async {
    /// read from keystore/keychain
    return _secureStorage.read(key: 'auth');
  }

  Future<bool> hasAuth() async {
    /// check auth in keystore/keychain
    return await readAuth() != null;
  }

  Future<void> persistLocation(LoginLocation location) async {
    /// write to keystore/keychain`
    await _secureStorage.write(key: 'location_name', value: location.name);
    await _secureStorage.write(key: 'location_uuid', value: location.uuid);
  }

  Future<void> deleteLocation() async {
    /// delete from keystore/keychain
    await _secureStorage.delete(key: 'location_name');
    await _secureStorage.delete(key: 'location_uuid');
  }

  Future<String> readLocationUuid() async {
    /// read from keystore/keychain
    return _secureStorage.read(key: 'location_uuid');
  }

  Future<String> readLocationName() async {
    /// read from keystore/keychain
    return _secureStorage.read(key: 'location_name');
  }

  Future<bool> hasLocation() async {
    /// check location in keystore/keychain
    return await readLocationUuid() != null && await readLocationName() != null;
  }

  Future<void> persistInstance(String url) async {
    await _secureStorage.write(key: 'instance', value: url);
  }

  Future<void> deleteInstance() async {
    await _secureStorage.delete(key: 'instance');
  }

  Future<String> readInstance() async {
    return _secureStorage.read(key: 'instance');
  }

  Future<bool> hasInstance() async {
    return await readInstance() != null;
  }

  Future<SQLiteDatabase> initDatabase() async {
    return _dbHelper.database;
  }

  Future<bool> deleteDatabase() async {
    return _dbHelper.deleteDatabase();
  }

  // Executes the job queue
  executeJobs() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      SQLiteCursor jobs = await _dbHelper.queryJobs();
      String auth = await readAuth();
      String apiBase = await readInstance();
      for (var job in jobs) {
        if (job[columnJobId] == JOB_CREATE_PATIENT) {
          Map dataMap = json.decode(job[columnData]);
          PatientIds patientIds = await createPatient(
              auth: auth,
              body: dataMap,
              apiBase: apiBase);
          if (patientIds != null) {
            await _dbHelper.updateLocalPatientIds(
                job[columnLocalId],
                patientIds);
            await _dbHelper.removeFromJobQueue(job[columnId]);
          }
        } else if (job[columnJobId] == JOB_UPDATE_PATIENT) {
          int localId = job[columnLocalId];
          Map<String, dynamic> row = await _dbHelper.getPatientByLocalId(
              localId);
          String uuid = row[columnUuid];
          Map dataMap = json.decode(job[columnData]);
          await updatePatient(
              auth: auth,
              body: dataMap,
              uuid: uuid,
              apiBase: apiBase);
          await _dbHelper.removeFromJobQueue(job[columnId]);
        }
      }
    }
  }

  updateAllPatients() async {
    SQLiteCursor patients = await _dbHelper.queryLocalPatients();
    for (var patient in patients) {
      await insertOrUpdatePatientByUuid(patient[columnUuid]);
    }
  }

  Future<int> insertOrUpdatePatientByUuid(String uuid) async {
    await executeJobs();
    PatientPersonalInfo info = await getPatient(
        auth: await readAuth(),
        uuid: uuid,
        apiBase: await readInstance());
    return await _dbHelper.insertOrUpdatePatientFromPersonalInfo(info);
  }

  Future<PatientPersonalInfo> getLocalPatientInfo(
      int localId, String uuid) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      localId = await insertOrUpdatePatientByUuid(uuid);
    }
    Map<String, dynamic> row = await _dbHelper.getPatientByLocalId(localId);
    return PatientPersonalInfo.fromRow(row);
  }

  createPatientFromForm(Map data) async {
    int patientLocalId = await _dbHelper.insertToPatients(data);
    String jsonData = json.encode(data).replaceAll('"null"', 'null');
    await _dbHelper
        .insertToJobQueue(patientLocalId, JOB_CREATE_PATIENT, jsonData);
    await executeJobs();
  }

  editPatient(Map data, int localId) async {
    await _dbHelper.editPatient(data, localId);
    String jsonData = json.encode(data).replaceAll('"null"', 'null');
    await _dbHelper.insertToJobQueue(localId, JOB_UPDATE_PATIENT, jsonData);
  }

  Future<List<PatientSearchResult>> searchPatients(String query, String locationUuid) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      String auth = await readAuth();
      return await queryPatient(
          auth: auth,
          locationUuid: locationUuid,
          query: query,
          apiBase: await readInstance());
    }
    SQLiteCursor cursor = await _dbHelper.searchPatients(query);
    return PatientSearchList.fromCursor(cursor).patientSearchList;
  }
}
