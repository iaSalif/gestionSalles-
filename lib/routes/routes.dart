import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_salles/screens/auth/home_page.dart';
import 'package:gestion_salles/screens/auth/welcome_page.dart';
import 'package:gestion_salles/screens/auth/login_screen.dart';
import 'package:gestion_salles/screens/auth/sign_screen.dart';
import 'package:gestion_salles/services/screens/User/departement_dashboard.dart';
import 'package:gestion_salles/services/screens/admin/admin_dashboard.dart';
import 'package:gestion_salles/services/screens/admin/right_management_screen.dart';
import 'package:gestion_salles/services/screens/admin/room_management_screen.dart';
import 'package:gestion_salles/services/screens/admin/ufr_management_screen.dart';
import 'package:gestion_salles/services/screens/admin/user_management_screen.dart';
import '../screens/auth/logout_screen.dart';

// Page temporaire pour tester la navigation
class TestPage extends StatelessWidget {
  final String title;
  const TestPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Colors.orange.shade600,
            ),
            const SizedBox(height: 20),
            Text(
              'Page de test: $title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Cette page est en cours de développement',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppRoutes {
  // Routes principales
  static const String home = '/MyHomePage';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String logout = '/logout'; // Nouvelle constante pour la déconnexion
  // Routes administrateur
  static const String adminDashboard = '/admin';
  static const String userManagement = '/admin/users';
  static const String roomManagement = '/admin/rooms';
  static const String ufrManagement = '/admin/ufr';
  static const String rightsManagement = '/admin/rights';
  static const String reservationManagement = '/admin/reservations';
  static const String reports = '/admin/reports';
  static const String notifications = '/admin/notifications';
  static const String statistics = '/admin/statistics';
  static const String notFound = '/404';

  // Routes utilisateur
  //static const String userDashboard = '/user/d';
  static const String departmentDashboard = '/department';

  // Définition des routes
  static Map<String, WidgetBuilder> get routes => <String, WidgetBuilder>{
    // Routes principales
    home: (context) => MyHomePage(title: home),
    welcome: (context) => const WelcomePage(),
    login: (context) => const LoginScreen(title: 'Connexion'),
    signup: (context) => const SignUpPage(),
    logout: (context) => const LogoutScreen(),

    // Routes administrateur
    adminDashboard: (context) => const AdminDashboardPage(),
    userManagement: (context) => const UserManagementPage(),
    ufrManagement: (context) => const UFRManagementScreen(),
    rightsManagement: (context) => const AccessRightsScreen(),

    // Routes utilisateur
    //userDashboard: (context) => const userDashboard,
    departmentDashboard: (context) =>  DepartementDashboard(),

    // Pages temporaires en attendant l'implémentation
    reservationManagement: (context) => const TestPage(title: 'Gestion des Réservations'),
    reports: (context) => const TestPage(title: 'Rapports et Statistiques'),
    notifications: (context) => const TestPage(title: 'Gestion des Notifications'),
    statistics: (context) => const TestPage(title: 'Statistiques'),
  };



  // Méthode pour la navigation simple
  static void navigateTo(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Méthode pour la navigation avec remplacement
  static void navigateAndReplace(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Méthode pour la navigation en effaçant la pile
  static void navigateAndClearStack(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }

  // Méthodes spécifiques pour l'authentification
  static void navigateToLogin(BuildContext context) {
    navigateAndClearStack(context, login); // Modifié pour vider la pile
  }

  static void navigateToSignup(BuildContext context) {
    navigateTo(context, signup);
  }

  static void navigateToHome(BuildContext context) {
    navigateAndClearStack(context, home);
  }

  // Méthode pour la déconnexion
  static Future<void> performLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Déconnexion réussie'), backgroundColor: Colors.green),
        );
        navigateToLogin(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Méthodes spécifiques pour l'administration
  static void navigateToAdminDashboard(BuildContext context) {
    navigateAndClearStack(context, adminDashboard);
  }

  static void navigateToUserManagement(BuildContext context) {
    navigateTo(context, userManagement);
  }

  static void navigateToRoomManagement(BuildContext context, {String? ufrId}) {
    navigateTo(context, roomManagement, arguments: {'ufrId': ufrId});
  }

  static void navigateToUfrManagement(BuildContext context) {
    navigateTo(context, ufrManagement);
  }

  static void navigateToRightsManagement(BuildContext context) {
    navigateTo(context, rightsManagement);
  }

  static void navigateToReservationManagement(BuildContext context) {
    navigateTo(context, reservationManagement);
  }

  static void navigateToReports(BuildContext context) {
    navigateTo(context, reports);
  }

  static void navigateToNotifications(BuildContext context) {
    navigateTo(context, notifications);
  }

  static void navigateToStatistics(BuildContext context) {
    navigateTo(context, statistics);
  }

  // Méthodes spécifiques pour les utilisateurs
  //static void navigateToUserDashboard(BuildContext context) {
    //navigateAndClearStack(context, userDashboard);
  //}

  static void navigateToDepartmentDashboard(BuildContext context) {
    navigateAndClearStack(context, departmentDashboard);
  }

  // Méthode pour vérifier si une route existe
  static bool routeExists(String routeName) {
    return routes.containsKey(routeName);
  }

  // Gestion des routes inexistantes
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (routes.containsKey(settings.name)) {
      return MaterialPageRoute(
        builder: routes[settings.name]!,
        settings: settings,
      );
    }

    switch (settings.name) {
      case roomManagement:
        return MaterialPageRoute(
          builder: (context) => Builder(
            builder: (context) {
              final args = settings.arguments as Map<String, dynamic>?;
              final ufrId = args?['ufrId'] as String?;
              return RoomManagementScreen(ufrId: ufrId);
            },
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Page introuvable'),
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 100,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '404',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Page non trouvée: ${settings.name}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        home,
                            (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Retour à l\'accueil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          settings: settings,
        );
    }
  }

  static void handleNavigationError(BuildContext context, String errorMessage) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}