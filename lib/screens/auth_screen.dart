import 'package:flutter/material.dart';
import 'dart:math' as math;

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _showPassword = false;
  late AnimationController _animationController;
  late AnimationController _particleController;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_isLogin) {
      print('Connexion: ${_emailController.text}');
      _showSnackBar('Connexion réussie !', Colors.green);
    } else {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showSnackBar('Les mots de passe ne correspondent pas', Colors.red);
        return;
      }
      print('Inscription: ${_nameController.text}');
      _showSnackBar('Inscription réussie !', Colors.green);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0FDF4), // green-50
              Color(0xFFECFDF5), // emerald-50
              Color(0xFFF0FDFA), // teal-50
            ],
          ),
        ),
        child: Stack(
          children: [
            // Particules flottantes
            ...List.generate(20, (index) => _buildFloatingParticle(index)),

            // Contenu principal
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    _buildHeader(),
                    SizedBox(height: 32),
                    _buildMainContainer(),
                    SizedBox(height: 24),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final random = math.Random(index);
        final offset = Offset(
          random.nextDouble() * MediaQuery.of(context).size.width,
          random.nextDouble() * MediaQuery.of(context).size.height,
        );

        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Opacity(
            opacity: 0.3 *
                (0.5 +
                    0.5 *
                        math.sin(
                            _particleController.value * 2 * math.pi + index)),
            child: Icon(
              Icons.eco,
              size: 12 + random.nextDouble() * 16,
              color: Colors.green[200],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      )),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              
              borderRadius: BorderRadius.circular(40),
              
            ),
            child: Image.asset(
              'assets/LOGO_SBG.png',
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.eco,
                    size: 80, color: Color.fromARGB(255, 106, 187, 109));
              },
            ),
          ),
          SizedBox(height: 16),
          Text(
            'PhytoScan',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _isLogin
                ? 'Connectez-vous à votre compte'
                : 'Rejoignez notre communauté d\'agriculteurs',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContainer() {
    return FadeTransition(
      opacity: _animationController,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildToggleButtons(),
              SizedBox(height: 32),
              _buildFormFields(),
              SizedBox(height: 24),
              _buildSubmitButton(),
              SizedBox(height: 32),
              _buildDivider(),
              SizedBox(height: 16),
              _buildSocialButtons(),
              if (!_isLogin) ...[
                SizedBox(height: 24),
                _buildInfoCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = true),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isLogin
                      ? [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4)
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 18,
                      color: _isLogin ? Colors.green[600] : Colors.grey[500],
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Connexion',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _isLogin ? Colors.green[600] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = false),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isLogin
                      ? [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4)
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group,
                      size: 18,
                      color: !_isLogin ? Colors.green[600] : Colors.grey[500],
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Inscription',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: !_isLogin ? Colors.green[600] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        if (!_isLogin) ...[
          _buildTextField(
            controller: _nameController,
            hint: 'Nom complet',
            icon: Icons.person,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            hint: 'Numéro de téléphone',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _locationController,
            hint: 'Localisation (Ville, Région)',
            icon: Icons.location_on,
          ),
          SizedBox(height: 16),
        ],
        _buildTextField(
          controller: _emailController,
          hint: 'Adresse email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Email requis';
            if (!value!.contains('@')) return 'Email invalide';
            return null;
          },
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hint: 'Mot de passe',
          icon: Icons.lock,
          isPassword: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Mot de passe requis';
            if (value!.length < 6) return 'Au moins 6 caractères';
            return null;
          },
        ),
        if (!_isLogin) ...[
          SizedBox(height: 16),
          _buildTextField(
            controller: _confirmPasswordController,
            hint: 'Confirmer le mot de passe',
            icon: Icons.lock,
            isPassword: true,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Confirmation requise';
              return null;
            },
          ),
        ],
        if (_isLogin) ...[
          SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  color: Colors.green[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_showPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.green[500]!, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _handleSubmit,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? 'Se connecter' : 'Créer mon compte',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _buildSocialButton(
          'Continuer avec Google',
          Colors.red,
          () {},
        ),
        SizedBox(height: 12),
        _buildSocialButton(
          'Continuer avec Facebook',
          Colors.blue[600]!,
          () {},
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, Color color, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.eco, color: Colors.green[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pourquoi rejoindre Manioc AI ?',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                ...[
                  'Diagnostic rapide de vos cultures',
                  'Conseils personnalisés d\'experts',
                  'Suivi de l\'évolution de vos plantations',
                  'Communauté d\'agriculteurs'
                ].map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $item',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Text.rich(
      TextSpan(
        text: 'En vous connectant, vous acceptez nos ',
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
        children: [
          TextSpan(
            text: 'Conditions d\'utilisation',
            style: TextStyle(color: Colors.green[600]),
          ),
          TextSpan(text: ' et notre '),
          TextSpan(
            text: 'Politique de confidentialité',
            style: TextStyle(color: Colors.green[600]),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
