import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Couleurs du thème
  static const Color _primaryColor = Color(0xFF4A90E2);
  static const Color _backgroundColor = Color(0xFFF5F7FA);
  static const Color _textColor = Color(0xFF2E3A47);
  static const Color _cardColor = Colors.white;

  // Période sélectionnée pour les statistiques
  String _selectedPeriod = 'Cette semaine';
  final List<String> _periods = [
    'Aujourd\'hui',
    'Cette semaine',
    'Ce mois',
    'Ce trimestre',
    'Cette année'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPeriodSelector(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildRoomsTab(),
                _buildUsersTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Statistiques',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _primaryColor,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.download, color: Colors.white),
          onPressed: _exportStatistics,
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshStatistics,
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _cardColor,
      child: Row(
        children: [
          const Text(
            'Période : ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              isExpanded: true,
              underline: Container(),
              items: _periods.map((String period) {
                return DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPeriod = newValue;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: _cardColor,
      child: TabBar(
        controller: _tabController,
        labelColor: _primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: _primaryColor,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Vue d\'ensemble'),
          Tab(text: 'Salles'),
          Tab(text: 'Utilisateurs'),
          Tab(text: 'Rapports'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverviewCards(),
          const SizedBox(height: 20),
          _buildUsageChart(),
          const SizedBox(height: 20),
          _buildTopMetrics(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        double childAspectRatio = constraints.maxWidth > 600 ? 1.2 : 1.8;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              'Réservations totales',
              '1,247',
              Icons.event,
              _primaryColor,
              '+12%',
            ),
            _buildStatCard(
              'Taux d\'occupation',
              '78%',
              Icons.pie_chart,
              const Color(0xFF4CAF50),
              '+5%',
            ),
            _buildStatCard(
              'Utilisateurs actifs',
              '156',
              Icons.people,
              const Color(0xFFFF9800),
              '+8%',
            ),
            _buildStatCard(
              'Salles utilisées',
              '35/42',
              Icons.meeting_room,
              const Color(0xFF9C27B0),
              '+2%',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String trend) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Utilisation des salles par jour',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 65),
                      const FlSpot(1, 78),
                      const FlSpot(2, 82),
                      const FlSpot(3, 75),
                      const FlSpot(4, 88),
                      const FlSpot(5, 45),
                      const FlSpot(6, 32),
                    ],
                    isCurved: true,
                    color: _primaryColor,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: _primaryColor.withOpacity(0.1),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: _primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métriques clés',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Durée moyenne de réservation', '2h 30min', Icons.access_time),
          _buildMetricRow('Taux d\'annulation', '8%', Icons.cancel),
          _buildMetricRow('Pic d\'utilisation', '14h-16h', Icons.trending_up),
          _buildMetricRow('Salle la plus demandée', 'Amphi A', Icons.star),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: _primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: _textColor,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRoomUsageChart(),
          const SizedBox(height: 20),
          _buildRoomsList(),
        ],
      ),
    );
  }

  Widget _buildRoomUsageChart() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition de l\'utilisation des salles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 35,
                    title: '35%',
                    color: _primaryColor,
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: '25%',
                    color: const Color(0xFF4CAF50),
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: const Color(0xFFFF9800),
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: const Color(0xFF9C27B0),
                    radius: 60,
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend(),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildLegendItem('Amphithéâtres', _primaryColor),
            _buildLegendItem('Salles de cours', const Color(0xFF4CAF50)),
            _buildLegendItem('Salles TD', const Color(0xFFFF9800)),
            _buildLegendItem('Laboratoires', const Color(0xFF9C27B0)),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 9),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top 5 des salles les plus utilisées',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildRoomItem('Amphi A', '95%', Icons.trending_up, Colors.green),
          _buildRoomItem('Salle 201', '87%', Icons.trending_up, Colors.green),
          _buildRoomItem('Labo Info', '78%', Icons.trending_up, Colors.orange),
          _buildRoomItem('Salle 105', '65%', Icons.trending_down, Colors.red),
          _buildRoomItem('Amphi B', '52%', Icons.trending_down, Colors.red),
        ],
      ),
    );
  }

  Widget _buildRoomItem(String roomName, String usage, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              roomName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textColor,
              ),
            ),
          ),
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            usage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserStatsCards(),
          const SizedBox(height: 20),
          _buildUserActivityChart(),
          const SizedBox(height: 20),
          _buildTopUsers(),
        ],
      ),
    );
  }

  Widget _buildUserStatsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        double childAspectRatio = constraints.maxWidth > 600 ? 1.2 : 1.8;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              'Nouveaux utilisateurs',
              '24',
              Icons.person_add,
              const Color(0xFF4CAF50),
              '+15%',
            ),
            _buildStatCard(
              'Utilisateurs actifs',
              '156',
              Icons.people,
              _primaryColor,
              '+8%',
            ),
            _buildStatCard(
              'Réservations/utilisateur',
              '8.2',
              Icons.event_note,
              const Color(0xFFFF9800),
              '+3%',
            ),
            _buildStatCard(
              'Taux de satisfaction',
              '4.6/5',
              Icons.star,
              const Color(0xFF9C27B0),
              '+0.2',
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserActivityChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activité des utilisateurs par heure',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 30,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 8, barRods: [BarChartRodData(toY: 5, color: _primaryColor)]),
                  BarChartGroupData(x: 10, barRods: [BarChartRodData(toY: 12, color: _primaryColor)]),
                  BarChartGroupData(x: 12, barRods: [BarChartRodData(toY: 18, color: _primaryColor)]),
                  BarChartGroupData(x: 14, barRods: [BarChartRodData(toY: 25, color: _primaryColor)]),
                  BarChartGroupData(x: 16, barRods: [BarChartRodData(toY: 22, color: _primaryColor)]),
                  BarChartGroupData(x: 18, barRods: [BarChartRodData(toY: 8, color: _primaryColor)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUsers() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Utilisateurs les plus actifs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildUserItem('Dr. Martin', 'Professeur', '24 réservations', Icons.person),
          _buildUserItem('Sophie Dubois', 'Étudiante', '18 réservations', Icons.person),
          _buildUserItem('Jean Dupont', 'Professeur', '15 réservations', Icons.person),
          _buildUserItem('Marie Claire', 'Personnel', '12 réservations', Icons.person),
          _buildUserItem('Ahmed Hassan', 'Étudiant', '10 réservations', Icons.person),
        ],
      ),
    );
  }

  Widget _buildUserItem(String name, String role, String reservations, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _primaryColor.withOpacity(0.1),
            child: Icon(icon, color: _primaryColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              reservations,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportCard(
            'Rapport d\'utilisation mensuel',
            'Analyse détaillée de l\'utilisation des salles ce mois',
            Icons.description,
            _primaryColor,
                () => _generateReport('monthly'),
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            'Rapport de satisfaction',
            'Feedback des utilisateurs et évaluations',
            Icons.sentiment_satisfied,
            const Color(0xFF4CAF50),
                () => _generateReport('satisfaction'),
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            'Rapport financier',
            'Coûts et revenus liés aux réservations',
            Icons.attach_money,
            const Color(0xFFFF9800),
                () => _generateReport('financial'),
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            'Rapport de maintenance',
            'État des équipements et besoins de maintenance',
            Icons.build,
            const Color(0xFF9C27B0),
                () => _generateReport('maintenance'),
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            'Rapport personnalisé',
            'Créer un rapport selon vos critères',
            Icons.tune,
            const Color(0xFF607D8B),
                () => _showCustomReportDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _exportStatistics() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exporter les statistiques'),
          content: const Text('Choisissez le format d\'exportation :'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _exportToPDF();
              },
              child: const Text('PDF'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _exportToCSV();
              },
              child: const Text('CSV'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _exportToExcel();
              },
              child: const Text('Excel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

// Fonction pour exporter en PDF
  void _exportToPDF() async {
    try {
      // Implémentation de l'export PDF
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exportation PDF en cours...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Logique d'exportation PDF ici
      // await generatePDFReport();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statistiques exportées en PDF avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'exportation PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Fonction pour exporter en CSV
  void _exportToCSV() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exportation CSV en cours...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Logique d'exportation CSV ici
      // await generateCSVReport();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statistiques exportées en CSV avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'exportation CSV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Fonction pour exporter en Excel
  void _exportToExcel() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exportation Excel en cours...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Logique d'exportation Excel ici
      // await generateExcelReport();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statistiques exportées en Excel avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'exportation Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // Ajoutez ces méthodes à la fin de votre classe _StatisticsScreenState
// juste avant la dernière accolade fermante }

  void _refreshStatistics() {
    setState(() {
      // Logique pour actualiser les statistiques
      // Vous pouvez ici recharger les données depuis votre API ou base de données
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statistiques actualisées !'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _generateReport(String reportType) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Génération du rapport ${_getReportTypeName(reportType)} en cours...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Simulation d'un délai de génération
      await Future.delayed(const Duration(seconds: 2));

      switch (reportType) {
        case 'monthly':
          await _generateMonthlyReport();
          break;
        case 'satisfaction':
          await _generateSatisfactionReport();
          break;
        case 'financial':
          await _generateFinancialReport();
          break;
        case 'maintenance':
          await _generateMaintenanceReport();
          break;
        default:
          throw Exception('Type de rapport non reconnu');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rapport ${_getReportTypeName(reportType)} généré avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la génération du rapport: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getReportTypeName(String reportType) {
    switch (reportType) {
      case 'monthly':
        return 'd\'utilisation mensuel';
      case 'satisfaction':
        return 'de satisfaction';
      case 'financial':
        return 'financier';
      case 'maintenance':
        return 'de maintenance';
      default:
        return 'personnalisé';
    }
  }

  Future<void> _generateMonthlyReport() async {
    // Logique pour générer le rapport mensuel
    // Ici vous pourriez :
    // - Collecter les données d'utilisation du mois
    // - Créer un document PDF ou Excel
    // - Sauvegarder le fichier
    print('Génération du rapport mensuel...');
  }

  Future<void> _generateSatisfactionReport() async {
    // Logique pour générer le rapport de satisfaction
    print('Génération du rapport de satisfaction...');
  }

  Future<void> _generateFinancialReport() async {
    // Logique pour générer le rapport financier
    print('Génération du rapport financier...');
  }

  Future<void> _generateMaintenanceReport() async {
    // Logique pour générer le rapport de maintenance
    print('Génération du rapport de maintenance...');
  }

  void _showCustomReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rapport personnalisé'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Configurez votre rapport personnalisé :'),
                const SizedBox(height: 16),

                // Sélection de la période
                const Text('Période :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _periods.map((String period) {
                    return DropdownMenuItem<String>(
                      value: period,
                      child: Text(period),
                    );
                  }).toList(),
                  onChanged: (String? value) {},
                  hint: const Text('Sélectionner une période'),
                ),
                const SizedBox(height: 16),

                // Types de données à inclure
                const Text('Données à inclure :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Utilisation des salles'),
                  value: true,
                  onChanged: (bool? value) {},
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Statistiques utilisateurs'),
                  value: true,
                  onChanged: (bool? value) {},
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Données financières'),
                  value: false,
                  onChanged: (bool? value) {},
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Informations de maintenance'),
                  value: false,
                  onChanged: (bool? value) {},
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _generateCustomReport();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Générer'),
            ),
          ],
        );
      },
    );
  }

  void _generateCustomReport() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Génération du rapport personnalisé en cours...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Simulation du temps de génération
      await Future.delayed(const Duration(seconds: 3));

      // Logique pour générer le rapport personnalisé
      // Ici vous pourriez utiliser les paramètres sélectionnés par l'utilisateur
      print('Génération du rapport personnalisé...');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport personnalisé généré avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la génération du rapport personnalisé: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}