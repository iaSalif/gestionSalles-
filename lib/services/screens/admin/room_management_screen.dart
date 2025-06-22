import 'package:cloud_firestore/cloud_firestore.dart';
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

  final List<String> _ufrList = [
    'Toutes',
    'UFR-ST',
    'UFR-LSH',
    'UFR-SEG',
    'UIT',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E3A47),
        title: const Text('Gestion des Salles'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('salles').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('Aucune salle trouvée.'));
                }
                final allRooms = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

                final filteredRooms = allRooms.where((room) {
                  final matchesSearch = room['nom'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      room['filiere'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      room['localisation'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesUFR = _selectedUFR == 'Toutes' || room['ufr_id'] == _selectedUFR;
                  return matchesSearch && matchesUFR;
                }).toList();

                final totalCapacite = filteredRooms.fold(0, (int sum, room) => sum + (room['capacite'] as int));

                return Column(
                  children: [
                    _buildStats(filteredRooms.length, totalCapacite),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredRooms.length,
                        itemBuilder: (context, index) => _buildRoomCard(filteredRooms[index]),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Rechercher une salle...',
              prefixIcon: Icon(Icons.search),
              filled: true,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('UFR: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedUFR,
                  isExpanded: true,
                  items: _ufrList.map((ufr) => DropdownMenuItem(value: ufr, child: Text(ufr))).toList(),
                  onChanged: (value) => setState(() => _selectedUFR = value!),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStats(int totalSalles, int capaciteTotale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard('Total Salles', totalSalles.toString(), Icons.meeting_room, Colors.indigo),
          _buildStatCard('Capacité Totale', capaciteTotale.toString(), Icons.people, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(title, style: const TextStyle(color: Colors.grey))
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(room['nom']),
        subtitle: Text('${room['ufr_id']} • ${room['localisation']} • ${room['capacite']} places'),
        trailing: PopupMenuButton<String>(
          onSelected: (choice) {
            if (choice == 'delete') {
              FirebaseFirestore.instance.collection('salles').doc(room['id']).delete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ),
    );
  }
}
