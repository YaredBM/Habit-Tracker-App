import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/habits/presentation/habits_screen.dart';
import 'features/splash/splash_screen.dart';
import 'notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init (Android reads google-services.json automatically)
  await Firebase.initializeApp();

  // Notifications init (your existing service)
  await NotificationService.initialize();

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const EcoHabitApp());
}

class EcoHabitApp extends StatelessWidget {
  const EcoHabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoHabit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // ✅ AuthGate is inside HabitsScreen, so it should be the entry screen.
      home: const AuthGate(),

      // Optional named routes if you want them.
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/habits': (_) => const HabitsScreen(),
      },
    );
  }
}
