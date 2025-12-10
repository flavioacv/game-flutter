
import 'package:pixel_adventure/core/exception/app_exception.dart';

class LocalStorageException implements AppException {
  @override
  final String message;

  @override
  final StackTrace? stackTrace;

  const LocalStorageException({
    required this.message,
    required this.stackTrace,
  });
}
