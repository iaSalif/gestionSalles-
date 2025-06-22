import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestion_salles/routes/routes.dart';
import 'package:gestion_salles/widgets/auth_state_listener.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      print('✅ Firebase initialisé avec succès');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Erreur Firebase : $e');
    }
    // Afficher un écran d'erreur si Firebase échoue (optionnel)
    runApp(const ErrorApp());
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthStateListener(
      autoRedirect: true, // Redirection automatique selon l'état d'authentification
      child: MaterialApp(
        title: 'Gestion des Salles',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          visualDensity: VisualDensity.adaptivePlatformDensity,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black87),
            titleLarge: TextStyle(fontWeight: FontWeight.bold),
          ),
          // Désactiver temporairement les sémantiques pour tester
          // semanticsDebugger: true, // Activer pour déboguer les sémantiques
        ),
        initialRoute: AppRoutes.welcome,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        // Ajouter un builder pour gérer les erreurs de rendu
        builder: (context, child) {
          // Ajouter un ScaffoldMessenger global pour gérer les SnackBars
          return ScaffoldMessenger(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

// Widget affiché en cas d'erreur d'initialisation Firebase
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Erreur lors de l\'initialisation de l\'application.\nVeuillez vérifier votre connexion et réessayer.',
            style: TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}