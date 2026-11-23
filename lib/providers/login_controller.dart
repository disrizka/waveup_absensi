import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waveup_absensi/providers/session_provider.dart';
import 'package:waveup_absensi/repositories/auth_repository.dart';



class LoginController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> login(String user, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref.read(authRepositoryProvider).login(
            user: user.trim(),
            password: password,
            deviceId: '1234656',
            deviceName: Platform.isIOS ? 'iPhone' : 'Android',
            fcmToken: '123456',
          );
      await ref.read(sessionProvider.notifier).setSession(session);
    });
  }
}

final loginControllerProvider =
    AutoDisposeAsyncNotifierProvider<LoginController, void>(LoginController.new);