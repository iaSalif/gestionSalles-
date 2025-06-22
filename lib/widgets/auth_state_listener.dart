import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';
import '../routes/routes.dart';

class AuthStateListener extends StatefulWidget {
  final Widget child;
  final bool autoRedirect;
  final bool initialSignUp;

  const AuthStateListener({
    super.key,
    required this.child,
    this.autoRedirect = true,
    this.initialSignUp = false,
  });

  @override
  State<AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends State<AuthStateListener> {
  late final Stream<User?> _authStateStream;

  @override
  void initState() {
    super.initState();
    _authStateStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _ErrorScreen();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return _AuthenticatedStateWrapper(
            user: snapshot.data!,
            child: widget.child,
            onSignOut: _handleSignOut,
            autoRedirect: widget.autoRedirect,
            initialSignUp: widget.initialSignUp,
          );
        }

        return widget.child;
      },
    );
  }

  Future<void> _handleSignOut(String reason) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Déconnexion automatique : $reason'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Erreur déconnexion : $e');
    }
  }
}

class _AuthenticatedStateWrapper extends StatefulWidget {
  final User user;
  final Widget child;
  final Function(String) onSignOut;
  final bool autoRedirect;
  final bool initialSignUp;

  const _AuthenticatedStateWrapper({
    required this.user,
    required this.child,
    required this.onSignOut,
    required this.autoRedirect,
    required this.initialSignUp,
  });

  @override
  State<_AuthenticatedStateWrapper> createState() => _AuthenticatedStateWrapperState();
}

class _AuthenticatedStateWrapperState extends State<_AuthenticatedStateWrapper> {
  late final Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = AuthService().getCurrentUserData();

    if (widget.autoRedirect && !widget.initialSignUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _redirectAfterLogin());
    }
  }

  Future<void> _redirectAfterLogin() async {
    try {
      final userData = await _userDataFuture;
      if (mounted && userData != null) {
        final userRole = userData['role'] as String?;
        if (userRole != null) {
          await AuthService.navigateByRole(context, userRole);
        } else {
          widget.onSignOut('Rôle utilisateur non défini');
        }
      } else {
        widget.onSignOut('Données utilisateur introuvables');
      }
    } catch (e) {
      if (kDebugMode) print('Erreur redirection : $e');
      widget.onSignOut('Erreur lors de la récupération des données');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!['role'] == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onSignOut('Erreur ou rôle manquant');
          });
          return const _LoadingScreen();
        }

        return widget.child;
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('Une erreur est survenue.', style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
