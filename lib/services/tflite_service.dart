import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  late Interpreter _interpreter;
  late List<String> _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('cassava_model.tflite');
      _labels = await _loadLabels();
      print('Modèle TFLite chargé avec succès');
    } catch (e) {
      print('Erreur lors du chargement du modèle : $e');
      throw Exception('Impossible de charger le modèle TFLite');
    }
  }

  Future<List<String>> _loadLabels() async {
    final labelsData = await rootBundle.loadString('assets/labels.txt');
    return labelsData.split('\n').where((label) => label.isNotEmpty).toList();
  }

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    try {
      // Préparer l'image pour le modèle
      var input = await _preprocessImage(imageFile);
      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);
      _interpreter.run(input, output);

      // Traiter les résultats
      var maxIndex = 0;
      var maxScore = 0.0;
      for (var i = 0; i < output[0].length; i++) {
        if (output[0][i] > maxScore) {
          maxScore = output[0][i];
          maxIndex = i;
        }
      }
      return {
        'diseaseName': _labels[maxIndex],
        'confidence': maxScore * 100, // Convertir en pourcentage
      };
    } catch (e) {
      print('Erreur lors de la classification : $e');
      return {
        'diseaseName': 'Erreur',
        'confidence': 0.0,
      };
    }
  }

  Future<List<Object>> _preprocessImage(File imageFile) async {
    // Charger l'image
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Impossible de décoder l\'image');
    }

    // Redimensionner l'image (ex. 224x224, à ajuster selon votre modèle)
    image = img.copyResize(image, width: 224, height: 224);

    // Convertir en tenseur (normalisation entre 0 et 1)
    var input = Float32List(1 * 224 * 224 * 3); // [1, 224, 224, 3]
    var pixelIndex = 0;
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        var pixel = image.getPixel(x, y);
        // Accéder aux canaux RGB directement via les propriétés r, g, b
        input[pixelIndex++] = pixel.r / 255.0; // R
        input[pixelIndex++] = pixel.g / 255.0; // G
        input[pixelIndex++] = pixel.b / 255.0; // B
      }
    }

    // Retourner la liste comme un tenseur 4D
    return [input];
  }

  void dispose() {
    _interpreter.close();
  }
}