import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/pages/add/add_view.dart';

class AppRoutes {
  static const String splash = '/Splash';
  static const String onBoarding = '/onBoarding';
  static const String share = '/share';

  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return CustomPageRoute(
            settings: RouteSettings(name: settings.name),
            builder: (_) => const AddPage());



      default:
        return CustomPageRoute(
            settings: RouteSettings(name: settings.name),
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text("no_route_defined_for_settings_name_".tr +
                          settings.name!)),
                ));
    }
  }
}

class CustomPageRoute extends MaterialPageRoute {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 500);

  CustomPageRoute({settings, builder})
      : super(builder: builder, settings: settings);
}
