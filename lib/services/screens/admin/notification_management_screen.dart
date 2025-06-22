// services/screens/admin/notification_management_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';

import '../../../models/notification_model.dart';
//import '../../../services/notification_service.dart';
import '../../../widgets/send_notification_dialog.dart';

class NotificationManagementScreen extends StatefulWidget {
  const NotificationManagementScreen({super.key});

  @override
  State<NotificationManagementScreen> createState() =>
      _NotificationManagementScreenState();
}

class _NotificationManagementScreenState
    extends State<NotificationManagementScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  // StreamSubscription pour éviter les fuites mémoire
  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    // CORRECTION 1: Annuler l'abonnement au stream pour éviter setState() après dispose()
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  void _loadNotifications() {
    _notificationService.initializeNotifications();

    // CORRECTION 1: Utiliser StreamSubscription pour pouvoir l'annuler
    _notificationsSubscription = _notificationService.notificationsStream
        .listen((notifications) {
          // Vérifier si le widget est encore monté avant d'appeler setState
          if (mounted) {
            setState(() {
              _notifications = notifications;
              _isLoading = false;
            });
          }
        });
  }

  List<NotificationModel> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'unread':
        return _notifications.where((n) => !n.isRead).toList();
      case 'read':
        return _notifications.where((n) => n.isRead).toList();
      case 'high_priority':
        return _notifications
            .where(
              (n) =>
                  n.priority == NotificationPriority.high ||
                  n.priority == NotificationPriority.urgent,
            )
            .toList();
      default:
        return _notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Notifications'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _notificationService.markAllAsRead();
                  break;
                case 'delete_all':
                  _showDeleteAllDialog();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.done_all),
                        SizedBox(width: 8),
                        Text('Marquer tout comme lu'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Supprimer tout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres et statistiques
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Statistiques
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        _notifications.length.toString(),
                        Icons.notifications,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Non lues',
                        _notifications
                            .where((n) => !n.isRead)
                            .length
                            .toString(),
                        Icons.notifications_active,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Urgentes',
                        _notifications
                            .where(
                              (n) => n.priority == NotificationPriority.urgent,
                            )
                            .length
                            .toString(),
                        Icons.priority_high,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // CORRECTION 2: Améliorer la mise en page des filtres
                Row(
                  children: [
                    const Text(
                      'Filtrer par:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          isDense: true,
                        ),
                        // CORRECTION 2: Utiliser isExpanded pour éviter le débordement
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Toutes les notifications'),
                          ),
                          DropdownMenuItem(
                            value: 'unread',
                            child: Text('Non lues'),
                          ),
                          DropdownMenuItem(value: 'read', child: Text('Lues')),
                          DropdownMenuItem(
                            value: 'high_priority',
                            child: Text('Priorité élevée'),
                          ),
                        ],
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              _selectedFilter = value!;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste des notifications
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _filteredNotifications[index];
                        return _buildNotificationCard(notification);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSendNotificationDialog,
        backgroundColor: const Color(0xFF4A90E2),
        icon: const Icon(Icons.send, color: Colors.white),
        label: const Text(
          'Nouvelle notification',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getPriorityColor(notification.priority).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(notification.type),
            color: _getPriorityColor(notification.priority),
            size: 24,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(notification.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(notification.priority),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getPriorityDisplayName(notification.priority),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                if (!notification.isRead) {
                  _notificationService.markAsRead(notification.id);
                }
                break;
              case 'delete':
                _showDeleteDialog(notification);
                break;
            }
          },
          itemBuilder:
              (context) => [
                if (!notification.isRead)
                  const PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        Icon(Icons.done),
                        SizedBox(width: 8),
                        Text('Marquer comme lu'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune notification trouvée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les notifications apparaîtront ici',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showSendNotificationDialog() async {
    final result = await showDialog<NotificationModel>(
      context: context,
      builder: (context) => const SendNotificationDialog(),
    );

    if (result != null && mounted) {
      await _notificationService.sendNotification(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer la notification'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer "${notification.title}" ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _notificationService.deleteNotification(notification.id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer toutes les notifications'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer toutes les notifications ? Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _notificationService.deleteAllNotifications();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Supprimer tout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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
