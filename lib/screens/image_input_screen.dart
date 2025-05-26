import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manioc_ai/screens/loading_screen.dart';

class ImageInputScreen extends StatelessWidget {
  final File selectedImage;

  const ImageInputScreen({super.key, required this.selectedImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image sélectionnée"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Image.file(
              selectedImage,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.science),
            label: const Text("Analyser l’image"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(200, 50),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LoadingScreen(imageFile: selectedImage),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
