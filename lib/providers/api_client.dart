import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'session_provider.dart';

class AuthClient extends http.BaseClient {
  final Ref _ref;
  final http.Client _inner = http.Client();

  AuthClient(this._ref);

  http.Request _copy(http.BaseRequest original, List<int> bytes, String? token) {
    final req = http.Request(original.method, original.url)
      ..followRedirects = original.followRedirects
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection
      ..headers.addAll(original.headers)
      ..bodyBytes = bytes;
    req.headers.putIfAbsent('Content-Type', () => 'application/json');
    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }
    return req;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final bytes = await request.finalize().toBytes();

    final token = _ref.read(sessionProvider).valueOrNull?.token.accessToken;
    final first = await _inner.send(_copy(request, bytes, token));
    if (first.statusCode != 401) return first;

    final newToken = await _ref.read(sessionProvider.notifier).refreshAccessToken();
    if (newToken == null) return first; 

    await first.stream.drain(); 
    return _inner.send(_copy(request, bytes, newToken));
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

final apiClientProvider = Provider<http.Client>((ref) {
  final client = AuthClient(ref);
  ref.onDispose(client.close);
  return client;
});