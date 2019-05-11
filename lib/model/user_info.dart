import 'dart:core';

class UserInfo {
  final bool result;
  final String message;
  final Plans plans;
  final User user;

  UserInfo.fromJson(Map jsonMap)
      : result = jsonMap['result'],
        message = jsonMap['message'],
        plans = new Plans.fromJson(jsonMap['plans']),
        user = new User.fromJson(jsonMap['user']);
}

class Plans {
  final RitetagPlanDetails ritetagPlan;

  Plans.fromJson(Map jsonMap)
      : ritetagPlan = jsonMap['ritetag'] == null
            ? RitetagPlanDetails.noPlan()
            : RitetagPlanDetails.fromJson(jsonMap['ritetag']);
}

class RitetagPlanDetails {
  final bool isActive;
  final bool isTrial;
  final String name;
  final DateTime expiration;

  RitetagPlanDetails.noPlan()
      : isActive = false,
        isTrial = false,
        name = null,
        expiration = null;

  RitetagPlanDetails.fromJson(Map jsonMap)
      : isActive =
      jsonMap['expiration'] == null || // Implies subscription active
          DateTime.now()
              .toUtc()
              .isBefore(DateTime.parse(jsonMap['expiration'])) ??
          false,
        isTrial = jsonMap['name'].toString().contains('trial'),
        name = jsonMap['name'],
        expiration = jsonMap['expiration'] == null
            ? null
            : DateTime.parse(jsonMap['expiration']);

  /// Changes how two [RitetagPlanDetails] objects are compared
  @override
  operator ==(other) =>
      other is RitetagPlanDetails &&
          isActive == other.isActive &&
          isTrial == other.isTrial &&
          name == other.name &&
          expiration == other.expiration;
}

class User {
  final int id;
  final String name;
  final String profileImage;
  final String email;

  User.fromJson(Map jsonMap)
      : id = jsonMap['id'],
        name = jsonMap['name'] ?? "",
        profileImage = jsonMap['profileImage'] ?? "",
        email = jsonMap['email'] ?? "";

  User.noInfo()
      : id = 0,
        name = 'RiteTag',
        email = 'Log into RiteTag',
        profileImage = 'assets/logo_app.png';
}