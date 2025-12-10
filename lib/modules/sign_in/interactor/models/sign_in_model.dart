import 'package:pixel_adventure/core/value_objects/email.dart';
import 'package:pixel_adventure/core/value_objects/password.dart';

class SignInModel {
  final Email email;
  final Password password;

  bool get isValid {
    return email.isValid && password.isValid;
  }

  const SignInModel({
    required this.email,
    required this.password,
  });

  factory SignInModel.empty() {
    return const SignInModel(
      email: Email(''),
      password: Password(''),
    );
  }

  SignInModel copyWith({
    Email? email,
    Password? password,
  }) {
    return SignInModel(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email.toString(),
      'password': password.toString(),
    };
  }
}
