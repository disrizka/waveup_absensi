import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../models/session.dart';
import '../repositories/auth_repository.dart';
import '../services/session_storage.dart';

/// State: null = belum login, Session = sudah login.
class SessionNotifier extends AsyncNotifier<Session?> {
  Future<String?>? _refreshing; // mencegah refresh bersamaan

  @override
  Future<Session?> build() => ref.read(sessionStorageProvider).read();

  Future<void> setSession(Session s) async {
    await ref.read(sessionStorageProvider).write(s);
    state = AsyncData(s);
  }

  Future<void> logout() async {
    await ref.read(sessionStorageProvider).clear();
    state = const AsyncData(null);
  }

  /// Refresh access token. Return access token baru, atau null jika gagal.
  /// Jika refresh token sudah tidak valid -> otomatis logout.
  Future<String?> refreshAccessToken() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<String?> _doRefresh() async {
    final current = state.valueOrNull;
    if (current == null) return null;
    try {
      final newAccess = await ref
          .read(authRepositoryProvider)
          .refreshToken(current.token.refreshToken);
      await setSession(
        current.copyWith(token: current.token.copyWith(accessToken: newAccess)),
      );
      return newAccess;
    } on ApiException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 401 || e.statusCode == 403) {
        await logout();
      }
      return null;
    }
  }
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, Session?>(
  SessionNotifier.new,
);
