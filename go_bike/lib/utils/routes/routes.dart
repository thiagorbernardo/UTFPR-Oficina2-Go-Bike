import 'package:flutter/material.dart';

import 'package:go_bike/ui/screens/home_screen.dart';
import 'package:go_bike/ui/screens/profile_screen/profile_screen.dart';

class Routes {
  Routes._();

  static const String home = '/home';
  static const String profile = '/profile';

  static final routes = <String, WidgetBuilder>{
    // Home
    home: (BuildContext context) => const HomeScreen(),
    profile: (BuildContext context) => const ProfileScreen(),
  };
}
