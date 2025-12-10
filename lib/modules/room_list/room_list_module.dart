import 'package:flutter_modular/flutter_modular.dart';
import 'package:pixel_adventure/core/services/local_storage/local_storage_service.dart';
import 'package:pixel_adventure/core/services/multiplayer/multiplayer_service.dart';
import 'package:pixel_adventure/modules/room_list/interactor/controllers/room_list_controller.dart';
import 'package:pixel_adventure/modules/room_list/ui/pages/room_list_page.dart';

class RoomListModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton(MultiplayerService.new);
    i.addSingleton<RoomListController>(
      () => RoomListController(
        i.get<MultiplayerService>(),
        Modular.get<LocalStorageService>(),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => RoomListPage(
        characterSelected: r.args.data['selected'] as String,
      ),
    );
  }
}
