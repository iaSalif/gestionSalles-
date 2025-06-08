import 'package:flutter/material.dart';
import 'package:gestion_salles/screens/cours/annuler_cours_page.dart';
import 'package:gestion_salles/screens/cours/modifier_cours_page.dart';
import 'package:gestion_salles/screens/cours/programmer_cours_page.dart'; // Ajoutez cette ligne

class DepartementDashboard extends StatefulWidget {
  const DepartementDashboard({super.key});

  @override
  _DepartementDashboardState createState() => _DepartementDashboardState();
}

class _DepartementDashboardState extends State<DepartementDashboard> {
  // Constantes de couleurs UNZ
  static const Color _primaryColor = Color(0xFF1E3A8A);
  static const Color _goldColor = Color(0xFFFFB800);
  static const Color _backgroundColor = Color(0xFFF1F5F9);

  // Index pour la navigation bottom
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _goldColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.school,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chef de Département',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Université Norbert Zongo',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de bienvenue avec design UNZ
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _goldColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.dashboard,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Gestion des cours et planification académique',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '📅 ${_getCurrentDate()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 35),

            // Section Gestion des Cours avec style UNZ
            _buildSectionHeader('Gestion des Cours/TD', Icons.book),
            SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.add_box,
                    title: 'Programmer\nCours/TD',
                    color: Color(0xFF10B981),
                    onTap: () => _navigateToProgrammerCours(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.edit_note,
                    title: 'Modifier\nCours/TD',
                    color: Color(0xFFF59E0B),
                    onTap: () => _navigateToModifierCours(),
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.cancel_outlined,
                    title: 'Annuler\nCours/TD',
                    color: Color(0xFFEF4444),
                    onTap: () => _navigateToAnnulerCours(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.history,
                    title: 'Historique\nCours',
                    color: Color(0xFF3B82F6),
                    onTap: () => _navigateToHistorique(),
                  ),
                ),
              ],
            ),

            SizedBox(height: 35),

            // Section Planification avec style UNZ
            _buildSectionHeader('Planification', Icons.calendar_month),
            SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.visibility,
                    title: 'Consulter\nOccupation',
                    color: Color(0xFF3B82F6),
                    onTap: () => _navigateToConsulterOccupation(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.auto_awesome,
                    title: 'Générer\nPlanning',
                    color: Color(0xFF8B5CF6),
                    onTap: () => _navigateToGenererPlanning(),
                  ),
                ),
              ],
            ),

            SizedBox(height: 35),

            // Statistiques avec design UNZ amélioré
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.analytics,
                          color: _primaryColor,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Résumé du jour',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: _buildStatItem('Cours', '12', Color(0xFF3B82F6), Icons.book),
                      ),
                      Expanded(
                        child: _buildStatItem('TD', '8', Color(0xFF10B981), Icons.groups),
                      ),
                      Expanded(
                        child: _buildStatItem('Salles', '15', Color(0xFFF59E0B), Icons.meeting_room),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 80), // Espace pour le bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildBottomNavItem(
                  icon: Icons.home,
                  label: 'Accueil',
                  index: 0,
                  isSelected: _currentIndex == 0,
                  onTap: () => _onBottomNavTap(0),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: Icons.schedule,
                  label: 'Planning',
                  index: 1,
                  isSelected: _currentIndex == 1,
                  onTap: () => _onBottomNavTap(1),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: Icons.book,
                  label: 'Cours',
                  index: 2,
                  isSelected: _currentIndex == 2,
                  onTap: () => _onBottomNavTap(2),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: Icons.analytics,
                  label: 'Stats',
                  index: 3,
                  isSelected: _currentIndex == 3,
                  onTap: () => _onBottomNavTap(3),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: Icons.more_horiz,
                  label: 'Plus',
                  index: 4,
                  isSelected: _currentIndex == 4,
                  onTap: () => _onBottomNavTap(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? _primaryColor : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _primaryColor : Colors.grey[600],
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
      // Accueil - déjà sur la page
        _showSnackBar('Accueil');
        break;
      case 1:
      // Planning
        _navigateToGenererPlanning();
        break;
      case 2:
      // Cours - Menu de gestion des cours
        _showCoursMenu();
        break;
      case 3:
      // Statistiques
        _showSnackBar('Statistiques du département');
        break;
      case 4:
      // Plus d'options
        _showMoreOptions();
        break;
    }
  }

  void _showCoursMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Cours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.add_box, color: Color(0xFF10B981)),
              title: const Text('Programmer Cours/TD'),
              onTap: () {
                Navigator.pop(context);
                _navigateToProgrammerCours();
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_note, color: Color(0xFFF59E0B)),
              title: const Text('Modifier Cours/TD'),
              onTap: () {
                Navigator.pop(context);
                _navigateToModifierCours();
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel_outlined, color: Color(0xFFEF4444)),
              title: const Text('Annuler Cours/TD'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAnnulerCours();
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Color(0xFF3B82F6)),
              title: const Text('Historique des cours'),
              onTap: () {
                Navigator.pop(context);
                _navigateToHistorique();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plus d\'options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.visibility, color: _primaryColor),
              title: const Text('Consulter Occupation'),
              onTap: () {
                Navigator.pop(context);
                _navigateToConsulterOccupation();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: _primaryColor),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Paramètres');
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: _primaryColor),
              title: const Text('Aide'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Aide');
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: _primaryColor),
              title: const Text('À propos'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('À propos de l\'application');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primaryColor,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: _primaryColor,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // Méthodes de navigation - Navigation implémentée
  void _navigateToProgrammerCours() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProgrammerCoursPage()),
    );
  }

  void _navigateToModifierCours() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ModifierCoursPage()),
    );
  }

  void _navigateToAnnulerCours() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnnulerCoursPage())
    );
  }

  void _navigateToHistorique() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Historique - À implémenter')),
        body: Center(child: Text('Page en cours de développement')),
      )),
    );
  }

  void _navigateToConsulterOccupation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Consulter Occupation - À implémenter')),
        body: Center(child: Text('Page en cours de développement')),
      )),
    );
  }

  void _navigateToGenererPlanning() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Générer Planning - À implémenter')),
        body: Center(child: Text('Page en cours de développement')),
      )),
    );
  }
}