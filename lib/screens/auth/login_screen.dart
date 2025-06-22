import 'package:flutter/material.dart';
import 'package:gestion_salles/routes/routes.dart';
import 'package:gestion_salles/services/auth_services.dart';

class LoginScreen extends StatefulWidget {
  final String title;

  const LoginScreen({super.key, required this.title});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final result = await AuthService().signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final userRole = result['userData']['role'] ?? 'utilisateur';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Connexion réussie !'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _navigateToUserDashboard(userRole);
      } else {
        _showErrorMessage(result['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      _showErrorMessage('Une erreur s\'est produite lors de la connexion');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToUserDashboard(String role) {
    String cleanRole = role.toLowerCase().trim().replaceAll(' ', '-');
    String targetRoute;

    if (['administrateur', 'admin'].contains(cleanRole)) {
      targetRoute = AppRoutes.adminDashboard;
    } else if (['chef-de-departement', 'chef-de-departement-coordonnateur'].contains(cleanRole)) {
      targetRoute = AppRoutes.chefDepartmentDashboard;
    } else if (['chefscolarite', 'chefscolarité'].contains(cleanRole)) {
      targetRoute = AppRoutes.chefScolariteDashboard;
    } else if (cleanRole == 'csaf') {
      targetRoute = AppRoutes.csafDashboard;
    } else if (['responsable-pedagogique', 'responsable-pédagogique'].contains(cleanRole)) {
      targetRoute = AppRoutes.responsablePedagogiqueDashboard;
    } else if (cleanRole == 'directeur-de-patrimoine') {
      targetRoute = AppRoutes.directeurPatrimoineDashboard;
    } else {
      targetRoute = AppRoutes.chefDepartmentDashboard;
    }

    Navigator.pushReplacementNamed(context, targetRoute);
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Image.asset(
                        'assets/images/unz_logo.png',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.login, size: 80, color: Colors.grey);
                        },
                      ),
                    ),
                    const Text(
                      'Connectez-vous',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        return !emailRegex.hasMatch(value.trim()) ? 'Email invalide' : null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mot de passe
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          tooltip: _obscurePassword ? 'Afficher' : 'Masquer',
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Veuillez entrer votre mot de passe'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Bouton
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Se connecter', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pushNamed(context, AppRoutes.signup),
                      child: const Text('Pas encore de compte ? S\'inscrire'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
