import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:manioc_ai/routes/route_pages.dart';
import 'package:manioc_ai/screens/result_screen.dart';
import 'package:manioc_ai/services/tflite_service.dart';

class LoadingScreen extends StatefulWidget {
  final File imageFile;
  final TFLiteService tfliteService;

  const LoadingScreen({super.key, required this.imageFile, required this.tfliteService});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late AnimationController _particleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _particleAnimation;

  int _messageIndex = 0;
  double _progress = 0.0;
  Timer? _messageTimer;

  final List<Map<String, dynamic>> _analysisSteps = [
    {"message": "Initialisation de l'IA...", "icon": Icons.memory, "color": Colors.blue},
    {"message": "Analyse des nervures de la feuille...", "icon": Icons.park, "color": Colors.green},
    {"message": "Détection des motifs pathologiques...", "icon": Icons.search, "color": Colors.orange},
    {"message": "Classification des symptômes...", "icon": Icons.psychology, "color": Colors.purple},
    {"message": "Calcul du niveau de confiance...", "icon": Icons.analytics, "color": Colors.teal},
    {"message": "Finalisation des résultats...", "icon": Icons.check_circle, "color": Colors.green}
  ];

  @override
  void initState() {
    super.initState();

    if (widget.imageFile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur: Aucune image fournie pour l\'analyse'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      });
      return;
    }

    _initializeAnimations();
    _startAnalysisSequence();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_rotationController);

    _progressController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _particleAnimation = Tween<double>(begin: 0, end: 1).animate(_particleController);

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _progressController.forward();
    _particleController.repeat();
  }

  void _startAnalysisSequence() {
    _messageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _messageIndex < _analysisSteps.length - 1) {
        setState(() {
          _messageIndex++;
          _progress = (_messageIndex + 1) / _analysisSteps.length;
        });
      }
    });

    Future.delayed(const Duration(seconds: 6), () async {
      if (mounted) {
        final results = await widget.tfliteService.classifyImage(widget.imageFile);
        _navigateToResults(results['diseaseName']!, results['confidence']!);
      }
    });
  }

  void _navigateToResults(String diseaseName, double confidence) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ResultScreen(
          imageFile: widget.imageFile,
          diseaseName: diseaseName,
          confidence: confidence,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_messageIndex >= _analysisSteps.length) {
      _messageIndex = _analysisSteps.length - 1;
    }

    final currentStep = _analysisSteps[_messageIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.1),
              const Color(0xFFE8F5E9),
              Colors.white,
              const Color(0xFF2196F3).withOpacity(0.1),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ...List.generate(12, (index) => _buildFloatingParticle(index)),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: currentStep['color'].withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/LOGO_SBG.png',
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.eco,
                                  size: 80,
                                  color: currentStep['color'],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: _progressAnimation.value,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.grey.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    currentStep['color'],
                                  ),
                                ),
                              );
                            },
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Icon(
                              currentStep['icon'],
                              key: ValueKey(_messageIndex),
                              size: 32,
                              color: currentStep['color'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Text(
                          '${(_progressAnimation.value * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: currentStep['color'],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          currentStep['message'],
                          key: ValueKey(_messageIndex),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _analysisSteps.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index <= _messageIndex ? 12 : 8,
                          height: index <= _messageIndex ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index <= _messageIndex
                                ? currentStep['color']
                                : Colors.grey.withOpacity(0.3),
                          ),
                        ),
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
  }

  Widget _buildFloatingParticle(int index) {
    final random = Random(index);
    final size = 4.0 + random.nextDouble() * 8.0;
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    final animationDelay = random.nextDouble() * 2.0;

    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        final progress = (_particleAnimation.value + animationDelay) % 1.0;
        final top = MediaQuery.of(context).size.height * (1.2 - progress * 1.4);

        return Positioned(
          left: left,
          top: top,
          child: Opacity(
            opacity: (sin(progress * pi) * 0.5 + 0.5) * 0.6,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: [
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple,
                ][index % 4].withOpacity(0.6),
              ),
            ),
          ),
        );
      },
    );
  }
}