import 'dart:io';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final File imageFile;
  final String diseaseName;
  final double confidence;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.diseaseName,
    required this.confidence,
  });

  String getAdvice(String disease) {
    if (disease.contains('CBSD')) {
      return "Évitez de replanter des boutures infectées.\nUtilisez des variétés résistantes.";
    } else if (disease.contains('CMD')) {
      return "CMD est causée par un virus.\nDétruisez les plantes infectées tôt.";
    } else if (disease.contains('CBB')) {
      return "Nettoyez bien les outils agricoles.\nFavorisez la rotation des cultures.";
    } else if (disease.contains('CGM')) {
      return "Vérifiez la présence d’acariens.\nUtilisez des traitements biologiques.";
    } else {
      return "Aucune maladie détectée.\nLa plante semble saine 🌱";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String advice = getAdvice(diseaseName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat de l’analyse'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                imageFile,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Maladie détectée :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              diseaseName,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Probabilité : ${(confidence * 100).toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      advice,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text("Retour à l'accueil"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
