import 'package:firebase_auth/firebase_auth.dart';
import 'package:pixel_adventure/core/constants/key_local_storage/key_local_storage.dart';
import 'package:pixel_adventure/core/exception/app_exception.dart';
import 'package:pixel_adventure/core/services/local_storage/local_storage_service.dart';
import 'package:pixel_adventure/modules/sign_in/interactor/models/sign_in_model.dart';
import 'package:pixel_adventure/modules/sign_in/interactor/state/sign_in_state.dart';

import 'sign_in_service.dart';

class SignInServiceImpl implements SignInService {
  final LocalStorageService _localStorageService;

  const SignInServiceImpl({
    required LocalStorageService localStorageService,
  }) : _localStorageService = localStorageService;

  @override
  Future<SignInState> doSignIn(SignInModel signInModel) async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: signInModel.email.toString(),
              password: signInModel.password.toString());

      await _localStorageService.setString(
        KeyLocalStorage.KEY_ID_USER,
        user.user?.uid ?? '',
      );

      print(user.user?.uid);

      return LoggedState(
        signInModel: signInModel,
        obscurePassword: false,
      );
    } on AppException catch (error) {
      return SignInFailure(
        signInModel: signInModel,
        appException: error,
        obscurePassword: false,
      );
    }
  }

  @override
  Future<SignInState> doSignInNick(String nick) async {
    try {
      await _localStorageService.setString(
        KeyLocalStorage.KEY_ID_USER,
        nick,
      );

      return LoggedState(
        signInModel: SignInModel.empty(),
        obscurePassword: false,
      );
    } on AppException catch (error) {
      return SignInFailure(
        signInModel: SignInModel.empty(),
        appException: error,
        obscurePassword: false,
      );
    }
  }
}
