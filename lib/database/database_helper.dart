import 'dart:io';

import 'package:flutter_android/android_content.dart' show Context;
import 'package:flutter_sqlcipher/sqlite.dart';
import 'package:hikma_health/model/patient.dart';

class DatabaseHelper {

  static final tableJobQueue = 'job_queue';
  static final columnId = 'id';
  static final columnJobId = 'job_id';
  static final columnData = 'data';

  static final tablePatients = 'patients';

  static final columnGivenName = 'first_name';
  static final columnMiddleName = 'middle_name';
  static final columnFamilyName = 'family_name';
  static final columnNamePreferred = 'name_preferred';

  static final columnAddress1 = 'address1';
  static final columnAddress2 = 'address2';
  static final columnAddress3 = 'address3';
  static final columnCityVillage = 'city_village';
  static final columnCountyDistrict = 'county_district';
  static final columnStateProvince = 'state_province';

  static final columnUuid = 'uuid';
  static final columnPID = 'pid';
  static final columnNID = 'nid';

  static final columnFirstNameLocal = 'first_name_local';
  static final columnMiddleNameLocal = 'middle_name_local';
  static final columnLastNameLocal = 'last_name_local';

  static final columnGender = 'gender';
  static final columnBirthDate = 'birth_date';
  static final columnBirthDateEstimated = 'birth_date_estimated';
  static final columnCauseOfDeath = 'cause_of_death';

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static SQLiteDatabase _database;
  Future<SQLiteDatabase> get database async {
    if (_database == null) await _initDatabase();
    return _database;
  }

  Future<SQLiteDatabase> _initDatabase() async {
    var cacheDir = await Context.cacheDir;
    if (!cacheDir.existsSync()) {
      await cacheDir.create(recursive: true);
    }
    // Careful here
    var cacheFile = File('${cacheDir.path}/cache.db');
    if (cacheFile.existsSync()) {
      _database = await SQLiteDatabase.openOrCreateDatabase(cacheFile.path);
    } else {
      _database = await SQLiteDatabase.openOrCreateDatabase(cacheFile.path);
      await _onCreate(_database);
    }
    return _database;
  }

  _onCreate(SQLiteDatabase db) async {
    await db.execSQL("""
      CREATE TABLE $tableJobQueue (
        $columnId INTEGER PRIMARY KEY,
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
        $columnNamePreferred BOOLEAN,
        
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
        $columnBirthDate DATETIME,
        $columnBirthDateEstimated BOOLEAN,
        $columnCauseOfDeath TEXT
      )
    """);
  }

  /// Helper methods

  Future<bool> deleteDatabase() async {
    var cacheDir = await Context.cacheDir;
    _database = null;
    return SQLiteDatabase.deleteDatabase('${cacheDir.path}/cache.db');
  }

  Future<int> insertToJobQueue(int jobId, String data) async {
    return _database.insert(
      table: tableJobQueue,
      values: <String, dynamic>{
        columnId: null,
        columnJobId: jobId,
        columnData: data,
      },
    );
  }

  removeFromJobQueue(int id) async {
  }

  Future<int> insertToPatients(Map data) async {
    return _database.insert(
      table: tablePatients,
      values: <String, dynamic> {
        columnId: null, // auto-incremented ID assigned automatically
        columnGivenName: data['patient']['person']['names'][0]['givenName'],
        columnMiddleName: data['patient']['person']['names'][0]['middleName'],
        columnFamilyName: data['patient']['person']['names'][0]['familyName'],
        columnNamePreferred: false,

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

        columnGender: data['patient']['gender'],
        columnBirthDate: data['patient']['birthdate'],
        columnBirthDateEstimated: data['patient']['birthdateEstimated'],
        columnCauseOfDeath: data['patient']['causeOfDeath'],
      },
    );
  }

  updatePatientIds(int localId, PatientIds patientIds) async {
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

  Future<SQLiteCursor> queryJobs() {
    return _database.rawQuery('SELECT * FROM $tableJobQueue');
  }
}
