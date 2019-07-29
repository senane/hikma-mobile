import 'dart:io';

import 'package:flutter_android/android_content.dart' show Context;
import 'package:flutter_sqlcipher/sqlite.dart';
import 'package:hikma_health/model/patient.dart';

import '../constants.dart';

class DatabaseHelper {

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static SQLiteDatabase _database;
  Future<SQLiteDatabase> get database async {
    if (_database == null) await _initDatabase();
    return _database;
  }

  Future<SQLiteDatabase> _initDatabase() async {
    /// If there exists a database, open it. Otherwise, create new database.
    var cacheDir = await Context.cacheDir;
    if (!cacheDir.existsSync()) {
      await cacheDir.create(recursive: true);
    }
    // Careful here
    var cacheFile = File('${cacheDir.path}/cache.db');
    bool newDatabase = !(cacheFile.existsSync());
    _database = await SQLiteDatabase.openOrCreateDatabase(cacheFile.path);
    if (newDatabase) {
      await _onCreate(_database);
    }
    return _database;
  }

  _onCreate(SQLiteDatabase db) async {
    /// Initialize database tables
    await db.execSQL("""
      CREATE TABLE $tableJobQueue (
        $columnId INTEGER PRIMARY KEY,
        $columnLocalId INTEGER, 
        $columnJobId INTEGER,
        $columnData TEXT NOT NULL
      )
    """);
    await db.execSQL("""
      CREATE TABLE $tablePatients (
        $columnId INTEGER PRIMARY KEY,
        $columnGivenName TEXT,
        $columnMiddleName TEXT,
        $columnFamilyName TEXT,
        
        $columnAddress1 TEXT,
        $columnAddress2 TEXT,
        $columnAddress3 TEXT,
        $columnCityVillage TEXT,
        $columnCountyDistrict TEXT,
        $columnStateProvince TEXT,
        
        $columnUuid TEXT,
        $columnPID TEXT,
        $columnNID TEXT,

        $columnFirstNameLocal TEXT,
        $columnMiddleNameLocal TEXT,
        $columnLastNameLocal TEXT,
        
        $columnGender TEXT,
        $columnBirthDate DATETIME
      )
    """);
  }

  /// # Helper methods

  /// ## Database Methods

  Future<bool> deleteDatabase() async {
    var cacheDir = await Context.cacheDir;
    _database = null;
    return SQLiteDatabase.deleteDatabase('${cacheDir.path}/cache.db');
  }

  /// ## Job Queue methods

  Future<int> insertToJobQueue(int localId, int jobId, String data) async {
    return _database.insert(
      table: tableJobQueue,
      values: <String, dynamic>{
        columnId: null,
        columnLocalId: localId, // Links job to a patient in the database
        columnJobId: jobId, // Type of job (create patient, edit, etc.)
        columnData: data, // The job itself
      },
    );
  }

  removeFromJobQueue(int id) async {
    return _database.delete(
      table: tableJobQueue,
      where: 'id = ?',
      whereArgs: <String>[id.toString()],
    );
  }

  Future<SQLiteCursor> queryJobs() {
    return _database.rawQuery('SELECT * FROM $tableJobQueue');
  }

  /// ## Patients Methods

  Future<int> insertToPatients(Map data) {
    /// Creates a patient from the json output of the create patient form.
    return _database.insert(
      table: tablePatients,
      values: <String, dynamic> {
        columnId: null, // auto-incremented ID assigned automatically
        columnGivenName: data['patient']['person']['names'][0]['givenName'],
        columnMiddleName: data['patient']['person']['names'][0]['middleName'],
        columnFamilyName: data['patient']['person']['names'][0]['familyName'],

        columnUuid: 'Unassigned',
        columnPID: 'Unassigned',
        columnNID: 'Unassigned',

        columnAddress1: data['patient']['person']['addresses'][0]['address1'],
        columnCityVillage:
        data['patient']['person']['addresses'][0]['cityVillage'],
        columnCountyDistrict:
        data['patient']['person']['addresses'][0]['countyDistrict'],
        columnStateProvince:
        data['patient']['person']['addresses'][0]['stateProvince'],

        columnFirstNameLocal:
        data['patient']['person']['attributes'][0]['value'],
        columnMiddleNameLocal:
        data['patient']['person']['attributes'][1]['value'],
        columnLastNameLocal:
        data['patient']['person']['attributes'][2]['value'],

        columnGender: data['patient']['person']['gender'],
        columnBirthDate: data['patient']['person']['birthdate'],
      },
    );
  }

