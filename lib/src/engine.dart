import 'dart:async';
import 'package:http/http.dart' as http;
import 'models.dart';

class DirbEngine {
  static final DirbEngine _instance = DirbEngine._internal();
  factory DirbEngine() => _instance;
  DirbEngine._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  static const List<String> _defaultWordlist = [
    'admin', 'administrator', 'login', 'dashboard', 'panel', 'api',
    'backup', 'uploads', 'files', 'images', 'includes', 'src',
    'config', 'settings', 'test', 'dev', 'temp', 'tmp',
    'cgi-bin', 'scripts', 'js', 'css', 'assets', 'static',
    'private', 'public', 'protected', 'secure', 'hidden',
    'wp-content', 'wp-admin', 'wp-includes', 'phpmyadmin',
    '.git', '.svn', '.htaccess', '.htpasswd', '.env',
    'robots.txt', 'sitemap.xml', 'humans.txt',
    'phpinfo.php', 'info.php', 'server-status',
    'console', 'manager', 'portal', 'forum', 'blog',
    'api', 'v1', 'v2', 'swagger', 'docs', 'graphql',
    'user', 'users', 'account', 'accounts', 'members',
    'download', 'downloads', 'upload', 'media',
    'cache', 'log', 'logs', 'error', 'errors',
    'db', 'database', 'sql', 'data',
    'bin', 'lib', 'inc', 'core', 'base',
  ];

  Future<List<DirbResult>> scan(String url, {
    List<String>? wordlist,
    bool recursive = false,
    int maxDepth = 2,
    int concurrency = 10,
  }) async {
    final normalizedUrl = url.startsWith('http') ? url : 'http://$url';
    final base = normalizedUrl.endsWith('/') ? normalizedUrl : '$normalizedUrl/';
    final words = wordlist ?? _defaultWordlist;
    final results = <DirbResult>[];
    final visited = <String>{};

    await _scanLevel(base, words, results, visited, concurrency);

    if (recursive && maxDepth > 1) {
      final directories = results.where((r) => r.isDirectory).toList();
      for (final dir in directories.take(5)) { // Limit recursion
        final subUrl = '$base${dir.path}/';
        if (!visited.contains(subUrl)) {
          await _scanLevel(subUrl, words, results, visited, concurrency);
        }
      }
    }

    return results;
  }

  Future<void> _scanLevel(
    String baseUrl,
    List<String> words,
    List<DirbResult> results,
    Set<String> visited,
    int concurrency,
  ) async {
    visited.add(baseUrl);
    for (int i = 0; i < words.length; i += concurrency) {
      final chunk = words.skip(i).take(concurrency).toList();
      final futures = chunk.map((w) => _probe(baseUrl, w)).toList();
      final chunkResults = await Future.wait(futures);
      for (final r in chunkResults) {
        if (r != null) results.add(r);
      }
    }
  }

  Future<DirbResult?> _probe(String base, String word) async {
    try {
      final url = '$base$word';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'DirBuster-1.0-RC1 (dirb/2.22)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 404) return null;

      final contentType = response.headers['content-type'] ?? '';
      final isDirectory = response.statusCode == 301 || response.statusCode == 302 ||
          contentType.contains('text/html');

      return DirbResult(
        path: word,
        statusCode: response.statusCode,
        contentType: contentType,
        contentLength: response.contentLength,
        isDirectory: isDirectory,
      );
    } catch (_) {
      return null;
    }
  }
}
