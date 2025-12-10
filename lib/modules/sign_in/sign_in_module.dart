import 'package:flutter_modular/flutter_modular.dart';
import 'package:pixel_adventure/core/core_module/core_module.dart';
import 'package:pixel_adventure/modules/sign_in/interactor/controllers/sign_in_controller.dart';
import 'package:pixel_adventure/modules/sign_in/ui/pages/sign_in_page.dart';

import 'data/services/sign_in_service.dart';
import 'data/services/sign_in_service_impl.dart';

class SignInModule extends Module {
  @override
  List<Module> get imports => [
        CoreModule(),
      ];

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) {
      return SignInPage(
        signInController: Modular.get<SignInController>(),
      );
    });
  }

  @override
  void binds(Injector i) {
    i.addLazySingleton<SignInService>(
      SignInServiceImpl.new,
    );
    i.addLazySingleton<SignInController>(
      SignInController.new,
    );
  }
}
