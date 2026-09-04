import 'package:flutter/material.dart';
import 'views/main_lab_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZenerRegulatorLabApp());
}

class ZenerRegulatorLabApp extends StatefulWidget {
  const ZenerRegulatorLabApp({super.key});

  @override
  State<ZenerRegulatorLabApp> createState() => _ZenerRegulatorLabAppState();
}

class _ZenerRegulatorLabAppState extends State<ZenerRegulatorLabApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zener Diode Voltage Regulator Virtual Lab',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

      // Light Theme (Clean Academic Lab)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          brightness: Brightness.light,
          surface: const Color(0xFFF8FAFC),
          background: const Color(0xFFF1F5F9),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: -0.2,
          ),
          titleSmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Color(0xFF334155),
          ),
          bodySmall: TextStyle(
            fontSize: 11.5,
            height: 1.4,
            color: Color(0xFF64748B),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0284C7),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
        dividerColor: const Color(0xFFE2E8F0),
      ),

      // Dark Theme (Default for STEM Engineering Workbench)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          brightness: Brightness.dark,
          surface: const Color(0xFF131D2F),
          background: const Color(0xFF0A0F1D),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0F1D),
        cardTheme: CardThemeData(
          color: const Color(0xFF131D2F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF22324D), width: 1.2),
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFFF8FAFC),
            letterSpacing: -0.4,
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF1F5F9),
            letterSpacing: -0.2,
          ),
          titleSmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Color(0xFFCBD5E1),
          ),
          bodySmall: TextStyle(
            fontSize: 11.5,
            height: 1.4,
            color: Color(0xFF94A3B8),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0E1726),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
        dividerColor: const Color(0xFF1E293B),
      ),

      home: MainLabScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}
