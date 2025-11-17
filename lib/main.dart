import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const VoiceReaderApp());
}

class VoiceReaderApp extends StatelessWidget {
  const VoiceReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sesli Yanıt Programı',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE8F5E9), // Açık yeşil arka plan
      ),
      home: const HomePage(),
    );
  }
}
