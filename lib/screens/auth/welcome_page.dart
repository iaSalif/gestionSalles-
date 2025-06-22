import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestion_salles/screens/auth/login_screen.dart';
import 'package:gestion_salles/screens/auth/sign_screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgrounds/login_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ✅ Overlay with content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ Titre animé
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      "Bienvenue",
                      style: GoogleFonts.montserrat(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E88E5), // Couleur bleue UNZ
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ Carrousel animé
                  FadeInUp(
                    duration: const Duration(milliseconds: 1200),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 100,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        enlargeCenterPage: true,
                        viewportFraction: 1.0,
                      ),
                      items: [
                        "Système de gestion des salles avec vérification automatique d'identité",
                        "Optimisation des programmations de cours et devoirs",
                        "Réservation intelligente selon la disponibilité",
                        "Priorité automatique pour les évaluations"
                      ].map((text) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Text(
                              text,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.robotoSlab(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                shadows: [
                                  const Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // ✅ Bouton Se connecter
                  FadeInUp(
                    duration: const Duration(milliseconds: 1400),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const LoginScreen(title: 'Se connecter'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E88E5),
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Color(0xFF1E88E5)),
                          ),
                        ),
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Bouton S'inscrire
                  FadeInUp(
                    duration: const Duration(milliseconds: 1600),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
