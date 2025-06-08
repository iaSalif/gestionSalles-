import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';

/// Gestionnaire global de l'état d'authentification - VERSION OPTIMISÉE
class AuthStateListener extends StatefulWidget {
  final Widget child;
  final bool autoRedirect;

  const AuthStateListener({
    super.key,
    required this.child,
    this.autoRedirect = true,
  });

  @override
  State<AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends State<AuthStateListener> {
  late final Stream<User?> _authStateStream;

  @override
  void initState() {
    super.initState();
    // ✅ Stream créé une seule fois pour éviter les rebuilds inutiles
    _authStateStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        // Gestion des erreurs de connexion
        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error.toString());
        }

        // État de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen(); // ✅ Widget const séparé
        }

        // Utilisateur connecté
        if (snapshot.hasData && snapshot.data != null) {
          return _buildAuthenticatedState(snapshot.data!);
        }

        // Utilisateur non connecté
        return widget.child;
      },
    );
  }

  Widget _buildErrorScreen(String error) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: _ErrorContent(), // ✅ Widget const séparé
      ),
    );
  }

  Widget _buildAuthenticatedState(User user) {
    if (!widget.autoRedirect) {
      return widget.child;
    }

    return _AuthenticatedStateWrapper(
      user: user,
      onSignOut: _handleSignOut,
      child: widget.child,
    );
  }

  Future<void> _handleSignOut(String reason) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Déconnexion automatique: $reason'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la déconnexion: $e');
      }
    }
  }
}

// ✅ Widget séparé pour l'état authentifié (meilleure organisation)
class _AuthenticatedStateWrapper extends StatefulWidget {
  final User user;
  final Widget child;
  final Function(String) onSignOut;

  const _AuthenticatedStateWrapper({
    required this.user,
    required this.child,
    required this.onSignOut,
  });

  @override
  State<_AuthenticatedStateWrapper> createState() => _AuthenticatedStateWrapperState();
}

class _AuthenticatedStateWrapperState extends State<_AuthenticatedStateWrapper> {
  late final Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    // ✅ Future créé une seule fois dans initState
    _userDataFuture = AuthService().getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onSignOut('Données utilisateur introuvables');
          });
          return const _LoadingScreen();
        }

        final userData = snapshot.data!;
        final userRole = userData['role'] as String?;

        if (userRole == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onSignOut('Rôle utilisateur non défini');
          });
          return const _LoadingScreen();
        }

        return AuthenticatedApp(
          userRole: userRole,
          userData: userData,
          child: widget.child,
        );
      },
    );
  }
}

// ✅ Widgets const séparés pour de meilleures performances
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LoadingIcon(),
              SizedBox(height: 32),
              CircularProgressIndicator(color: Color(0xFF4A90E2)),
              SizedBox(height: 24),
              Text(
                'Vérification de l\'authentification...',
                style: TextStyle(fontSize: 16, color: Color(0xFF2E3A47)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingIcon extends StatelessWidget {
  const _LoadingIcon();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.school, size: 48, color: Colors.white),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent();

  @override
  Widget build(BuildContext context) {
    return Center(
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
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Erreur d\'authentification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Une erreur s\'est produite lors de la vérification de votre authentification.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Utiliser Navigator pour revenir ou recharger
                Navigator.of(context).pushReplacementNamed('/');
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
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
    );
  }
}

/// Widget qui encapsule l'application pour un utilisateur authentifié
class AuthenticatedApp extends StatelessWidget {
  final Widget child;
  final String userRole;
  final Map<String, dynamic> userData;

  const AuthenticatedApp({
    super.key,
    required this.child,
    required this.userRole,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Mixin optimisé pour les pages qui ont besoin d'accéder aux données utilisateur
mixin AuthAware<T extends StatefulWidget> on State<T> {
  Map<String, dynamic>? _currentUserData;
  String? _currentUserRole;
  Future<Map<String, dynamic>?>? _userDataFuture;

  Map<String, dynamic>? get currentUserData => _currentUserData;
  String? get currentUserRole => _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // ✅ Utilise le cache si disponible
      _userDataFuture ??= AuthService().getCurrentUserData();
      final userData = await _userDataFuture;

      if (mounted && userData != null) {
        setState(() {
          _currentUserData = userData;
          _currentUserRole = userData['role'] as String?;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des données utilisateur: $e');
      }
    }
  }

  void refreshUserData() {
    _userDataFuture = null;
    _loadUserData();
  }
}

// ✅ Utilitaire pour débugger les performances
class PerformanceHelper {
  static void logRebuild(String widgetName) {
    if (kDebugMode) {
      print('🔄 REBUILD: $widgetName à ${DateTime.now()}');
    }
  }

  static T measureTime<T>(String operation, T Function() function) {
    if (!kDebugMode) return function();

    final stopwatch = Stopwatch()..start();
    final result = function();
    stopwatch.stop();
    if (kDebugMode) {
      print('⏱️ $operation: ${stopwatch.elapsedMilliseconds}ms');
    }
    return result;
  }
}