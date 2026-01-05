import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/habits/presentation/habits_screen.dart';
import 'features/splash/splash_screen.dart';
import 'notifications/notification_service.dart';

import 'l10n/app_localizations.dart';
import 'core/locale/locale_controller.dart';

//final localeController = LocaleController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp();

  // Notifications init
  await NotificationService.initialize();

  // Load saved locale (or null => system)
  await localeController.load();

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) {
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

          locale: localeController.locale,

          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
            Locale('de'),
            Locale('es'),
            Locale('tr'),
            Locale('ru'),
          ],

          // If you still get "const list" errors, remove the `const` keyword here.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],

          home: const AuthGate(),

          routes: {
            '/splash': (_) => const SplashScreen(),
            '/habits': (_) => const HabitsScreen(),
          },
        );
      },
    );
  }
}
