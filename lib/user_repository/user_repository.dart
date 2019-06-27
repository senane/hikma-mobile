import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sqlcipher/sqlite.dart';
import 'package:hikma_health/database/database_helper.dart';
import 'package:hikma_health/model/patient.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:meta/meta.dart';

import '../constants.dart';

class UserRepository {

  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    String basicAuth = await auth(username: username, password: password);
    return basicAuth;
  }

  Future<String> authenticateBasic() async {
    String auth = await _secureStorage.read(key: 'auth');
    String basicAuth = await baseAuth(auth: auth);
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

  Future<SQLiteDatabase> initDatabase() async {
    return dbHelper.database;
  }

  Future<bool> deleteDatabase() async {
    return dbHelper.deleteDatabase();
  }

  // Executes the job queue
  executeJobs() async {
    SQLiteCursor jobs = await dbHelper.queryJobs();
    String auth = await readAuth();
    for (var job in jobs) {
      if (job['job_id'] == JOB_CREATE_PATIENT) {
        Map dataMap = json.decode(job['data']);
        PatientIds patientIds = await createPatient(auth: auth, body: dataMap);
        print(job);
        if (patientIds != null) {
          await dbHelper.updateLocalPatientIds(job['record_id'], patientIds);
          await dbHelper.removeFromJobQueue(job['id']);

          String idString = job['id'].toString();
          print('removed job $idString');
        }
      }
    }
  }

  updateAllPatients() async {
    SQLiteCursor patients = await dbHelper.queryLocalPatients();
    for (var patient in patients) {
      PatientPersonalInfo info = await getPatient(
          auth: await readAuth(),
          uuid: patient['uuid']
      );
      await dbHelper.insertOrUpdatePatientFromPersonalInfo(info);
    }
  }
}
