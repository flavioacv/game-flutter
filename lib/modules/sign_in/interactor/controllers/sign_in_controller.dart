import 'package:flutter/material.dart';
import 'package:pixel_adventure/core/constants/key_local_storage/key_local_storage.dart';
import 'package:pixel_adventure/core/mixins/emit_mixin.dart';
import 'package:pixel_adventure/core/services/local_storage/local_storage_service.dart';
import 'package:pixel_adventure/core/value_objects/password.dart';
import 'package:pixel_adventure/modules/sign_in/data/services/sign_in_service.dart';
import 'package:pixel_adventure/modules/sign_in/interactor/state/sign_in_state.dart';

class SignInController extends ValueNotifier<SignInState> with EmitMixin {
  final SignInService signInService;
  final LocalStorageService localStorageService;

  SignInController({
    required this.signInService,
    required this.localStorageService,
  }) : super(SignInState.loggedOut());

  Future<void> doSignIn() async {
    emit(value.setLoading());

    final state = await signInService.doSignIn(value.signInModel);

    emit(state);
  }

  Future<void> doSignInNick({required String nick}) async {
    emit(value.setLoading());

    final state = await signInService.doSignInNick(nick);

    emit(state);
  }

  Future<bool> verifyNick() async {
    final nick =
        await localStorageService.getString(KeyLocalStorage.KEY_ID_USER);
    return nick != null && nick.isNotEmpty;
  }

  void setEmail(String? email) {
    emit(value.setEmail(email));
  }

  void setPassword(Password password) {
    emit(value.setPassword(password));
  }

  void toggleObscure() {
    emit(value.toggleObscure());
  }
}
