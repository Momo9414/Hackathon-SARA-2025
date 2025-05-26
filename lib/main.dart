import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ManiocAIApp());
}

class ManiocAIApp extends StatelessWidget {
  const ManiocAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhytoScan',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
