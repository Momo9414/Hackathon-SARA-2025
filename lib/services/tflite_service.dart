import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

// OPTION 1: Avec tflite_flutter (recommandé)
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isModelLoaded = false;

  // MÉTHODE 1: Chargement avec tflite_flutter
  Future<void> loadModelWithTfliteFlutter() async {
    try {
      print('🔄 Chargement du modèle avec tflite_flutter...');
      
      // Charger le modèle depuis les assets
      _interpreter = await Interpreter.fromAsset('assets/cassava_model.tflite');
      print('✅ Modèle chargé avec succès');
      
      // Charger les labels
      await _loadLabels();
      
      _isModelLoaded = true;
      print('✅ Service TFLite initialisé avec succès');
      
    } catch (e) {
      print('❌ Erreur lors du chargement avec tflite_flutter: $e');
      throw Exception('Impossible de charger le modèle: $e');
    }
  }

  // MÉTHODE 2: Chargement manuel des bytes
  Future<void> loadModelManually() async {
    try {
      print('🔄 Chargement manuel du modèle...');
      
      // Charger les bytes du modèle
      final ByteData modelData = await rootBundle.load('assets/cassava_model.tflite');
      final Uint8List modelBytes = modelData.buffer.asUint8List();
      
      // Créer l'interpréteur avec les bytes
      _interpreter = Interpreter.fromBuffer(modelBytes);
      print('✅ Modèle chargé manuellement');
      
      // Charger les labels
      await _loadLabels();
      
      _isModelLoaded = true;
      print('✅ Service TFLite initialisé manuellement');
      
    } catch (e) {
      print('❌ Erreur lors du chargement manuel: $e');
      throw Exception('Impossible de charger le modèle manuellement: $e');
    }
  }

  // MÉTHODE 3: Avec l'ancienne bibliothèque tflite
  Future<void> loadModelWithOldTflite() async {
    try {
      print('🔄 Chargement avec l\'ancienne bibliothèque tflite...');
      
      // Uncomment si vous utilisez tflite: ^1.1.2
      /*
      String? res = await Tflite.loadModel(
        model: "assets/models/model.tflite",
        labels: "assets/models/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );
      
      if (res != null) {
        print('✅ Modèle chargé avec l\'ancienne bibliothèque');
        _isModelLoaded = true;
      } else {
        throw Exception('Échec du chargement du modèle');
      }
      */
      
    } catch (e) {
      print('❌ Erreur avec l\'ancienne bibliothèque: $e');
      throw Exception('Impossible de charger avec l\'ancienne méthode: $e');
    }
  }

  // Charger les labels
  Future<void> _loadLabels() async {
    try {
      final String labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n').where((label) => label.isNotEmpty).toList();
      print('✅ ${_labels!.length} labels chargés');
    } catch (e) {
      print('⚠️ Impossible de charger les labels: $e');
      // Créer des labels par défaut si nécessaire
      _labels = ['healthy', 'diseased'];
    }
  }

  // MÉTHODE PRINCIPALE DE CHARGEMENT (essaie plusieurs options)
  Future<void> loadModel() async {
    print('🚀 Début du chargement du modèle...');
    
    // Vérifier d'abord si les fichiers existent
    bool modelExists = await _checkAssetExists('assets/cassava_model.tflite');
    bool labelsExist = await _checkAssetExists('assets/labels.txt');
    
    print('📁 Modèle existe: $modelExists');
    print('📁 Labels existent: $labelsExist');
    
    if (!modelExists) {
      throw Exception('Le fichier model.tflite n\'existe pas dans assets/');
    }

    // Essayer différentes méthodes de chargement
    List<Future<void> Function()> loadingMethods = [
      loadModelWithTfliteFlutter,
      loadModelManually,
    ];

    Exception? lastException;
    
    for (int i = 0; i < loadingMethods.length; i++) {
      try {
        print('🔄 Tentative ${i + 1}/${loadingMethods.length}...');
        await loadingMethods[i]();
        print('✅ Modèle chargé avec succès (méthode ${i + 1})');
        return; // Succès, on sort
      } catch (e) {
        print('❌ Méthode ${i + 1} échouée: $e');
        lastException = e is Exception ? e : Exception(e.toString());
      }
    }
    
    // Si toutes les méthodes ont échoué
    throw lastException ?? Exception('Toutes les méthodes de chargement ont échoué');
  }

  // Vérifier si un asset existe
  Future<bool> _checkAssetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Classification d'image
  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      throw Exception('Le modèle n\'est pas chargé');
    }

    try {
      // Lire et préprocesser l'image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Impossible de décoder l\'image');
      }

      // Redimensionner l'image (ajustez selon votre modèle)
      final resized = img.copyResize(image, width: 224, height: 224);
      
      // Convertir en format d'entrée pour le modèle
      final input = _imageToByteListFloat32(resized, 224, 224);
      
      // Préparer la sortie
      final output = List.filled(1 * (_labels?.length ?? 2), 0.0).reshape([1, _labels?.length ?? 2]);
      
      // Faire la prédiction
      _interpreter!.run(input, output);
      
      // Traiter les résultats
      final predictions = output[0] as List<double>;
      final maxIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
      final confidence = predictions[maxIndex] * 100;
      
      return {
        'diseaseName': _labels?[maxIndex] ?? 'Unknown',
        'confidence': confidence,
        'allPredictions': predictions,
        'labels': _labels,
      };
      
    } catch (e) {
      print('❌ Erreur lors de la classification: $e');
      throw Exception('Erreur lors de la classification: $e');
    }
  }

  // Convertir l'image en format d'entrée
  List<List<List<List<double>>>> _imageToByteListFloat32(img.Image image, int width, int height) {
    var convertedBytes = List.generate(
      1,
      (i) => List.generate(
        height,
        (j) => List.generate(
          width,
          (k) => List.generate(3, (l) => 0.0),
        ),
      ),
    );

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        final pixel = image.getPixel(j, i);
        convertedBytes[0][i][j][0] = (pixel.r / 255.0); // Rouge
        convertedBytes[0][i][j][1] = (pixel.g / 255.0); // Vert
        convertedBytes[0][i][j][2] = (pixel.b / 255.0); // Bleu
      }
    }

    return convertedBytes;
  }

  bool get isModelLoaded => _isModelLoaded;
  List<String>? get labels => _labels;

  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
    print('🧹 Service TFLite nettoyé');
  }
}

