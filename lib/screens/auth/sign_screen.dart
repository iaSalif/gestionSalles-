import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestion_salles/routes/routes.dart';
import 'package:gestion_salles/services/auth_services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomController = TextEditingController();
  final _departementController = TextEditingController();
  final _ufrController = TextEditingController();

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State variables
  String _selectedRole = 'CSAF';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _roles = [
    'Chef de département/Coordonnateur',
    'Chef de scolarité',
    'Directeur de patrimoine',
    'CSAF',
    'Directeur Adjoint',
    'Administrateur',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomController.dispose();
    _departementController.dispose();
    _ufrController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      if (kDebugMode) {
        print('Validation du formulaire échouée');
      }
      return;
    }

    setState(() => _isLoading = true);
    if (kDebugMode) {
      print('Début de l\'inscription...');
    }

    try {
      final authResult = await AuthService().createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nom: _nomController.text.trim(),
        role: _selectedRole,
        departement: _departementController.text.trim(),
        ufr: _ufrController.text.trim().isNotEmpty ? _ufrController.text.trim() : null,
        fullName: '',
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          if (kDebugMode) {
            print('Timeout atteint pour createUserWithEmailAndPassword');
          }
          throw Exception('Délai d\'attente dépassé lors de l\'inscription');
        },
      );

      if (kDebugMode) {
        print('Résultat reçu : $authResult');
      }

      if (!mounted) return;

      if (authResult != null) {
        bool isSuccess = authResult['success'] == true;
        String? message = authResult['message'] as String?;
        dynamic user = authResult['user'];

        if (kDebugMode) {
          print('Traitement: success=$isSuccess, message=$message, user=${user?.toString()}');
        }

        if (isSuccess) {
          if (kDebugMode) {
            print('Inscription réussie');
          }

          // Attendre la synchronisation des données utilisateur
          Map<String, dynamic>? userData;
          int retries = 0;
          const maxRetries = 5;

          while (userData == null && retries < maxRetries) {
            if (kDebugMode) {
              print('Tentative ${retries + 1}/$maxRetries de récupération des données utilisateur');
            }

            try {
              userData = await AuthService().getCurrentUserData().timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  if (kDebugMode) {
                    print('Timeout atteint pour getCurrentUserData');
                  }
                  return null;
                },
              );
            } catch (e) {
              if (kDebugMode) {
                print('Erreur lors de la récupération des données utilisateur: $e');
              }
            }

            if (userData == null) {
              await Future.delayed(const Duration(milliseconds: 500));
              retries++;
            }
          }

          if (userData != null) {
            if (kDebugMode) {
              print('Données utilisateur récupérées : $userData');
            }
            await _showSuccessDialog(message ?? 'Compte créé avec succès !');
          } else {
            if (kDebugMode) {
              print('Échec de la récupération des données utilisateur après $maxRetries tentatives');
            }
            _showErrorMessage('Erreur : profil utilisateur non synchronisé. Vérifiez votre connexion.');
          }
        } else {
          if (kDebugMode) {
            print('Échec de l\'inscription : $message');
          }
          _showErrorMessage(message ?? 'Échec de l\'inscription. Veuillez réessayer.');
        }
      } else {
        if (kDebugMode) {
          print('authResult est null');
        }
        _showErrorMessage('Aucune réponse reçue du serveur. Veuillez réessayer.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur inattendue capturée : $e');
      }
      String errorMessage = 'Une erreur inattendue s\'est produite';

      final errorString = e.toString().toLowerCase();
      if (errorString.contains('network')) {
        errorMessage = 'Problème de connexion réseau. Vérifiez votre internet.';
      } else if (errorString.contains('permission-denied')) {
        errorMessage = 'Erreur de permission Firestore. Contactez l\'administrateur.';
      } else if (errorString.contains('email-already-in-use')) {
        errorMessage = 'Cet email est déjà utilisé.';
      } else if (errorString.contains('timeout')) {
        errorMessage = 'Délai d\'attente dépassé. Vérifiez votre connexion ou réessayez.';
      }

      _showErrorMessage(errorMessage);
    } finally {
      if (mounted) {
        if (kDebugMode) {
          print('Fin de l\'inscription, _isLoading = false');
        }
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    print('Affichage du dialogue de succès : $message');
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        print('Construction du dialogue');
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.shade600,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Inscription réussie !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Vous allez être redirigé vers la page de connexion.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    print('Clic sur Se connecter, navigation vers LoginScreen');
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    print('Affichage du message d\'erreur : $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Hero(
              tag: 'auth_logo',
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_add,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Créer un compte',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Rejoignez la plateforme de gestion des salles',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 20,
    offset: const Offset(0, 4),
    ),
    ],
    ),
    child: Form(
    key: _formKey,
    child: Column(
    children: [
    _buildTextField(
    controller: _nomController,
    label: 'Nom complet',
    icon: Icons.person_outline,
    validator: (value) {
    if (value == null || value.trim().isEmpty) {
    return 'Veuillez entrer votre nom';
    }
    if (value.trim().length < 2) {
    return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
    },
    ),
    const SizedBox(height: 20),
    _buildTextField(
    controller: _emailController,
    label: 'Adresse e-mail',
    icon: Icons.email_outlined,
    keyboardType: TextInputType.emailAddress,
    validator: (value) {
    if (value == null || value.trim().isEmpty) {
    return 'Veuillez entrer votre email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Format d\'email invalide';
    }
    return null;
    },
    ),
    const SizedBox(height: 20),
    _buildTextField(
    controller: _passwordController,
    label: 'Mot de passe',
    icon: Icons.lock_outline,
    obscureText: _obscurePassword,
    suffixIcon: IconButton(
    icon: Icon(
    _obscurePassword ? Icons.visibility_off : Icons.visibility,
    color: Colors.grey.shade600,
    ),
    onPressed: () {
    setState(() {
    _obscurePassword = !_obscurePassword;
    });
    },
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Veuillez entrer un mot de passe';
    }
    if (value.length < 6) {
    return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
    },
    ),
    const SizedBox(height: 20),
    _buildTextField(
    controller: _confirmPasswordController,
    label: 'Confirmer le mot de passe',
    icon: Icons.lock_outline,
    obscureText: _obscureConfirmPassword,
    suffixIcon: IconButton(
    icon: Icon(
    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
    color: Colors.grey.shade600,
    ),
    onPressed: () {
    setState(() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    });
    },
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Veuillez confirmer votre mot de passe';
    }
    if (value != _passwordController.text) {
    return 'Les mots de passe ne correspondent pas';
    }
    return null;
    },
    ),
      const SizedBox(height: 20),
      _buildRoleDropdown(),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _departementController,
        label: 'Département',
        icon: Icons.business_outlined,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Veuillez entrer votre département';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _ufrController,
        label: 'UFR (optionnel)',
        icon: Icons.school_outlined,
        validator: null, // Champ optionnel
      ),
    ],
    ),
    ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF1E88E5),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        decoration: InputDecoration(
          labelText: 'Rôle',
          prefixIcon: Icon(Icons.work_outline, color: Colors.grey.shade600),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF1E88E5),
              width: 2,
            ),
          ),
        ),
        items: _roles.map((String role) {
          return DropdownMenuItem<String>(
            value: role,
            child: Text(
              role,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedRole = newValue;
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez sélectionner un rôle';
          }
          return null;
        },
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
        isExpanded: true,
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: _isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Inscription en cours...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
            : const Text(
          'Créer le compte',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Déjà un compte ? ',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(
                      color: Color(0xFF1E88E5),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey.shade700,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildForm(),
                      const SizedBox(height: 24),
                      _buildSignUpButton(),
                      _buildLoginLink(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}