
import 'package:flutter_modular/flutter_modular.dart';

import '../services/local_storage/local_storage_service.dart';
import '../services/local_storage/local_storage_service_impl.dart';

class CoreModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i.add<LocalStorageService>(LocalStorageServiceImpl.new);
  }
}