// 4. CLASSE DE VALIDATION AMÉLIORÉE
class ModelValidator {
  static Future<bool> validateModel() async {
    try {
      print('🔍 Validation du modèle...');
      
      // Vérifier l'existence du fichier
      final modelData = await rootBundle.load('assets/cassava_model.tflite');
      print('✅ Fichier modèle trouvé (${modelData.lengthInBytes} bytes)');
      
      // Vérifier la signature TFLite (les premiers bytes)
      final bytes = modelData.buffer.asUint8List();
      if (bytes.length < 8) {
        print('❌ Fichier trop petit pour être un modèle TFLite valide');
        return false;
      }
      
      // Vérifier la signature TFLite magic number
      const tfliteMagic = [0x54, 0x46, 0x4C, 0x33]; // "TFL3" en hexadécimal
      bool hasValidSignature = true;
      for (int i = 0; i < 4; i++) {
        if (bytes[i] != tfliteMagic[i]) {
          hasValidSignature = false;
          break;
        }
      }
      
      if (!hasValidSignature) {
        print('⚠️ Signature TFLite invalide, mais le fichier pourrait quand même fonctionner');
      } else {
        print('✅ Signature TFLite valide');
      }
      
      return true;
    } catch (e) {
      print('❌ Erreur lors de la validation: $e');
      return false;
    }
  }

  static Future<bool> validateLabels() async {
    try {
      print('🔍 Validation des labels...');
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      final labels = labelsData.split('\n').where((label) => label.trim().isNotEmpty).toList();
      
      print('✅ ${labels.length} labels trouvés:');
      for (int i = 0; i < labels.length && i < 5; i++) {
        print('  - ${labels[i]}');
      }
      if (labels.length > 5) {
        print('  - ... et ${labels.length - 5} autres');
      }
      
      return labels.isNotEmpty;
    } catch (e) {
      print('❌ Erreur lors de la validation des labels: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> fullDiagnostic() async {
    print('🏥 DIAGNOSTIC COMPLET DU MODÈLE');
    print('================================');
    
    final results = <String, dynamic>{};
    
    // 1. Vérifier les assets
    results['modelExists'] = await validateModel();
    results['labelsExist'] = await validateLabels();
    
    // 2. Vérifier les dépendances
    results['dependencies'] = {
      'tflite_flutter': 'À vérifier dans pubspec.yaml',
      'image': 'À vérifier dans pubspec.yaml',
    };
    
    // 3. Tester le chargement
    try {
      final service = TFLiteService();
      await service.loadModel();
      results['loadingTest'] = 'SUCCESS';
      service.dispose();
    } catch (e) {
      results['loadingTest'] = 'FAILED: $e';
    }
    
    print('📊 Résultats du diagnostic:');
    results.forEach((key, value) {
      print('  $key: $value');
    });
    
    return results;
  }
}