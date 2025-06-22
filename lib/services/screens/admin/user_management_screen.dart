import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Controllers pour le formulaire d'ajout/modification
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  String _selectedRole = 'Utilisateur';
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  // Fonction pour ajouter un utilisateur avec gestion d'erreur améliorée
  Future<void> _ajouterUtilisateur(StateSetter dialogSetState) async {
    if (!_formKey.currentState!.validate()) return;

    dialogSetState(() => _isLoading = true);

    try {
      // Vérifier si l'email existe déjà
      final existingUser =
          await _firestore
              .collection('utilisateurs')
              .where(
                'email',
                isEqualTo: _emailController.text.trim().toLowerCase(),
              )
              .get();

      if (existingUser.docs.isNotEmpty) {
        _showErrorMessage('Un utilisateur avec cet email existe déjà');
        dialogSetState(() => _isLoading = false);
        return;
      }

      await _firestore.collection('utilisateurs').add({
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'telephone': _telephoneController.text.trim(),
        'role': _selectedRole,
        'actif': _isActive,
        'dateCreation': FieldValue.serverTimestamp(),
        'derniereConnexion': null,
      });

      // Nettoyer le formulaire et fermer le dialog
      _clearForm();
      dialogSetState(() => _isLoading = false);
      Navigator.of(context).pop();
      _showSuccessMessage(
        'Utilisateur "${_prenomController.text} ${_nomController.text}" ajouté avec succès',
      );
    } catch (e) {
      _showErrorMessage('Erreur lors de l\'ajout: ${e.toString()}');
      dialogSetState(() => _isLoading = false);
    }
  }

  // Fonction pour modifier un utilisateur avec validation
  Future<void> _modifierUtilisateur(
    String id,
    StateSetter dialogSetState,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    dialogSetState(() => _isLoading = true);

    try {
      // Vérifier si l'email existe déjà pour un autre utilisateur
      final existingUser =
          await _firestore
              .collection('utilisateurs')
              .where(
                'email',
                isEqualTo: _emailController.text.trim().toLowerCase(),
              )
              .get();

      if (existingUser.docs.isNotEmpty && existingUser.docs.first.id != id) {
        _showErrorMessage('Un autre utilisateur avec cet email existe déjà');
        dialogSetState(() => _isLoading = false);
        return;
      }

      await _firestore.collection('utilisateurs').doc(id).update({
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'telephone': _telephoneController.text.trim(),
        'role': _selectedRole,
        'actif': _isActive,
        'dateModification': FieldValue.serverTimestamp(),
      });

      // Nettoyer le formulaire et fermer le dialog
      _clearForm();
      dialogSetState(() => _isLoading = false);
      Navigator.of(context).pop();
      _showSuccessMessage(
        'Utilisateur "${_prenomController.text} ${_nomController.text}" modifié avec succès',
      );
    } catch (e) {
      _showErrorMessage('Erreur lors de la modification: ${e.toString()}');
      dialogSetState(() => _isLoading = false);
    }
  }

  // Fonction pour supprimer un utilisateur
  Future<void> _supprimerUtilisateur(
    String id,
    String nom,
    String prenom,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer l\'utilisateur "$prenom $nom" ?\n\nCette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (result == true) {
      try {
        await _firestore.collection('utilisateurs').doc(id).delete();
        _showSuccessMessage('Utilisateur "$prenom $nom" supprimé avec succès');
      } catch (e) {
        _showErrorMessage('Erreur lors de la suppression: ${e.toString()}');
      }
    }
  }

  // Fonction pour basculer le statut actif/inactif
  Future<void> _toggleUserStatus(
    String id,
    bool currentStatus,
    String nom,
    String prenom,
  ) async {
    try {
      await _firestore.collection('utilisateurs').doc(id).update({
        'actif': !currentStatus,
        'dateModification': FieldValue.serverTimestamp(),
      });
      _showSuccessMessage(
        currentStatus
            ? 'Utilisateur "$prenom $nom" désactivé'
            : 'Utilisateur "$prenom $nom" activé',
      );
    } catch (e) {
      _showErrorMessage('Erreur: ${e.toString()}');
    }
  }

  // Fonctions utilitaires pour les messages
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Fonction pour nettoyer le formulaire
  void _clearForm() {
    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();
    _telephoneController.clear();
    _selectedRole = 'Utilisateur';
    _isActive = true;
  }

  // Fonction pour pré-remplir le formulaire lors de la modification
  void _fillForm(Map<String, dynamic> userData) {
    _nomController.text = userData['nom'] ?? '';
    _prenomController.text = userData['prenom'] ?? '';
    _emailController.text = userData['email'] ?? '';
    _telephoneController.text = userData['telephone'] ?? '';
    _selectedRole = userData['role'] ?? 'Utilisateur';
    _isActive = userData['actif'] ?? true;
  }

  // Dialog pour ajouter/modifier un utilisateur avec UI corrigée
  void _showUserDialog({String? userId, Map<String, dynamic>? userData}) {
    if (userData != null) {
      _fillForm(userData);
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Container(
                    width: double.maxFinite,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                      maxWidth: 500,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header du dialog
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                userId == null ? Icons.person_add : Icons.edit,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  userId == null
                                      ? 'Ajouter un utilisateur'
                                      : 'Modifier l\'utilisateur',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed:
                                    _isLoading
                                        ? null
                                        : () {
                                          _clearForm();
                                          Navigator.of(context).pop();
                                        },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Contenu du formulaire
                        Flexible(
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Nom
                                  TextFormField(
                                    controller: _nomController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nom *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.words,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Le nom est requis';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'Le nom doit contenir au moins 2 caractères';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Prénom
                                  TextFormField(
                                    controller: _prenomController,
                                    decoration: const InputDecoration(
                                      labelText: 'Prénom *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person_outline),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.words,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Le prénom est requis';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'Le prénom doit contenir au moins 2 caractères';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Email
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.email),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'L\'email est requis';
                                      }
                                      if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(value.trim())) {
                                        return 'Format d\'email invalide';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Téléphone
                                  TextFormField(
                                    controller: _telephoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Téléphone',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.phone),
                                      hintText: '+226 XX XX XX XX',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        if (value.length < 8) {
                                          return 'Numéro de téléphone trop court';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Rôle
                                  DropdownButtonFormField<String>(
                                    value: _selectedRole,
                                    decoration: const InputDecoration(
                                      labelText: 'Rôle',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.verified_user),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Administrateur',
                                        child: Text('Administrateur'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Gestionnaire',
                                        child: Text('Gestionnaire'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Utilisateur',
                                        child: Text('Utilisateur'),
                                      ),
                                    ],
                                    onChanged:
                                        (value) => setState(
                                          () => _selectedRole = value!,
                                        ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Statut actif - Version améliorée
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                _isActive
                                                    ? Icons.check_circle
                                                    : Icons.block,
                                                color:
                                                    _isActive
                                                        ? Colors.green
                                                        : Colors.red,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Statut de l\'utilisateur',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const Spacer(),
                                              Switch(
                                                value: _isActive,
                                                onChanged:
                                                    (value) => setState(
                                                      () => _isActive = value,
                                                    ),
                                                activeColor: Colors.green,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _isActive
                                                ? 'L\'utilisateur peut se connecter à l\'application'
                                                : 'L\'utilisateur ne pourra pas se connecter',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Actions du dialog
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed:
                                    _isLoading
                                        ? null
                                        : () {
                                          _clearForm();
                                          Navigator.of(context).pop();
                                        },
                                child: const Text('Annuler'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed:
                                    _isLoading
                                        ? null
                                        : () {
                                          if (userId == null) {
                                            _ajouterUtilisateur(setState);
                                          } else {
                                            _modifierUtilisateur(
                                              userId,
                                              setState,
                                            );
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              userId == null
                                                  ? Icons.add
                                                  : Icons.save,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              userId == null
                                                  ? 'Ajouter'
                                                  : 'Modifier',
                                            ),
                                          ],
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: const Color(0xFF2E3A47),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche améliorée
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, prénom ou email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                        : null,
              ),
              onChanged:
                  (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          // Liste des utilisateurs
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('utilisateurs')
                      .orderBy('dateCreation', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Chargement des utilisateurs...'),
                      ],
                    ),
                  );
                }

                final users =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nom = (data['nom'] ?? '').toLowerCase();
                      final prenom = (data['prenom'] ?? '').toLowerCase();
                      final email = (data['email'] ?? '').toLowerCase();

                      return _searchQuery.isEmpty ||
                          nom.contains(_searchQuery) ||
                          prenom.contains(_searchQuery) ||
                          email.contains(_searchQuery);
                    }).toList();

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Aucun utilisateur trouvé'
                              : 'Aucun résultat pour "$_searchQuery"',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Text('Effacer la recherche'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final userId = doc.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor:
                              data['actif'] == true
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                          child:
                              data['actif'] == true
                                  ? Icon(
                                    Icons.person,
                                    color: Colors.green.shade700,
                                    size: 28,
                                  )
                                  : Icon(
                                    Icons.person_off,
                                    color: Colors.red.shade700,
                                    size: 28,
                                  ),
                        ),
                        title: Text(
                          '${data['prenom'] ?? ''} ${data['nom'] ?? ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(child: Text(data['email'] ?? '')),
                              ],
                            ),
                            if (data['telephone'] != null &&
                                data['telephone'].toString().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(data['telephone']),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(
                                      data['role'],
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_user,
                                        size: 14,
                                        color: _getRoleColor(data['role']),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        data['role'] ?? 'Utilisateur',
                                        style: TextStyle(
                                          color: _getRoleColor(data['role']),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (data['actif'] == true
                                            ? Colors.green
                                            : Colors.red)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        data['actif'] == true
                                            ? Icons.check_circle
                                            : Icons.block,
                                        size: 14,
                                        color:
                                            data['actif'] == true
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        data['actif'] == true
                                            ? 'Actif'
                                            : 'Inactif',
                                        style: TextStyle(
                                          color:
                                              data['actif'] == true
                                                  ? Colors.green
                                                  : Colors.red,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            final nom = data['nom'] ?? '';
                            final prenom = data['prenom'] ?? '';

                            switch (value) {
                              case 'modifier':
                                _showUserDialog(userId: userId, userData: data);
                                break;
                              case 'toggle_status':
                                _toggleUserStatus(
                                  userId,
                                  data['actif'] ?? true,
                                  nom,
                                  prenom,
                                );
                                break;
                              case 'supprimer':
                                _supprimerUtilisateur(userId, nom, prenom);
                                break;
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'modifier',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('Modifier'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'toggle_status',
                                  child: Row(
                                    children: [
                                      Icon(
                                        data['actif'] == true
                                            ? Icons.block
                                            : Icons.check_circle,
                                        color:
                                            data['actif'] == true
                                                ? Colors.orange
                                                : Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        data['actif'] == true
                                            ? 'Désactiver'
                                            : 'Activer',
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'supprimer',
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserDialog(),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'Administrateur':
        return Colors.red.shade600;
      case 'Gestionnaire':
        return Colors.orange.shade600;
      default:
        return Colors.blue.shade600;
    }
  }
}
