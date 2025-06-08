import 'package:flutter/material.dart';

class AnnulerCoursPage extends StatefulWidget {
  const AnnulerCoursPage({super.key});

  @override
  _AnnulerCoursPageState createState() => _AnnulerCoursPageState();
}

class _AnnulerCoursPageState extends State<AnnulerCoursPage> {
  static const Color _primaryColor = Color(0xFF1E3A8A);
  static const Color _goldColor = Color(0xFFFFB800);
  static const Color _backgroundColor = Color(0xFFF1F5F9);

  final List<Map<String, String>> _coursList = [
    {'id': 'C001', 'titre': 'Mathématiques TD', 'salle': 'Salle A', 'date': '08/06/2025'},
    {'id': 'C002', 'titre': 'Physique Cours', 'salle': 'Salle B', 'date': '09/06/2025'},
  ];

  String? _selectedCoursId;
  String _annulationReason = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text('Annuler Cours/TD'),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40), // Ajustement de la largeur
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionnez un cours/TD à annuler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Cours/TD',
                  ),
                  value: _selectedCoursId,
                  items: _coursList.map((cours) {
                    return DropdownMenuItem<String>(
                      value: cours['id'],
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 100, // Limite la largeur
                        child: Text(
                          '${cours['titre']} - ${cours['salle']} (${cours['date']})',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCoursId = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Raison de l\'annulation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Entrez la raison de l\'annulation',
                ),
                onChanged: (value) {
                  setState(() {
                    _annulationReason = value;
                  });
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _selectedCoursId == null || _annulationReason.isEmpty
                    ? null
                    : () {
                  _annulerCours();
                },
                child: Text(
                  'Confirmer l\'annulation',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _annulerCours() {
    if (_selectedCoursId != null && _annulationReason.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cours ${_coursList.firstWhere((cours) => cours['id'] == _selectedCoursId)['titre']} annulé avec succès.'),
          backgroundColor: _primaryColor,
        ),
      );
      Navigator.pop(context);
    }
  }
}