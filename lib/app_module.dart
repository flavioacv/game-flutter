import 'package:flutter_modular/flutter_modular.dart';
import 'package:pixel_adventure/core/constants/routes/app_routes.dart';
import 'package:pixel_adventure/core/core_module/core_module.dart';
import 'package:pixel_adventure/core/services/local_storage/local_storage_service.dart';
import 'package:pixel_adventure/core/services/local_storage/local_storage_service_impl.dart';
import 'package:pixel_adventure/modules/game/game.dart';
import 'package:pixel_adventure/modules/menu_select/menu_select_page.dart';
import 'package:pixel_adventure/modules/room_list/room_list_module.dart';
import 'package:pixel_adventure/modules/sign_in/sign_in_module.dart';

class AppModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i.add<LocalStorageService>(LocalStorageServiceImpl.new);
  }

  @override
  List<Module> get imports => [
        CoreModule(),
      ];

  @override
  void routes(RouteManager r) {
    r.module(
      Modular.initialRoute,
      module: SignInModule(),
    );

    r.module(
      AppRoutes.roomListRoute,
      module: RoomListModule(),
    );

    r.child(
      AppRoutes.gamePageRoute,
      child: (context) => GamePage(
        characterSelected: r.args.data['selected'],
        roomId: r.args.data['roomId'],
        localStorageService: Modular.get<LocalStorageService>(),
      ),
    );

    r.child(
      '/menu',
      child: (context) => CharacterSelectionScreen(),
    );
  }
}
