// models/notification_model.dart
import 'dart:async';
import 'dart:math';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final String? targetUserId;
  final String? targetUfrId;
  final String? relatedRoomId;
  final bool isRead;
  final bool isActive;
  final DateTime? scheduledAt;
  final String senderId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.targetUserId,
    this.targetUfrId,
    this.relatedRoomId,
    this.isRead = false,
    this.isActive = true,
    this.scheduledAt,
    required this.senderId,
    required timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == 'NotificationPriority.${json['priority']}',
      ),
      createdAt: DateTime.parse(json['createdAt']),
      targetUserId: json['targetUserId'],
      targetUfrId: json['targetUfrId'],
      relatedRoomId: json['relatedRoomId'],
      isRead: json['isRead'] ?? false,
      isActive: json['isActive'] ?? true,
      scheduledAt:
          json['scheduledAt'] != null
              ? DateTime.parse(json['scheduledAt'])
              : null,
      senderId: json['senderId'],
      timestamp: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'targetUserId': targetUserId,
      'targetUfrId': targetUfrId,
      'relatedRoomId': relatedRoomId,
      'isRead': isRead,
      'isActive': isActive,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'senderId': senderId,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    String? targetUserId,
    String? targetUfrId,
    String? relatedRoomId,
    bool? isRead,
    bool? isActive,
    DateTime? scheduledAt,
    String? senderId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      targetUserId: targetUserId ?? this.targetUserId,
      targetUfrId: targetUfrId ?? this.targetUfrId,
      relatedRoomId: relatedRoomId ?? this.relatedRoomId,
      isRead: isRead ?? this.isRead,
      isActive: isActive ?? this.isActive,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      senderId: senderId ?? this.senderId,
      timestamp: null,
    );
  }
}

enum NotificationType {
  general,
  roomBooking,
  roomCancellation,
  maintenanceAlert,
  systemUpdate,
  userUpdate,
  ufrUpdate,
  emergency,
}

enum NotificationPriority { low, medium, high, urgent }

// services/notification_service.dart

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationModel> _notifications = [];
  final StreamController<List<NotificationModel>> _notificationsController =
      StreamController<List<NotificationModel>>.broadcast();

  Stream<List<NotificationModel>> get notificationsStream =>
      _notificationsController.stream;
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  // Simuler l'ajout de notifications initiales
  void initializeNotifications() {
    _notifications.addAll([
      NotificationModel(
        id: _generateId(),
        title: 'Maintenance programmée',
        message:
            'La salle A101 sera fermée pour maintenance le 15 juin de 14h à 16h.',
        type: NotificationType.maintenanceAlert,
        priority: NotificationPriority.high,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        relatedRoomId: 'room_a101',
        senderId: 'admin_001',
        timestamp: null,
      ),
      NotificationModel(
        id: _generateId(),
        title: 'Nouveau utilisateur',
        message: 'Un nouvel enseignant a été ajouté au système.',
        type: NotificationType.userUpdate,
        priority: NotificationPriority.medium,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        senderId: 'admin_001',
        timestamp: null,
      ),
      NotificationModel(
        id: _generateId(),
        title: 'Réservation annulée',
        message:
            'La réservation de la salle B203 pour demain à 10h a été annulée.',
        type: NotificationType.roomCancellation,
        priority: NotificationPriority.medium,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        relatedRoomId: 'room_b203',
        senderId: 'user_123',
        isRead: true,
        timestamp: null,
      ),
    ]);
    _notificationsController.add(_notifications);
  }

  Future<void> sendNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
    _notificationsController.add(_notifications);
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notificationsController.add(_notifications);
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _notificationsController.add(_notifications);
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notificationsController.add(_notifications);
  }

  Future<void> deleteAllNotifications() async {
    _notifications.clear();
    _notificationsController.add(_notifications);
  }

  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  List<NotificationModel> getNotificationsByPriority(
    NotificationPriority priority,
  ) {
    return _notifications.where((n) => n.priority == priority).toList();
  }

  String _generateId() {
    return 'notif_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  void dispose() {
    _notificationsController.close();
  }
}
