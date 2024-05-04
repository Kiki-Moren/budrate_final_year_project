class CustomException implements Exception {
  final String message;
  final int statusCode;

  CustomException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => message;
}
