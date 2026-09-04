import 'package:flutter/material.dart';
import 'screens/dual_clock_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DualClockApp());
}

class DualClockApp extends StatelessWidget {
  final Widget? home;

  const DualClockApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF3F51B5); // Deep Indigo Material 3 Seed

    return MaterialApp(
      title: 'Time Bridge',
      debugShowCheckedModeBanner: false,
      // Theme always follows the system configuration automatically
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FE),
        cardTheme: const CardThemeData(
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          scrolledUnderElevation: 0,
        ),
        timePickerTheme: TimePickerThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF131318),
        cardTheme: const CardThemeData(
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          scrolledUnderElevation: 0,
        ),
        timePickerTheme: TimePickerThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      home: home ?? const DualClockScreen(),
    );
  }
}
