import 'package:flutter/material.dart';

import '../screens/home_scaffold.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/splash_screen.dart';

const String splashScreenRoute = '/';
const String loginScreenRoute = '/login';
const String signUpScreenRoute = '/signup';
const String homeScaffoldRoute = '/home';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case splashScreenRoute:
      return MaterialPageRoute(builder: (context) => const SplashScreen());
    case loginScreenRoute:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case signUpScreenRoute:
      return MaterialPageRoute(builder: (context) => const SignUpScreen());
    case homeScaffoldRoute:
      return MaterialPageRoute(builder: (context) => const HomeScaffold());
    default:
      return MaterialPageRoute(builder: (context) => const HomeScaffold());
  }
}
