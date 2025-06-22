import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../routes/routes.dart';

class ChefScolariteDashboard extends StatefulWidget {
  const ChefScolariteDashboard({super.key});

  @override
  State<ChefScolariteDashboard> createState() => _ChefScolariteDashboardState();
}

class _ChefScolariteDashboardState extends State<ChefScolariteDashboard> {
  static const Color _primaryColor = Color(0xFF3F51B5);
  int _currentIndex = 0;
  int _nbDevoirs = 0;
  int _nbSallesUfr = 0;
  String ufrId = 'UFR-ST';

  @override
  void initState() {
    super.initState();
    _chargerStatistiques();
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Déconnexion réussie'), backgroundColor: Colors.green),
        );
        AppRoutes.navigateToLogin(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _chargerStatistiques() async {
    final devoirs = await FirebaseFirestore.instance
        .collection('devoirs')
        .where('ufr_id', isEqualTo: ufrId)
        .get();

    final salles = await FirebaseFirestore.instance
        .collection('salles')
        .where('ufr_id', isEqualTo: ufrId)
        .get();

    setState(() {
      _nbDevoirs = devoirs.docs.length;
      _nbSallesUfr = salles.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Chef de Scolarité';
    final lastLogin = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        backgroundColor: _primaryColor,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _chargerStatistiques),
        ],
      ),
      drawer: _buildDrawer(user),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AppRoutes.navigateTo(context, AppRoutes.programmerDevoirPage),
        label: const Text('Nouveau Devoir'),
        icon: const Icon(Icons.add),
        backgroundColor: _primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWelcomeCard(userName, lastLogin),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment, color: _primaryColor),
                    title: Text("$_nbDevoirs devoirs"),
                    subtitle: const Text("programmés"),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.meeting_room, color: _primaryColor),
                    title: Text("$_nbSallesUfr salles"),
                    subtitle: const Text("disponibles"),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Actions Rapides", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildQuickActions(),
          const SizedBox(height: 20),
          const Text("Historique des programmations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildHistoriqueDevoirs(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildWelcomeCard(String userName, DateTime lastLogin) {
    return Card(
      color: _primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bonjour, $userName', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Gérez efficacement les devoirs et examens", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text("Dernière connexion: ${lastLogin.day}/${lastLogin.month}/${lastLogin.year} à ${lastLogin.hour}:${lastLogin.minute}", style: const TextStyle(color: Colors.white70)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _actionButton(Icons.add_task, "Programmer\nDevoir", Colors.green, AppRoutes.programmerDevoirPage),
        _actionButton(Icons.edit, "Modifier\nDevoir", Colors.orange, AppRoutes.gestionProgrammation),
        _actionButton(Icons.cancel, "Annuler\nDevoir", Colors.red, AppRoutes.gestionProgrammation),
        _actionButton(Icons.bar_chart, "Statistiques", Colors.blue, AppRoutes.statistiquesScolarite),
        _actionButton(Icons.history, "Historique\nDevoirs", Colors.purple, AppRoutes.historiqueScolarite),
        _actionButton(Icons.meeting_room, "Occupation\nSalles", Colors.teal, AppRoutes.roomManagement),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, String route) {
    return GestureDetector(
      onTap: () => AppRoutes.navigateTo(context, route),
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) - 32,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoriqueDevoirs() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('devoirs')
          .where('ufr_id', isEqualTo: ufrId)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text("Aucune activité récente");
        }
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.book_online, color: _primaryColor),
                title: Text(data['titre'] ?? ''),
                subtitle: Text("Salle: ${data['salle_id']} - Date: ${data['date']} à ${data['heure']}"),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDrawer(User? user) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: _primaryColor),
            accountName: const Text('Chef de Scolarité'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: _primaryColor),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Tableau de bord'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() => _currentIndex = index);
        switch (index) {
          case 1:
            AppRoutes.navigateTo(context, AppRoutes.historiqueScolarite);
            break;
          case 2:
            _showSnackBar('QR Code');
            break;
          case 3:
            _showSnackBar('Notifications');
            break;
          default:
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR Code'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifs'),
      ],
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: _primaryColor),
      );
    }
  }
}
