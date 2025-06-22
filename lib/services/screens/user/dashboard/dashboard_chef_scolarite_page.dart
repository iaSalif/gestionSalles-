import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardChefScolaritePage extends StatefulWidget {
  final String ufrId; // exemple : 'UFR-ST'
  const DashboardChefScolaritePage({super.key, required this.ufrId});

  @override
  State<DashboardChefScolaritePage> createState() => _DashboardChefScolaritePageState();
}

class _DashboardChefScolaritePageState extends State<DashboardChefScolaritePage> {
  int _nbDevoirs = 0;
  int _nbSallesUFR = 0;

  @override
  void initState() {
    super.initState();
    _chargerStatistiques();
  }

  Future<void> _chargerStatistiques() async {
    final devoirs = await FirebaseFirestore.instance
        .collection('devoirs')
        .where('ufr_id', isEqualTo: widget.ufrId)
        .get();

    final salles = await FirebaseFirestore.instance
        .collection('salles')
        .where('ufr_id', isEqualTo: widget.ufrId)
        .get();

    setState(() {
      _nbDevoirs = devoirs.docs.length;
      _nbSallesUFR = salles.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard Chef de Scolarité - ${widget.ufrId}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Statistiques
            Row(
              children: [
                _buildStatCard("Devoirs programmés", _nbDevoirs.toString(), Icons.assignment, Colors.blue),
                const SizedBox(width: 16),
                _buildStatCard("Salles UFR", _nbSallesUFR.toString(), Icons.meeting_room, Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            // Historique des devoirs
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('devoirs')
                    .where('ufr_id', isEqualTo: widget.ufrId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text("Aucun devoir programmé"));
                  return ListView(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const Icon(Icons.event_note),
                        title: Text(data['titre'] ?? 'Sans titre'),
                        subtitle: Text("Salle: ${data['salle_nom'] ?? data['salle_id']} | ${data['date']} à ${data['heure']}"),
                        trailing: Text(data['statut'] ?? 'N/A'),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }
}
