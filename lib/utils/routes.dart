import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../models/medicine_reminder.dart';
import '../screens/add_medicine_reminder_screen.dart';
import '../screens/edit_medicine_reminder_screen.dart';
import '../screens/edit_medicine_screen.dart';
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
  static const String editMedicine = '/inventory/edit';
  // New Routes for Reminders
  static const String addReminder = '/reminders/add';
  static const String editReminder = '/reminders/edit';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signUp: (context) => const SignUpScreen(),
    home: (context) => HomeScreen(),
    inventoryDetail: (context) => const InventoryDetailScreen(), // Add route mapping
    editMedicine: (context) => EditMedicineScreen(medicine: ModalRoute.of(context)!.settings.arguments as Medicine),
    // Add Reminder Routes
    addReminder: (context) => const AddMedicineReminderScreen(),
    editReminder: (context) => EditMedicineReminderScreen(reminder: ModalRoute.of(context)!.settings.arguments as MedicineReminder),
  };
}
