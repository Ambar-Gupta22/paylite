import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/domain/session.dart';

class SecureSessionStore {
  final FlutterSecureStorage _storage;

  static const String _sessionKey = 'paylite_session';

  SecureSessionStore(this._storage);

  Future<void> saveSession(Session session) async {
    final jsonString = jsonEncode(session.toJson());
    await _storage.write(key: _sessionKey, value: jsonString);
  }

  Future<Session?> getSession() async {
    final jsonString = await _storage.read(key: _sessionKey);
    if (jsonString == null) return null;

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return Session.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
  }
}
