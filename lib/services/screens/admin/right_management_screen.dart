import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AccessRightsScreen extends StatefulWidget {
  const AccessRightsScreen({super.key});

  @override
  State<AccessRightsScreen> createState() => _AccessRightsScreenState();
}

class _AccessRightsScreenState extends State<AccessRightsScreen>
    with SingleTickerProviderStateMixin {
  // Constantes de couleurs cohérentes avec le dashboard
  static const Color _primaryColor = Color(0xFF4A90E2);
  static const Color _backgroundColor = Color(0xFFF5F7FA);
  static const Color _textColor = Color(0xFF2E3A47);
  static const Color _cardColor = Colors.white;
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _warningColor = Color(0xFFFF9800);
  static const Color _errorColor = Color(0xFFF44336);

  late TabController _tabController;
  String _selectedRole = 'Tous';
  String _searchQuery = '';
  String _selectedAuditAction = 'Toutes';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRoleManagementTab(),
                _buildPermissionsTab(),
                _buildAuditTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _textColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Gestion des droits d\'accès',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshData,
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: const CircleAvatar(
            backgroundColor: _primaryColor,
            child: Icon(Icons.security, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: _cardColor,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Column(
        children: [
          _buildSearchAndFilter(),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: _primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: _primaryColor,
            tabs: const [
              Tab(icon: Icon(Icons.manage_accounts, size: 20), text: 'Rôles'),
              Tab(icon: Icon(Icons.security, size: 20), text: 'Permissions'),
              Tab(icon: Icon(Icons.history, size: 20), text: 'Audit'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Rechercher un utilisateur...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primaryColor),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              color: Colors.grey[50],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRole,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                items:
                    _getRoleOptions().map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(
                          role,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleManagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoleOverview(),
          const SizedBox(height: 24),
          _buildUserRolesList(),
        ],
      ),
    );
  }

  Widget _buildRoleOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vue d\'ensemble des rôles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Ajuster la grille selon la largeur disponible
              int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
              double childAspectRatio = constraints.maxWidth > 600 ? 3.0 : 2.5;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildRoleStatCard('Administrateurs', '1', _errorColor),
                  _buildRoleStatCard(
                    'Chefs de département',
                    '8',
                    _primaryColor,
                  ),
                  _buildRoleStatCard('Chefs de scolarité', '5', _successColor),
                  _buildRoleStatCard('Resp. pédagogiques', '12', _warningColor),
                  _buildRoleStatCard('Dir. patrimoine', '2', Colors.purple),
                  _buildRoleStatCard('Membres CSAF', '6', Colors.teal),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleStatCard(String role, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                role,
                style: TextStyle(
                  fontSize: 18,
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRolesList() {
    final users = _getFilteredUsers();

    return Container(
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Attribution des rôles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserRoleTile(user);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserRoleTile(UserRole user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
        child: Text(
          user.name.substring(0, 2).toUpperCase(),
          style: TextStyle(
            color: _getRoleColor(user.role),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w600, color: _textColor),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          // Utiliser Wrap au lieu de Row pour éviter les débordements
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.role,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getRoleColor(user.role),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      user.isActive
                          ? _successColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.isActive ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    fontSize: 10,
                    color: user.isActive ? _successColor : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleUserAction(value, user),
        itemBuilder:
            (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Modifier le rôle'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: user.isActive ? 'deactivate' : 'activate',
                child: Row(
                  children: [
                    Icon(
                      user.isActive ? Icons.block : Icons.check_circle,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(user.isActive ? 'Désactiver' : 'Activer'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'permissions',
                child: Row(
                  children: [
                    Icon(Icons.security, size: 18),
                    SizedBox(width: 8),
                    Text('Permissions'),
                  ],
                ),
              ),
            ],
      ),
    );
  }

  Widget _buildPermissionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildPermissionMatrix()],
      ),
    );
  }

  Widget _buildPermissionMatrix() {
    return Container(
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Matrice des permissions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('permissions')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    'Erreur lors du chargement des permissions',
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                // Fallback sur données statiques si Firestore est vide
                final List<Map<String, dynamic>> permissionsData =
                    snapshot.hasData && snapshot.data!.docs.isNotEmpty
                        ? snapshot.data!.docs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .toList()
                        : [
                          {
                            'role': 'Administrateur',
                            'users': true,
                            'salles': true,
                            'ufr': true,
                            'cours_td': true,
                            'devoirs': true,
                            'plannings': true,
                            'systeme': true,
                          },
                          {
                            'role': 'Chef de département',
                            'users': true,
                            'salles': true,
                            'ufr': true,
                            'cours_td': true,
                            'devoirs': true,
                            'plannings': true,
                            'systeme': false,
                          },
                          {
                            'role': 'Chef de scolarité',
                            'users': true,
                            'salles': true,
                            'ufr': false,
                            'cours_td': true,
                            'devoirs': true,
                            'plannings': true,
                            'systeme': false,
                          },
                          {
                            'role': 'Responsable pédagogique',
                            'users': false,
                            'salles': false,
                            'ufr': false,
                            'cours_td': true,
                            'devoirs': true,
                            'plannings': false,
                            'systeme': false,
                          },
                          {
                            'role': 'Directeur du patrimoine',
                            'users': false,
                            'salles': true,
                            'ufr': false,
                            'cours_td': false,
                            'devoirs': false,
                            'plannings': false,
                            'systeme': false,
                          },
                          {
                            'role': 'Membre CSAF',
                            'users': false,
                            'salles': false,
                            'ufr': false,
                            'cours_td': false,
                            'devoirs': false,
                            'plannings': false,
                            'systeme': false,
                          },
                        ];

                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Rôle')),
                    DataColumn(label: Text('Utilisateurs')),
                    DataColumn(label: Text('Salles')),
                    DataColumn(label: Text('UFR')),
                    DataColumn(label: Text('Cours/TD')),
                    DataColumn(
                      label: Text('Devoirs'),
                    ), // Correction de "Dvoirs"
                    DataColumn(label: Text('Plannings')),
                    DataColumn(label: Text('Système')),
                  ],
                  rows:
                      permissionsData.map((data) {
                        return DataRow(
                          cells: [
                            DataCell(Text(data['role'])),
                            DataCell(
                              _buildPermissionIcon(data['users'] ?? false),
                            ),
                            DataCell(
                              _buildPermissionIcon(data['salles'] ?? false),
                            ),
                            DataCell(
                              _buildPermissionIcon(data['ufr'] ?? false),
                            ),
                            DataCell(
                              _buildPermissionIcon(data['cours_td'] ?? false),
                            ),
                            DataCell(
                              _buildPermissionIcon(data['devoirs'] ?? false),
                            ),
                            DataCell(
                              _buildPermissionIcon(data['plannings'] ?? false),
                            ),
                            DataCell(
                              _buildPermissionIcon(data['systeme'] ?? false),
                            ),
                          ],
                        );
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionIcon(bool hasPermission) {
    return Icon(
      hasPermission ? Icons.check_circle : Icons.cancel,
      color: hasPermission ? _successColor : _errorColor,
      size: 20,
    );
  }

  Widget _buildAuditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuditFilters(),
          const SizedBox(height: 20),
          _buildAuditList(),
        ],
      ),
    );
  }

  Widget _buildAuditFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedAuditAction,
                  decoration: const InputDecoration(
                    labelText: 'Type d\'action',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  isExpanded: true,
                  items:
                      [
                            'Toutes',
                            'Connexion',
                            'Modification rôle',
                            'Création compte',
                            'Suppression',
                          ]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAuditAction = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Période',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _selectDateRange(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditList() {
    final auditLogs = _getAuditLogs();

    return Container(
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Journal d\'audit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: auditLogs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = auditLogs[index];
              return _buildAuditLogTile(log);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogTile(AuditLog log) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: _getActionColor(log.action).withOpacity(0.2),
        child: Icon(
          _getActionIcon(log.action),
          color: _getActionColor(log.action),
          size: 20,
        ),
      ),
      title: Text(
        log.description,
        style: const TextStyle(fontWeight: FontWeight.w600, color: _textColor),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Par: ${log.userName}'),
          Text(
            log.timestamp,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getActionColor(log.action).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          log.action,
          style: TextStyle(
            fontSize: 12,
            color: _getActionColor(log.action),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showAddUserDialog,
      backgroundColor: _primaryColor,
      child: const Icon(Icons.person_add, color: Colors.white),
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

  // Méthodes utilitaires et données
  List<String> _getRoleOptions() {
    return [
      'Tous',
      'Administrateur',
      'Chef de département',
      'Chef de scolarité',
      'Responsable pédagogique',
      'Directeur du patrimoine',
      'Membre CSAF',
    ];
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Administrateur':
        return _errorColor;
      case 'Chef de département':
        return _primaryColor;
      case 'Chef de scolarité':
        return _successColor;
      case 'Responsable pédagogique':
        return _warningColor;
      case 'Directeur du patrimoine':
        return Colors.purple;
      case 'Membre CSAF':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'Connexion':
        return _successColor;
      case 'Modification':
        return _warningColor;
      case 'Création':
        return _primaryColor;
      case 'Suppression':
        return _errorColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'Connexion':
        return Icons.login;
      case 'Modification':
        return Icons.edit;
      case 'Création':
        return Icons.add;
      case 'Suppression':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }

  List<UserRole> _getFilteredUsers() {
    List<UserRole> users = [
      UserRole(
        'Dr. Amadou Traoré',
        'a.traore@unz.bf',
        'Chef de département',
        true,
      ),
      UserRole(
        'Prof. Fatima Ouédraogo',
        'f.ouedraogo@unz.bf',
        'Responsable pédagogique',
        true,
      ),
      UserRole(
        'M. Ibrahim Sawadogo',
        'i.sawadogo@unz.bf',
        'Chef de scolarité',
        false,
      ),
      UserRole(
        'Mme Aicha Compaoré',
        'a.compaore@unz.bf',
        'Directeur du patrimoine',
        true,
      ),
      UserRole('Dr. Jean Kaboré', 'j.kabore@unz.bf', 'Membre CSAF', true),
    ];

    if (_selectedRole != 'Tous') {
      users = users.where((user) => user.role == _selectedRole).toList();
    }

    if (_searchQuery.isNotEmpty) {
      users =
          users
              .where(
                (user) =>
                    user.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    user.email.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return users;
  }

  List<AuditLog> _getAuditLogs() {
    return [
      AuditLog(
        'Connexion réussie',
        'Dr. Amadou Traoré',
        'Connexion',
        '02/06/2025 14:30',
      ),
      AuditLog(
        'Modification du rôle utilisateur',
        'Admin System',
        'Modification',
        '02/06/2025 13:15',
      ),
      AuditLog(
        'Création d\'un nouveau compte',
        'Admin System',
        'Création',
        '01/06/2025 16:45',
      ),
      AuditLog(
        'Tentative de connexion échouée',
        'Utilisateur inconnu',
        'Connexion',
        '01/06/2025 10:20',
      ),
      AuditLog(
        'Suppression d\'un compte utilisateur',
        'Admin System',
        'Suppression',
        '31/05/2025 09:30',
      ),
    ];
  }

  void _refreshData() {
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Données actualisées')));
  }

  void _handleUserAction(String action, UserRole user) {
    switch (action) {
      case 'edit':
        _showEditRoleDialog(user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(user);
        break;
      case 'permissions':
        _showPermissionsDialog(user);
        break;
    }
  }

  void _showEditRoleDialog(UserRole user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Modifier le rôle de ${user.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Nouveau rôle',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items:
                      _getRoleOptions().skip(1).map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                  onChanged: (value) {
                    selectedRole = value!;
                  },
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
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rôle modifié avec succès')),
                  );
                },
                child: const Text('Modifier'),
              ),
            ],
          ),
    );
  }

  void _toggleUserStatus(UserRole user) {
    setState(() {
      user.isActive = !user.isActive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.name} ${user.isActive ? 'activé' : 'désactivé'}'),
      ),
    );
  }

  void _showPermissionsDialog(UserRole user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Permissions de ${user.name}'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Fonctionnalité en cours de développement'),
                SizedBox(height: 20),
                Text(
                  'Les permissions détaillées seront disponibles prochainement.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  void _showAddUserDialog() {
    String selectedRole = 'Administrateur';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajouter un utilisateur'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items:
                      _getRoleOptions().skip(1).map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                  onChanged: (value) {
                    selectedRole = value!;
                  },
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
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Utilisateur ajouté avec succès'),
                    ),
                  );
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Vous pouvez stocker la plage de dates sélectionnée dans une variable d'état
        // Par exemple: _selectedDateRange = picked;
      });
    }
  }
}

// Classes de modèles pour les données
class UserRole {
  final String name;
  final String email;
  final String role;
  bool isActive;

  UserRole(this.name, this.email, this.role, this.isActive);
}

class AuditLog {
  final String description;
  final String userName;
  final String action;
  final String timestamp;

  AuditLog(this.description, this.userName, this.action, this.timestamp);
}
