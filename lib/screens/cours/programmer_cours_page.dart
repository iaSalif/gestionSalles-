import 'package:flutter/material.dart';

class ProgrammerCoursPage extends StatefulWidget {
  @override
  _ProgrammerCoursPageState createState() => _ProgrammerCoursPageState();
}

class _ProgrammerCoursPageState extends State<ProgrammerCoursPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs du formulaire
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Variables pour les sélections
  String? _selectedType = 'Cours';
  DateTime? _selectedDate;
  TimeOfDay? _selectedHeure;
  String? _selectedSalle;
  String? _selectedValidateur;

  // Listes de données (à remplacer par des appels API)
  final List<String> _typesCours = ['Cours', 'TD', 'TP'];
  final List<Map<String, String>> _salles = [
    {'id': '1', 'nom': 'Amphithéâtre A'},
    {'id': '2', 'nom': 'Salle 101'},
    {'id': '3', 'nom': 'Salle 102'},
    {'id': '4', 'nom': 'Laboratoire Info'},
  ];

  final List<Map<String, String>> _validateurs = [
    {'id': '1', 'nom': 'Dr. OUEDRAOGO'},
    {'id': '2', 'nom': 'Prof. SAWADOGO'},
    {'id': '3', 'nom': 'Dr. KABORE'},
  ];

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          'Programmer Cours/TD',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFB800),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.add_box, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nouveau Cours/TD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Planifier une nouvelle session',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Formulaire
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre du cours
                    _buildSectionTitle(
                      'Informations du cours',
                      Icons.info_outline,
                    ),
                    SizedBox(height: 15),

                    TextFormField(
                      controller: _titreController,
                      decoration: _buildInputDecoration(
                        'Titre du cours',
                        Icons.title,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir le titre du cours';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 15),

                    // Type de cours
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: _buildInputDecoration('Type', Icons.category),
                      items:
                          _typesCours.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedType = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner le type';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 15),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _buildInputDecoration(
                        'Description (optionnel)',
                        Icons.description,
                      ),
                      maxLines: 3,
                    ),

                    SizedBox(height: 25),

                    // Section Planning
                    _buildSectionTitle('Planning', Icons.schedule),
                    SizedBox(height: 15),

                    // Date
                    InkWell(
                      onTap: () => _selectDate(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Color(0xFF1E3A8A),
                            ),
                            SizedBox(width: 12),
                            Text(
                              _selectedDate == null
                                  ? 'Sélectionner la date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: TextStyle(
                                color:
                                    _selectedDate == null
                                        ? Colors.grey
                                        : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // Heure
                    InkWell(
                      onTap: () => _selectTime(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Color(0xFF1E3A8A)),
                            SizedBox(width: 12),
                            Text(
                              _selectedHeure == null
                                  ? 'Sélectionner l\'heure'
                                  : '${_selectedHeure!.hour.toString().padLeft(2, '0')}:${_selectedHeure!.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color:
                                    _selectedHeure == null
                                        ? Colors.grey
                                        : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // Salle
                    DropdownButtonFormField<String>(
                      value: _selectedSalle,
                      decoration: _buildInputDecoration(
                        'Salle',
                        Icons.meeting_room,
                      ),
                      items:
                          _salles.map((Map<String, String> salle) {
                            return DropdownMenuItem<String>(
                              value: salle['id'],
                              child: Text(salle['nom']!),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSalle = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner une salle';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 25),

                    // Section Validation
                    _buildSectionTitle('Validation', Icons.verified_user),
                    SizedBox(height: 15),

                    // Validateur
                    DropdownButtonFormField<String>(
                      value: _selectedValidateur,
                      decoration: _buildInputDecoration(
                        'Validateur',
                        Icons.person,
                      ),
                      items:
                          _validateurs.map((Map<String, String> validateur) {
                            return DropdownMenuItem<String>(
                              value: validateur['id'],
                              child: Text(validateur['nom']!),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedValidateur = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un validateur';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF10B981),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Programmer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Color(0xFF1E3A8A), size: 18),
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Color(0xFF1E3A8A)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFF1E3A8A), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
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
            colorScheme: ColorScheme.light(primary: Color(0xFF1E3A8A)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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
            colorScheme: ColorScheme.light(primary: Color(0xFF1E3A8A)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedHeure) {
      setState(() {
        _selectedHeure = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Vérifier les champs obligatoires supplémentaires
      if (_selectedDate == null) {
        _showErrorDialog('Veuillez sélectionner une date');
        return;
      }
      if (_selectedHeure == null) {
        _showErrorDialog('Veuillez sélectionner une heure');
        return;
      }

      // Ici, vous implémenteriez l'appel API pour sauvegarder le cours
      _saveCours();
    }
  }

  void _saveCours() {
    // TODO: Implémenter l'appel API
    Map<String, dynamic> coursData = {
      'titre': _titreController.text,
      'type': _selectedType,
      'description': _descriptionController.text,
      'date': _selectedDate!.toIso8601String(),
      'heure': '${_selectedHeure!.hour}:${_selectedHeure!.minute}',
      'salle_id': _selectedSalle,
      'validateur_id': _selectedValidateur,
      'createur_id': 'current_user_id', // À récupérer du contexte utilisateur
      'status': 'en_attente',
    };

    print('Données du cours à sauvegarder: $coursData');

    // Simuler un appel API
    _showSuccessDialog();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text('Erreur'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Succès'),
            ],
          ),
          content: Text(
            'Le cours a été programmé avec succès et envoyé pour validation.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialog
                Navigator.of(context).pop(); // Retourner au dashboard
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
