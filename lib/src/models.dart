class DirbResult {
  final String path;
  final int statusCode;
  final String? contentType;
  final int? contentLength;
  final bool isDirectory;

  const DirbResult({
    required this.path,
    required this.statusCode,
    this.contentType,
    this.contentLength,
    this.isDirectory = false,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'statusCode': statusCode,
    'contentType': contentType,
    'contentLength': contentLength,
    'isDirectory': isDirectory,
  };
}
