/// 📁 Dirb Engine - Basic directory scanning for Flutter
library dirb_engine;

import 'package:http/http.dart' as http;

class DirbEngine {
  static final DirbEngine _instance = DirbEngine._internal();
  factory DirbEngine() => _instance;
  DirbEngine._internal();

  bool _initialized = false;

  static const List<String> _defaultWordlist = [
    'admin', 'login', 'config', 'api', 'upload', 'test', 'dev'
  ];

  /// 🚀 تهيئة المحرك
  Future<void> initialize() async {
    _initialized = true;
  }

  /// 🔍 فحص الدلائل الأساسي
  Future<List<DirbResult>> scan(String target, {List<String>? wordlist}) async {
    final wordlistToUse = wordlist ?? _defaultWordlist;
    final results = <DirbResult>[];
    for (final word in wordlistToUse) {
      try {
        final url = '$target/$word';
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
        if (response.statusCode != 404) {
          results.add(DirbResult(
            path: word,
            statusCode: response.statusCode,
            size: response.body.length,
          ));
        }
      } catch (_) {}
    }
    return results;
  }

  /// 📊 حالة المحرك
  bool get isInitialized => _initialized;
}

class DirbResult {
  final String path;
  final int statusCode;
  final int size;
  DirbResult({required this.path, required this.statusCode, required this.size});
}
