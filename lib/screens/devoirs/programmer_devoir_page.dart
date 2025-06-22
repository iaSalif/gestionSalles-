import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgrammerDevoirPage extends StatefulWidget {
  const ProgrammerDevoirPage({super.key});

  @override
  State<ProgrammerDevoirPage> createState() => _ProgrammerDevoirPageState();
}

class _ProgrammerDevoirPageState extends State<ProgrammerDevoirPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _effectifController = TextEditingController();
  DateTime? _date;
  TimeOfDay? _heure;
  List<QueryDocumentSnapshot> _sallesDisponibles = [];
  String? _salleSelectionnee;
  bool _isLoading = false;

  Future<void> _chargerSallesDisponibles() async {
    if (_date == null || _heure == null) return;
    final effectif = int.tryParse(_effectifController.text) ?? 0;

    final dateStr = DateFormat('yyyy-MM-dd').format(_date!);
    final heureStr = _heure!.format(context);

    final devoirs = await FirebaseFirestore.instance
        .collection('devoirs')
        .where('date', isEqualTo: dateStr)
        .where('heure', isEqualTo: heureStr)
        .get();

    final sallesOccupees = devoirs.docs.map((d) => d['salle_id']).toSet();

    final salles = await FirebaseFirestore.instance.collection('salles').get();

    List<QueryDocumentSnapshot> disponibles = salles.docs.where((salle) {
    final capacite = salle['capacite'] ?? 0;
    return !sallesOccupees.contains(salle.id) && capacite >= effectif;
    }).toList();

    // Suggestion d'heure alternative si aucune salle dispo
    if (disponibles.isEmpty) {
    for (int offset in [1, 2]) {
    final nouvelleHeure = _heure!.replacing(hour: _heure!.hour + offset);
    final altHeureStr = nouvelleHeure.format(context);
    final altDevoirs = await FirebaseFirestore.instance
        .collection('devoirs')
        .where('date', isEqualTo: dateStr)
        .where('heure', isEqualTo: altHeureStr)
        .get();

    final altOccupees = altDevoirs.docs.map((d) => d['salle_id']).toSet();
    disponibles = salles.docs.where((salle) {
    final capacite = salle['capacite'] ?? 0;
    return !altOccupees.contains(salle.id) && capacite >= effectif;
    }).toList();

    if (disponibles.isNotEmpty) {
    if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
    content: Text(
    'Aucune salle libre à $heureStr. Suggestion : ${nouvelleHeure.format(context)}',
    ),
    ),
    );
    }
    setState(() {
    _heure = nouvelleHeure;
    _sallesDisponibles = disponibles;
    _salleSelectionnee = null;
    });
    return;
    }
    }
    }

    setState(() {
    _sallesDisponibles = disponibles;
    _salleSelectionnee = null;
    });
  }

  Future<void> _programmerDevoir() async {
    if (!_formKey.currentState!.validate() || _date == null || _heure == null || _salleSelectionnee == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('devoirs').add({
        'titre': _titreController.text.trim(),
        'salle_id': _salleSelectionnee,
        'date': DateFormat('yyyy-MM-dd').format(_date!),
        'heure': _heure!.format(context),
        'effectif': int.tryParse(_effectifController.text.trim()),
        'statut': 'programmé',
        'createur_id': 'ID_USER_EN_COURS',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Devoir programmé avec succès')),
        );
        _formKey.currentState!.reset();
        _titreController.clear();
        _effectifController.clear();
        setState(() {
          _date = null;
          _heure = null;
          _sallesDisponibles.clear();
          _salleSelectionnee = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur : $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programmer un devoir')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(labelText: 'Titre du devoir'),
                validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un titre' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _effectifController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nombre d`\'étudiants'),
                    validator: (value) {
              if (value == null || value.isEmpty) return 'Veuillez entrer un effectif';
              if (int.tryParse(value) == null) return 'Entrez un nombre valide';
              return null;
              },
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(_date == null ? 'Choisir une date' : 'Date : ${DateFormat('yyyy-MM-dd').format(_date!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              ListTile(
                title: Text(_heure == null ? 'Choisir une heure' : 'Heure : ${_heure!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _heure = picked);
                },
              ),
              ElevatedButton(
                onPressed: _chargerSallesDisponibles,
                child: const Text('🔍 Vérifier les salles disponibles'),
              ),
              if (_sallesDisponibles.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text("Salles disponibles :", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _salleSelectionnee,
                  decoration: const InputDecoration(labelText: 'Choisir une salle'),
                  items: _sallesDisponibles.map((salle) {
                    return DropdownMenuItem(
                      value: salle.id,
                      child: Text('${salle['nom']} - ${salle['capacite']} places'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _salleSelectionnee = value),
                  validator: (value) => value == null ? 'Veuillez choisir une salle' : null,
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _programmerDevoir,
                child: _isLoading ? const CircularProgressIndicator() : const Text("✅ Programmer"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
