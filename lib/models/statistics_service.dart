import 'dart:async';
import 'dart:math';

// Models pour les statistiques
class StatisticModel {
  final String id;
  final String label;
  final double value;
  final String unit;
  final DateTime timestamp;
  final String category;

  StatisticModel({
    required this.id,
    required this.label,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.category,
  });

  factory StatisticModel.fromJson(Map<String, dynamic> json) {
    return StatisticModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
    };
  }
}

class UsageDataPoint {
  final DateTime date;
  final double value;
  final String category;

  UsageDataPoint({
    required this.date,
    required this.value,
    required this.category,
  });
}

class RoomStatistic {
  final String roomId;
  final String roomName;
  final String roomType;
  final double usagePercentage;
  final int totalBookings;
  final double averageDuration;
  final double rating;

  RoomStatistic({
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.usagePercentage,
    required this.totalBookings,
    required this.averageDuration,
    required this.rating,
  });
}

class UserStatistic {
  final String userId;
  final String userName;
  final String userRole;
  final int totalBookings;
  final double averageBookingDuration;
  final DateTime lastActivity;
  final double satisfactionScore;

  UserStatistic({
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.totalBookings,
    required this.averageBookingDuration,
    required this.lastActivity,
    required this.satisfactionScore,
  });
}

enum StatisticPeriod {
  today,
  thisWeek,
  thisMonth,
  thisQuarter,
  thisYear,
  custom,
}

class StatisticsService {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  final StreamController<List<StatisticModel>> _statisticsController =
      StreamController<List<StatisticModel>>.broadcast();

  Stream<List<StatisticModel>> get statisticsStream =>
      _statisticsController.stream;

  final List<StatisticModel> _statistics = [];
  final Random _random = Random();

  // Initialiser le service avec des données de test
  void initialize() {
    _generateMockData();
    _startPeriodicUpdates();
  }

