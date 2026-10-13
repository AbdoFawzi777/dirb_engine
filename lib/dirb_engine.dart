import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 📁 Dirb Absolute Engine v20.0 - Full Linux-Parity Content Scanner
class DirbEngine {
  static final DirbEngine _instance = DirbEngine._internal();
  factory DirbEngine() => _instance;
  DirbEngine._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    _initialized = true;
  }

  static const List<String> commonWordlist = [
    'admin', 'administrator', 'api', 'app', 'assets', 'auth', 'backup', 'backups',
    'bin', 'cache', 'cgi-bin', 'config', 'core', 'css', 'data', 'database', 'db',
    'debug', 'dev', 'dist', 'doc', 'docs', 'download', 'downloads', 'error', 'etc',
    'events', 'export', 'files', 'fonts', 'forum', 'help', 'home', 'images', 'img',
    'import', 'include', 'includes', 'index', 'install', 'js', 'lib', 'libs', 'log',
    'login', 'logout', 'logs', 'mail', 'manage', 'manual', 'media', 'modules', 'my',
    'mysql', 'new', 'news', 'old', 'order', 'panel', 'passwords', 'php', 'phpmyadmin',
    'plugins', 'portal', 'private', 'prod', 'public', 'register', 'reports', 'robots.txt',
    'root', 'save', 'search', 'secret', 'server-status', 'services', 'settings', 'setup',
    'share', 'shop', 'sitemap.xml', 'source', 'src', 'staff', 'staging', 'stat',
    'static', 'stats', 'status', 'store', 'support', 'temp', 'test', 'tests', 'tmp',
    'tools', 'update', 'upload', 'uploads', 'user', 'users', 'util', 'utils', 'v1',
    'v2', 'vendor', 'view', 'web', 'webadmin', 'wp-admin', 'wp-content', 'wp-includes',
  ];

  Future<DirbResult> scan(
    String target, {
    List<String>? wordlist,
    int concurrency = 15,
    int timeoutSeconds = 5,
    List<int> filterCodes = const [404],
    Function(int progress, String status)? onProgress,
  }) async {
    var normalizedUrl = target.startsWith('http') ? target : 'http://$target';
    
    // Auto-fallback if https fails
    if (normalizedUrl.startsWith('https://')) {
      try {
        await http.head(Uri.parse(normalizedUrl)).timeout(const Duration(seconds: 3));
      } catch (_) {
        normalizedUrl = normalizedUrl.replaceFirst('https://', 'http://');
      }
    }

    final baseUrl = normalizedUrl.endsWith('/') ? normalizedUrl : '$normalizedUrl/';
    final words = wordlist ?? commonWordlist;
    final List<DiscoveryMatch> found = [];
    final client = http.Client();
    final startTime = DateTime.now();

    onProgress?.call(5, "Initializing DIRB content scan against $baseUrl (${words.length} paths)...");

    int completed = 0;
    try {
      for (int i = 0; i < words.length; i += concurrency) {
        final chunk = words.skip(i).take(concurrency).toList();
        final futures = chunk.map((path) async {
          final url = '$baseUrl$path';
          try {
            final resp = await client.get(
              Uri.parse(url),
              headers: {'User-Agent': 'DIRB/2.22 (RedOps Tactical Engine)'},
            ).timeout(Duration(seconds: timeoutSeconds));

            if (!filterCodes.contains(resp.statusCode)) {
              return DiscoveryMatch(
                path: '/$path',
                status: resp.statusCode,
                size: resp.body.length,
                contentType: resp.headers['content-type'] ?? 'unknown',
              );
            }
          } catch (_) {}
          return null;
        }).toList();

        final results = await Future.wait(futures);
        for (final r in results) {
          if (r != null) found.add(r);
        }

        completed += chunk.length;
        final pct = ((completed / words.length) * 90).toInt() + 5;
        onProgress?.call(pct, "DIRB scanning: $completed / ${words.length} paths");
      }
    } finally {
      client.close();
    }

    onProgress?.call(100, "DIRB scan completed. Discovered ${found.length} items.");

    return DirbResult(
      target: baseUrl,
      matches: found,
      duration: DateTime.now().difference(startTime),
      totalScanned: words.length,
    );
  }
}

class DiscoveryMatch {
  final String path;
  final int status;
  final int size;
  final String contentType;

  DiscoveryMatch({
    required this.path,
    required this.status,
    required this.size,
    this.contentType = 'unknown',
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'status': status,
    'size': size,
    'content_type': contentType,
  };
}

class DirbResult {
  final String target;
  final List<DiscoveryMatch> matches;
  final Duration duration;
  final int totalScanned;

  DirbResult({
    required this.target,
    required this.matches,
    required this.duration,
    this.totalScanned = 0,
  });

  List<String> get discoveredPaths => matches.map((m) => m.path).toList();

  Map<String, dynamic> toJson() => {
    'target': target,
    'found_count': matches.length,
    'matches': matches.map((m) => m.toJson()).toList(),
    'discovered_paths': discoveredPaths,
    'total_scanned': totalScanned,
    'duration_ms': duration.inMilliseconds,
  };
}
