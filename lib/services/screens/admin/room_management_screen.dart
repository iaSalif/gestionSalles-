import 'package:flutter/material.dart';

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key, required ufrId});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedUFR = 'Toutes';
  String _searchQuery = '';

  // Données des salles basées sur votre document UFR-ST
  final List<Map<String, dynamic>> _rooms = [
    // UFR-ST
    {'id': '01', 'nom': '11', 'ufr_id': 'UFR-ST', 'capacite': 40, 'localisation': 'Bâtiment A', 'filiere': 'Mathématiques', 'classe': 'Licence 2 & 3'},
    {'id': '02', 'nom': '12', 'ufr_id': 'UFR-ST', 'capacite': 35, 'localisation': 'Bâtiment A', 'filiere': 'Physique', 'classe': 'Licence 3'},
    {'id': '03', 'nom': '13', 'ufr_id': 'UFR-ST', 'capacite': 30, 'localisation': 'Bâtiment A', 'filiere': 'Biochimie', 'classe': 'Licence 3'},
    {'id': '04', 'nom': '14', 'ufr_id': 'UFR-ST', 'capacite': 45, 'localisation': 'Bâtiment A', 'filiere': 'Chimie', 'classe': 'Licence 2 & 3'},
    {'id': '05', 'nom': 'CP1 Centre', 'ufr_id': 'UFR-ST', 'capacite': 60, 'localisation': 'Bâtiment B', 'filiere': 'Informatique', 'classe': 'Licence 2'},
    {'id': '06', 'nom': 'CP1 Ouest', 'ufr_id': 'UFR-ST', 'capacite': 55, 'localisation': 'Bâtiment B', 'filiere': 'Master Maths', 'classe': ''},
    {'id': '07', 'nom': 'SAP (deux salles)', 'ufr_id': 'UFR-ST', 'capacite': 80, 'localisation': 'Bâtiment C', 'filiere': '', 'classe': ''},
    {'id': '08', 'nom': 'Polyvalente (trois salles)', 'ufr_id': 'UFR-ST', 'capacite': 120, 'localisation': 'Bâtiment C', 'filiere': '', 'classe': ''},
    {'id': '09', 'nom': 'Grande salle R+2', 'ufr_id': 'UFR-ST', 'capacite': 100, 'localisation': 'Bâtiment D', 'filiere': 'Physique', 'classe': 'Licence 2'},
    {'id': '10', 'nom': 'Amphi mille', 'ufr_id': 'UFR-ST', 'capacite': 1000, 'localisation': 'Amphithéâtre', 'filiere': 'SVT', 'classe': 'Licence 1 & 2'},
    {'id': '11', 'nom': 'Amphi 500', 'ufr_id': 'UFR-ST', 'capacite': 500, 'localisation': 'Amphithéâtre', 'filiere': 'Biologie', 'classe': 'Licence 3'},
    {'id': '12', 'nom': 'PSUT Est', 'ufr_id': 'UFR-ST', 'capacite': 40, 'localisation': 'Bâtiment E', 'filiere': 'MPCI', 'classe': 'Licence 1&2'},
    {'id': '13', 'nom': 'LSH R+2', 'ufr_id': 'UFR-ST', 'capacite': 35, 'localisation': 'Bâtiment F', 'filiere': '', 'classe': ''},

    // UFR-LSH
    {'id': '14', 'nom': 'Salle A1', 'ufr_id': 'UFR-LSH', 'capacite': 50, 'localisation': 'Bâtiment LSH', 'filiere': 'Lettres', 'classe': 'Licence 1'},
    {'id': '15', 'nom': 'Salle A2', 'ufr_id': 'UFR-LSH', 'capacite': 45, 'localisation': 'Bâtiment LSH', 'filiere': 'Histoire', 'classe': 'Licence 2'},
    {'id': '16', 'nom': 'Amphi LSH', 'ufr_id': 'UFR-LSH', 'capacite': 200, 'localisation': 'Amphithéâtre LSH', 'filiere': '', 'classe': ''},

    // UFR-SEG
    {'id': '17', 'nom': 'Salle SEG1', 'ufr_id': 'UFR-SEG', 'capacite': 60, 'localisation': 'Bâtiment SEG', 'filiere': 'Économie', 'classe': 'Licence 1'},
    {'id': '18', 'nom': 'Salle SEG2', 'ufr_id': 'UFR-SEG', 'capacite': 55, 'localisation': 'Bâtiment SEG', 'filiere': 'Gestion', 'classe': 'Licence 2'},
    {'id': '19', 'nom': 'Amphi SEG', 'ufr_id': 'UFR-SEG', 'capacite': 150, 'localisation': 'Amphithéâtre SEG', 'filiere': '', 'classe': ''},

    // UIT
    {'id': '20', 'nom': 'Lab Info 1', 'ufr_id': 'UIT', 'capacite': 30, 'localisation': 'Bâtiment UIT', 'filiere': 'Informatique', 'classe': 'Licence 2'},
    {'id': '21', 'nom': 'Lab Info 2', 'ufr_id': 'UIT', 'capacite': 35, 'localisation': 'Bâtiment UIT', 'filiere': 'Informatique', 'classe': 'Licence 3'},
    {'id': '22', 'nom': 'Salle UIT', 'ufr_id': 'UIT', 'capacite': 40, 'localisation': 'Bâtiment UIT', 'filiere': 'Technologie', 'classe': 'Master'},
  ];

  final List<String> _ufrList = ['Toutes', 'UFR-ST', 'UFR-LSH', 'UFR-SEG', 'UIT'];

  List<Map<String, dynamic>> get _filteredRooms {
    return _rooms.where((room) {
      final matchesSearch = room['nom'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room['filiere'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room['localisation'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesUFR = _selectedUFR == 'Toutes' || room['ufr_id'] == _selectedUFR;
      return matchesSearch && matchesUFR;
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
          'Gestion des Salles',
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
            onPressed: () => _showAddRoomDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une salle...',
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
                const SizedBox(height: 12),
                // Filtre par UFR
                Row(
                  children: [
                    const Text(
                      'UFR: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedUFR,
                        isExpanded: true,
                        items: _ufrList.map((String ufr) {
                          return DropdownMenuItem<String>(
                            value: ufr,
                            child: Text(ufr),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedUFR = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Statistiques
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Salles',
                    _filteredRooms.length.toString(),
                    Icons.meeting_room,
                    const Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Capacité Totale',
                    _filteredRooms
                        .fold(0, (sum, room) => sum + (room['capacite'] as int))
                        .toString(),
                    Icons.people,
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),

          // Liste des salles
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredRooms.length,
              itemBuilder: (context, index) {
                final room = _filteredRooms[index];
                return _buildRoomCard(room);
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A47),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room['nom'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3A47),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room['ufr_id'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF2E3A47)),
                onSelected: (String result) {
                  switch (result) {
                    case 'edit':
                      _showEditRoomDialog(room);
                      break;
                    case 'delete':
                      _showDeleteConfirmation(room);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.location_on, room['localisation'], const Color(0xFFFF9800)),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.people, '${room['capacite']} places', const Color(0xFF4CAF50)),
            ],
          ),
          if (room['filiere'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(Icons.school, room['filiere'], const Color(0xFF9C27B0)),
                if (room['classe'].isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.class_, room['classe'], const Color(0xFF607D8B)),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une Salle'),
          content: const Text('Fonctionnalité d\'ajout de salle à implémenter'),
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

  void _showEditRoomDialog(Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier ${room['nom']}'),
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
                  SnackBar(content: Text('Salle ${room['nom']} modifiée')),
                );
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer la salle "${room['nom']}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  _rooms.removeWhere((r) => r['id'] == room['id']);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Salle ${room['nom']} supprimée')),
                );
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}