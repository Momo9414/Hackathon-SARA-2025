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
      return "Vérifiez la présence d'acariens.\nUtilisez des traitements biologiques.";
    } else {
      return "Aucune maladie détectée.\nLa plante semble saine 🌱";
    }
  }

  Color _getDiseaseColor(String disease) {
    if (disease.toLowerCase().contains('healthy') || disease.toLowerCase().contains('saine')) {
      return Colors.green;
    }
    return Colors.red;
  }

  IconData _getDiseaseIcon(String disease) {
    if (disease.toLowerCase().contains('healthy') || disease.toLowerCase().contains('saine')) {
      return Icons.check_circle;
    }
    return Icons.warning;
  }

  @override
  Widget build(BuildContext context) {
    final String advice = getAdvice(diseaseName);
    final Color diseaseColor = _getDiseaseColor(diseaseName);
    final IconData diseaseIcon = _getDiseaseIcon(diseaseName);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Résultat de l\'analyse',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green[700]!, Colors.green[500]!],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Image avec shadow et border
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            imageFile,
                            height: 280,
                            width: 280,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            
            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Carte de résultat
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Icône et titre
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: diseaseColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  diseaseIcon,
                                  color: diseaseColor,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Diagnostic',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      diseaseName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: diseaseColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Barre de confiance
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Niveau de confiance',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${(confidence * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: diseaseColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: confidence,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(diseaseColor),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Carte de conseils
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Conseils de traitement',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              advice,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text(
                            "Nouvelle analyse",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.home, color: Colors.white),
                          label: const Text(
                            "Accueil",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}