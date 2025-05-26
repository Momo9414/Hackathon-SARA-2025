import 'package:flutter/material.dart';
import 'package:manioc_ai/routes/routes.dart';
import 'package:manioc_ai/screens/home_screen.dart';
import 'package:manioc_ai/screens/image_input_screen.dart';
import 'package:manioc_ai/screens/loading_screen.dart';
import 'package:manioc_ai/screens/result_screen.dart';
import 'package:manioc_ai/services/tflite_service.dart';
import 'dart:io';

class RoutePageList {
  static Route<dynamic> generateRoute(RouteSettings settings, TFLiteService tfliteService) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(builder: (context) => HomeScreen(tfliteService: tfliteService));

      case Routes.imagescan:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ImageInputScreen(
            selectedImage: args?['selectedImage'] as File?,
            tfliteService: tfliteService,
          ),
        );

      case Routes.splash:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['imageFile'] != null) {
          return MaterialPageRoute(
            builder: (context) => LoadingScreen(
              imageFile: args['imageFile'] as File,
              tfliteService: tfliteService,
            ),
          );
        }
        return MaterialPageRoute(builder: (context) => HomeScreen(tfliteService: tfliteService));

      case Routes.result:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args['imageFile'] != null &&
            args['diseaseName'] != null &&
            args['confidence'] != null) {
          return MaterialPageRoute(
            builder: (context) => ResultScreen(
              imageFile: args['imageFile'] as File,
              diseaseName: args['diseaseName'] as String,
              confidence: args['confidence'] as double,
            ),
          );
        }
        return MaterialPageRoute(builder: (context) => HomeScreen(tfliteService: tfliteService));

      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Page non trouvée')),
          ),
        );
    }
  }
}

class NavigationUtils {
  static void navigateToImageInput(BuildContext context, {required File selectedImage}) {
    Navigator.pushNamed(
      context,
      Routes.imagescan,
      arguments: {'selectedImage': selectedImage},
    );
  }

  static void navigateToSplash(BuildContext context, {required File imageFile}) {
    Navigator.pushNamed(
      context,
      Routes.splash,
      arguments: {'imageFile': imageFile},
    );
  }

  static void navigateToResult(
    BuildContext context, {
    required File imageFile,
    required String diseaseName,
    required double confidence,
  }) {
    Navigator.pushReplacementNamed(
      context,
      Routes.result,
      arguments: {
        'imageFile': imageFile,
        'diseaseName': diseaseName,
        'confidence': confidence,
      },
    );
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.home,
      (route) => false,
    );
  }
}