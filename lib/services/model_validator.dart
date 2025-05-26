import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelValidator {
  static Future<Map<String, dynamic>> validateModel() async {
    Map<String, dynamic> result = {
      'isValid': false,
      'error': null,
      'modelInfo': {},
    };

    try {
      // Vérifier si le fichier existe
      try {
        final modelData = await rootBundle.load('assets/cassava_model.tflite');
        result['modelInfo']['fileSize'] = modelData.lengthInBytes;
        print('Fichier modèle trouvé, taille: ${modelData.lengthInBytes} bytes');
      } catch (e) {
        result['error'] = 'Fichier modèle introuvable: $e';
        return result;
      }

      // Essayer de créer l'interpréteur
      Interpreter interpreter;
      try {
        interpreter = await Interpreter.fromAsset('assets/cassava_model.tflite');
      } catch (e) {
        result['error'] = 'Impossible de créer l\'interpréteur: $e';
        return result;
      }

      // Obtenir les informations du modèle
      var inputTensors = interpreter.getInputTensors();
      var outputTensors = interpreter.getOutputTensors();

      result['modelInfo']['inputShape'] = inputTensors.first.shape;
      result['modelInfo']['outputShape'] = outputTensors.first.shape;
      result['modelInfo']['inputType'] = inputTensors.first.type.toString();
      result['modelInfo']['outputType'] = outputTensors.first.type.toString();

      print('Informations du modèle:');
      print('  Input shape: ${inputTensors.first.shape}');
      print('  Output shape: ${outputTensors.first.shape}');
      print('  Input type: ${inputTensors.first.type}');
      print('  Output type: ${outputTensors.first.type}');

      // Tester une inférence simple
      try {
        var inputShape = inputTensors.first.shape;
        var outputShape = outputTensors.first.shape;
        
        // Créer des données d'entrée factices
        var input = List.generate(
          inputShape[0], // batch_size
          (b) => List.generate(
            inputShape[1], // height
            (h) => List.generate(
              inputShape[2], // width
              (w) => List.generate(
                inputShape[3], // channels
                (c) => 0.5, // valeur factice
              ),
            ),
          ),
        );

        var output = List.generate(
          outputShape[0],
          (i) => List.filled(outputShape[1], 0.0),
        );

        interpreter.run(input, output);
        result['modelInfo']['testInference'] = 'Succès';
        print('Test d\'inférence réussi');
      } catch (e) {
        result['modelInfo']['testInference'] = 'Échec: $e';
        print('Test d\'inférence échoué: $e');
      }

      interpreter.close();
      result['isValid'] = true;
    } catch (e) {
      result['error'] = 'Erreur de validation: $e';
    }

    return result;
  }

  static Future<bool> validateLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      var labels = labelsData.split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();
      
      print('Labels trouvés: ${labels.length}');
      for (int i = 0; i < labels.length; i++) {
        print('  $i: ${labels[i]}');
      }
      
      return labels.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la validation des labels: $e');
      return false;
    }
  }
}