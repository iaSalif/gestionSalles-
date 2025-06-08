import 'package:flutter/material.dart';
import 'package:gestion_salles/services/screens/admin/room_management_screen.dart';

class UFRManagementScreen extends StatefulWidget {
  const UFRManagementScreen({super.key});

  @override
  State<UFRManagementScreen> createState() => _UFRManagementScreenState();
}

class _UFRManagementScreenState extends State<UFRManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _ufrs = [
    {
      'id': 'UFR-ST',
      'nom': 'Sciences et Technologies',
      'responsables': 'Dr. OUEDRAOGO Marie',
      'departement': 'Sciences',
      'totalSalles': 13,
      'totalCapacite': 2845,
      'filieres': ['Mathématiques', 'Physique', 'Chimie', 'Biologie', 'Informatique', 'SVT'],
      'description': 'Unité de Formation et de Recherche en Sciences et Technologies',
      'dateCreation': '2020-01-15',
      'statut': 'Actif',
    },
    {
      'id': 'UFR-LSH',
      'nom': 'Lettres, Sciences Humaines et Sociales',
      'responsables': 'Prof. SANOGO Jean',
      'departement': 'Lettres et Sciences Humaines',
      'totalSalles': 3,
      'totalCapacite': 295,
      'filieres': ['Lettres Modernes', 'Histoire-Géographie', 'Sociologie', 'Philosophie'],
      'description': 'Unité de Formation et de Recherche en Lettres, Sciences Humaines et Sociales',
      'dateCreation': '2019-09-01',
      'statut': 'Actif',
    },
    {
      'id': 'UFR-SEG',
      'nom': 'Sciences Économiques et de Gestion',
      'responsables': 'Dr. KONE Aminata',
      'departement': 'Sciences Économiques',
      'totalSalles': 3,
      'totalCapacite': 265,
      'filieres': ['Économie', 'Gestion', 'Comptabilité', 'Finance'],
      'description': 'Unité de Formation et de Recherche en Sciences Économiques et de Gestion',
      'dateCreation': '2020-03-20',
      'statut': 'Actif',
    },
    {
      'id': 'UIT',
      'nom': 'Unité d\'Innovation Technologique',
      'responsables': 'Dr. TRAORE Moussa',
      'departement': 'Technologie',
      'totalSalles': 3,
      'totalCapacite': 105,
      'filieres': ['Informatique Appliquée', 'Génie Logiciel', 'Technologies Numériques'],
      'description': 'Unité spécialisée dans l\'innovation et les technologies numériques',
      'dateCreation': '2021-01-10',
      'statut': 'Actif',
    },
  ];

  List<Map<String, dynamic>> get _filteredUFRs {
    return _ufrs.where((ufr) {
      return ufr['nom'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ufr['responsables'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ufr['departement'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E3A47),
        elevation: 0,
        title: const Text(
          'Gestion des UFR',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddUFRDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une UFR...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4A90E2)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Statistiques générales
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total UFR',
                    _filteredUFRs.length.toString(),
                    Icons.school,
                    const Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Salles',
                    _filteredUFRs
                        .fold(0, (sum, ufr) => sum + (ufr['totalSalles'] as int))
                        .toString(),
                    Icons.meeting_room,
                    const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Capacité Totale',
                    _filteredUFRs
                        .fold(0, (sum, ufr) => sum + (ufr['totalCapacite'] as int))
                        .toString(),
                    Icons.people,
                    const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ),

          // Liste des UFR
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredUFRs.length,
              itemBuilder: (context, index) {
                final ufr = _filteredUFRs[index];
                return _buildUFRCard(ufr);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A47),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUFRCard(Map<String, dynamic> ufr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête de la carte
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getGradientColors(ufr['id']),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ufr['id'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ufr['nom'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (String result) {
                    switch (result) {
                      case 'view':
                        _showUFRDetails(ufr);
                        break;
                      case 'edit':
                        _showEditUFRDialog(ufr);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(ufr);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Color(0xFF4A90E2)),
                          SizedBox(width: 8),
                          Text('Voir détails'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF4A90E2)),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contenu de la carte
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Responsable
                Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFF4A90E2), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Responsable: ${ufr['responsables']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2E3A47),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Statistiques
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStat('Salles', ufr['totalSalles'].toString(), Icons.meeting_room),
                    ),
                    Expanded(
                      child: _buildMiniStat('Capacité', ufr['totalCapacite'].toString(), Icons.people),
                    ),
                    Expanded(
                      child: _buildMiniStat('Filières', ufr['filieres'].length.toString(), Icons.school),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  ufr['description'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Filières (with proper widget list handling)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Display first 3 filières
                    ...(ufr['filieres'] as List<String>)
                        .take(3)
                        .map((filiere) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getUFRColor(ufr['id']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        filiere,
                        style: TextStyle(
                          fontSize: 11,
                          color: _getUFRColor(ufr['id']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )),
                    // Show "+X more" if there are more than 3 filières
                    if (ufr['filieres'].length > 3)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${ufr['filieres'].length - 3}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Actions rapides
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showUFRDetails(ufr),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Détails'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _getUFRColor(ufr['id']),
                          side: BorderSide(color: _getUFRColor(ufr['id'])),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToRooms(ufr),
                        icon: const Icon(Icons.meeting_room, size: 16),
                        label: const Text('Salles'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getUFRColor(ufr['id']),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4A90E2)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A47),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(String ufrId) {
    switch (ufrId) {
      case 'UFR-ST':
        return [const Color(0xFF4A90E2), const Color(0xFF357ABD)];
      case 'UFR-LSH':
        return [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)];
      case 'UFR-SEG':
        return [const Color(0xFF4CAF50), const Color(0xFF388E3C)];
      case 'UIT':
        return [const Color(0xFFFF9800), const Color(0xFFF57C00)];
      default:
        return [const Color(0xFF607D8B), const Color(0xFF455A64)];
    }
  }

  Color _getUFRColor(String ufrId) {
    switch (ufrId) {
      case 'UFR-ST':
        return const Color(0xFF4A90E2);
      case 'UFR-LSH':
        return const Color(0xFF9C27B0);
      case 'UFR-SEG':
        return const Color(0xFF4CAF50);
      case 'UIT':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF607D8B);
    }
  }

  void _showUFRDetails(Map<String, dynamic> ufr) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getGradientColors(ufr['id']),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ufr['id'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        ufr['nom'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenu
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Responsable', ufr['responsables'], Icons.person),
                        _buildDetailRow('Département', ufr['departement'], Icons.business),
                        _buildDetailRow('Date de création', ufr['dateCreation'], Icons.calendar_today),
                        _buildDetailRow('Statut', ufr['statut'], Icons.info),
                        _buildDetailRow('Total salles', ufr['totalSalles'].toString(), Icons.meeting_room),
                        _buildDetailRow('Capacité totale', '${ufr['totalCapacite']} places', Icons.people),

                        const SizedBox(height: 20),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A47),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ufr['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          'Filières',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A47),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (ufr['filieres'] as List<String>)
                              .map((filiere) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getUFRColor(ufr['id']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getUFRColor(ufr['id']).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              filiere,
                              style: TextStyle(
                                fontSize: 13,
                                color: _getUFRColor(ufr['id']),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4A90E2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2E3A47),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUFRDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une UFR'),
          content: const Text('Fonctionnalité d\'ajout d\'UFR à implémenter'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUFRDialog(Map<String, dynamic> ufr) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier ${ufr['id']}'),
          content: const Text('Fonctionnalité de modification à implémenter'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('UFR ${ufr['id']} modifiée')),
                );
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> ufr) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer l\'UFR "${ufr['id']}" ?\n\nCette action supprimera également toutes les salles associées.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  _ufrs.removeWhere((u) => u['id'] == ufr['id']);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('UFR ${ufr['id']} supprimée')),
                );
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToRooms(Map<String, dynamic> ufr) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation vers les salles de ${ufr['id']}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoomManagementScreen(ufrId: null,),
              ),
            );
          },
        ),
      ),
    );
  }
}