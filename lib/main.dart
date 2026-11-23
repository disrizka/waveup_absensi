import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/session_provider.dart';

void main() {
  runApp(const ProviderScope(child: WaveUpApp()));
}

class WaveUpApp extends ConsumerWidget {
  const WaveUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return MaterialApp(
      title: 'WaveUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B7F7C)),
      ),
      home: session.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, __) => const LoginPage(),
        data: (s) => s == null ? const LoginPage() : const HomePage(),
      ),
    );
  }
}
