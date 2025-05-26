import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'result_screen.dart';

class LoadingScreen extends StatefulWidget {
  final File imageFile;

  const LoadingScreen({super.key, required this.imageFile});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _messageIndex = 0;

  final List<String> _messages = [
    "Analyse des nervures de la feuille...",
    "Connexion au cerveau des plantes...",
    "Détection des motifs viraux...",
    "Lecture du langage des cassavas...",
    "Presque prêt... patience verte 🍃"
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(_controller);

    // changer de message toutes les 2 secondes
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });

    // simulation du traitement (après 6 secondes, aller au résultat)
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imageFile: widget.imageFile,
            diseaseName: "CBSD - Cassava Brown Streak Disease",
            confidence: 0.891, // à remplacer plus tard par le vrai résultat du modèle
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Image.asset(
                'assets/logo.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.green),
            const SizedBox(height: 30),
            Text(
              _messages[_messageIndex],
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
