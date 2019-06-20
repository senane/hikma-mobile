import 'dart:io';

import 'package:flutter_android/android_content.dart' show Context;
import 'package:flutter_sqlcipher/sqlite.dart';

class DatabaseHelper {

  static final tableJobQueue = 'job_queue';
  static final columnId = 'id';
  static final columnPatientId = 'patient_id';
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

  static final columnPIDIdentifierSourceUuid = 'pid_identifier_source_uuid';
  static final columnPIDIdentifierPrefix = 'pid_identifier_prefix';
  static final columnPIDIdentifierType = 'pid_identifier_type';
  static final columnPIDIdentifierPreferred = 'pid_identifier_preferred';
  static final columnPIDIdentifierVoided = 'pid_identifier_voided';

  static final columnNIDIdentifierSourceUuid = 'nid_identifier_uuid';
  static final columnNIDIdentifierPrefix = 'nid_identifier_prefix';
  static final columnNIDIdentifierType = 'nid_identifier_type';
  static final columnNIDIdentifierPreferred = 'nid_identifier_preferred';
  static final columnNIDIdentifierVoided = 'nid_identifier_voided';

  static final columnFirstNameLocalUuid = 'first_name_local_uuid';
  static final columnFirstNameLocalValue = 'first_name_local_value';
  static final columnMiddleNameLocalUuid = 'middle_name_local_uuid';
  static final columnMiddleNameLocalValue = 'middle_name_local_value';
  static final columnLastNameLocalUuid = 'last_name_local_uuid';
  static final columnLastNameLocalValue = 'last_name_local_value';

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
        $columnPatientId INTEGER, 
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
        
        $columnPIDIdentifierSourceUuid TEXT,
        $columnPIDIdentifierPrefix TEXT,
        $columnPIDIdentifierType TEXT,
        $columnPIDIdentifierPreferred BOOLEAN,
        $columnPIDIdentifierVoided BOOLEAN,
        
        $columnNIDIdentifierSourceUuid TEXT,
        $columnNIDIdentifierPrefix TEXT,
        $columnNIDIdentifierType TEXT,
        $columnNIDIdentifierPreferred BOOLEAN,
        $columnNIDIdentifierVoided BOOLEAN,

        $columnFirstNameLocalUuid TEXT,
        $columnFirstNameLocalValue TEXT,
        $columnMiddleNameLocalUuid TEXT,
        $columnMiddleNameLocalValue TEXT,
        $columnLastNameLocalUuid TEXT,
        $columnLastNameLocalValue TEXT,
        
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

  Future<int> insertToJobQueue(int patientId, int jobId, String data) async {
    SQLiteDatabase db = await instance.database;
    var linkId = db.insert(
      table: tableJobQueue,
      values: <String, dynamic>{
        columnId: null,
        columnPatientId: patientId,
        columnJobId: jobId,
        columnData: data,
      },
    );
    return linkId;
  }

  Future<int> removeFromJobQueue(int id) async {
    SQLiteDatabase db = await instance.database;

  }

  Future<int> insertToPatients(Map data) async {
    SQLiteDatabase db = await instance.database;
    var linkId = db.insert(
      table: tablePatients,
      values: <String, dynamic>{
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

        columnPIDIdentifierSourceUuid:
          data['patient']['identifiers'][0]['identifierSourceUuid'],
        columnPIDIdentifierPrefix:
          data['patient']['identifiers'][0]['identifierPrefix'],
        columnPIDIdentifierType:
          data['patient']['identifiers'][0]['identifierType'],
        columnPIDIdentifierPreferred:
          data['patient']['identifiers'][0]['identifierPreferred'],
        columnPIDIdentifierVoided:
          data['patient']['identifiers'][0]['identifierVoided'],

        columnNIDIdentifierSourceUuid:
          data['patient']['identifiers'][1]['identifierSourceUuid'],
        columnNIDIdentifierPrefix:
          data['patient']['identifiers'][1]['identifierPrefix'],
        columnNIDIdentifierType:
          data['patient']['identifiers'][1]['identifierType'],
        columnNIDIdentifierPreferred:
          data['patient']['identifiers'][1]['identifierPreferred'],
        columnNIDIdentifierVoided:
          data['patient']['identifiers'][1]['identifierVoided'],

        columnFirstNameLocalUuid:
          data['patient']['person']['attributes'][0]['attributeType']['uuid'],
        columnFirstNameLocalValue:
          data['patient']['person']['attributes'][0]['value'],
        columnMiddleNameLocalUuid:
          data['patient']['person']['attributes'][1]['attributeType']['uuid'],
        columnMiddleNameLocalValue:
          data['patient']['person']['attributes'][1]['value'],
        columnLastNameLocalUuid:
          data['patient']['person']['attributes'][2]['attributeType']['uuid'],
        columnLastNameLocalValue:
          data['patient']['person']['attributes'][2]['value'],

        columnGender: data['patient']['gender'],
        columnBirthDate: data['patient']['birthdate'],
        columnBirthDateEstimated: data['patient']['birthdateEstimated'],
        columnCauseOfDeath: data['patient']['causeOfDeath'],
        },
    );
    return linkId;
  }

  Future<SQLiteCursor> queryJobs() {
    return _database.rawQuery('SELECT * FROM $tableJobQueue');
  }
}
