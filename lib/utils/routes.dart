import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/inventory_detail_screen.dart'; // Import InventoryDetailScreen
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/splash_screen.dart';


class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String home = '/home';
  static const String inventoryDetail = '/inventory/detail'; // Add new route

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signUp: (context) => const SignUpScreen(),
    home: (context) => HomeScreen(),
    inventoryDetail: (context) => const InventoryDetailScreen(), // Add route mapping
  };
}