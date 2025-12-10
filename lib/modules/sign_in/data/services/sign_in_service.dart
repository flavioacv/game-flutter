import '../../interactor/models/sign_in_model.dart';
import '../../interactor/state/sign_in_state.dart';

abstract interface class SignInService {
  Future<SignInState> doSignIn(SignInModel signInModel);
  Future<SignInState> doSignInNick(String nick);
}
