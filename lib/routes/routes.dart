import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_salles/screens/auth/home_page.dart';
import 'package:gestion_salles/screens/auth/welcome_page.dart';
import 'package:gestion_salles/screens/auth/login_screen.dart';
import 'package:gestion_salles/screens/auth/sign_screen.dart';
import 'package:gestion_salles/screens/auth/logout_screen.dart';
import 'package:gestion_salles/widgets/auth_wrapper.dart';

import 'package:gestion_salles/services/screens/admin/admin_dashboard.dart';
import 'package:gestion_salles/services/screens/admin/right_management_screen.dart';
import 'package:gestion_salles/services/screens/admin/room_management_screen.dart';
import 'package:gestion_salles/services/screens/admin/ufr_management_screen.dart';
import 'package:gestion_salles/services/screens/admin/user_management_screen.dart';

import 'package:gestion_salles/services/screens/user/chef_departement_dashboard.dart';
import 'package:gestion_salles/services/screens/user/chef_scolarite_dashboard.dart';
import 'package:gestion_salles/services/screens/user/dashboard/dashboard_chef_scolarite_page.dart'; // ✅ Ajout

import 'package:gestion_salles/screens/devoirs/programmer_devoir_page.dart';
// import '../services/screens/user/csaf_dashboard.dart';
// import '../services/screens/user/responsable_pedagogique_dashboard.dart';
// import '../services/screens/user/directeur_patrimoine_dashboard.dart';

import '../services/auth_services.dart';

class AppRoutes {
  // Routes principales
  static const String home = '/MyHomePage';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String logout = '/logout';

  // Routes administrateur
  static const String adminDashboard = '/admin';
  static const String userManagement = '/admin/users';
  static const String roomManagement = '/admin/rooms';
  static const String ufrManagement = '/admin/ufr';
  static const String rightsManagement = '/admin/rights';

  // Routes utilisateur par rôle
  static const String departmentDashboard = '/department';
  static const String chefDepartmentDashboard = '/chefDepartment';
  static const String chefScolariteDashboard = '/chefScolarite';
  static const String chefScolariteDashboardFull = '/chefScolarite/dashboard'; // ✅ Ajout
  static const String csafDashboard = '/csaf';
  static const String responsablePedagogiqueDashboard = '/responsable-pedagogique';
  static const String directeurPatrimoineDashboard = '/directeur-patrimoine';

  // Routes spécifiques Chef de Scolarité
  static const String programmerDevoirPage = '/chefScolarite/programmer-devoir';
  static const String modifierDevoir = '/chefScolarite/modifier-devoir';
  static const String annulerDevoir = '/chefScolarite/annuler-devoir';
  static const String statistiquesScolarite = '/chefScolarite/statistiques';
  static const String historiqueScolarite = '/chefScolarite/historique';
  static const String parametresScolarite = '/chefScolarite/parametres';
  static const String gestionProgrammation = '/chefScolarite/gestion-programmation';


  // Routes spécifiques Directeur de Patrimoine
  static const String gererSalles = '/directeur-de-patrimoine/gerer-salles';
  static const String programmerRencontre = '/directeur-de-patrimoine/programmer-rencontre';
  static const String modifierRencontre = '/directeur-de-patrimoine/modifier-rencontre';
  static const String annulerRencontre = '/directeur-de-patrimoine/annuler-rencontre';

  // Routes spécifiques CSAF
  static const String programmerRencontreCSAF = '/csaf/programmer-rencontre';
  static const String modifierRencontreCSAF = '/csaf/modifier-rencontre';
  static const String annulerRencontreCSAF = '/csaf/annuler-rencontre';

  // Routes spécifiques Responsable Pédagogique
  static const String consulterProgrammation = '/responsable-pedagogique/consulter-programmation';
  static const String validerPlanning = '/responsable-pedagogique/valider-planning';
  static const String envoyerNotifications = '/responsable-pedagogique/envoyer-notifications';

