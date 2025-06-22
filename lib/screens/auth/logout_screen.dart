import 'package:flutter/material.dart';

import 'package:gestion_salles/routes/routes.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  bool _isLoggingOut = false; // État pour suivre la déconnexion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Déconnexion')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Voulez-vous vraiment vous déconnecter ?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_isLoggingOut)
              const CircularProgressIndicator() // Indicateur de chargement
            else
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoggingOut = true;
                  });
                  await AppRoutes.performLogout(context);
                  setState(() {
                    _isLoggingOut = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Oui, me déconnecter'),
              ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Retour à la page précédente
              },
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }
}
