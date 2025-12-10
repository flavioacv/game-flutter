import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pixel_adventure/core/themes/theme_data.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  //late PixelAdventure game;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: Modular.routerConfig,
      theme: themeData,
      debugShowCheckedModeBanner: false,
    );
  }
}
