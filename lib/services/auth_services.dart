import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache pour les données utilisateur
  static Map<String, dynamic>? _cachedUserData;
  static String? _cachedUserRole;

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream pour écouter les changements d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Connexion avec email et mot de passe - VERSION CORRIGÉE
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Tentative de connexion pour: $email');

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Authentification Firebase réussie pour UID: ${result.user!.uid}');

      if (result.user != null) {
        // Récupérer les données utilisateur depuis Firestore
        Map<String, dynamic>? userData = await getUserDataFromFirestore(result.user!.uid);

        if (userData != null) {
          // Cache les données
          _cachedUserData = userData;
          _cachedUserRole = userData['role'];

          print('Données utilisateur récupérées: $userData');

          return {
            'success': true,
            'user': result.user,
            'role': userData['role'],
            'userData': userData,
            'message': 'Connexion réussie'
          };
        } else {
          if (kDebugMode) {
            print('Aucun document utilisateur trouvé dans Firestore');
          }
          return {
            'success': false,
            'message': 'Profil utilisateur introuvable. Contactez l\'administrateur.',
            'user': null,
            'userData': null
          };
        }
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException: ${e.code} - ${e.message}');
      }

      return {
        'success': false,
        'message': _handleAuthException(e),
        'user': null,
        'userData': null
      };
    } catch (e) {
      if (kDebugMode) {
        print('Erreur inattendue: $e');
      }
      return {
        'success': false,
        'message': 'Une erreur inattendue s\'est produite: $e',
        'user': null,
        'userData': null
      };
    }

    return {
      'success': false,
      'message': 'Erreur de connexion inconnue',
      'user': null,
      'userData': null
    };
  }

  // Méthode pour récupérer les données utilisateur depuis Firestore
  Future<Map<String, dynamic>?> getUserDataFromFirestore(String uid) async {
    try {
      if (kDebugMode) {
        print('Recherche des données pour UID: $uid');
      }

      // Chercher d'abord dans la collection 'administrateur'
      DocumentSnapshot userDoc = await _firestore
          .collection('administrateur')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        if (kDebugMode) {
          print('Utilisateur trouvé dans la collection "administrateur"');
        }
      } else {
        if (kDebugMode) {
          print('Utilisateur non trouvé dans administrateur, recherche dans utilisateurs...');
        }
        userDoc = await _firestore
            .collection('utilisateurs')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          if (kDebugMode) {
            print('Utilisateur trouvé dans la collection "utilisateurs"');
          }
        }
      }

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Nettoyer le rôle récupéré
        String userRole = (userData['role'] ?? 'Utilisateur').toString().trim();
        userData['role'] = userRole;

        if (kDebugMode) {
          print('Données récupérées: $userData');
        }
        return userData;
      } else {
        if (kDebugMode) {
          print('Aucun document trouvé dans les deux collections');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des données Firestore: $e');
      }
    }
    return null;
  }

  // Obtenir les données de l'utilisateur actuel avec cache
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Vérifier le cache d'abord
        if (_cachedUserData != null) {
          if (kDebugMode) {
            print('Utilisation des données en cache');
          }
          return _cachedUserData;
        }

        // Sinon, récupérer depuis Firestore
        if (kDebugMode) {
          print('Récupération des données depuis Firestore...');
        }
        Map<String, dynamic>? userData = await getUserDataFromFirestore(user.uid);

        if (userData != null) {
          _cachedUserData = userData;
          _cachedUserRole = userData['role'];
        }

        return userData;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des données utilisateur: $e');
      }
    }
    return null;
  }

  // Méthode pour vérifier l'état d'authentification avec retry
  Future<bool> verifyAuthenticationState() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('Aucun utilisateur connecté');
        }
        return false;
      }

      // Recharger les informations utilisateur
      await user.reload();
      user = _auth.currentUser;

      if (user == null) {
        if (kDebugMode) {
          print('Utilisateur déconnecté après reload');
        }
        return false;
      }

      // Vérifier que les données Firestore sont accessibles
      Map<String, dynamic>? userData = await getCurrentUserData();
      if (userData == null) {
        if (kDebugMode) {
          print('Impossible de récupérer les données utilisateur depuis Firestore');
        }
        return false;
      }

      if (kDebugMode) {
        print('État d\'authentification vérifié avec succès');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la vérification de l\'état d\'authentification: $e');
      }
      return false;
    }
  }

  // Inscription avec email et mot de passe - VERSION CORRIGÉE
  Future<Map<String, dynamic>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String role = 'Utilisateur',
    required String nom,
    required String departement,
    String? ufr,
  }) async {
    try {
      print('Tentative de création de compte pour: $email');

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Compte Firebase créé avec UID: ${result.user!.uid}');

      if (result.user != null) {
        // Créer le profil utilisateur dans Firestore
        Map<String, dynamic> userData = {
          'email': email,
          'fullName': fullName.isNotEmpty ? fullName : nom, // Utiliser nom si fullName est vide
          'role': role,
          'nom': nom,
          'departement': departement,
          'ufr': ufr,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        };

        // Choisir la collection selon le rôle
        String collection = (role.toLowerCase() == 'admin' || role.toLowerCase() == 'administrateur')
            ? 'administrateur'
            : 'utilisateurs';

        if (kDebugMode) {
          print('Sauvegarde dans la collection: $collection');
        }

        await _firestore
            .collection(collection)
            .doc(result.user!.uid)
            .set(userData);

        if (kDebugMode) {
          print('Données sauvegardées dans Firestore');
        }

        // Mettre à jour le displayName
        await result.user!.updateDisplayName(fullName.isNotEmpty ? fullName : nom);

        // Mettre en cache
        _cachedUserData = userData;
        _cachedUserRole = role;

        // Attendre un peu pour s'assurer que les données sont bien synchronisées
        await Future.delayed(const Duration(milliseconds: 500));

        // Vérifier que les données sont bien sauvegardées
        Map<String, dynamic>? verifyData = await getUserDataFromFirestore(result.user!.uid);
        if (verifyData != null) {
          if (kDebugMode) {
            print('Vérification réussie des données sauvegardées');
          }
          return {
            'success': true,
            'user': result.user,
            'role': role,
            'userData': userData,
            'message': 'Compte créé avec succès'
          };
        } else {
          if (kDebugMode) {
            print('Échec de la vérification des données sauvegardées');
          }
          return {
            'success': false,
            'message': 'Erreur lors de la sauvegarde du profil utilisateur',
            'user': result.user,
            'userData': null
          };
        }
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException: ${e.code} - ${e.message}');
      }
      return {
        'success': false,
        'message': _handleAuthException(e),
        'user': null,
        'userData': null
      };
    } catch (e) {
      if (kDebugMode) {
        print('Erreur inattendue: $e');
      }
      return {
        'success': false,
        'message': 'Une erreur inattendue s\'est produite: $e',
        'user': null,
        'userData': null
      };
    }

    return {
      'success': false,
      'message': 'Erreur de création de compte inconnue',
      'user': null,
      'userData': null
    };
  }

  // Réinitialisation du mot de passe
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Déconnexion avec nettoyage du cache
  Future<void> signOut() async {
    try {
      // Nettoyer le cache
      _cachedUserData = null;
      _cachedUserRole = null;

      await _auth.signOut();
      if (kDebugMode) {
        print('Déconnexion réussie et cache nettoyé');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la déconnexion: $e');
      }
      throw 'Erreur lors de la déconnexion';
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Obtenir le rôle en cache
  String? getCachedUserRole() {
    return _cachedUserRole;
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Chercher dans quelle collection se trouve l'utilisateur
      DocumentSnapshot adminDoc = await _firestore
          .collection('administrateur')
          .doc(uid)
          .get();

      if (adminDoc.exists) {
        await _firestore.collection('administrateur').doc(uid).update(data);
      } else {
        await _firestore.collection('utilisateurs').doc(uid).update(data);
      }

      // Mettre à jour le cache si nécessaire
      if (_cachedUserData != null) {
        _cachedUserData!.addAll(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour du profil: $e');
      }
      throw 'Erreur lors de la mise à jour du profil';
    }
  }

  // Navigation selon le rôle - VERSION AMÉLIORÉE
  static Future<void> navigateByRole(BuildContext context, String userRole) async {
    // Nettoyer le rôle : supprimer espaces et convertir en minuscules
    String cleanRole = userRole.trim().toLowerCase();
    print('Rôle détecté: "$userRole" -> Rôle nettoyé: "$cleanRole"');

    // Attendre un court délai pour s'assurer que l'état est stable
    await Future.delayed(const Duration(milliseconds: 100));

    if (!context.mounted) return;

    switch (cleanRole) {
      case 'administrateur':
      case 'admin':
        print('Redirection vers /admin pour le rôle $userRole');
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 'utilisateur':
      case 'user':
      case 'chef de département':
      case 'chef de département/coordonnateur':
      case 'chef de scolarité':
      case 'chef':
      case 'responsable pédagogique':
      case 'responsable':
      case 'directeur de patrimoine':
      case 'directeur':
      case 'directeur adjoint':
      case 'csaf':
        if (kDebugMode) {
          print('Redirection vers /user pour le rôle $userRole');
        }
        Navigator.pushReplacementNamed(context, '/user');
        break;
      default:
        if (kDebugMode) {
          print('Rôle inconnu: "$userRole" (nettoyé: "$cleanRole"), redirection vers /login');
        }
        Navigator.pushReplacementNamed(context, '/login');
        break;
    }
  }

  // Gestion des exceptions Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'invalid-credential':
        return 'Identifiants invalides';
      case 'invalid-email':
        return 'Format d\'email invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'operation-not-allowed':
        return 'Opération non autorisée';
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'requires-recent-login':
        return 'Veuillez vous reconnecter pour effectuer cette action';
      case 'network-request-failed':
        return 'Problème de connexion réseau. Vérifiez votre connexion internet.';
      case 'permission-denied':
        return 'Permissions insuffisantes. Contactez l\'administrateur';
      default:
        return 'Erreur d\'authentification: ${e.message}';
    }
  }

  // Méthodes utilitaires pour les rôles
  static bool isAdmin(String role) {
    return role.toLowerCase() == 'administrateur' || role.toLowerCase() == 'admin';
  }

  static bool isChef(String role) {
    return role.toLowerCase().contains('chef');
  }

  static bool isResponsable(String role) {
    return role.toLowerCase().contains('responsable');
  }

  static bool isDirecteur(String role) {
    return role.toLowerCase().contains('directeur');
  }

  static bool isCSAF(String role) {
    return role.toLowerCase() == 'csaf';
  }
}