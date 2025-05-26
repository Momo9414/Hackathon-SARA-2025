import 'package:flutter/material.dart';
import 'package:manioc_ai/routes/route_pages.dart';
import 'package:manioc_ai/routes/routes.dart';
import 'package:manioc_ai/screens/home_screen.dart';
import 'package:manioc_ai/services/tflite_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tfliteService = TFLiteService();
  await tfliteService.loadModel();
  runApp(ManiocAIApp(tfliteService: tfliteService));
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