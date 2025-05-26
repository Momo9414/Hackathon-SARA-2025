import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manioc_ai/main.dart';
import 'package:manioc_ai/services/tflite_service.dart';
import 'dart:io';

// Créer une classe mock pour TFLiteService
class MockTFLiteService implements TFLiteService {
  @override
  Future<void> loadModel() async {
    // Simulation du chargement du modèle
    return;
  }

  @override
  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    // Simulation de la classification avec un File en entrée
    return {
      'diseaseName': 'Test Disease',
      'confidence': 85.0,
    };
  }

  @override
  void dispose() {
    // Simulation de la méthode dispose
  }
}

void main() {
  testWidgets('App launches and loads home screen', (WidgetTester tester) async {
    // Créer une instance mock de TFLiteService
    final mockTfliteService = MockTFLiteService();
    
    // Simuler l'initialisation asynchrone comme dans main.dart
    await mockTfliteService.loadModel();
    
    // Build our app and trigger a frame
    await tester.pumpWidget(ManiocAIApp(tfliteService: mockTfliteService));
    
    // Wait for any async operations to complete
    await tester.pumpAndSettle();
    
    // Vérifier que l'application se construit sans crash
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Vérifier la présence d'éléments spécifiques dans HomeScreen
    expect(find.text('Analyse PhytoScan'), findsOneWidget);
    expect(find.text('Commencer une analyse'), findsOneWidget);
  });

  testWidgets('MockTFLiteService classifyImage works', (WidgetTester tester) async {
    final mockTfliteService = MockTFLiteService();
    
    // Créer un fichier factice pour le test (pas besoin qu'il existe réellement)
    final testFile = File('test_image.jpg');
    
    // Tester la méthode classifyImage
    final result = await mockTfliteService.classifyImage(testFile);
    
    expect(result['diseaseName'], equals('Test Disease'));
    expect(result['confidence'], equals(85.0));
  });
}