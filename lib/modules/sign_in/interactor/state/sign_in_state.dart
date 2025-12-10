import 'package:pixel_adventure/core/exception/app_exception.dart';
import 'package:pixel_adventure/core/value_objects/email.dart';
import 'package:pixel_adventure/core/value_objects/password.dart';

import '../models/sign_in_model.dart';

sealed class SignInState {
  final SignInModel signInModel;
  final bool isLoading;
  final AppException? appException;
  final bool obscurePassword;

  const SignInState({
    required this.signInModel,
    required this.obscurePassword,
    this.isLoading = false,
    this.appException,
  });

  SignInState setFailure(AppException appException) {
    return SignInFailure(
      signInModel: signInModel,
      appException: appException,
      obscurePassword: obscurePassword,
    );
  }

  SignInState setLoading() {
    return SignInLoading(
      signInModel: signInModel,
      appException: appException,
      obscurePassword: obscurePassword,
    );
  }

  SignInState setLogged() {
    return LoggedState(
      signInModel: signInModel,
      obscurePassword: obscurePassword,
    );
  }

  SignInState setEmail(String? email) {
    return LoggedOutState(
      signInModel: signInModel.copyWith(
        email: Email(email.toString()),
      ),
      obscurePassword: obscurePassword,
    );
  }

  SignInState setPassword(Password password) {
    return LoggedOutState(
      signInModel: signInModel.copyWith(
        password: password,
      ),
      obscurePassword: obscurePassword,
    );
  }

  factory SignInState.loggedOut() {
    return LoggedOutState(
      signInModel: SignInModel.empty(),
      obscurePassword: true,
    );
  }

  SignInState toggleObscure() {
    return LoggedOutState(
      signInModel: signInModel,
      obscurePassword: !obscurePassword,
    );
  }
}

class LoggedOutState extends SignInState {
  const LoggedOutState({
    required super.signInModel,
    required super.obscurePassword,
  });
}

class LoggedState extends SignInState {
  const LoggedState({
    required super.signInModel,
    super.isLoading = false,
    required super.obscurePassword,
  });
}

class SignInFailure extends SignInState {
  const SignInFailure({
    required super.signInModel,
    required super.appException,
    super.isLoading = false,
    required super.obscurePassword,
  });
}

class SignInLoading extends SignInState {
  const SignInLoading({
    required super.signInModel,
    required super.appException,
    super.isLoading = true,
    required super.obscurePassword,
  });
}
