import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const TimeZoneConverterApp());
}

class TimeZoneConverterApp extends StatelessWidget {
  const TimeZoneConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Zone Converter',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3949AB),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        fontFamily: 'Arial',
      ),
      home: const SplashScreen(),
    );
  }
}