import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_salles/services/screens/admin/right_management_screen.dart';
import 'package:gestion_salles/services/screens/admin/room_management_screen.dart';
import 'package:gestion_salles/services/screens/admin/statistics_screen.dart';
import 'package:gestion_salles/services/screens/admin/ufr_management_screen.dart';
import 'package:gestion_salles/services/screens/admin/user_management_screen.dart';
import 'package:gestion_salles/models/notification_model.dart';
import 'package:gestion_salles/routes/routes.dart';
import 'package:gestion_salles/widgets/auth_wrapper.dart';
import 'notification_management_screen.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Constantes pour éviter la recréation d'objets
  static const Color _primaryColor = Color(0xFF4A90E2);
  static const Color _secondaryColor = Color(0xFF357ABD);
  static const Color _backgroundColor = Color(0xFFF5F7FA);
  static const Color _textColor = Color(0xFF2E3A47);
  static const Color _cardColor = Colors.white;

  // Styles pré-définis pour éviter la recréation
  static const TextStyle _titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: _textColor,
  );

  static const TextStyle _headerTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const EdgeInsets _defaultPadding = EdgeInsets.all(20);
  static const EdgeInsets _sectionPadding = EdgeInsets.only(
    left: 20,
    right: 20,
    top: 20,
    bottom: 40,
  );

  // Index pour la navigation bottom
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Déconnexion réussie'),
            backgroundColor: Colors.green,
          ),
        );
        AppRoutes.navigateToLogin(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AuthWrapper(
      requiredRole: 'administrateur',
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        body: SingleChildScrollView(
          padding: _sectionPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 32),
              _buildOverviewSection(screenWidth),
              const SizedBox(height: 32),
              _buildSystemManagementSection(),
              const SizedBox(height: 32),
              const SizedBox(height: 80),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Tableau de bord Admin',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: _primaryColor,
      elevation: 0,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 35,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Administrateur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard,
                  title: 'Tableau de bord',
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.manage_accounts,
                  title: 'Gérer les utilisateurs',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToUserManagement();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.school,
                  title: 'Gérer les UFR',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToUFRManagement();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.meeting_room,
                  title: 'Gérer les salles',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToRoomManagement();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.security,
                  title: 'Droits d\'accès',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAccessRights();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToNotifications();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.analytics,
                  title: 'Statistiques',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToStatistics();
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Paramètres',
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Paramètres');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help,
                  title: 'Aide',
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Aide');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info,
                  title: 'À propos',
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('À propos de l\'application');
                  },
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: _buildDrawerItem(
              icon: Icons.logout,
              title: 'Déconnexion',
              iconColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _signOut();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? _primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: iconColor == Colors.red ? Colors.red : _textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 10,
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryColor, _secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bienvenue, Administrateur', style: _headerTitleStyle),
          SizedBox(height: 8),
          Text(
            'Système de gestion des salles',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vue d\'ensemble', style: _titleStyle),
        const SizedBox(height: 16),
        _buildStatsGrid(screenWidth),
      ],
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
                  icon: Icons.history,
                  label: 'Historique',
                  index: 1,
                  isSelected: _currentIndex == 1,
                  onTap: () => _onBottomNavTap(1),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: Icons.qr_code_scanner,
                  label: 'QR Code',
                  index: 2,
                  isSelected: _currentIndex == 2,
                  onTap: () => _onBottomNavTap(2),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: Icons.notifications,
                  label: 'Notifs',
                  index: 3,
                  isSelected: _currentIndex == 3,
                  onTap: () => _onBottomNavTap(3),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: Icons.more_horiz,
                  label: 'Autres',
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
          color:
              isSelected ? _primaryColor.withOpacity(0.1) : Colors.transparent,
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
        _showSnackBar('Accueil');
        break;
      case 1:
        _navigateToStatistics();
        break;
      case 2:
        _showSnackBar('Scanner QR Code');
        break;
      case 3:
        _navigateToNotifications();
        break;
      case 4:
        _showMoreOptions();
        break;
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Container(
            padding: _defaultPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plus d\'options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.settings, color: _primaryColor),
                  title: const Text('Paramètres'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Paramètres');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help, color: _primaryColor),
                  title: const Text('Aide'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Aide');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: _primaryColor),
                  title: const Text('À propos'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('À propos de l\'application');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Déconnexion'),
                  onTap: () {
                    Navigator.pop(context);
                    _signOut();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatsGrid(double screenWidth) {
    final cardWidth = screenWidth > 600 ? 200.0 : (screenWidth - 60) / 2;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: screenWidth > 600 ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: screenWidth > 600 ? 1.2 : 1.1,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildStatCard(
                'Utilisateurs',
                'Erreur',
                Icons.people,
                _primaryColor,
                cardWidth,
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatCard(
                'Utilisateurs',
                'Chargement...',
                Icons.people,
                _primaryColor,
                cardWidth,
              );
            }
            final userCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatCard(
              'Utilisateurs',
              '$userCount',
              Icons.people,
              _primaryColor,
              cardWidth,
            );
          },
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('salles').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildStatCard(
                'Salles',
                'Erreur',
                Icons.meeting_room,
                const Color(0xFFFF9800),
                cardWidth,
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatCard(
                'Salles',
                'Chargement...',
                Icons.meeting_room,
                const Color(0xFFFF9800),
                cardWidth,
              );
            }
            final salleCount =
                snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatCard(
              'Salles',
              '$salleCount',
              Icons.meeting_room,
              const Color(0xFFFF9800),
              cardWidth,
            );
          },
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('ufrs').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildStatCard(
                'UFR',
                'Erreur',
                Icons.school,
                const Color(0xFF9C27B0),
                cardWidth,
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatCard(
                'UFR',
                'Chargement...',
                Icons.school,
                const Color(0xFF9C27B0),
                cardWidth,
              );
            }
            final ufrCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatCard(
              'UFR',
              '$ufrCount',
              Icons.school,
              const Color(0xFF9C27B0),
              cardWidth,
            );
          },
        ),
        _buildNotificationStatCard(cardWidth),
      ],
    );
  }

  Widget _buildNotificationStatCard(double cardWidth) {
    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService().notificationsStream,
      builder: (context, snapshot) {
        final notificationCount = snapshot.hasData ? snapshot.data!.length : 0;
        final unreadCount =
            snapshot.hasData
                ? snapshot.data!.where((n) => !n.isRead).length
                : 0;

        return _buildStatCard(
          'Notifications',
          '$notificationCount${unreadCount > 0 ? ' ($unreadCount)' : ''}',
          Icons.notifications,
          const Color(0xFF9C27B0),
          cardWidth,
        );
      },
    );
  }

  Widget _buildSystemManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gestion système', style: _titleStyle),
        const SizedBox(height: 16),
        _buildFunctionGrid(),
      ],
    );
  }

  Widget _buildFunctionGrid() {
    final functions = [
      FunctionData(
        'Gérer les utilisateurs',
        Icons.manage_accounts,
        _primaryColor,
        _navigateToUserManagement,
      ),
      FunctionData(
        'Gérer les UFR',
        Icons.school,
        const Color(0xFF9C27B0),
        _navigateToUFRManagement,
      ),
      FunctionData(
        'Gérer les salles',
        Icons.meeting_room,
        const Color(0xFFFF9800),
        _navigateToRoomManagement,
      ),
      FunctionData(
        'Droits d\'accès',
        Icons.security,
        const Color(0xFF4CAF50),
        _navigateToAccessRights,
      ),
      FunctionData(
        'Notifications',
        Icons.notifications,
        const Color(0xFFF44336),
        _navigateToNotifications,
      ),
      FunctionData(
        'Statistiques',
        Icons.analytics,
        const Color(0xFF607D8B),
        _navigateToStatistics,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: functions.length,
      itemBuilder: (context, index) {
        final function = functions[index];
        return _buildFunctionCard(
          function.title,
          function.icon,
          function.color,
          function.onTap,
        );
      },
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    double width,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _buildCardDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  void _navigateToUserManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserManagementPage()),
    );
  }

  void _navigateToUFRManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UFRManagementScreen()),
    );
  }

  void _navigateToRoomManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RoomManagementScreen(ufrId: null),
      ),
    );
  }

  void _navigateToAccessRights() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccessRightsScreen()),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationManagementScreen()),
    );
  }

  void _navigateToStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StatisticsScreen()),
    );
  }

  void _addNewUser() {
    _showSnackBar('Ajouter un nouvel utilisateur');
  }

  void _sendNotification() {
    _showSnackBar('Envoyer une notification');
    _showNotificationDialog();
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController messageController = TextEditingController();

        return AlertDialog(
          title: const Text('Envoyer une notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _sendNotificationToUsers(
                  titleController.text,
                  messageController.text,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendNotificationToUsers(String title, String message) async {
    if (title.isEmpty || message.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'senderId': FirebaseAuth.instance.currentUser?.uid ?? '',
        'sender': FirebaseAuth.instance.currentUser?.email ?? 'Administrateur',
        'isRead': false,
        'type': 'admin_broadcast',
        'priority': 'normal',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Notification envoyée avec succès');
    } catch (e) {
      _showSnackBar('Erreur lors de l\'envoi: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}

class FunctionData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  FunctionData(this.title, this.icon, this.color, this.onTap);
}

class NotificationService {
  Stream<List<NotificationModel>> get notificationsStream {
    return FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return NotificationModel(
                  id: doc.id,
                  title: data['title'] ?? '',
                  message: data['message'] ?? '',
                  timestamp:
                      (data['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                  senderId: data['senderId'] ?? '',
                  sender: data['sender'] ?? '',
                  isRead: data['isRead'] ?? false,
                  type: data['type'] ?? 'general',
                  priority: data['priority'] ?? 'normal',
                  createdAt:
                      (data['createdAt'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                );
              }).toList(),
        );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String senderId;
  final String sender;
  final bool isRead;
  final String type;
  final String priority;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.senderId,
    required this.sender,
    required this.isRead,
    required this.type,
    required this.priority,
    required this.createdAt,
  });
}