  editPatient(Map data, int localId) async {
    /// Edits a patient from the json output of the edit patient form.
    _database.update(
        table: tablePatients,
        values: <String, dynamic> {
          columnGivenName: data['patient']['person']['names'][0]['givenName'],
          columnMiddleName: data['patient']['person']['names'][0]['middleName'],
          columnFamilyName: data['patient']['person']['names'][0]['familyName'],

          columnAddress1: data['patient']['person']['addresses'][0]['address1'],
          columnCityVillage:
          data['patient']['person']['addresses'][0]['cityVillage'],
          columnCountyDistrict:
          data['patient']['person']['addresses'][0]['countyDistrict'],
          columnStateProvince:
          data['patient']['person']['addresses'][0]['stateProvince'],

          columnFirstNameLocal:
          data['patient']['person']['attributes'][0]['value'],
          columnMiddleNameLocal:
          data['patient']['person']['attributes'][1]['value'],
          columnLastNameLocal:
          data['patient']['person']['attributes'][2]['value'],

          columnGender: data['patient']['person']['gender'],
          columnBirthDate: data['patient']['person']['birthdate'],
        },
        where: '$columnId = ?',
        whereArgs: <String> [localId.toString()],
    );
    return await getPatientByLocalId(localId);
  }

  Future<int> insertOrUpdatePatientFromPersonalInfo(
      PatientPersonalInfo info) async {
    /// If the patient does not exist, create it. Otherwise update patient info.
    bool exists = await patientExists(info.uuid);
    if (!exists) {
      await _database.insert(
          table: tablePatients,
          values: <String, dynamic> {
            columnUuid: info.uuid,
          }
      );
    }
    await _database.update(
        table: tablePatients,
        values: <String, dynamic>{
          columnNID: info.nationalId,

          columnGivenName: info.firstName,
          columnFamilyName: info.lastName,
          columnPID: info.patientId,

          columnGivenName: info.firstName,
          columnMiddleName: info.middleName,
          columnFamilyName: info.lastName,

          columnAddress1: info.address,
          columnCityVillage: info.cityVillage,
          columnStateProvince: info.state,

          columnFirstNameLocal: info.firstNameLocal,
          columnMiddleNameLocal: info.middleNameLocal,
          columnLastNameLocal: info.lastNameLocal,

          columnGender: info.gender,
          columnBirthDate: info.birthDate,
        },
        where: '$columnUuid = ?',
        whereArgs: <String>[info.uuid]
    );
    Map<String, dynamic> patient = await getPatientByUuid(info.uuid);
    return patient[columnId];
  }

  Future<bool> patientExists(String uuid) async {
    SQLiteCursor localVersions = await _database.query(
      table: tablePatients,
      where: '$columnUuid = ?',
      whereArgs: [uuid],
    );
    return (localVersions.getCount() > 0);
  }

  updateLocalPatientIds(int localId, PatientIds patientIds) async {
    /// Initially, locally saved patients are not assigned patient IDs,
    /// national IDs, or UUIDs. This must be done by the online instance of
    /// Bahmni. This method is used to update only the IDs after the patient
    /// has been created online.
    Map ids = patientIds.toMap();
    await _database.update(
      table: tablePatients,
      values: <String, dynamic>{
        columnUuid: ids['uuid'],
        columnPID: ids['pid'],
        columnNID: ids['nid'],
      },
      where: '$columnId = ?',
      whereArgs: <String>[localId.toString()]
    );
  }

  Future<SQLiteCursor> queryLocalPatients() {
    return _database.rawQuery('SELECT * FROM $tablePatients');
  }

  Future<Map<String, dynamic>> getPatientByUuid(String uuid) async {
    SQLiteCursor patients = await _database.query(
      table: tablePatients,
      where: '$columnUuid = ?',
      whereArgs: <String>[uuid]
    );
    return patients.first;
  }

  Future<Map<String, dynamic>> getPatientByLocalId(int localId) async {
    SQLiteCursor patients = await _database.query(
        table: tablePatients,
        where: '$columnId = ?',
        whereArgs: <String>[localId.toString()]
    );
    return patients.first;
  }

  Future<SQLiteCursor> searchPatients(String query) async {
    List<String> colsToSearch = [
      columnGivenName,
      columnMiddleName,
      columnFamilyName,
      columnPID,
    ];
    List<String> queryList = query.split(' ');
    List<String> searchConditions = [];
    queryList.forEach((word) {
      List<String> cond = [];
      colsToSearch.forEach((col) {
        cond.add(col + " LIKE '%$word%'");
      });
      searchConditions.add('(${cond.join(' OR ')})');
    });
    String searchString = searchConditions.join(' AND ');
    return _database.rawQuery(
        "SELECT * FROM $tablePatients "
            "WHERE ($searchString) "
            "AND $columnPID IS NOT NULL "
    );
  }
}