  void _generateMockData() {
    final now = DateTime.now();
    final random = Random();

    // Générer des statistiques pour les 30 derniers jours
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));

      _statistics.addAll([
        StatisticModel(
          id: 'bookings_${i}',
          label: 'Réservations',
          value: (20 + random.nextInt(30)).toDouble(),
          unit: 'réservations',
          timestamp: date,
          category: 'bookings',
        ),
        StatisticModel(
          id: 'usage_${i}',
          label: 'Taux d\'utilisation',
          value: (50 + random.nextInt(40)).toDouble(),
          unit: '%',
          timestamp: date,
          category: 'usage',
        ),
        StatisticModel(
          id: 'users_${i}',
          label: 'Utilisateurs actifs',
          value: (10 + random.nextInt(20)).toDouble(),
          unit: 'utilisateurs',
          timestamp: date,
          category: 'users',
        ),
      ]);
    }

    _statisticsController.add(_statistics);
  }

  void _startPeriodicUpdates() {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _updateStatistics();
    });
  }

  void _updateStatistics() {
    // Simuler la mise à jour des statistiques en temps réel
    final now = DateTime.now();
    final newStats = [
      StatisticModel(
        id: 'bookings_current',
        label: 'Réservations',
        value: (20 + _random.nextInt(30)).toDouble(),
        unit: 'réservations',
        timestamp: now,
        category: 'bookings',
      ),
      StatisticModel(
        id: 'usage_current',
        label: 'Taux d\'utilisation',
        value: (50 + _random.nextInt(40)).toDouble(),
        unit: '%',
        timestamp: now,
        category: 'usage',
      ),
    ];

    _statistics.addAll(newStats);
    _statisticsController.add(_statistics);
  }

  // Obtenir les statistiques générales
  Future<Map<String, dynamic>> getOverviewStatistics(
    StatisticPeriod period,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simuler un appel API

    return {
      'totalBookings': 1247 + _random.nextInt(100),
      'occupancyRate': 78 + _random.nextInt(15),
      'activeUsers': 156 + _random.nextInt(20),
      'roomsInUse': '${35 + _random.nextInt(7)}/42',
      'averageBookingDuration': 2.5 + (_random.nextDouble() * 2),
      'cancellationRate': 8 + _random.nextInt(5),
      'peakHours': '14h-16h',
      'mostBookedRoom': 'Amphi A',
      'trends': {
        'bookings': '+12%',
        'occupancy': '+5%',
        'users': '+8%',
        'rooms': '+2%',
      },
    };
  }

  // Obtenir les données d'utilisation pour les graphiques
  Future<List<UsageDataPoint>> getUsageData(StatisticPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final data = <UsageDataPoint>[];
    final now = DateTime.now();

    // Générer des données pour les 7 derniers jours
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      data.add(
        UsageDataPoint(
          date: date,
          value: 50 + _random.nextInt(40).toDouble(),
          category: 'daily_usage',
        ),
      );
    }

    return data;
  }

  // Obtenir les statistiques des salles
  Future<List<RoomStatistic>> getRoomStatistics(StatisticPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final rooms = [
      'Amphi A',
      'Amphi B',
      'Salle 201',
      'Salle 105',
      'Labo Info',
      'Salle 302',
      'Salle 204',
      'Salle TD1',
      'Salle TD2',
      'Bibliothèque',
    ];

    final roomTypes = [
      'Amphithéâtre',
      'Salle de cours',
      'Laboratoire',
      'Salle TD',
    ];

    return rooms.map((room) {
        return RoomStatistic(
          roomId: room.toLowerCase().replaceAll(' ', '_'),
          roomName: room,
          roomType: roomTypes[_random.nextInt(roomTypes.length)],
          usagePercentage: 30 + _random.nextInt(70).toDouble(),
          totalBookings: 50 + _random.nextInt(100),
          averageDuration: 1.5 + (_random.nextDouble() * 3),
          rating: 3.5 + (_random.nextDouble() * 1.5),
        );
      }).toList()
      ..sort((a, b) => b.usagePercentage.compareTo(a.usagePercentage));
  }

  // Obtenir les statistiques des utilisateurs
  Future<List<UserStatistic>> getUserStatistics(StatisticPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final users = [
      {'name': 'Dr. Martin', 'role': 'Professeur'},
      {'name': 'Sophie Dubois', 'role': 'Étudiante'},
      {'name': 'Jean Dupont', 'role': 'Professeur'},
      {'name': 'Marie Claire', 'role': 'Personnel'},
      {'name': 'Ahmed Hassan', 'role': 'Étudiant'},
      {'name': 'Lisa Wang', 'role': 'Étudiante'},
      {'name': 'Prof. Bernard', 'role': 'Professeur'},
      {'name': 'Ana Rodriguez', 'role': 'Personnel'},
    ];

    return users.map((user) {
        return UserStatistic(
          userId: user['name']!.toLowerCase().replaceAll(' ', '_'),
          userName: user['name']!,
          userRole: user['role']!,
          totalBookings: 5 + _random.nextInt(25),
          averageBookingDuration: 1.0 + (_random.nextDouble() * 3),
          lastActivity: DateTime.now().subtract(
            Duration(days: _random.nextInt(7)),
          ),
          satisfactionScore: 3.0 + (_random.nextDouble() * 2),
        );
      }).toList()
      ..sort((a, b) => b.totalBookings.compareTo(a.totalBookings));
  }

  // Obtenir les données pour le graphique en barres (activité par heure)
  Future<Map<int, int>> getHourlyActivity(StatisticPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final hourlyData = <int, int>{};
    for (int hour = 8; hour <= 18; hour++) {
      // Simuler plus d'activité aux heures de pointe (12h-16h)
      int baseActivity = 5;
      if (hour >= 12 && hour <= 16) {
        baseActivity = 15;
      } else if (hour >= 10 && hour <= 11 || hour >= 17 && hour <= 18) {
        baseActivity = 10;
      }

      hourlyData[hour] = baseActivity + _random.nextInt(10);
    }

    return hourlyData;
  }

  // Obtenir les données pour le graphique circulaire (répartition des types de salles)
  Future<Map<String, double>> getRoomTypeDistribution() async {
    await Future.delayed(const Duration(milliseconds: 150));

    return {
      'Amphithéâtres': 35.0,
      'Salles de cours': 25.0,
      'Salles TD': 20.0,
      'Laboratoires': 20.0,
    };
  }

  // Exporter les statistiques
  Future<bool> exportStatistics(String format, StatisticPeriod period) async {
    await Future.delayed(const Duration(seconds: 2)); // Simuler l'export

    // Ici vous pourriez implémenter la logique d'export réelle
    // Par exemple, générer un PDF ou un fichier Excel

    return _random.nextBool(); // Simuler succès/échec aléatoire
  }

  // Générer un rapport personnalisé
  Future<Map<String, dynamic>> generateCustomReport({
    required List<String> metrics,
    required StatisticPeriod period,
    required List<String> roomIds,
    required List<String> userTypes,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Ici vous pourriez implémenter la logique de génération de rapport personnalisé
    return {
      'reportId': 'custom_${DateTime.now().millisecondsSinceEpoch}',
      'metrics': metrics,
      'period': period.toString(),
      'roomIds': roomIds,
      'userTypes': userTypes,
      'generatedAt': DateTime.now().toIso8601String(),
      'status': 'generated',
    };
  }

  // Obtenir les métriques clés avec comparaison de période
  Future<Map<String, dynamic>> getKeyMetricsWithComparison(
    StatisticPeriod period,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      'currentPeriod': {
        'totalBookings': 1247,
        'occupancyRate': 78,
        'activeUsers': 156,
        'satisfaction': 4.6,
      },
      'previousPeriod': {
        'totalBookings': 1112,
        'occupancyRate': 74,
        'activeUsers': 144,
        'satisfaction': 4.4,
      },
      'growth': {
        'totalBookings': 12.1,
        'occupancyRate': 5.4,
        'activeUsers': 8.3,
        'satisfaction': 4.5,
      },
    };
  }

  // Nettoyer les ressources
  void dispose() {
    _statisticsController.close();
  }
}
