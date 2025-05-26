import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manioc_ai/routes/route_pages.dart';
import 'package:manioc_ai/services/tflite_service.dart';

class ImageInputScreen extends StatefulWidget {
  final File? selectedImage;
  final TFLiteService tfliteService;

  const ImageInputScreen({super.key, this.selectedImage, required this.tfliteService});

  @override
  State<ImageInputScreen> createState() => _ImageInputScreenState();
}

class _ImageInputScreenState extends State<ImageInputScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    print('SelectedImage : ${widget.selectedImage?.path}');
    if (widget.selectedImage != null) {
      print('Fichier existe : ${File(widget.selectedImage!.path).existsSync()}');
    }
    _selectedImage = widget.selectedImage;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _pickNewImage() async {
    try {
      final picker = ImagePicker();
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        File newImage = File(pickedFile.path);
        if (await newImage.exists()) {
          setState(() {
            _selectedImage = newImage;
          });
          print('Nouvelle image sélectionnée: ${newImage.path}');
        } else {
          _showErrorSnackBar('Erreur: Image non trouvée');
        }
      }
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
      _showErrorSnackBar('Erreur lors de la sélection de l\'image');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Caméra'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            "Image sélectionnée",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.1),
              const Color(0xFFE8F5E9),
              Colors.white,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_selectedImage != null && _selectedImage!.existsSync()) ...[
                                Hero(
                                  tag: 'selected_image',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 0,
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxHeight: 200,
                                          maxWidth: double.infinity,
                                        ),
                                        child: Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('Erreur de chargement de l\'image : $error');
                                            return Container(
                                              height: 150,
                                              color: Colors.grey.shade200,
                                              child: const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                    size: 50,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Impossible de charger l\'image',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.check_circle_outline,
                                          color: Color(0xFF4CAF50),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Image prête pour l\'analyse',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: _pickNewImage,
                                  icon: const Icon(Icons.swap_horiz),
                                  label: const Text('Changer d\'image'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF4CAF50),
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.image_not_supported,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Aucune image sélectionnée',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _pickNewImage,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4CAF50),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.add_photo_alternate),
                                            SizedBox(width: 8),
                                            Text('Choisir une image'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Intelligence Artificielle Avancée',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Notre IA analysera votre image pour identifier\nles maladies et fournir des recommandations',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      height: 56,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(28),
                                          onTap: () => Navigator.pop(context),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.arrow_back,
                                                color: Colors.black54,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Retour',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: _selectedImage != null ? 2 : 1,
                                    child: _selectedImage != null
                                        ? AnimatedBuilder(
                                            animation: _pulseAnimation,
                                            builder: (context, child) {
                                              return Transform.scale(
                                                scale: _pulseAnimation.value,
                                                child: Container(
                                                  height: 56,
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [
                                                        Color(0xFF4CAF50),
                                                        Color(0xFF45A049),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    borderRadius: BorderRadius.circular(28),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(0xFF4CAF50).withOpacity(0.4),
                                                        spreadRadius: 0,
                                                        blurRadius: 12,
                                                        offset: const Offset(0, 6),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius: BorderRadius.circular(28),
                                                      onTap: () {
                                                        print('Démarrage de l\'analyse avec: ${_selectedImage!.path}');
                                                        NavigationUtils.navigateToSplash(
                                                          context,
                                                          imageFile: _selectedImage!,
                                                        );
                                                      },
                                                      child: const Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.psychology,
                                                            color: Colors.white,
                                                            size: 24,
                                                          ),
                                                          SizedBox(width: 12),
                                                          Text(
                                                            'Analyser',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(28),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Analyser',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'L\'analyse prend généralement 2-3 secondes',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}