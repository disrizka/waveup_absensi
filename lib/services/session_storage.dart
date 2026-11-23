import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/session.dart';

class SessionStorage {
  static const _key = 'waveup_session';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Session?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      return Session.fromJson(jsonDecode(raw));
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> write(Session s) =>
      _storage.write(key: _key, value: jsonEncode(s.toJson()));

  Future<void> clear() => _storage.delete(key: _key);
}

final sessionStorageProvider = Provider<SessionStorage>((_) => SessionStorage());