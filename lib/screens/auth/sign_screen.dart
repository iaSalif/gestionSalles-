import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/routes.dart';
import '../../services/auth_services.dart';

final Map<String, (String, IconData)> roleDetails = {
  'chefDepartement': ('Coordonnateur', Icons.manage_accounts),
  'chefscolarite': ('Chef de scolarité', Icons.school),
  'directeurPatrimoine': ('Directeur du patrimoine', Icons.business),
  'csaf': ('CSAF', Icons.security),
  'responsablePedagogique': ('Responsable pédagogique', Icons.book),
  'administrateur': ('Administrateur', Icons.admin_panel_settings),
};

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomController = TextEditingController();
  final _departementController = TextEditingController();
  final _ufrController = TextEditingController();
  String _selectedRole = 'chefDepartement';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordsMatch = true;

  final List<String> _roles = roleDetails.keys.toList();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordsMatch);
    _confirmPasswordController.addListener(_checkPasswordsMatch);
  }

  void _checkPasswordsMatch() {
    final match = _passwordController.text == _confirmPasswordController.text;
    if (_passwordsMatch != match) {
      setState(() {
        _passwordsMatch = match;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomController.dispose();
    _departementController.dispose();
    _ufrController.dispose();
    super.dispose();
  }

  Future<void> _showSuccessDialog(String message) async {
    if (!mounted) return;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Succès'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(_emailController.text.trim());
      if (signInMethods.isNotEmpty) {
        _showErrorMessage('Cet email est déjà utilisé.');
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la vérification de l\'email: $e');
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final authResult = await AuthService().createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nomController.text.trim(),
        role: _selectedRole.toLowerCase().trim().replaceAll(' ', '-'),
        nom: _nomController.text.trim(),
        departement: _departementController.text.trim(),
        ufr: _ufrController.text.trim().isNotEmpty ? _ufrController.text.trim() : null,
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (authResult['success'] == true) {
        await _showSuccessDialog('Compte créé avec succès !');
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
        }
      } else {
        _showErrorMessage(authResult['message'] ?? 'Échec de l\'inscription.');
      }
    } catch (e) {
      String errorMessage = 'Une erreur inattendue s\'est produite';
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('network')) {
        errorMessage = 'Problème de connexion réseau. Vérifiez votre internet.';
      } else if (errorString.contains('permission-denied')) {
        errorMessage = 'Erreur de permission Firestore. Contactez l\'administrateur.';
      } else if (errorString.contains('email-already-in-use')) {
        errorMessage = 'Cet email est déjà utilisé.';
      } else if (errorString.contains('timeout')) {
        errorMessage = 'Délai d\'attente dépassé. Réessayez.';
      }
      if (mounted) _showErrorMessage(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Semantics(
                explicitChildNodes: true,
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
                            return const Icon(
                              Icons.school,
                              size: 80,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                      const Text(
                        'Créer un compte',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Nom complet
                      Semantics(
                        label: 'Nom complet',
                        child: TextFormField(
                          key: const Key('nom_complet_field'),
                          controller: _nomController,
                          decoration: const InputDecoration(
                            labelText: 'Nom complet',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Veuillez entrer votre nom' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      Semantics(
                        label: 'Adresse email',
                        child: TextFormField(
                          key: const Key('email_field'),
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            return !emailRegex.hasMatch(value.trim())
                                ? 'Veuillez entrer un email valide' : null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Mot de passe
                      Semantics(
                        label: 'Mot de passe',
                        child: TextFormField(
                          key: const Key('password_field'),
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              tooltip: _obscurePassword ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
                            ),
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            return value.length < 6
                                ? 'Le mot de passe doit contenir au moins 6 caractères' : null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirmation mot de passe
                      Semantics(
                        label: 'Confirmer le mot de passe',
                        child: TextFormField(
                          key: const Key('confirm_password_field'),
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              tooltip: _obscureConfirmPassword ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez confirmer votre mot de passe';
                            }
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (!_passwordsMatch && _confirmPasswordController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Les mots de passe ne correspondent pas',
                            style: TextStyle(color: Colors.red[700], fontSize: 13),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Rôle
                      Semantics(
                        label: 'Sélection du rôle',
                        child: DropdownButtonFormField<String>(
                          key: const Key('role_dropdown'),
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Rôle',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.work),
                          ),
                          isExpanded: true,
                          items: _roles.map((role) {
                            final details = roleDetails[role]!;
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Row(
                                children: [
                                  Icon(details.$2, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      details.$1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedRole = value);
                            }
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Veuillez sélectionner un rôle' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Département
                      Semantics(
                        label: 'Département',
                        child: TextFormField(
                          key: const Key('departement_field'),
                          controller: _departementController,
                          decoration: const InputDecoration(
                            labelText: 'Département',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Veuillez entrer votre département' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // UFR
                      Semantics(
                        label: 'UFR optionnel',
                        child: TextFormField(
                          key: const Key('ufr_field'),
                          controller: _ufrController,
                          decoration: const InputDecoration(
                            labelText: 'UFR (optionnel)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.school),
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: (!_passwordsMatch || _isLoading) ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('S\'inscrire', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pushNamed(context, AppRoutes.login),
                        child: const Text('Déjà un compte ? Connectez-vous'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
