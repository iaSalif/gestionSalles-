import 'package:flutter/material.dart';
import '../../../widgets/auth_wrapper.dart';
import '../../auth_services.dart';

class ChefDepartementDashboard extends StatelessWidget {
  const ChefDepartementDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      requiredRole: 'Chef de Département',
      child: ChefDepartementContent(),
    );
  }
}

class ChefDepartementContent extends StatefulWidget {
  const ChefDepartementContent({super.key});

  @override
  _ChefDepartementContentState createState() => _ChefDepartementContentState();
}

class _ChefDepartementContentState extends State<ChefDepartementContent> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _authService.getCurrentUserData();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Erreur lors du chargement des données: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - Chef de Département'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        // Retirer automaticBackButton et utiliser le drawer par défaut
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Actions pour les notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await _authService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 20),
                        SizedBox(width: 8),
                        Text('Profil'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, size: 20),
                        SizedBox(width: 8),
                        Text('Paramètres'),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Déconnexion',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      // Ajout du Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userData?['fullName'] ??
                        userData?['nom'] ??
                        'Chef de Département',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Département: ${userData?['departement'] ?? 'Non spécifié'}',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.schedule,
              title: 'Programmer Cours/TD',
              subtitle: 'Créer un nouveau cours/TD',
              onTap: () {
                Navigator.pop(context);
                // Navigation vers programmation cours/TD
              },
            ),
            _buildDrawerItem(
              icon: Icons.edit,
              title: 'Modifier Cours/TD',
              subtitle: 'Modifier un cours/TD existant',
              onTap: () {
                Navigator.pop(context);
                // Navigation vers modification cours/TD
              },
            ),
            _buildDrawerItem(
              icon: Icons.cancel,
              title: 'Annuler Cours/TD',
              subtitle: 'Annuler un cours/TD programmé',
              onTap: () {
                Navigator.pop(context);
                // Navigation vers annulation cours/TD
              },
            ),
            Divider(),
            _buildDrawerItem(
              icon: Icons.meeting_room,
              title: 'Consulter Occupation Salles',
              subtitle: 'Voir l\'occupation des salles',
              onTap: () {
                Navigator.pop(context);
                // Navigation vers occupation salles
              },
            ),
            _buildDrawerItem(
              icon: Icons.calendar_view_week,
              title: 'Générer un Planning',
              subtitle: 'Créer un planning complet',
              onTap: () {
                Navigator.pop(context);
                // Navigation vers génération planning
              },
            ),
            Divider(),
            _buildDrawerItem(
              icon: Icons.analytics,
              title: 'Statistiques',
              subtitle: 'Voir les rapports et statistiques',
              onTap: () {
                Navigator.pop(context);
                // Navigation vers statistiques
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Paramètres',
              subtitle: 'Configuration du système',
              onTap: () {
                Navigator.pop(context);
                // Navigation vers paramètres
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await _authService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte de bienvenue
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue,',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      userData?['fullName'] ??
                          userData?['nom'] ??
                          'Chef de Département',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Département: ${userData?['departement'] ?? 'Non spécifié'}',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Statistiques rapides
            Text(
              'Aperçu Rapide',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Salles Disponibles',
                    value: '12',
                    icon: Icons.meeting_room,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Réservations',
                    value: '8',
                    icon: Icons.calendar_today,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'En Attente',
                    value: '3',
                    icon: Icons.hourglass_empty,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Conflits',
                    value: '1',
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            SizedBox(height: 32),

            // Actions principales
            Text(
              'Actions Principales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  title: 'Gérer les Salles',
                  subtitle: 'Voir et modifier les salles',
                  icon: Icons.business,
                  color: Colors.blue,
                  onTap: () {
                    // Navigation vers gestion des salles
                  },
                ),
                _buildActionCard(
                  title: 'Planifier Cours',
                  subtitle: 'Créer un planning',
                  icon: Icons.schedule,
                  color: Colors.green,
                  onTap: () {
                    // Navigation vers planification
                  },
                ),
                _buildActionCard(
                  title: 'Rapports',
                  subtitle: 'Voir les statistiques',
                  icon: Icons.analytics,
                  color: Colors.purple,
                  onTap: () {
                    // Navigation vers rapports
                  },
                ),
                _buildActionCard(
                  title: 'Paramètres',
                  subtitle: 'Configuration',
                  icon: Icons.settings,
                  color: Colors.grey,
                  onTap: () {
                    // Navigation vers paramètres
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue.shade700, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      onTap: onTap,
      dense: true,
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
