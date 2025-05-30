import 'package:flutter/material.dart';
import 'package:myapp/models/medicine.dart';

import '../screens/home_scaffold.dart';
import '../screens/login_screen.dart';
import '../screens/medicine_detail_page.dart';
import '../screens/signup_screen.dart';
import '../screens/splash_screen.dart';

const String splashScreenRoute = '/';
const String loginScreenRoute = '/login';
const String signUpScreenRoute = '/signup';
const String homeScaffoldRoute = '/home';
const String inventeryDetailRoute = '/inventory/detail';

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
    case inventeryDetailRoute:
      // You might need to pass arguments to the detail screen
      return MaterialPageRoute(builder: (context) =>  MedicineDetailPage(medicine: settings.arguments as Medicine),);
    default:
      return MaterialPageRoute(builder: (context) => const HomeScaffold());
  }
}
