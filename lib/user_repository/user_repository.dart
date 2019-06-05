import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:meta/meta.dart';

class UserRepository {

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    String basicAuth = await auth(username: username, password: password);
    return basicAuth;
  }

  Future<String> authenticateBasic() async {
    String auth = await FlutterSecureStorage().read(key: 'auth');
    String basicAuth = await baseAuth(auth: auth);
    return basicAuth;
  }

  Future<void> deleteAuth() async {
    /// delete from keystore/keychain
    await FlutterSecureStorage().delete(key: 'auth');
  }

  Future<void> persistAuth(String auth) async {
    /// write to keystore/keychain
    await FlutterSecureStorage().write(key: 'auth', value: auth);
  }

  Future<String> readAuth() async {
    /// read from keystore/keychain
    return FlutterSecureStorage().read(key: 'auth');
  }

  Future<bool> hasAuth() async {
    /// check auth in keystore/keychain
    return await readAuth() != null;
  }
}