  static Map<String, WidgetBuilder> get routes => <String, WidgetBuilder>{
    home: (context) => MyHomePage(title: home),
    welcome: (context) => const WelcomePage(),
    login: (context) => const LoginScreen(title: 'Connexion'),
    signup: (context) => const SignUpPage(),
    logout: (context) => const LogoutScreen(),

    // Routes admin
    adminDashboard: (context) => const AuthWrapper(
      requiredRole: 'administrateur',
      child: AdminDashboardPage(),
    ),
    userManagement: (context) => const AuthWrapper(
      requiredRole: 'administrateur',
      child: UserManagementPage(),
    ),
    ufrManagement: (context) => const AuthWrapper(
      requiredRole: 'administrateur',
      child: UFRManagementScreen(),
    ),
    rightsManagement: (context) => const AuthWrapper(
      requiredRole: 'administrateur',
      child: AccessRightsScreen(),
    ),

    // Routes utilisateurs
    chefDepartmentDashboard: (context) => const AuthWrapper(
      requiredRole: 'chefDepartment',
      child: ChefDepartementDashboard(),
    ),
    chefScolariteDashboard: (context) => const AuthWrapper(
      requiredRole: 'chefScolarite',
      child: ChefScolariteDashboard(),
    ),
    chefScolariteDashboardFull: (context) => const AuthWrapper(
      requiredRole: 'chefScolarite',
      child: DashboardChefScolaritePage(ufrId: '',), // ✅ Ajout du vrai dashboard dynamique
    ),

    // Dashboards temporaires
    csafDashboard: (context) => const AuthWrapper(
      requiredRole: 'csaf',
      child: PlaceholderDashboard(title: 'Dashboard CSAF', role: 'CSAF'),
    ),
    responsablePedagogiqueDashboard: (context) => const AuthWrapper(
      requiredRole: 'responsable-pedagogique',
      child: PlaceholderDashboard(
          title: 'Dashboard Responsable Pédagogique',
          role: 'Responsable Pédagogique'),
    ),
    directeurPatrimoineDashboard: (context) => const AuthWrapper(
      requiredRole: 'directeur-de-patrimoine',
      child: PlaceholderDashboard(
          title: 'Dashboard Directeur de Patrimoine',
          role: 'Directeur de Patrimoine'),
    ),

    // Spécifique Chef de Scolarité
    programmerDevoirPage: (context) => const AuthWrapper(
      requiredRole: 'chefScolarite',
      child: ProgrammerDevoirPage(),
    ),
    modifierDevoir: (context) => const AuthWrapper(
      requiredRole: 'chefScolarite',
      child: PlaceholderDashboard(title: 'Modifier Devoir', role: 'chefScolarite'),
    ),
    annulerDevoir: (context) => const AuthWrapper(
      requiredRole: 'chefScolarite',
      child: PlaceholderDashboard(title: 'Annuler Devoir', role: 'chefScolarite'),
    ),
    statistiquesScolarite: (context) => const AuthWrapper(
      requiredRole: 'chefScolarite',
      child: PlaceholderDashboard(title: 'Statistiques', role: 'chefScolarite'),
    ),
    historiqueScolarite: (context) => const AuthWrapper(
      requiredRole: 'chefScolarite',
      child: PlaceholderDashboard(title: 'Historique', role: 'chefScolarite'),
    ),
    parametresScolarite: (context) => const AuthWrapper(
      requiredRole: 'chefScolarite',
      child: PlaceholderDashboard(title: 'Paramètres', role: 'chefScolarite'),
    ),
  };

  // Méthode pour la navigation simple
  static void navigateTo(
      BuildContext context,
      String routeName, {
        Map<String, dynamic>? arguments,
      }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Méthode pour la navigation avec remplacement
  static void navigateAndReplace(
      BuildContext context,
      String routeName, {
        Map<String, dynamic>? arguments,
      }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Méthode pour la navigation en effaçant la pile
  static void navigateAndClearStack(
      BuildContext context,
      String routeName, {
        Map<String, dynamic>? arguments,
      }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }

  // Méthodes spécifiques pour l'authentification
  static void navigateToLogin(BuildContext context) {
    navigateAndClearStack(context, login);
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
          const SnackBar(
            content: Text('Déconnexion réussie'),
            backgroundColor: Colors.green,
          ),
        );
        navigateToLogin(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: $e'),
            backgroundColor: Colors.red,
          ),
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

  static void navigateToChefDepartmentDashboard(BuildContext context) {
    navigateAndClearStack(context, chefDepartmentDashboard);
  }

  // Méthodes spécifiques pour le Chef de Scolarité
  static void navigateToChefScolariteDashboard(BuildContext context) {
    navigateAndClearStack(context, chefScolariteDashboard);
  }

  static void navigateToProgrammerDevoir(BuildContext context) {
    navigateTo(context, programmerDevoirPage);
  }

  static void navigateToModifierDevoir(BuildContext context) {
    navigateTo(context, modifierDevoir);
  }

  static void navigateToAnnulerDevoir(BuildContext context) {
    navigateTo(context, annulerDevoir);
  }

  static void navigateToGestionProgrammation(BuildContext context) {
    navigateTo(context, gestionProgrammation);
  }

  // Méthodes pour CSAF
  static void navigateToCSAFDashboard(BuildContext context) {
    navigateAndClearStack(context, csafDashboard);
  }

  // Méthodes pour Responsable Pédagogique
  static void navigateToResponsablePedagogiqueDashboard(BuildContext context) {
    navigateAndClearStack(context, responsablePedagogiqueDashboard);
  }

  // Méthodes pour Directeur de Patrimoine
  static void navigateToDirecteurPatrimoineDashboard(BuildContext context) {
    navigateAndClearStack(context, directeurPatrimoineDashboard);
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

// Widget temporaire pour les dashboards non encore implémentés
class PlaceholderDashboard extends StatelessWidget {
  final String title;
  final String role;

  const PlaceholderDashboard({
    super.key,
    required this.title,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AppRoutes.performLogout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard,
              size: 100,
              color: Colors.blue.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              'Dashboard $role',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Cette interface sera bientôt disponible',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => AppRoutes.performLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}