import 'package:firebase_core/firebase_core.dart';
import 'package:flame/flame.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pixel_adventure/app_module.dart';
import 'package:pixel_adventure/app_widget.dart';
import 'package:pixel_adventure/firebase_options.dart';

// Change to false to use live database instance.
const USE_DATABASE_EMULATOR = true;
// The port we've set the Firebase Database emulator to run on via the
// `firebase.json` configuration file.
const emulatorPort = 9000;
// Android device emulators consider localhost of the host machine as 10.0.2.2
// so let's use that if running on Android.
final emulatorHost =
    (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        ? '10.0.2.2'
        : 'localhost';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSpineFlutter();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  // PixelAdventure game = PixelAdventure();
  runApp(
    ModularApp(
      module: AppModule(),
      child: const AppWidget(),
    ),
  );
}
