// widgets/send_notification_dialog.dart
import 'package:flutter/material.dart';
import 'dart:math';

import '../models/notification_model.dart';

class SendNotificationDialog extends StatefulWidget {
  const SendNotificationDialog({super.key});

  @override
  State<SendNotificationDialog> createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<SendNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  NotificationType _selectedType = NotificationType.general;
  NotificationPriority _selectedPriority = NotificationPriority.medium;
  String _targetAudience = 'all'; // all, users, ufr, individual
  String? _selectedUfrId;
  String? _selectedUserId;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  static const Color _primaryColor = Color(0xFF4A90E2);

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.send, color: _primaryColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Envoyer une notification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contenu scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Titre *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le titre est obligatoire';
                          }
                          if (value.length > 100) {
                            return 'Le titre ne peut pas dépasser 100 caractères';
                          }
                          return null;
                        },
                        maxLength: 100,
                      ),
                      const SizedBox(height: 16),

                      // Message
                      TextFormField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Message *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.message),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le message est obligatoire';
                          }
                          if (value.length > 500) {
                            return 'Le message ne peut pas dépasser 500 caractères';
                          }
                          return null;
                        },
                        maxLength: 500,
                      ),
                      const SizedBox(height: 16),

                      // Type (dropdown complet)
                      DropdownButtonFormField<NotificationType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        isExpanded:
                            true, // Important : permet au dropdown de prendre toute la largeur
                        items:
                            NotificationType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min, // Évite le débordement
                                  children: [
                                    Icon(_getTypeIcon(type), size: 16),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      // Permet au texte de s'adapter
                                      child: Text(
                                        _getTypeDisplayName(type),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Priorité (dropdown complet)
                      DropdownButtonFormField<NotificationPriority>(
                        value: _selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priorité',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.priority_high),
                        ),
                        isExpanded:
                            true, // Important : permet au dropdown de prendre toute la largeur
                        items:
                            NotificationPriority.values.map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min, // Évite le débordement
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(priority),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      // Permet au texte de s'adapter
                                      child: Text(
                                        _getPriorityDisplayName(priority),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Destinataires
                      const Text(
                        'Destinataires',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAudienceSelector(),
                      const SizedBox(height: 16),

                      // Programmation (optionnelle)
                      Card(
                        child: ExpansionTile(
                          leading: const Icon(Icons.schedule),
                          title: const Text('Programmer l\'envoi (optionnel)'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: _selectScheduledDate,
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'Date',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(
                                                Icons.calendar_today,
                                              ),
                                            ),
                                            child: Text(
                                              _scheduledDate != null
                                                  ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                                                  : 'Sélectionner une date',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: InkWell(
                                          onTap: _selectScheduledTime,
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'Heure',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(
                                                Icons.access_time,
                                              ),
                                            ),
                                            child: Text(
                                              _scheduledTime != null
                                                  ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                                                  : 'Sélectionner une heure',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (_scheduledDate != null ||
                                      _scheduledTime != null)
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _scheduledDate = null;
                                              _scheduledTime = null;
                                            });
                                          },
                                          icon: const Icon(Icons.clear),
                                          label: const Text('Effacer'),
                                        ),
                                      ],
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

              // Boutons d'action
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _sendNotification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Envoyer'),
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

  Widget _buildAudienceSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          value: 'all',
          groupValue: _targetAudience,
          title: const Text('Tous les utilisateurs'),
          subtitle: const Text('Envoyer à tous les utilisateurs du système'),
          onChanged: (value) {
            setState(() {
              _targetAudience = value!;
              _selectedUfrId = null;
              _selectedUserId = null;
            });
          },
        ),
        RadioListTile<String>(
          value: 'ufr',
          groupValue: _targetAudience,
          title: const Text('UFR spécifique'),
          subtitle: const Text('Envoyer à tous les membres d\'une UFR'),
          onChanged: (value) {
            setState(() {
              _targetAudience = value!;
              _selectedUserId = null;
            });
          },
        ),
        if (_targetAudience == 'ufr') ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedUfrId,
            decoration: const InputDecoration(
              labelText: 'Sélectionner une UFR',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            isExpanded: true, // Correction appliquée ici aussi
            items: const [
              DropdownMenuItem(
                value: 'ufr1',
                child: Text('UFR Sciences et Technologies'),
              ),
              DropdownMenuItem(
                value: 'ufr2',
                child: Text('UFR Lettres et Sciences Humaines'),
              ),
              DropdownMenuItem(
                value: 'ufr3',
                child: Text('UFR Sciences Économiques'),
              ),
              DropdownMenuItem(
                value: 'ufr4',
                child: Text('UFR Sciences Juridiques'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedUfrId = value;
              });
            },
            validator: (value) {
              if (_targetAudience == 'ufr' &&
                  (value == null || value.isEmpty)) {
                return 'Veuillez sélectionner une UFR';
              }
              return null;
            },
          ),
        ],
        RadioListTile<String>(
          value: 'individual',
          groupValue: _targetAudience,
          title: const Text('Utilisateur spécifique'),
          subtitle: const Text('Envoyer à un utilisateur en particulier'),
          onChanged: (value) {
            setState(() {
              _targetAudience = value!;
              _selectedUfrId = null;
            });
          },
        ),
        if (_targetAudience == 'individual') ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedUserId,
            decoration: const InputDecoration(
              labelText: 'Sélectionner un utilisateur',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            isExpanded: true, // Correction appliquée ici aussi
            items: const [
              DropdownMenuItem(
                value: 'user1',
                child: Text('Prof. Martin Dupont'),
              ),
              DropdownMenuItem(
                value: 'user2',
                child: Text('Dr. Sarah Johnson'),
              ),
              DropdownMenuItem(
                value: 'user3',
                child: Text('Prof. Ahmed Benali'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedUserId = value;
              });
            },
            validator: (value) {
              if (_targetAudience == 'individual' &&
                  (value == null || value.isEmpty)) {
                return 'Veuillez sélectionner un utilisateur';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Future<void> _selectScheduledDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _scheduledDate = date;
      });
    }
  }

  Future<void> _selectScheduledTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _scheduledTime = time;
      });
    }
  }

  void _sendNotification() {
    if (_formKey.currentState!.validate()) {
      DateTime? scheduledDateTime;
      if (_scheduledDate != null && _scheduledTime != null) {
        scheduledDateTime = DateTime(
          _scheduledDate!.year,
          _scheduledDate!.month,
          _scheduledDate!.day,
          _scheduledTime!.hour,
          _scheduledTime!.minute,
        );
      }

      final notification = NotificationModel(
        id: _generateId(),
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: _selectedType,
        priority: _selectedPriority,
        createdAt: DateTime.now(),
        targetUserId: _targetAudience == 'individual' ? _selectedUserId : null,
        targetUfrId: _targetAudience == 'ufr' ? _selectedUfrId : null,
        scheduledAt: scheduledDateTime,
        senderId: 'admin_001',
        timestamp: null, // ID de l'administrateur connecté
      );

      Navigator.pop(context, notification);
    }
  }

  String _generateId() {
    return 'notif_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Méthodes utilitaires (reprises de l'écran principal)
  String _getTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return 'Général';
      case NotificationType.roomBooking:
        return 'Réservation';
      case NotificationType.roomCancellation:
        return 'Annulation';
      case NotificationType.maintenanceAlert:
        return 'Maintenance';
      case NotificationType.systemUpdate:
        return 'Mise à jour';
      case NotificationType.userUpdate:
        return 'Utilisateur';
      case NotificationType.ufrUpdate:
        return 'UFR';
      case NotificationType.emergency:
        return 'Urgence';
    }
  }

  String _getPriorityDisplayName(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return 'Faible';
      case NotificationPriority.medium:
        return 'Moyen';
      case NotificationPriority.high:
        return 'Élevé';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.green;
      case NotificationPriority.medium:
        return Colors.orange;
      case NotificationPriority.high:
        return Colors.red;
      case NotificationPriority.urgent:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return Icons.info;
      case NotificationType.roomBooking:
        return Icons.event;
      case NotificationType.roomCancellation:
        return Icons.event_busy;
      case NotificationType.maintenanceAlert:
        return Icons.build;
      case NotificationType.systemUpdate:
        return Icons.system_update;
      case NotificationType.userUpdate:
        return Icons.person;
      case NotificationType.ufrUpdate:
        return Icons.school;
      case NotificationType.emergency:
        return Icons.warning;
    }
  }
}
