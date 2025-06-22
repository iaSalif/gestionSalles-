import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';
import '../routes/routes.dart';

/// Wrapper qui protège les pages selon le rôle utilisateur
class AuthWrapper extends StatefulWidget {
  final Widget child;
  final String requiredRole;
  final Widget? loadingWidget;
  final bool redirectToLogin;

  const AuthWrapper({
    super.key,
    required this.child,
    required this.requiredRole,
    this.loadingWidget,
    this.redirectToLogin = true,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _hasAccess = false;
  String? _currentUserRole;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    if (_isNavigating) return;

    try {
      final authService = AuthService();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (widget.redirectToLogin && mounted && !_isNavigating) {
          _navigateToLogin();
        }
        return;
      }

      final userData = await authService.getCurrentUserData();
      if (kDebugMode) {
        print('Utilisateur actuel: ${user.uid}, Route: ${ModalRoute.of(context)?.settings.name}');
      }
      if (kDebugMode) {
        print('Données utilisateur: $userData');
      }
      if (userData == null) {
        if (widget.redirectToLogin && mounted && !_isNavigating) {
          _showErrorAndRedirect('Données utilisateur introuvables');
        }
        return;
      }

      final userRole = userData['role'] as String?;
      if (kDebugMode) {
        print('Rôle utilisateur: $userRole, Rôle requis: ${widget.requiredRole}');
      }
      if (userRole == null) {
        if (widget.redirectToLogin && mounted && !_isNavigating) {
          _showErrorAndRedirect('Rôle utilisateur non défini');
        }
        return;
      }

      if (mounted) {
        setState(() {
          _currentUserRole = userRole;
          _hasAccess = _checkRoleAccess(userRole, widget.requiredRole);
          _isLoading = false;
        });
        if (kDebugMode) {
          print('Accès autorisé: $_hasAccess');
        }
        if (!_hasAccess && !_isNavigating) {
          _redirectBasedOnRole(userRole);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la vérification d\'accès: $e');
      }
      if (widget.redirectToLogin && mounted && !_isNavigating) {
        _showErrorAndRedirect('Erreur de vérification des droits');
      }
    }
  }

  bool _checkRoleAccess(String userRole, String requiredRole) {
    final normalizedUserRole = userRole.toLowerCase().trim().replaceAll(' ', '-');
    final normalizedRequiredRole = requiredRole.toLowerCase().trim().replaceAll(' ', '-');

    if (kDebugMode) {
      print('Rôles normalisés - User: $normalizedUserRole, Required: $normalizedRequiredRole');
    }

    if (normalizedUserRole == normalizedRequiredRole) return true;

    if (normalizedRequiredRole == 'administrateur' && AuthService.isAdmin(userRole)) return true;
    if (normalizedRequiredRole == 'chef-departement' && AuthService.isChefDepartement(userRole)) return true;
    if (normalizedRequiredRole == 'chefscolarite' && AuthService.isChefScolarite(userRole)) return true;
    if (normalizedRequiredRole == 'csaf' && AuthService.isCSAF(userRole)) return true;
    if (normalizedRequiredRole == 'responsable-pedagogique' && AuthService.isResponsablePedagogique(userRole)) return true;
    if (normalizedRequiredRole == 'directeur-de-patrimoine' && AuthService.isDirecteurPatrimoine(userRole)) return true;
    if (normalizedRequiredRole == 'utilisateur' && AuthService.isUtilisateur(userRole)) return true;

    return false;
  }

  void _navigateToLogin() {
    if (_isNavigating || !mounted) return;

    _isNavigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  void _showErrorAndRedirect(String message) {
    if (!mounted || _isNavigating) return;

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

    _isNavigating = true;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  void _redirectBasedOnRole(String userRole) {
    if (!mounted || _isNavigating) return;

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

    _isNavigating = true;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _navigateToCorrectDashboard(userRole);
      }
    });
  }

  void _navigateToCorrectDashboard(String userRole) {
    if (!mounted || _isNavigating) return;

    String targetRoute = _getTargetRouteForRole(userRole);

    try {
      Navigator.pushReplacementNamed(context, targetRoute);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la navigation vers $targetRoute: $e');
      }
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  String _getTargetRouteForRole(String userRole) {
    if (AuthService.isAdmin(userRole)) {
      return AppRoutes.adminDashboard;
    }
    if (AuthService.isChefDepartement(userRole) || AuthService.isChefDepartementCoordonnateur(userRole)) {
      return AppRoutes.chefDepartmentDashboard;
    }
    if (AuthService.isChefScolarite(userRole)) {
      return AppRoutes.chefScolariteDashboard;
    }
    if (AuthService.isCSAF(userRole)) {
      return AppRoutes.csafDashboard;
    }
    if (AuthService.isResponsablePedagogique(userRole)) {
      return AppRoutes.responsablePedagogiqueDashboard;
    }
    if (AuthService.isDirecteurPatrimoine(userRole)) {
      return AppRoutes.directeurPatrimoineDashboard;
    }
    if (AuthService.isUtilisateur(userRole)) {
      return AppRoutes.departmentDashboard;
    }

    return AppRoutes.login;
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
              child: const Icon(Icons.school, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Color(0xFF4A90E2)),
            const SizedBox(height: 24),
            const Text(
              'Vérification des droits d\'accès...',
              style: TextStyle(fontSize: 16, color: Color(0xFF2E3A47)),
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
                child: Icon(Icons.block, size: 48, color: Colors.red.shade600),
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
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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
                  if (_currentUserRole != null && mounted && !_isNavigating) {
                    _navigateToCorrectDashboard(_currentUserRole!);
                  } else if (mounted && !_isNavigating) {
                    _navigateToLogin();
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour à mon espace'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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
