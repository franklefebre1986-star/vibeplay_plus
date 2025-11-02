import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const VibePlayApp());
}

class VibePlayApp extends StatelessWidget {
  const VibePlayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibePlay+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const SplashScreen(),
    );
  }
}
