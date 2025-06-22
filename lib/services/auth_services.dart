import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../routes/routes.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔐 Création de compte
  Future<Map<String, dynamic>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required String nom,
    required String departement,
    String? ufr,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception("Utilisateur non trouvé après création.");

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'fullName': fullName,
        'role': role,
        'nom': nom,
        'departement': departement,
        'ufr': ufr,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'userId': user.uid};
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'Erreur Firebase lors de la création du compte.'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// 🔐 Connexion
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception("Utilisateur introuvable après connexion");

      final userData = await _firestore.collection('users').doc(user.uid).get();
      if (!userData.exists) throw Exception("Aucune donnée utilisateur trouvée");

      return {'success': true, 'userData': userData.data()};
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'Erreur Firebase lors de la connexion.'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// 🔍 Obtenir les données actuelles
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userData = await _firestore.collection('users').doc(user.uid).get();
    return userData.data();
  }

  /// ✅ Vérifie si l'utilisateur est connecté
  Future<bool> verifyAuthenticationState() async {
    return _auth.currentUser != null;
  }

  /// ✅ Récupère l'utilisateur Firebase actuel
  User? get currentUser => _auth.currentUser;

  /// 🚪 Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 🔁 Redirection selon le rôle
  static String getTargetRouteForRole(String role) {
    final cleanRole = role.toLowerCase().trim().replaceAll(' ', '-');

    switch (cleanRole) {
      case 'administrateur':
        return AppRoutes.adminDashboard;
      case 'chef-departement':
      case 'chefdepartement-coordonnateur':
        return AppRoutes.chefDepartmentDashboard;
      case 'chefscolarite':
      case 'chefscolarité':
        return AppRoutes.chefScolariteDashboard;
      case 'csaf':
        return AppRoutes.csafDashboard;
      case 'responsable-pedagogique':
      case 'responsablepédagogique':
        return AppRoutes.responsablePedagogiqueDashboard;
      case 'directeurpatrimoine':
        return AppRoutes.directeurPatrimoineDashboard;
      case 'utilisateur':
        return AppRoutes.departmentDashboard;
      default:
        return AppRoutes.login;
    }
  }

  /// 🚀 Navigation auto selon rôle
  static Future<void> navigateByRole(BuildContext context, String userRole) async {
    if (!context.mounted) return;

    final targetRoute = getTargetRouteForRole(userRole);
    final navigator = Navigator.maybeOf(context);

    if (navigator != null && ModalRoute.of(context)?.settings.name != targetRoute) {
      navigator.pushNamedAndRemoveUntil(targetRoute, (route) => false);
    }
  }

  // ========================================
  // ✅ Vérification des rôles utilisateurs
  // ========================================

  static bool isAdmin(String role) {
    final r = role.toLowerCase().trim().replaceAll(' ', '-');
    return r == 'administrateur' || r == 'admin';
  }

  static bool isChefDepartement(String role) {
    final r = role.toLowerCase().trim().replaceAll(' ', '-');
    return r == 'chef-departement' || r == 'chefdepartement';
  }

  static bool isChefDepartementCoordonnateur(String role) {
    final r = role.toLowerCase().trim().replaceAll(' ', '-');
    return r == 'chefdepartement-coordonnateur';
  }

  static bool isChefScolarite(String role) {
    final r = role.toLowerCase().trim().replaceAll(' ', '-');
    return r == 'chefscolarite' || r == 'chefscolarité';
  }

  static bool isResponsablePedagogique(String role) {
    final r = role.toLowerCase().trim().replaceAll(' ', '-');
    return r == 'responsablepedagogique' || r == 'responsable-pedagogique';
  }

  static bool isCSAF(String role) {
    final r = role.toLowerCase().trim().replaceAll(' ', '-');
    return r == 'csaf';
  }

  static bool isDirecteurPatrimoine(String role) {
    final r = role.toLowerCase().trim().replaceAll(' ', '-');
    return r == 'directeurpatrimoine';
  }

  static bool isUtilisateur(String role) {
    final r = role.toLowerCase().trim().replaceAll(' ', '-');
    return r == 'utilisateur';
  }
}
