// 2. firebase_service.dart
// ====================
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gestion_salles/firebase_options.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  // Services Firebase
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // État d'initialisation
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialisation complète de Firebase
  static Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('🔥 Initialisation de Firebase...');
      }

      // Initialisation Firebase Core
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configuration Firestore
      await _configureFirestore();

      // Configuration Auth
      await _configureAuth();

      instance._isInitialized = true;

      if (kDebugMode) {
        print('✅ Firebase initialisé avec succès');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur initialisation Firebase: $e');
      }
      rethrow;
    }
  }

  /// Configuration Firestore
  static Future<void> _configureFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Configuration pour la persistance locale
      if (!kIsWeb) {
        await firestore.enablePersistence();
      }

      // Configuration des paramètres
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      if (kDebugMode) {
        print('Firestore configuré');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur configuration Firestore: $e');
      }
    }
  }

  /// Configuration Firebase Auth
  static Future<void> _configureAuth() async {
    try {
      final auth = FirebaseAuth.instance;

      // Configuration pour la persistance de session
      await auth.setPersistence(Persistence.LOCAL);

      // Langue par défaut
      await auth.setLanguageCode('fr');

      if (kDebugMode) {
        print('Firebase Auth configuré');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur configuration Auth: $e');
      }
    }
  }

  /// Vérification de la santé Firebase
  static Future<bool> checkFirebaseHealth() async {
    try {
      // Test de connexion Firestore
      await FirebaseFirestore.instance
          .collection('health_check')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));

      // Test de l'état Auth
      final user = FirebaseAuth.instance.currentUser;

      if (kDebugMode) {
        print('Firebase Health Check: OK');
        print('Utilisateur connecté: ${user?.email ?? "Anonyme"}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Health Check: FAILED - $e');
      }
      return false;
    }
  }

  /// Nettoyage des ressources
  static Future<void> cleanup() async {
    try {
      // Nettoyage du cache Firestore
      await FirebaseFirestore.instance.clearPersistence();

      if (kDebugMode) {
        print('Firebase cleanup terminé');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur cleanup Firebase: $e');
      }
    }
  }
}
