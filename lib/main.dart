import 'package:flutter/material.dart';
import 'package:manioc_ai/routes/route_pages.dart';
import 'package:manioc_ai/routes/routes.dart';
import 'package:manioc_ai/screens/home_screen.dart';
import 'package:manioc_ai/services/tflite_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LoadingApp());
}

class LoadingApp extends StatefulWidget {
  const LoadingApp({super.key});

  @override
  _LoadingAppState createState() => _LoadingAppState();
}

class _LoadingAppState extends State<LoadingApp> {
  late TFLiteService tfliteService;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // Add this to your _initializeApp method in main.dart
Future<void> _initializeApp() async {
  // Validate model first
  var validation = await ModelValidator.validateModel();
  print('Validation du modèle: $validation');
  
  var labelsValid = await ModelValidator.validateLabels();
  print('Labels valides: $labelsValid');
  
  tfliteService = TFLiteService();
  
  try {
    await tfliteService.loadModel();
    print('Modèle chargé avec succès');
  } catch (e) {
    print('Erreur lors de l\'initialisation: $e');
    setState(() {
      _error = 'Erreur lors du chargement du modèle :\n$e';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.green.shade50,
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                SizedBox(height: 16),
                Text(
                  'Chargement du modèle...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red.shade50,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur d\'initialisation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _initializeApp();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ManiocAIApp(tfliteService: tfliteService);
  }
}

class ManiocAIApp extends StatelessWidget {
  final TFLiteService tfliteService;

  const ManiocAIApp({super.key, required this.tfliteService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhytoScan',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: Routes.home,
      onGenerateRoute: (settings) => RoutePageList.generateRoute(settings, tfliteService),
      home: HomeScreen(tfliteService: tfliteService),
      debugShowCheckedModeBanner: false,
    );
  }
}