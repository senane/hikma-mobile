class Session {
  final String id;
  final bool authenticated;

  Session.fromJson(Map jsonMap)
      : id = jsonMap['sessionId'],
        authenticated = jsonMap['authenticated'];
}
