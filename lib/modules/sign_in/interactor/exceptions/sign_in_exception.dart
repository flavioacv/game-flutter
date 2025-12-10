import '../../../../core/exception/app_exception.dart';

class SignInException implements AppException {
  @override
  final String message;

  @override
  final StackTrace? stackTrace;

  const SignInException({
    required this.message,
    required this.stackTrace,
  });
}
