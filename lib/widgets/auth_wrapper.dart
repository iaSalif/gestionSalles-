import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';

/// Wrapper qui protège les pages selon le rôle utilisateur
class AuthWrapper extends StatefulWidget {
  final Widget child;
  final String requiredRole;
  final Widget? loadingWidget;
  final bool redirectToLogin;

  const AuthWrapper({
    Key? key,
    required this.child,
    required this.requiredRole,
    this.loadingWidget,
    this.redirectToLogin = true,
  }) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _hasAccess = false;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    try {
      final authService = AuthService();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Utilisateur non connecté
        if (widget.redirectToLogin && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }
        return;
      }

      // Récupérer les données utilisateur
      final userData = await authService.getCurrentUserData();

      if (userData == null) {
        // Données utilisateur non trouvées
        if (widget.redirectToLogin && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorAndRedirect('Données utilisateur introuvables');
          });
        }
        return;
      }

      final userRole = userData['role'] as String?;

      if (userRole == null) {
        // Rôle non défini
        if (widget.redirectToLogin && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorAndRedirect('Rôle utilisateur non défini');
          });
        }
        return;
      }

      setState(() {
        _currentUserRole = userRole;
        _hasAccess = _checkRoleAccess(userRole, widget.requiredRole);
        _isLoading = false;
      });

      // Si pas d'accès, rediriger vers la page appropriée
      if (!_hasAccess && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _redirectBasedOnRole(userRole);
        });
      }

    } catch (e) {
      print('Erreur lors de la vérification d\'accès: $e');
      if (widget.redirectToLogin && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorAndRedirect('Erreur de vérification des droits');
        });
      }
    }
  }

  bool _checkRoleAccess(String userRole, String requiredRole) {
    // Normaliser les rôles pour la comparaison
    final normalizedUserRole = userRole.toLowerCase().trim();
    final normalizedRequiredRole = requiredRole.toLowerCase().trim();

    // Vérification exacte d'abord
    if (normalizedUserRole == normalizedRequiredRole) {
      return true;
    }

    // Vérifications alternatives pour la compatibilité
    final roleMapping = {
      'administrateur': ['admin', 'administrator'],
      'admin': ['administrateur', 'administrator'],
      'chef de département': ['chef_departement', 'department_head'],
      'responsable pédagogique': ['responsable_pedagogique', 'academic_manager'],
      'directeur de patrimoine': ['directeur_patrimoine', 'property_director'],
      'csaf': ['comptable', 'accountant'],
    };

    final alternatives = roleMapping[normalizedRequiredRole] ?? [];
    return alternatives.contains(normalizedUserRole);
  }

  void _showErrorAndRedirect(String message) {
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

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  void _redirectBasedOnRole(String userRole) {
    // Afficher un message d'accès refusé
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.block, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Accès refusé - Permissions insuffisantes'),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    // Rediriger vers la page appropriée selon le rôle
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        AuthService.navigateByRole(context, userRole);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ?? _buildDefaultLoading();
    }

    if (!_hasAccess) {
      return _buildAccessDenied();
    }

    return widget.child;
  }

  Widget _buildDefaultLoading() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF4A90E2), Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Color(0xFF4A90E2),
            ),
            const SizedBox(height: 24),
            const Text(
              'Vérification des droits d\'accès...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2E3A47),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade200, width: 2),
                ),
                child: Icon(
                  Icons.block,
                  size: 48,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Accès refusé',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Vous n\'avez pas les permissions nécessaires pour accéder à cette page.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Rôle requis: ${widget.requiredRole}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (_currentUserRole != null) ...[
                Text(
                  'Votre rôle: $_currentUserRole',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  if (_currentUserRole != null) {
                    AuthService.navigateByRole(context, _currentUserRole!);
                  } else {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour à mon espace'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}