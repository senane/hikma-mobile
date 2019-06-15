import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sqlcipher/sqlite.dart';
import 'package:hikma_health/database/database_helper.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:hikma_health/network/sync.dart';
import 'package:meta/meta.dart';

class UserRepository {

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
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
    return _dbHelper.database;
  }

  Future<bool> deleteDatabase() async {
    return _dbHelper.deleteDatabase();
  }

  queueJob(int jobId, String data) async {
    await _dbHelper.insertToJobQueue(jobId, data);
    return data;
  }

  sync() async {
    var jobs = await _dbHelper.queryJobs();
    for (var job in jobs) {
      synchronise(job);
    }
  }
}
