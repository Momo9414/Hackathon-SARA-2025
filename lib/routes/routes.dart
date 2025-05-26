class Routes {
  // Routes principales de l'application
  static const String home = '/';
  static const String imagescan = '/image_scan';
  static const String splash = '/splash';
  static const String result = '/result';
  
  // Routes additionnelles si besoin
  static const String imagePreview = '/image_preview';
  static const String loading = '/loading';
  static const String settings = '/settings';
  static const String auth = '/auth';
  
  // Liste de toutes les routes pour validation
  static const List<String> allRoutes = [
    home,
    imagescan,
    splash,
    result,
    imagePreview,
    loading,
    settings,
  ];
  
  // Méthode pour vérifier si une route existe
  static bool isValidRoute(String route) {
    return allRoutes.contains(route);
  }
}