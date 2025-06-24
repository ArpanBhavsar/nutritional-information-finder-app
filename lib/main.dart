import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/utils/routes.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'blocs/auth/auth_bloc.dart';
import 'blocs/medicine_inventory/medicine_inventory_bloc.dart';
import 'blocs/medicine_reminder/medicine_reminder_bloc.dart';
import 'blocs/medicine_scanner/medicine_scanner_bloc.dart';
import 'data/database_service.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://tshbjozreopvamxfevjz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRzaGJqb3pyZW9wdmFteGZldmp6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4MDkyMzYsImV4cCI6MjA2MjM4NTIzNn0.boZ1BJ3zlVBEVCBWMGJnMy6J3H7Tgm0GluN3UM9fUWM',
  );

  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().init();
  // Initialize timezone database
  tz.initializeTimeZones();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => MedicineScannerBloc(ollama: OllamaClient(), supabase: Supabase.instance.client)),
        BlocProvider(create: (context) => MedicineInventoryBloc()),
        BlocProvider(create: (context) => MedicineReminderBloc(databaseService: DatabaseService(), notificationService: NotificationService())..add(LoadReminders())),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Tracker',
      initialRoute: AppRoutes.splash,
      // Set initial route
      routes: AppRoutes.routes,
      // Provide the routes map
      theme: AppTheme.lightTheme,
      // Use the light theme
      darkTheme: AppTheme.darkTheme,
      // Use the dark theme,
      // home: const SplashScreen(),
    );
  }
}
