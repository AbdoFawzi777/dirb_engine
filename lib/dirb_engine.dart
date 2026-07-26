import 'dart:async';
import 'package:http/http.dart' as http;

/// 📁 Dirb Engine v6.0 - Absolute Perfection
class DirbEngine {
  static final DirbEngine _instance = DirbEngine._internal();
  factory DirbEngine() => _instance;
  DirbEngine._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    _initialized = true;
  }

  /// 🚀 Absolute Directory Auditing Logic
  Future<DirbResult> scan(String target, {List<String>? wordlist}) async {
    final list = wordlist ?? ['admin', 'backup', 'config', 'test', 'logs'];
    final List<DiscoveryMatch> found = [];
    final client = http.Client();
    final startTime = DateTime.now();

    try {
      for (final path in list) {
        final url = target.endsWith('/') ? target + path : '$target/$path';
        try {
          final resp = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
          if (resp.statusCode != 404) {
            found.add(DiscoveryMatch(path: path, status: resp.statusCode, size: resp.body.length));
          }
        } catch (_) {}
      }
    } finally {
      client.close();
    }

    return DirbResult(
      target: target,
      matches: found,
      duration: DateTime.now().difference(startTime),
    );
  }
}

class DiscoveryMatch {
  final String path;
  final int status, size;
  DiscoveryMatch({required this.path, required this.status, required this.size});
}

class DirbResult {
  final String target;
  final List<DiscoveryMatch> matches;
  final Duration duration;
  DirbResult({required this.target, required this.matches, required this.duration});
}
