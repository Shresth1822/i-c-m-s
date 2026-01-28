import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/home_screen.dart';

class AppRoutes {
  static const String home = '/';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
  };
}
