import 'package:flutter/material.dart';

/// Couleurs officielles de l'Université Nazi Boni (UNZ)
class UNZColors {
  // Couleurs principales UNZ
  static const Color primaryBlue = Color(0xFF1E3A8A); // Bleu principal UNZ
  static const Color secondaryBlue = Color(0xFF3B82F6); // Bleu secondaire
  static const Color accentGold = Color(0xFFFFB800); // Or/Jaune académique
  static const Color darkBlue = Color(0xFF1E40AF); // Bleu foncé

  // Couleurs fonctionnelles
  static const Color success = Color(0xFF10B981); // Vert succès
  static const Color warning = Color(0xFFF59E0B); // Orange avertissement
  static const Color error = Color(0xFFEF4444); // Rouge erreur
  static const Color info = Color(0xFF3B82F6); // Bleu information

  // Couleurs neutres
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF8FAFC);
  static const Color mediumGray = Color(0xFF64748B);
  static const Color darkGray = Color(0xFF334155);
  static const Color background = Color(0xFFF1F5F9);

  // Gradients UNZ
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFFC107)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Couleurs avec opacité pour les cartes
  static Color cardShadow = primaryBlue.withOpacity(0.1);
  static Color primaryLight = primaryBlue.withOpacity(0.1);
  static Color successLight = success.withOpacity(0.1);
  static Color warningLight = warning.withOpacity(0.1);
  static Color errorLight = error.withOpacity(0.1);
}
