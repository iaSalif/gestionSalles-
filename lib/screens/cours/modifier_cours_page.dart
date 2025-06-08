import 'package:flutter/material.dart';

class ModifierCoursPage extends StatefulWidget {
  const ModifierCoursPage({super.key});

  @override
  _ModifierCoursPageState createState() => _ModifierCoursPageState();
}

class _ModifierCoursPageState extends State<ModifierCoursPage> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  // Controllers pour les champs du formulaire
  final _titreController = TextEditingController();
  final _typeController = TextEditingController();
  final _dateController = TextEditingController();
  final _heureController = TextEditingController();

  // Variables d'état
  bool _isSearching = false;
  bool _isLoading = false;
  bool _courseFound = false;

  // Données simulées - remplacer par des appels API réels
  Map<String, dynamic>? _selectedCourse;
  String? _selectedSalle;
  String? _selectedValidateur;

  // Listes de données
  List<Map<String, dynamic>> _coursesList = [
    {
      'id': 'C001',
      'titre': 'Algorithmes et Structures de Données',
      'type': 'Cours',
      'date': '2024-12-15',
      'heure': '08:00',
      'salle_id': 'S101',
      'salle_nom': 'Amphithéâtre A',
      'createur': 'Dr. OUEDRAOGO',
      'validateur': 'Prof. KABORE',
      'status': 'validé'
    },
    {
      'id': 'TD001',
      'titre': 'TD - Base de données relationnelles',
      'type': 'TD',
      'date': '2024-12-16',
      'heure': '14:00',
      'salle_id': 'S205',
      'salle_nom': 'Salle Informatique 2',
      'createur': 'Dr. SAWADOGO',
      'validateur': 'Prof. TRAORE',
      'status': 'en_attente'
    },
    {
      'id': 'C002',
      'titre': 'Introduction aux Réseaux',
      'type': 'Cours',
      'date': '2024-12-17',
      'heure': '10:30',
      'salle_id': 'S301',
      'salle_nom': 'Salle de Conférence',
      'createur': 'Dr. ZONGO',
      'validateur': 'Prof. OUATTARA',
      'status': 'validé'
    }
  ];

  List<Map<String, dynamic>> _sallesList = [
    {'id': 'S101', 'nom': 'Amphithéâtre A', 'capacite': 200},
    {'id': 'S102', 'nom': 'Amphithéâtre B', 'capacite': 150},
    {'id': 'S201', 'nom': 'Salle Informatique 1', 'capacite': 30},
    {'id': 'S205', 'nom': 'Salle Informatique 2', 'capacite': 25},
    {'id': 'S301', 'nom': 'Salle de Conférence', 'capacite': 50},
  ];

  List<Map<String, dynamic>> _validateursList = [
    {'id': 'V001', 'nom': 'Prof. KABORE'},
    {'id': 'V002', 'nom': 'Prof. TRAORE'},
    {'id': 'V003', 'nom': 'Prof. OUATTARA'},
    {'id': 'V004', 'nom': 'Dr. SANKARA'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _titreController.dispose();
    _typeController.dispose();
    _dateController.dispose();
    _heureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.edit_note,
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
                  'Modifier Cours/TD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Gestion des modifications',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section de recherche
            _buildSearchSection(),

            SizedBox(height: 20),

            // Section des résultats de recherche
            if (_isSearching) _buildSearchResults(),

            SizedBox(height: 20),

            // Formulaire de modification
            if (_courseFound && _selectedCourse != null) _buildModificationForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1E3A8A).withOpacity(0.1),
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
                  color: Color(0xFF1E3A8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.search,
                  color: Color(0xFF1E3A8A),
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Rechercher',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Saisir l\'ID du cours ou le titre...',
              prefixIcon: Icon(Icons.search, color: Color(0xFF64748B)),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Color(0xFF64748B)),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _isSearching = false;
                    _courseFound = false;
                    _selectedCourse = null;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF1E3A8A), width: 2),
              ),
              filled: true,
              fillColor: Color(0xFFF8FAFC),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                _performSearch(value);
              }
            },
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _performSearch(_searchController.text),
            icon: Icon(Icons.search),
            label: Text('Rechercher'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_coursesList.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF1E3A8A).withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Color(0xFF64748B),
            ),
            SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            Text(
              'Vérifiez l\'ID ou le titre du cours',
              style: TextStyle(
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1E3A8A).withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Résultats de recherche',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _coursesList.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final course = _coursesList[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: course['type'] == 'Cours'
                        ? Color(0xFF3B82F6).withOpacity(0.1)
                        : Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    course['type'] == 'Cours' ? Icons.book : Icons.groups,
                    color: course['type'] == 'Cours'
                        ? Color(0xFF3B82F6)
                        : Color(0xFF10B981),
                  ),
                ),
                title: Text(
                  course['titre'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${course['id']} • ${course['type']}'),
                    Text('${course['date']} à ${course['heure']} - ${course['salle_nom']}'),
                  ],
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: course['status'] == 'validé'
                        ? Color(0xFF10B981).withOpacity(0.1)
                        : Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    course['status'] == 'validé' ? 'Validé' : 'En attente',
                    style: TextStyle(
                      color: course['status'] == 'validé'
                          ? Color(0xFF10B981)
                          : Color(0xFFF59E0B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onTap: () => _selectCourse(course),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModificationForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF1E3A8A).withOpacity(0.1),
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
                    color: Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Color(0xFFF59E0B),
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Modifier le cours/TD',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Titre du cours
            _buildFormField(
              label: 'Titre du cours/TD',
              controller: _titreController,
              icon: Icons.title,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Le titre est requis';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // Type de cours
            _buildDropdownField(
              label: 'Type',
              value: _typeController.text.isNotEmpty ? _typeController.text : null,
              items: ['Cours', 'TD'],
              icon: Icons.category,
              onChanged: (value) {
                setState(() {
                  _typeController.text = value ?? '';
                });
              },
            ),

            SizedBox(height: 16),

            // Date
            _buildDateField(),

            SizedBox(height: 16),

            // Heure
            _buildTimeField(),

            SizedBox(height: 16),

            // Salle
            _buildDropdownField(
              label: 'Salle',
              value: _selectedSalle,
              items: _sallesList.map((salle) => salle['nom'] as String).toList(),
              icon: Icons.meeting_room,
              onChanged: (value) {
                setState(() {
                  _selectedSalle = value;
                });
              },
            ),

            SizedBox(height: 16),

            // Validateur
            _buildDropdownField(
              label: 'Validateur',
              value: _selectedValidateur,
              items: _validateursList.map((val) => val['nom'] as String).toList(),
              icon: Icons.person_outline,
              onChanged: (value) {
                setState(() {
                  _selectedValidateur = value;
                });
              },
            ),

            SizedBox(height: 32),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveCourse(),
                    icon: Icon(Icons.save),
                    label: Text('Enregistrer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _resetForm(),
                    icon: Icon(Icons.refresh),
                    label: Text('Réinitialiser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF64748B),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xFF64748B)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
            filled: true,
            fillColor: Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xFF64748B)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
            filled: true,
            fillColor: Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: () => _selectDate(),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'La date est requise';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF64748B)),
            suffixIcon: Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
            filled: true,
            fillColor: Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heure',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _heureController,
          readOnly: true,
          onTap: () => _selectTime(),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'L\'heure est requise';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.access_time, color: Color(0xFF64748B)),
            suffixIcon: Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
            filled: true,
            fillColor: Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _courseFound = false;
    });

    // Simulation d'une recherche - remplacer par un appel API réel
    Future.delayed(Duration(milliseconds: 500), () {
      final results = _coursesList.where((course) {
        return course['id'].toLowerCase().contains(query.toLowerCase()) ||
            course['titre'].toLowerCase().contains(query.toLowerCase());
      }).toList();

      setState(() {
        _coursesList = results;
        _isSearching = true;
      });
    });
  }

  void _selectCourse(Map<String, dynamic> course) {
    setState(() {
      _selectedCourse = course;
      _courseFound = true;

      // Pré-remplir les champs avec les données du cours
      _titreController.text = course['titre'];
      _typeController.text = course['type'];
      _dateController.text = course['date'];
      _heureController.text = course['heure'];
      _selectedSalle = course['salle_nom'];
      _selectedValidateur = course['validateur'];
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1E3A8A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1E3A8A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _heureController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulation d'une sauvegarde - remplacer par un appel API réel
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Cours/TD modifié avec succès !'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Retour au dashboard après un délai
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      });
    }
  }

  void _resetForm() {
    setState(() {
      _selectedCourse = null;
      _courseFound = false;
      _isSearching = false;
      _selectedSalle = null;
      _selectedValidateur = null;
    });

    _titreController.clear();
    _typeController.clear();
    _dateController.clear();
    _heureController.clear();
    _searchController.clear();
  }
}